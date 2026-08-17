"""Apply the controller hooks while preserving the runtime code pages."""

from __future__ import annotations

from pathlib import Path


RUNTIME = Path(__file__).resolve().parents[1]
WORKSPACE = RUNTIME.parent
GUI_TEMPLATES = (
    WORKSPACE
    / "Arknights-Endfield-MME-Shader"
    / "Source"
    / "EndfieldMaterialStudio"
    / "EndfieldMaterialStudio.Core"
    / "Templates"
)


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if new in text:
        return text
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"{label}: expected one anchor, found {count}: {old!r}")
    return text.replace(old, new, 1)


def patch_file(path: Path, encoding: str, replacements: tuple[tuple[str, str], ...]) -> None:
    text = path.read_text(encoding=encoding).replace("\r\n", "\n")
    original = text
    for old, new in replacements:
        text = replace_once(
            text,
            old.replace("\r\n", "\n"),
            new.replace("\r\n", "\n"),
            str(path),
        )
    if text != original:
        path.write_text(text, encoding=encoding, newline="\n")
        print(f"patched: {path}")
    else:
        print(f"current: {path}")


FACE_REPLACEMENTS = (
    (
        '#include "zzz_face_skin_ramp_shared.hlsl"',
        '#include "zzz_face_skin_ramp_shared.hlsl"\r\n'
        '#include "internal/zzz_face_skin_controls.inc"',
    ),
    (
        '    float threshold = saturate(\r\n'
        '        1.0 - (front * 0.5 + 0.5) + ZzzFaceThresholdOffset);\r\n'
        '    float brightMask = smoothstep(\r\n'
        '        threshold - ZzzFaceSoftness,\r\n'
        '        threshold + ZzzFaceSoftness,',
        '    float threshold = saturate(\r\n'
        '        1.0 - (front * 0.5 + 0.5)\r\n'
        '            + ZzzFaceControlledThresholdOffset(ZzzFaceThresholdOffset));\r\n'
        '    float faceSoftness = ZzzFaceControlledSoftness(ZzzFaceSoftness);\r\n'
        '    float brightMask = smoothstep(\r\n'
        '        threshold - faceSoftness,\r\n'
        '        threshold + faceSoftness,',
    ),
    (
        '        max(ZzzFaceAoStrength, 0.0));',
        '        max(ZzzFaceControlledAo(ZzzFaceAoStrength), 0.0));',
    ),
    (
        '    float albedoSmoothness = max(ZzzFaceAlbedoSmoothness, 0.001);',
        '    float albedoSmoothness = max(\r\n'
        '        ZzzFaceSkinControlledRampSmoothness(ZzzFaceAlbedoSmoothness),\r\n'
        '        0.001);',
    ),
    (
        '        saturate(ZzzFaceRampStrength));',
        '        saturate(ZzzFaceSkinControlledRampStrength(ZzzFaceRampStrength)));',
    ),
    (
        '            * max(ZzzFaceNoseLength, 0.0));',
        '            * max(ZzzFaceControlledNoseLength(ZzzFaceNoseLength), 0.0));',
    ),
    (
        '        noseMask * noseGate * max(ZzzFaceNoseStrength, 0.0));',
        '        noseMask * noseGate\r\n'
        '            * max(ZzzFaceControlledNoseStrength(ZzzFaceNoseStrength), 0.0));',
    ),
    (
        '        max(ZzzFaceHighlightHardness, 0.1) * 8.0);',
        '        max(ZzzFaceControlledHighlightHardness(\r\n'
        '            ZzzFaceHighlightHardness), 0.1) * 8.0);',
    ),
    (
        '        0.5 + max(ZzzFaceHighlightWidth, 0.01),',
        '        0.5 + max(ZzzFaceControlledHighlightWidth(\r\n'
        '            ZzzFaceHighlightWidth), 0.01),',
    ),
    (
        '            * max(ZzzFaceHighlightStrength, 0.0));',
        '            * max(ZzzFaceControlledHighlightStrength(\r\n'
        '                ZzzFaceHighlightStrength), 0.0));',
    ),
    (
        '    shadedLinear *= max(ZzzFaceBrightness, 0.0);',
        '    shadedLinear *= max(ZzzFaceControlledBrightness(ZzzFaceBrightness), 0.0);',
    ),
    (
        "Goo's ShadeAlbedo",
        "The reference ShadeAlbedo",
    ),
)


