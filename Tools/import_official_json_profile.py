#!/usr/bin/env python3
"""Convert an official ZZZ Unity Material JSON into an MME MatCap profile.

The generated profile is deliberately static. Standard MME cannot parse JSON
at runtime, so the future GUI/importer owns JSON parsing and emits auditable
HLSL constants plus texture bindings for the effect compiler.
"""

from __future__ import annotations

import argparse
import json
import re
import struct
import zlib
from pathlib import Path
from typing import Any


PATH_ID_TEXTURES = {
    -2401745554373494259: "Eff_Matcap_025",
    -9139840526936460063: "Eff_MatCap_007",
}

ROLE_PREFIXES = {
    "Miyabi": "Unagi_Body_Map{map}",
    "Burnice": "Burnice_Body_Map{map}",
    "Jane": "JaneDoe_Body_Map{map}",
}

CHANNEL_SUFFIXES = {
    "_MainTex": "D",
    "_LightTex": "N",
    "_OtherDataTex": "M",
    "_OtherDataTex2": "A",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Import official ZZZ Material JSON into an MME profile."
    )
    parser.add_argument("--material-json", required=True, type=Path)
    parser.add_argument("--role", required=True, choices=sorted(ROLE_PREFIXES))
    parser.add_argument("--profile-name", required=True)
    parser.add_argument("--output-dir", required=True, type=Path)
    parser.add_argument(
        "--texture-dir",
        type=Path,
        help="Directory containing MME-ready PNG textures.",
    )
    parser.add_argument(
        "--package-path",
        type=Path,
        help="MME package root. Enables Debug FX, EMM, and test instructions.",
    )
    parser.add_argument(
        "--model-path",
        type=Path,
        help="PMX used by the generated Debug EMM.",
    )
    parser.add_argument(
        "--subsets",
        default="",
        help="Comma-separated PMX material indices for the Debug EMM.",
    )
    parser.add_argument(
        "--extra-effect",
        action="append",
        default=[],
        metavar="SUBSET=FX_PATH",
        help="Additional subset/FX mapping for the FullContext EMM.",
    )
    return parser.parse_args()


def load_material(path: Path) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    saved = data.get("m_SavedProperties")
    if not isinstance(saved, dict):
        raise ValueError(f"Not an official Unity Material JSON: {path}")
    return {
        "textures": saved.get("m_TexEnvs", {}),
        "floats": saved.get("m_Floats", {}),
        "colors": saved.get("m_Colors", {}),
    }


def slot_key(base: str, slot: int) -> str:
    return base if slot == 1 else f"{base}{slot}"


def finite_float(value: Any, default: float) -> float:
    try:
        result = float(value)
    except (TypeError, ValueError):
        return default
    if result != result or result in (float("inf"), float("-inf")):
        return default
    return result


def color3(value: Any, default: tuple[float, float, float]) -> list[float]:
    if not isinstance(value, dict):
        return list(default)
    return [
        finite_float(value.get("r"), default[0]),
        finite_float(value.get("g"), default[1]),
        finite_float(value.get("b"), default[2]),
    ]


def texture_binding(material: dict[str, Any], key: str) -> dict[str, Any]:
    env = material["textures"].get(key, {})
    texture = env.get("m_Texture", {}) if isinstance(env, dict) else {}
    return {
        "property": key,
        "name": str(texture.get("Name") or ""),
        "isNull": bool(texture.get("IsNull", True)),
        "fileId": int(texture.get("m_FileID") or 0),
        "pathId": int(texture.get("m_PathID") or 0),
    }


def material_map_index(material_name: str) -> int:
    match = re.search(r"Body[_ ]([12])", material_name, re.IGNORECASE)
    return int(match.group(1)) if match else 1


def infer_channel_name(role: str, material_name: str, key: str) -> str:
    suffix = CHANNEL_SUFFIXES.get(key)
    if not suffix:
        return ""
    prefix = ROLE_PREFIXES[role].format(map=material_map_index(material_name))
    return f"{prefix}_{suffix}"


