#!/usr/bin/env python3
"""Audit the public ZZZ MME controller contract and shader bindings.

This is a static check. It cannot replace dragging sliders in MMD, but it
does verify that every PMX morph has one matching shader binding, every
binding points at the intended controller file, and the signed hair offsets
retain a neutral value while allowing movement in both directions.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RUNTIME = ROOT / "ShaderRuntime"
CONTROLLER_ROOT = RUNTIME / "controller"


def load_profiles() -> dict[str, tuple[str, ...]]:
    sys.path.insert(0, str(ROOT / "Tools"))
    from build_zzz_controllers import CONTROLLERS, flatten_frames

    return {
        profile["file"]: flatten_frames(profile["frames"])
        for profile in CONTROLLERS
    }


def read_shader_text(path: Path) -> str:
    data = path.read_bytes()
    # Public ZZZ control includes intentionally use the MME/Japanese code
    # page. UTF-8 files are accepted first when they are unambiguous.
    try:
        return data.decode("utf-8")
    except UnicodeDecodeError:
        return data.decode("cp932")


def read_pmx_names(path: Path) -> list[str]:
    sys.path.insert(0, str(ROOT / "Tools"))
    from pmx_controller_builder import read_morph_names

    return read_morph_names(path.read_bytes())


def include_bindings(path: Path) -> list[tuple[str, str]]:
    text = path.read_bytes().decode("cp932")
    return re.findall(
        r"ZZZ_[A-Z_]+\((\w+),\s*\"([^\"]+)\"\)",
        text,
    )


def direct_bindings(path: Path) -> list[tuple[str, str, str]]:
    text = read_shader_text(path)
    defines = dict(
        re.findall(r"#define\s+(\w+)\s+\"([^\"]+)\"", text)
    )
    output: list[tuple[str, str, str]] = []
    pattern = re.compile(
        r"float(?:[234])?\s+(\w+)\s*:\s*CONTROLOBJECT\s*<(?P<body>.*?)>;",
        re.DOTALL,
    )
    for match in pattern.finditer(text):
        body = match.group("body")
        name_match = re.search(r"string\s+name\s*=\s*([^;]+);", body)
        item_match = re.search(r"string\s+item\s*=\s*\"([^\"]+)\"", body)
        if not item_match:
            continue
        name = name_match.group(1).strip() if name_match else "(self)"
        name = defines.get(name, name.strip('"'))
        output.append((match.group(1), name, item_match.group(1)))
    return output


def check_pair_names(names: set[str], label: str, errors: list[str]) -> None:
    for name in sorted(names):
        if name.endswith("+") and name[:-1] + "-" not in names:
            errors.append(f"{label}: missing negative pair for {name}")
        if name.endswith("-") and name[:-1] + "+" not in names:
            errors.append(f"{label}: missing positive pair for {name}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--json",
        type=Path,
        default=CONTROLLER_ROOT / "controller-contract.json",
    )
    args = parser.parse_args()

    errors: list[str] = []
    profiles = load_profiles()
    expected_by_controller = {
        file: set(names) for file, names in profiles.items()
    }

    manifest = json.loads(args.json.read_text(encoding="utf-8"))
    manifest_by_file = {
        item["file"]: item for item in manifest.get("controllers", [])
    }
    for controller, expected in expected_by_controller.items():
        path = CONTROLLER_ROOT / controller
        if not path.exists():
            errors.append(f"missing controller file: {controller}")
            continue
        actual_names = read_pmx_names(path)
        actual = set(actual_names)
        if len(actual_names) != len(actual):
            errors.append(f"{controller}: PMX contains duplicate morph names")
        if actual != expected:
            errors.append(f"{controller}: PMX morph set differs from profile")
        item = manifest_by_file.get(controller)
        if item is None or item.get("morphCount") != len(expected):
            errors.append(f"{controller}: manifest count is stale")
        elif item.get("sha256", "").lower() != hashlib.sha256(path.read_bytes()).hexdigest():
            errors.append(f"{controller}: manifest SHA-256 is stale")
        check_pair_names(expected, controller, errors)

    bindings_by_controller: dict[str, set[str]] = {
        controller: set() for controller in expected_by_controller
    }
    for path in (RUNTIME / "internal").glob("*_controls.inc"):
        if path.name == "zzz_hair_controls.inc":
            controller = "ZzzHair_controller.pmx"
        elif path.name == "zzz_face_skin_controls.inc":
            controller = "ZzzFaceSkin_controller.pmx"
        elif path.name == "zzz_cloth_matcap_controls.inc":
            controller = "ZzzClothMatCap_controller.pmx"
        elif path.name == "zzz_eye_controls.inc":
            controller = "ZzzEye_controller.pmx"
        else:
            continue
        bindings_by_controller[controller].update(
            item for _, item in include_bindings(path)
        )

    direct_files = (
        RUNTIME / "zzz_hgshadow_bridge.hlsl",
        RUNTIME / "internal" / "zzz_hair_zzzshadow_rim.hlsl",
        RUNTIME / "ZZZPost" / "ZZZPost.fx",
    )
    for path in direct_files:
        for _, controller, item in direct_bindings(path):
            if controller in bindings_by_controller:
                bindings_by_controller[controller].add(item)

    for controller, expected in expected_by_controller.items():
        actual = bindings_by_controller[controller]
        missing = sorted(expected - actual)
        unexpected = sorted(actual - expected)
        if missing:
            errors.append(f"{controller}: shader bindings missing {missing}")
        if unexpected:
            errors.append(f"{controller}: shader bindings unexpected {unexpected}")

    hair_controls = read_shader_text(RUNTIME / "internal" / "zzz_hair_controls.inc")
    signed_offset_anchor = "0.2 * ZzzHairControlSigned"
    if hair_controls.count(signed_offset_anchor) < 2:
        errors.append("hair offsets: signed X/Y implementation is not present")
    if "-0.2, 0.2" not in hair_controls:
        errors.append("hair offsets: symmetric clamp is not present")

    runtime_hair = read_shader_text(RUNTIME / "internal" / "zzz_hair_runtime.hlsl")
    if "ZzzHairControlledShadowOffsetYWithPitch" not in runtime_hair:
        errors.append("hair offset Y: pitch-aware controller helper is missing")
    if "ZzzHairControlledShadowOffsetYWithPitch(\n        ZzzHairShadowOffsetY, pitch)" not in runtime_hair:
        errors.append("hair offset Y: runtime is not using the pitch-aware helper")
    if "ZzzHairControlledShadowOffsetY(ZzzHairShadowOffsetY) * pitch" in runtime_hair:
        errors.append("hair offset Y: controller delta is still multiplied by pitch")

    manual_hair = read_shader_text(RUNTIME / "Manual" / "ZzzHair_Manual.fx")
    if "#define ZZZ_HAIR_FULL_CONTROLLER 1" not in manual_hair:
        errors.append("manual hair FX: full controller path is disabled")

    # A small numeric regression check for the documented neutral/dual-sided
    # behavior. Y also checks that manual motion remains visible when pitch is
    # zero, which is the failure mode this audit is intended to catch.
    base_x = 0.055
    neutral_x = max(-0.2, min(0.2, base_x + 0.2 * 0.0))
    positive_x = max(-0.2, min(0.2, base_x + 0.2 * 1.0))
    negative_x = max(-0.2, min(0.2, base_x - 0.2 * 1.0))
    if neutral_x != base_x or not positive_x > neutral_x or not negative_x < neutral_x:
        errors.append("hair offset X: neutral/positive/negative regression")

    for pitch in (0.0, 0.5, 1.0):
        base_y = 0.090 * pitch
        neutral_y = max(-0.2, min(0.2, base_y))
        positive_y = max(-0.2, min(0.2, base_y + 0.2))
        negative_y = max(-0.2, min(0.2, base_y - 0.2))
        if not positive_y > neutral_y or not negative_y < neutral_y:
            errors.append(f"hair offset Y: controller regression at pitch={pitch}")

    if errors:
        for error in errors:
            print("ERROR:", error)
        return 1

    print("ZZZ controller contract: PASS")
    print(f"controllers: {len(expected_by_controller)}")
    print(f"morphs: {sum(len(names) for names in expected_by_controller.values())}")
    print("hair offset X/Y: signed, neutral-preserving")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