SKIN_REPLACEMENTS = (
    (
        '#include "zzz_face_skin_ramp_shared.hlsl"',
        '#include "zzz_face_skin_ramp_shared.hlsl"\r\n'
        '#include "internal/zzz_face_skin_controls.inc"',
    ),
    (
        '    float glossiness = saturate(ZzzSkinSpecularGlossiness);',
        '    float glossiness = saturate(\r\n'
        '        ZzzSkinControlledGlossiness(ZzzSkinSpecularGlossiness));',
    ),
    (
        '    float specularRange = max(ZzzSkinSpecularRange, 0.0);',
        '    float specularRange = max(\r\n'
        '        ZzzSkinControlledSpecularRange(ZzzSkinSpecularRange), 0.0);',
    ),
    (
        '        * max(ZzzSkinSpecularStrength, 0.0);',
        '        * max(ZzzSkinControlledSpecularStrength(\r\n'
        '            ZzzSkinSpecularStrength), 0.0);',
    ),
    (
        '        ZZZ_FACE_SKIN_RAMP_STRENGTH_DEFAULT,\r\n'
        '        ZZZ_FACE_SKIN_RAMP_SMOOTHNESS_DEFAULT,',
        '        ZzzFaceSkinControlledRampStrength(\r\n'
        '            ZZZ_FACE_SKIN_RAMP_STRENGTH_DEFAULT),\r\n'
        '        ZzzFaceSkinControlledRampSmoothness(\r\n'
        '            ZZZ_FACE_SKIN_RAMP_SMOOTHNESS_DEFAULT),',
    ),
    (
        '    float width = max(ZzzSkinRimWidth, 0.05);',
        '    float width = max(ZzzSkinControlledRimWidth(ZzzSkinRimWidth), 0.05);',
    ),
    (
        '        max(ZzzSkinRimContrast, 0.001));',
        '        max(ZzzSkinControlledRimContrast(ZzzSkinRimContrast), 0.001));',
    ),
    (
        '        * max(ZzzSkinRimStrength, 0.0)',
        '        * max(ZzzSkinControlledRimStrength(ZzzSkinRimStrength), 0.0)',
    ),
)


EYE_BASE_REPLACEMENTS = (
    (
        '#define ZZZ_EYE_DIFFUSE_RESOURCE "textures/Unagi_Face_D.png"',
        '#define ZZZ_EYE_DIFFUSE_RESOURCE "textures/Unagi_Face_D.png"\r\n\r\n'
        '#include "internal/zzz_eye_controls.inc"',
    ),
    (
        '    float strength = saturate(ZzzEyeSoftLightStrength);',
        '    float strength = saturate(\r\n'
        '        ZzzEyeControlledSoftLight(ZzzEyeSoftLightStrength));',
    ),
    (
        '    colorLinear *= max(ZzzEyeBrightness, 0.0);',
        '    colorLinear *= max(ZzzEyeControlledBrightness(ZzzEyeBrightness), 0.0);',
    ),
)