def texture_index(texture_dir: Path | None) -> dict[str, Path]:
    if not texture_dir or not texture_dir.is_dir():
        return {}
    result: dict[str, Path] = {}
    for path in texture_dir.iterdir():
        if path.is_file():
            result[path.stem.casefold()] = path
            result[path.name.casefold()] = path
    return result


def resolve_texture(
    binding: dict[str, Any],
    role: str,
    material_name: str,
    index: dict[str, Path],
    warnings: list[str],
) -> dict[str, Any]:
    name = binding["name"]
    source = "official-name"
    if not name and not binding["isNull"]:
        inferred = PATH_ID_TEXTURES.get(binding["pathId"], "")
        if inferred:
            name = inferred
            source = "pathid-inference"
        else:
            inferred = infer_channel_name(role, material_name, binding["property"])
            if inferred:
                name = inferred
                source = "role-channel-inference"

    resolved: Path | None = None
    if name:
        resolved = index.get(name.casefold())
        if not resolved:
            resolved = index.get(f"{name}.png".casefold())
        if not resolved and name.casefold().startswith("eff_matcap_"):
            suffix = name.rsplit("_", 1)[-1]
            resolved = index.get(f"zzz_matcap_{suffix}.png".casefold())

    if not binding["isNull"] and not name:
        warnings.append(
            f"{binding['property']}: IsNull=false but texture name is empty "
            f"and PathID {binding['pathId']} is unknown."
        )
    elif name and index and not resolved:
        warnings.append(
            f"{binding['property']}: texture '{name}' was not found in the "
            "MME texture directory."
        )

    return {
        **binding,
        "name": name,
        "resolutionSource": source if name else "none",
        "resolvedFile": resolved.name if resolved else "",
        "resolvedPath": str(resolved) if resolved else "",
    }


def close_enough(left: float, right: float, epsilon: float = 1e-5) -> bool:
    return abs(left - right) <= epsilon


def build_profile(
    material: dict[str, Any],
    material_path: Path,
    role: str,
    profile_name: str,
    texture_dir: Path | None,
) -> dict[str, Any]:
    warnings: list[str] = []
    packed_conflicts: list[dict[str, Any]] = []
    name = material_path.stem
    index = texture_index(texture_dir)

    channels: dict[str, Any] = {}
    for key in CHANNEL_SUFFIXES:
        channels[key] = resolve_texture(
            texture_binding(material, key), role, name, index, warnings
        )

    slots: list[dict[str, Any]] = []
    floats = material["floats"]
    colors = material["colors"]
    for slot in range(1, 6):
        texture = resolve_texture(
            texture_binding(material, slot_key("_MatCapTex", slot)),
            role,
            name,
            index,
            warnings,
        )
        color_burst = finite_float(
            floats.get(slot_key("_MatCapColorBurst", slot)), 1.0
        )
        alpha_burst = finite_float(
            floats.get(slot_key("_MatCapAlphaBurst", slot)), 1.0
        )
        blend_mode = finite_float(
            floats.get(slot_key("_MatCapBlendMode", slot)), 0.0
        )
        tex_id = finite_float(
            floats.get(slot_key("_MatCapTexID", slot)), 100.0
        )
        refract = finite_float(
            floats.get(slot_key("_MatCapRefract", slot)), 0.0
        )
        u_speed = finite_float(
            floats.get(slot_key("_MatCapUSpeed", slot)), 0.0
        )
        v_speed = finite_float(
            floats.get(slot_key("_MatCapVSpeed", slot)), 0.0
        )
        tint = color3(
            colors.get(slot_key("_MatCapColorTint", slot)),
            (1.0, 1.0, 1.0),
        )

        packed = colors.get(slot_key("_MatCapParams", slot))
        if isinstance(packed, dict):
            packed_color = finite_float(packed.get("r"), color_burst)
            packed_alpha = finite_float(packed.get("g"), alpha_burst)
            if not (
                close_enough(packed_color, color_burst)
                and close_enough(packed_alpha, alpha_burst)
            ):
                conflict = {
                    "slot": slot,
                    "packed": [packed_color, packed_alpha],
                    "expanded": [color_burst, alpha_burst],
                    "rule": "expanded-scalars-win",
                }
                packed_conflicts.append(conflict)
                warnings.append(
                    f"Slot {slot}: packed _MatCapParams conflicts with expanded "
                    "ColorBurst/AlphaBurst; expanded scalars were kept."
                )

        enabled = bool(
            not texture["isNull"]
            and texture["name"]
            and (not index or texture["resolvedFile"])
        )
        slots.append(
            {
                "slot": slot,
                "enabled": enabled,
                "texture": texture,
                "tint": tint,
                "colorBurst": color_burst,
                "alphaBurst": alpha_burst,
                "blendMode": blend_mode,
                "texId": tex_id,
                "refract": refract,
                "uSpeed": u_speed,
                "vSpeed": v_speed,
            }
        )

    return {
        "schema": "zzz-mme-official-json-profile/v1",
        "profileName": profile_name,
        "role": role,
        "materialName": name,
        "sourceJson": str(material_path.resolve()),
        "textureDirectory": str(texture_dir.resolve()) if texture_dir else "",
        "authorityRules": {
            "expandedScalars": "authoritative",
            "packedVectors": "validation-only",
            "textureBinding": "MapSet + MaterialID + FiveSlotProfile",
            "runtimeJsonParsing": False,
        },
        "channels": channels,
        "matcapEnabled": finite_float(floats.get("_MatCap"), 0.0) > 0.5,
        "useMatcapMask": finite_float(floats.get("_UseMatCapMask"), 1.0),
        "slots": slots,
        "packedConflicts": packed_conflicts,
        "warnings": warnings,
    }


