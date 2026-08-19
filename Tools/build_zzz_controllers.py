"""Build the public ZZZ MME PMX controller set.

The PMX files contain neutral bone morphs. MME reads only their slider values
through CONTROLOBJECT, so a zeroed controller never changes the model itself.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
from pathlib import Path

from pmx_controller_builder import (
    PmxError,
    build_morph,
    locate_layout,
    pack_index,
    pack_text,
    read_morph_names,
)


CONTROLLERS = (
    {
        "file": "ZzzShadow_controller.pmx",
        "description": "ZZZ shadow sampling controller.",
        "frames": (
            ("投影調整", ("投影強+", "投影強-", "投影硬+", "投影硬-", "投影閉")),
        ),
    },
    {
        "file": "ZzzHair_controller.pmx",
        "description": "ZZZ hair material controller.",
        "frames": (
            ("髪基色", (
                "基色赤+", "基色赤-", "基色緑+", "基色緑-", "基色青+", "基色青-",
                "基色彩度+", "基色彩度-", "基色明度+", "基色明度-", "基色露出+", "基色露出-",
            )),
            ("髪陰影", (
                "陰影強+", "陰影強-", "陰影境界+", "陰影境界-", "陰影柔+", "陰影柔-",
            )),
            ("髪高光", (
                "高光強+", "高光強-", "高光上移", "高光下移", "高光幅+", "高光幅-",
                "高光硬+", "高光硬-", "高光赤+", "高光赤-", "高光緑+", "高光緑-",
                "高光青+", "高光青-",
            )),
            ("前髪投影", (
                "前髪影横+", "前髪影横-", "前髪影縦+", "前髪影縦-", "前髪影受光+", "前髪影受光-",
                "前髪影深度+", "前髪影深度-", "前髪影濃度+", "前髪影濃度-", "前髪影赤+", "前髪影赤-",
                "前髪影緑+", "前髪影緑-", "前髪影青+", "前髪影青-",
            )),
            ("髪辺光", (
                "辺光強+", "辺光強-", "辺光幅+", "辺光幅-", "辺光硬+", "辺光硬-",
                "辺光赤+", "辺光赤-", "辺光緑+", "辺光緑-", "辺光青+", "辺光青-",
            )),
        ),
    },
    {
        "file": "ZzzFaceSkin_controller.pmx",
        "description": "ZZZ face and skin controller with shared ramp controls.",
        "frames": (
            ("面部明暗", (
                "面明度+", "面明度-", "SDF位置+", "SDF位置-", "SDF柔+", "SDF柔-",
                "面AO+", "面AO-", "鼻影強+", "鼻影強-", "鼻影長+", "鼻影長-",
            )),
            ("面部高光", (
                "面高光強+", "面高光強-", "面高光幅+", "面高光幅-", "面高光硬+", "面高光硬-",
            )),
            ("共通肌色", (
                "肌色強+", "肌色強-", "肌色過渡+", "肌色過渡-",
            )),
            ("皮膚高光", (
                "皮高光強+", "皮高光強-", "皮高光範囲+", "皮高光範囲-",
                "皮高光光滑+", "皮高光光滑-",
            )),
            ("皮膚辺光", (
                "皮辺光強+", "皮辺光強-", "皮辺光幅+", "皮辺光幅-", "皮辺光硬+", "皮辺光硬-",
            )),
        ),
    },
    {
        "file": "ZzzClothMatCap_controller.pmx",
        "description": "ZZZ cloth, direct highlight, rim and five-slot MatCap controller.",
        "frames": (
            ("衣装明暗", (
                "衣装明度+", "衣装明度-", "衣装陰影位置+", "衣装陰影位置-",
                "衣装陰影柔+", "衣装陰影柔-", "衣装陰影強+", "衣装陰影強-",
            )),
            ("衣装高光", (
                "衣装高光強+", "衣装高光強-", "衣装高光遮蔽+", "衣装高光遮蔽-",
                "衣装高光範囲+", "衣装高光範囲-", "衣装高光光滑+", "衣装高光光滑-",
                "衣装高光赤+", "衣装高光赤-", "衣装高光緑+", "衣装高光緑-",
                "衣装高光青+", "衣装高光青-",
            )),
            ("衣装辺光", (
                "衣装辺光強+", "衣装辺光強-", "衣装辺光幅+", "衣装辺光幅-",
                "衣装辺光硬+", "衣装辺光硬-",
            )),
            ("球面全体", ("球面全体強+", "球面全体強-")),
            *((f"球面槽{slot}", (
                f"球面槽{slot}強+", f"球面槽{slot}強-", f"球面槽{slot}明+", f"球面槽{slot}明-",
                f"球面槽{slot}遮蔽+", f"球面槽{slot}遮蔽-", f"球面槽{slot}閉",
            )) for slot in range(1, 6)),
        ),
    },
    {
        "file": "ZzzEye_controller.pmx",
        "description": "ZZZ eye layers and EyeThrough controller.",
        "frames": (
            ("眼球基色", ("眼球明度+", "眼球明度-", "眼球受光+", "眼球受光-")),
            ("瞳内光", (
                "瞳内光強+", "瞳内光強-", "瞳内光透明+", "瞳内光透明-",
                "瞳内光遮蔽+", "瞳内光遮蔽-",
            )),
            ("眼高光", ("眼高光強+", "眼高光強-", "眼高光透明+", "眼高光透明-")),
            ("眼透", (
                "眼透強+", "眼透強-", "眼透明度+", "眼透明度-",
                "眼透境界+", "眼透境界-", "眼透柔+", "眼透柔-",
            )),
        ),
    },
    {
        "file": "ZzzPost_controller.pmx",
        "description": "ZZZ GT tonemap and bloom controller.",
        "frames": (
            ("GT色調", (
                "GT色調", "GT線形起点+", "GT線形起点-", "GT対比+", "GT対比-",
                "GT暗部+", "GT暗部-", "GT最大輝度+", "GT最大輝度-", "GT線形長+", "GT線形長-",
            )),
            ("輝光調整", (
                "露出+", "露出-", "輝光強+", "輝光強-", "輝光境界+", "輝光境界-",
                "輝光柔軟+", "輝光柔軟-", "輝光範囲+", "輝光範囲-",
            )),
        ),
    },
)


def flatten_frames(frames: tuple[tuple[str, tuple[str, ...]], ...]) -> tuple[str, ...]:
    return tuple(morph for _, morphs in frames for morph in morphs)


def build_display_frame(layout, name: str, indices: range) -> bytes:
    elements = b"".join(
        b"\x01" + pack_index(index, layout.morph_index_size)
        for index in indices
    )
    return b"".join((
        pack_text(name, layout.encoding),
        pack_text(name, layout.encoding),
        struct.pack("<Bi", 1, len(indices)),
        elements,
    ))


def build_display_frames(layout, frames) -> bytes:
    root_element = b"\x00" + pack_index(0, layout.bone_index_size)
    root = b"".join((
        pack_text("Root", layout.encoding),
        pack_text("Root", layout.encoding),
        struct.pack("<Bi", 1, 1),
        root_element,
    ))
    output = [root]
    start = 0
    for name, morphs in frames:
        output.append(build_display_frame(layout, name, range(start, start + len(morphs))))
        start += len(morphs)
    return struct.pack("<i", len(output)) + b"".join(output)


def build_controller(source: Path, output: Path, profile: dict) -> dict:
    morph_names = flatten_frames(profile["frames"])
    if len(morph_names) != len(set(morph_names)):
        raise PmxError(f"duplicate morph name in {profile['file']}")

    source_data = source.read_bytes()
    layout = locate_layout(source_data)
    metadata = b"".join((
        pack_text(output.stem, layout.encoding),
        pack_text(output.stem, layout.encoding),
        pack_text(profile["description"], layout.encoding),
        pack_text(profile["description"], layout.encoding),
    ))
    morphs = b"".join(build_morph(name, layout) for name in morph_names)
    output_data = b"".join((
        source_data[:layout.fixed_header_end],
        metadata,
        source_data[layout.metadata_end:layout.morph_offset],
        struct.pack("<i", len(morph_names)),
        morphs,
        build_display_frames(layout, profile["frames"]),
        source_data[layout.rigid_body_offset:],
    ))
    if read_morph_names(output_data) != morph_names:
        raise PmxError(f"generated morph contract mismatch: {profile['file']}")

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(output_data)
    return {
        "file": profile["file"],
        "description": profile["description"],
        "morphCount": len(morph_names),
        "sha256": hashlib.sha256(output_data).hexdigest().upper(),
        "frames": [
            {"name": name, "morphs": list(morphs)}
            for name, morphs in profile["frames"]
        ],
    }


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    controller_root = root / "ShaderRuntime" / "controller"
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--source",
        type=Path,
        default=controller_root / "ZzzHair_controller.pmx",
    )
    parser.add_argument("--output", type=Path, default=controller_root)
    args = parser.parse_args()

    source = args.source.resolve()
    output_root = args.output.resolve()
    manifest = {
        "schemaVersion": 1,
        "format": "ZZZ.MME.ControllerContract",
        "neutralValue": 0.0,
        "controllers": [],
    }
    for profile in CONTROLLERS:
        result = build_controller(source, output_root / profile["file"], profile)
        manifest["controllers"].append(result)
        print(f"{result['file']}: {result['morphCount']} morphs, {result['sha256']}")

    manifest_path = output_root / "controller-contract.json"
    manifest_path.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"manifest: {manifest_path}")


if __name__ == "__main__":
    main()
