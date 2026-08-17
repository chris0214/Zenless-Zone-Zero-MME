#!/usr/bin/env python3
"""Validate the frozen Goo groups used by the Phase 2 HLSL decoder."""
from __future__ import annotations

import argparse
import json
import math
from pathlib import Path


EXPECTED_HASHES = {
    "DecodeFaceLightTex": {
        "396b2d65a98849ee75359fdd0d4edd94d74aea682f57c8edb6130eaa521af905"
    },
    "DecodeLightTex": {
        "f66c1c94a991f8e3230c0bee812f2579ef92032108e22e5fd9513d755547b90b",
        "ccc39db896f9c01b4dd3945fd095f374ddbcb8a4b8a7ea3c35541fb6cdd98096",
    },
    "DecodeOtherTex": {
        "f5369c416eff9f5b1cf703550857c6dcd739d389950c3507ad7881e107548189"
    },
    "DecodeOtherTex2": {
        "54b01d2babf657b1820e14b0f58129bb608ac59032eb9ff8d2158e5c5e8ec878",
        "0a2bec4a4b70bf27da0cceafb2dbfa44e1b6c403c730fd778a58b79bd2aced00",
    },
    "Select": {
        "edd502ca7b57517be4a6c3343d827528f846ea263d4c5ac887f53a6a8b5399e4"
    },
    "SelectBool": {
        "1615bab0857c093f8af2c53fad4a31c80121738db97e0123fdc2d969635bf630"
    },
    "SelectColor": {
        "78f15e6142d9c6054154b0870b0c0d4e7eb5e09e6e915fa2618270e940c156d7"
    },
    "SelectInt": {
        "e458d9e239dbbe56d72b994d32a938168f9a1b79b271f1453f6ed2a725397374"
    },
}


def decode_material_id(value: float) -> int:
    return max(4 - math.floor(min(max(value, 0.0), 1.0) * 5.0), 0)


def validate_math() -> list[str]:
    errors: list[str] = []
    byte_cases = {
        0: 4,
        50: 4,
        51: 3,
        101: 3,
        102: 2,
        152: 2,
        153: 1,
        203: 1,
        204: 0,
        255: 0,
    }
    for packed, expected in byte_cases.items():
        actual = decode_material_id(packed / 255.0)
        if actual != expected:
            errors.append(
                f"MaterialId byte {packed}: expected {expected}, got {actual}"
            )

    diffuse_bias = (128.0 / 255.0 * 2.0 - 1.0) * 2.0
    if not -0.01 < diffuse_bias < 0.01:
        errors.append(f"Neutral DiffuseBias is not near zero: {diffuse_bias}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "snapshot",
        nargs="?",
        type=Path,
        default=Path(__file__).parents[1] / "docs" / "audit_snapshot.json",
    )
    args = parser.parse_args()
    snapshot = json.loads(args.snapshot.read_text(encoding="utf-8"))
    errors = validate_math()

    for project in snapshot["projects"]:
        groups = {group["name"]: group for group in project["node_groups"]}
        for name, accepted_hashes in EXPECTED_HASHES.items():
            group = groups.get(name)
            if group is None:
                errors.append(f"{project['blend']}: missing {name}")
                continue
            if group["sha256"] not in accepted_hashes:
                errors.append(
                    f"{project['blend']}: unexpected {name} hash "
                    f"{group['sha256']}"
                )

    if errors:
        for error in errors:
            print("ERROR:", error)
        return 1
    print("Goo Phase 2 decode contract: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