def hlsl_float(value: float) -> str:
    text = f"{value:.9g}"
    if "." not in text and "e" not in text.lower():
        text += ".0"
    return text


def hlsl_vec3(value: list[float]) -> str:
    return "float3(" + ", ".join(hlsl_float(v) for v in value) + ")"


def resource_for(binding: dict[str, Any], neutral: str) -> str:
    file_name = binding.get("resolvedFile") or ""
    return f"textures/{file_name}" if file_name else neutral


def render_inc(profile: dict[str, Any], neutral_resource: str) -> str:
    guard = re.sub(r"[^A-Z0-9]", "_", profile["profileName"].upper())
    lines = [
        "// Generated from official ZZZ Material JSON. Do not hand-edit.",
        f"// Source: {Path(profile['sourceJson']).name}",
        f"#ifndef ZZZ_JSON_PROFILE_{guard}_INCLUDED",
        f"#define ZZZ_JSON_PROFILE_{guard}_INCLUDED",
        "",
    ]
    channel_macros = {
        "_MainTex": "ZZZ_JSON_DIFFUSE_RESOURCE",
        "_LightTex": "ZZZ_JSON_NORMAL_RESOURCE",
        "_OtherDataTex": "ZZZ_JSON_MATERIAL_RESOURCE",
        "_OtherDataTex2": "ZZZ_JSON_ATTRIBUTE_RESOURCE",
    }
    for key, macro in channel_macros.items():
        lines.append(
            f'#define {macro} "{resource_for(profile["channels"][key], neutral_resource)}"'
        )
    lines.append("")

    for slot in profile["slots"]:
        number = slot["slot"]
        resource = resource_for(slot["texture"], neutral_resource)
        lines.append(f'#define ZZZ_JSON_MATCAP_SLOT_{number}_RESOURCE "{resource}"')
    lines.extend(
        [
            "",
            "static const float ZZZ_JsonMatcapMasterEnabled = "
            f"{1.0 if profile['matcapEnabled'] else 0.0:.1f};",
            "static const float ZZZ_JsonMatcapUseMask = "
            f"{hlsl_float(profile['useMatcapMask'])};",
            "",
        ]
    )

    for slot in profile["slots"]:
        number = slot["slot"]
        lines.extend(
            [
                f"static const float ZZZ_JsonMatcapEnabled{number} = "
                f"{1.0 if slot['enabled'] else 0.0:.1f};",
                f"static const float3 ZZZ_JsonMatcapTint{number} = "
                f"{hlsl_vec3(slot['tint'])};",
                f"static const float ZZZ_JsonMatcapColorBurst{number} = "
                f"{hlsl_float(slot['colorBurst'])};",
                f"static const float ZZZ_JsonMatcapAlphaBurst{number} = "
                f"{hlsl_float(slot['alphaBurst'])};",
                f"static const float ZZZ_JsonMatcapBlendMode{number} = "
                f"{hlsl_float(slot['blendMode'])};",
                f"static const float ZZZ_JsonMatcapTexId{number} = "
                f"{hlsl_float(slot['texId'])};",
                f"static const float ZZZ_JsonMatcapRefract{number} = "
                f"{hlsl_float(slot['refract'])};",
                f"static const float ZZZ_JsonMatcapUSpeed{number} = "
                f"{hlsl_float(slot['uSpeed'])};",
                f"static const float ZZZ_JsonMatcapVSpeed{number} = "
                f"{hlsl_float(slot['vSpeed'])};",
                "",
            ]
        )
    lines.extend(["#endif", ""])
    return "\n".join(lines)