EYE_OVERLAY_REPLACEMENTS = (
    (
        '#define ZZZ_EYE_OVERLAY_RESOURCE "textures/Unagi_Face_D.png"',
        '#define ZZZ_EYE_OVERLAY_RESOURCE "textures/Unagi_Face_D.png"\r\n\r\n'
        '#include "internal/zzz_eye_controls.inc"',
    ),
    (
        '    float coverage = saturate(ZzzEyeInnerOpacity) * materialVisibility;',
        '    float coverage = saturate(\r\n'
        '        ZzzEyeControlledInnerOpacity(ZzzEyeInnerOpacity))\r\n'
        '        * materialVisibility;',
    ),
    (
        '            texel.a * max(ZzzEyeInnerMaskGain, 0.0));',
        '            texel.a * max(\r\n'
        '                ZzzEyeControlledInnerMask(ZzzEyeInnerMaskGain), 0.0));',
    ),
    (
        '        * max(ZzzEyeInnerBrightness, 0.0);',
        '        * max(ZzzEyeControlledInnerBrightness(\r\n'
        '            ZzzEyeInnerBrightness), 0.0);',
    ),
    (
        '        ZzzEyeHighlightOpacity,\r\n'
        '        ZzzEyeHighlightBrightness,',
        '        ZzzEyeControlledHighlightOpacity(ZzzEyeHighlightOpacity),\r\n'
        '        ZzzEyeControlledHighlightBrightness(ZzzEyeHighlightBrightness),',
    ),
)


def patch_eye_through(path: Path) -> None:
    prefix = "../" if path.parent.name == "ZZZEyeThrough" else ""
    patch_file(
        path,
        "utf-8",
        (
            (
                f'#include "{prefix}internal/zzz_eye_through_contract.hlsl"',
                f'#include "{prefix}internal/zzz_eye_controls.inc"\n'
                f'#include "{prefix}internal/zzz_eye_through_contract.hlsl"',
            ),
            (
                '    feature.rgb = saturate(feature.rgb * max(ZZZ_EyeEyeThroughColorGain, 0.0));',
                '    feature.rgb = saturate(feature.rgb * max(\n'
                '        ZzzEyeControlledThroughGain(ZZZ_EyeEyeThroughColorGain), 0.0));',
            ),
            (
                '        saturate(ZZZ_EyeHairMaskCutoff),\n'
                '        saturate(ZZZ_EyeHairMaskCutoff\n'
                '            + max(ZZZ_EyeHairMaskFeather, 0.001)),',
                '        saturate(ZzzEyeControlledThroughCutoff(\n'
                '            ZZZ_EyeHairMaskCutoff)),\n'
                '        saturate(ZzzEyeControlledThroughCutoff(\n'
                '            ZZZ_EyeHairMaskCutoff)\n'
                '            + max(ZzzEyeControlledThroughFeather(\n'
                '                ZZZ_EyeHairMaskFeather), 0.001)),',
            ),
            (
                '    feature.a *= ZZZ_EyeEyeThroughAlpha(1.0);',
                '    feature.a *= saturate(\n'
                '        ZzzEyeControlledThroughStrength(ZZZ_EyeEyeThroughStrength));',
            ),
        ),
    )


def main() -> None:
    pairs = (
        (GUI_TEMPLATES / "ZzzFace_Template.fx", RUNTIME / "templates" / "ZzzFace.fx", FACE_REPLACEMENTS),
        (GUI_TEMPLATES / "ZzzSkin_Template.fx", RUNTIME / "templates" / "ZzzSkin.fx", SKIN_REPLACEMENTS),
        (GUI_TEMPLATES / "ZzzEye01_Base_Template.fx", RUNTIME / "templates" / "ZzzEye01_Base.fx", EYE_BASE_REPLACEMENTS),
        (GUI_TEMPLATES / "ZzzEye02_Overlays_Template.fx", RUNTIME / "templates" / "ZzzEye02_Overlays.fx", EYE_OVERLAY_REPLACEMENTS),
    )
    for source, runtime_copy, replacements in pairs:
        patch_file(source, "cp936", replacements)
        patch_file(runtime_copy, "cp936", replacements)

    patch_eye_through(RUNTIME / "ZZZEyeThrough" / "ZZZEyeThrough.fx")


if __name__ == "__main__":
    main()