def render_debug_fx(profile_name: str) -> str:
    template = r'''// Minimal D3DX9-safe JSON MatCap diagnostic.
#include "generated_json_profiles\__PROFILE__.inc"

float4x4 ZzzJsonWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 ZzzJsonWorld : WORLD;
float4x4 ZzzJsonView : VIEW;

float ZzzJsonMatcapView <
    string UIName = "表示";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = 0.0;

float ZzzJsonMatcapStrength <
    string UIName = "MatCap強度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 10.0;
> = 5.0;

float ZzzJsonMatcapForceMask <
    string UIName = "遮蔽強制";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 0.0;

texture2D ZzzJsonMaterialTexture < string ResourceName = ZZZ_JSON_MATERIAL_RESOURCE; >;
texture2D ZzzJsonAttributeTexture < string ResourceName = ZZZ_JSON_ATTRIBUTE_RESOURCE; >;
texture2D ZzzJsonMatcapTexture1 < string ResourceName = ZZZ_JSON_MATCAP_SLOT_1_RESOURCE; >;
texture2D ZzzJsonMatcapTexture2 < string ResourceName = ZZZ_JSON_MATCAP_SLOT_2_RESOURCE; >;
texture2D ZzzJsonMatcapTexture3 < string ResourceName = ZZZ_JSON_MATCAP_SLOT_3_RESOURCE; >;
texture2D ZzzJsonMatcapTexture4 < string ResourceName = ZZZ_JSON_MATCAP_SLOT_4_RESOURCE; >;
texture2D ZzzJsonMatcapTexture5 < string ResourceName = ZZZ_JSON_MATCAP_SLOT_5_RESOURCE; >;

#define ZZZ_JSON_SAMPLER(name, textureName, addressMode) \
sampler2D name = sampler_state { \
    texture = <textureName>; \
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR; \
    AddressU = addressMode; AddressV = addressMode; \
};
ZZZ_JSON_SAMPLER(ZzzJsonMaterialSampler, ZzzJsonMaterialTexture, WRAP)
ZZZ_JSON_SAMPLER(ZzzJsonAttributeSampler, ZzzJsonAttributeTexture, WRAP)
ZZZ_JSON_SAMPLER(ZzzJsonMatcapSampler1, ZzzJsonMatcapTexture1, CLAMP)
ZZZ_JSON_SAMPLER(ZzzJsonMatcapSampler2, ZzzJsonMatcapTexture2, CLAMP)
ZZZ_JSON_SAMPLER(ZzzJsonMatcapSampler3, ZzzJsonMatcapTexture3, CLAMP)
ZZZ_JSON_SAMPLER(ZzzJsonMatcapSampler4, ZzzJsonMatcapTexture4, CLAMP)
ZZZ_JSON_SAMPLER(ZzzJsonMatcapSampler5, ZzzJsonMatcapTexture5, CLAMP)

struct ZzzJsonAttributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord0 : TEXCOORD0;
};

struct ZzzJsonVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
};

ZzzJsonVaryings ZzzJsonVS(ZzzJsonAttributes input)
{
    ZzzJsonVaryings output = (ZzzJsonVaryings)0;
    output.positionCS = mul(input.positionOS, ZzzJsonWorldViewProjection);
    output.uv = input.texcoord0;
    output.normalWS = normalize(mul(input.normalOS, (float3x3)ZzzJsonWorld));
    return output;
}

float4 ZzzJsonPS(ZzzJsonVaryings input) : COLOR0
{
    float4 materialData = tex2D(ZzzJsonMaterialSampler, input.uv);
    float4 attributeData = tex2D(ZzzJsonAttributeSampler, input.uv);
    float materialId = max(4.0 - floor(saturate(materialData.r) * 5.0), 0.0);

    float w1 = 1.0 - step(0.5, materialId);
    float w2 = step(0.5, materialId) * (1.0 - step(1.5, materialId));
    float w3 = step(1.5, materialId) * (1.0 - step(2.5, materialId));
    float w4 = step(2.5, materialId) * (1.0 - step(3.5, materialId));
    float w5 = step(3.5, materialId);

    float3 normalVS = normalize(mul(input.normalWS, (float3x3)ZzzJsonView));
    float2 matcapUv = saturate(normalVS.xy * 0.5 + 0.5);
    float4 matcap =
        tex2D(ZzzJsonMatcapSampler1, matcapUv) * w1
        + tex2D(ZzzJsonMatcapSampler2, matcapUv) * w2
        + tex2D(ZzzJsonMatcapSampler3, matcapUv) * w3
        + tex2D(ZzzJsonMatcapSampler4, matcapUv) * w4
        + tex2D(ZzzJsonMatcapSampler5, matcapUv) * w5;

    float enabled =
        ZZZ_JsonMatcapEnabled1 * w1 + ZZZ_JsonMatcapEnabled2 * w2
        + ZZZ_JsonMatcapEnabled3 * w3 + ZZZ_JsonMatcapEnabled4 * w4
        + ZZZ_JsonMatcapEnabled5 * w5;
    float3 tint =
        ZZZ_JsonMatcapTint1 * w1 + ZZZ_JsonMatcapTint2 * w2
        + ZZZ_JsonMatcapTint3 * w3 + ZZZ_JsonMatcapTint4 * w4
        + ZZZ_JsonMatcapTint5 * w5;
    float colorBurst =
        ZZZ_JsonMatcapColorBurst1 * w1 + ZZZ_JsonMatcapColorBurst2 * w2
        + ZZZ_JsonMatcapColorBurst3 * w3 + ZZZ_JsonMatcapColorBurst4 * w4
        + ZZZ_JsonMatcapColorBurst5 * w5;
    float alphaBurst =
        ZZZ_JsonMatcapAlphaBurst1 * w1 + ZZZ_JsonMatcapAlphaBurst2 * w2
        + ZZZ_JsonMatcapAlphaBurst3 * w3 + ZZZ_JsonMatcapAlphaBurst4 * w4
        + ZZZ_JsonMatcapAlphaBurst5 * w5;

    float mask = lerp(
        saturate(attributeData.b),
        1.0,
        saturate(ZzzJsonMatcapForceMask));
    float alpha = saturate(matcap.a * mask * alphaBurst) * enabled;
    float3 matcapColor = pow(saturate(matcap.rgb), 2.2)
        * tint * colorBurst * alpha * max(ZzzJsonMatcapStrength, 0.0);
    matcapColor = pow(max(matcapColor, 0.0), 1.0 / 2.2);

    float viewMask = step(0.5, ZzzJsonMatcapView)
        * (1.0 - step(1.5, ZzzJsonMatcapView));
    float viewId = step(1.5, ZzzJsonMatcapView);
    float viewMatcap = 1.0 - saturate(viewMask + viewId);
    float3 outputColor =
        matcapColor * viewMatcap
        + mask.xxx * viewMask
        + (materialId * 0.25).xxx * viewId;
    return float4(saturate(outputColor), 1.0);
}

vertexshader ZzzJsonCompiledVS = compile vs_3_0 ZzzJsonVS();
pixelshader ZzzJsonCompiledPS = compile ps_3_0 ZzzJsonPS();

#define ZZZ_JSON_TECHNIQUE(name, passName) \
technique name < \
    string MMDPass = passName; \
    string Script = "RenderColorTarget0=;Pass=DrawObject;"; \
> { \
    pass DrawObject { \
        ZEnable = true; ZWriteEnable = true; CullMode = NONE; \
        AlphaBlendEnable = false; AlphaTestEnable = false; \
        VertexShader = <ZzzJsonCompiledVS>; \
        PixelShader = <ZzzJsonCompiledPS>; \
    } \
}

ZZZ_JSON_TECHNIQUE(ZzzJsonMatcapDebug, "object")
ZZZ_JSON_TECHNIQUE(ZzzJsonMatcapDebugSs, "object_ss")
'''
    return template.replace("__PROFILE__", profile_name)


def png_chunk(kind: bytes, payload: bytes) -> bytes:
    return (
        struct.pack(">I", len(payload))
        + kind
        + payload
        + struct.pack(">I", zlib.crc32(kind + payload) & 0xFFFFFFFF)
    )


def neutral_png() -> bytes:
    signature = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", 1, 1, 8, 6, 0, 0, 0)
    scanline = b"\x00\x00\x00\x00\x00"
    return (
        signature
        + png_chunk(b"IHDR", ihdr)
        + png_chunk(b"IDAT", zlib.compress(scanline))
        + png_chunk(b"IEND", b"")
    )


def write_debug_assets(
    profile: dict[str, Any],
    package_path: Path,
    model_path: Path,
    subsets: list[int],
    extra_effects: dict[int, Path],
) -> list[Path]:
    profile_name = profile["profileName"]
    fx_path = package_path / f"ZZZ_JSON_MatCap_Debug_{profile_name}.fx"
    fx_path.write_bytes(render_debug_fx(profile_name).encode("cp936"))

    emm_path = package_path / f"ZZZ_JSON_MatCap_Debug_{profile_name}.emm"
    lines = [
        "[Info]",
        "Version = 3",
        "",
        "[Object]",
        f"Pmd2 = {model_path.resolve()}",
        "",
        "[Effect]",
        "Default = none",
        "Pmd2 = none",
    ]
    lines.extend(f"Pmd2[{subset}] = {fx_path.resolve()}" for subset in subsets)
    lines.extend(
        f"Pmd2[{subset}] = {extra_fx_path.resolve()}"
        for subset, extra_fx_path in sorted(extra_effects.items())
    )
    lines.append("")
    emm_path.write_bytes("\r\n".join(lines).encode("cp936"))

    isolate_path = package_path / (
        f"ZZZ_JSON_MatCap_Isolate_{profile['role']}.emm"
    )
    isolate_path.write_bytes("\r\n".join(lines).encode("cp936"))

    generated_emm_paths = [emm_path, isolate_path]
    base_emm_path = package_path / f"ZZZ_Test_{profile['role']}.emm"
    if base_emm_path.is_file():
        base_text = base_emm_path.read_bytes().decode("cp936")
        for subset in subsets:
            pattern = rf"(?m)^Pmd2\[{subset}\]\s*=.*$"
            replacement = f"Pmd2[{subset}] = {fx_path.resolve()}"
            base_text, replacement_count = re.subn(
                pattern, lambda _: replacement, base_text, count=1
            )
            if replacement_count != 1:
                raise ValueError(
                    f"Subset {subset} was not found in {base_emm_path}"
                )
        for subset, extra_fx_path in sorted(extra_effects.items()):
            pattern = rf"(?m)^Pmd2\[{subset}\]\s*=.*$"
            replacement = f"Pmd2[{subset}] = {extra_fx_path.resolve()}"
            base_text, replacement_count = re.subn(
                pattern, lambda _: replacement, base_text, count=1
            )
            if replacement_count != 1:
                raise ValueError(
                    f"Subset {subset} was not found in {base_emm_path}"
                )
        full_context_path = package_path / (
            f"ZZZ_JSON_MatCap_Debug_{profile_name}_FullContext.emm"
        )
        full_context_path.write_bytes(base_text.encode("cp936"))
        generated_emm_paths.append(full_context_path)

    readme_path = package_path / f"JSON_MatCap_测试说明_{profile_name}.md"
    slot_lines = []
    for slot in profile["slots"]:
        texture_name = slot["texture"]["resolvedFile"] or "(empty)"
        slot_lines.append(
            f"- Slot {slot['slot']}: enabled={slot['enabled']}, "
            f"texture={texture_name}, blend={slot['blendMode']}, "
            f"colorBurst={slot['colorBurst']}, alphaBurst={slot['alphaBurst']}"
        )
    warning_lines = profile["warnings"] or ["(none)"]
    readme = "\n".join(
        [
            f"# JSON MatCap 测试：{profile_name}",
            "",
            f"加载 `{emm_path.name}`。该 EMM 只覆盖材质 "
            + ", ".join(str(value) for value in subsets)
            + "，不会加载阴影、眼透或后处理。",
            "",
            "FX 参数 `表示`：",
            "",
            "- 0：只显示 JSON MatCap，其他部分为黑色。",
            "- 1：显示 A.B MatCap 遮罩。",
            "- 2：显示 M.R 解码后的材质 ID。",
            "",
            "若 `表示=0` 全黑，把 `遮蔽強制` 调到 1：若此时出现 MatCap，"
            "说明纹理和 JSON 参数已正确读取，问题仅在该角色 A.B 遮罩。",
            "",
            "## 五槽导入结果",
            "",
            *slot_lines,
            "",
            "## 导入警告",
            "",
            *(f"- {warning}" for warning in warning_lines),
            "",
        ]
    )
    readme_path.write_text(readme, encoding="utf-8")
    return [fx_path, *generated_emm_paths, readme_path]


def main() -> int:
    args = parse_args()
    material_path = args.material_json.resolve()
    output_dir = args.output_dir.resolve()
    texture_dir = args.texture_dir.resolve() if args.texture_dir else None
    package_path = args.package_path.resolve() if args.package_path else None
    model_path = args.model_path.resolve() if args.model_path else None

    material = load_material(material_path)
    profile = build_profile(
        material,
        material_path,
        args.role,
        args.profile_name,
        texture_dir,
    )

    output_dir.mkdir(parents=True, exist_ok=True)
    neutral_path = output_dir / "ZZZ_JSON_NeutralMatCap.png"
    if not neutral_path.exists():
        neutral_path.write_bytes(neutral_png())

    if package_path and output_dir.parent == package_path:
        neutral_resource = f"{output_dir.name}/ZZZ_JSON_NeutralMatCap.png"
    else:
        neutral_resource = "generated_json_profiles/ZZZ_JSON_NeutralMatCap.png"

    inc_path = output_dir / f"{args.profile_name}.inc"
    json_path = output_dir / f"{args.profile_name}.json"
    inc_path.write_text(render_inc(profile, neutral_resource), encoding="ascii")
    json_path.write_text(
        json.dumps(profile, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    generated = [inc_path, json_path, neutral_path]
    if package_path:
        if not model_path:
            raise ValueError("--model-path is required when --package-path is used")
        subsets = [
            int(value.strip())
            for value in args.subsets.split(",")
            if value.strip()
        ]
        if not subsets:
            raise ValueError("--subsets is required when --package-path is used")
        extra_effects: dict[int, Path] = {}
        for mapping in args.extra_effect:
            subset_text, separator, effect_text = mapping.partition("=")
            if not separator or not subset_text.strip() or not effect_text.strip():
                raise ValueError(
                    "--extra-effect must use the form SUBSET=FX_PATH"
                )
            effect_path = Path(effect_text.strip())
            if not effect_path.is_absolute():
                effect_path = package_path / effect_path
            if not effect_path.is_file():
                raise ValueError(f"Extra effect was not found: {effect_path}")
            extra_effects[int(subset_text.strip())] = effect_path
        generated.extend(
            write_debug_assets(
                profile, package_path, model_path, subsets, extra_effects
            )
        )

    print(json.dumps({
        "profile": args.profile_name,
        "generated": [str(path) for path in generated],
        "enabledSlots": [
            slot["slot"] for slot in profile["slots"] if slot["enabled"]
        ],
        "warningCount": len(profile["warnings"]),
        "warnings": profile["warnings"],
    }, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
