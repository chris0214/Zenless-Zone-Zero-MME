// ZZZ cloth manual material. Static FX values are complete without the GUI.
// Required: replace N/M/A paths and subset. MatCap settings live in Profiles.
#include "Profiles/ZzzCloth_5Slot_Manual.inc"

#define ZZZ_CLOTH_USE_JSON_MATCAP 1
#define ZZZ_CLOTH_NORMAL_RESOURCE "../textures/common/neutral_normal.png"
#define ZZZ_CLOTH_MATERIAL_RESOURCE "../textures/common/neutral_material.png"
#define ZZZ_CLOTH_AUX_RESOURCE "../textures/common/neutral_attributes.png"
#define ZZZ_CLOTH_MATCAP_STRENGTH_DEFAULT 1.0
#define ZZZ_CLOTH_BRIGHTNESS_DEFAULT 1.0
#define ZZZ_CLOTH_NORMAL_STRENGTH_DEFAULT 1.0
#define ZZZ_CLOTH_SHADOW_NORMAL_DEFAULT 0.45
#define ZZZ_CLOTH_SHADOW_BIAS_DEFAULT 0.0
#define ZZZ_CLOTH_SHADOW_SOFTNESS_DEFAULT 0.05
#define ZZZ_CLOTH_RAMP_STRENGTH_DEFAULT 1.0
#define ZZZ_CLOTH_SPECULAR_STRENGTH_DEFAULT 1.0
#define ZZZ_CLOTH_SPECULAR_MASK_DEFAULT 1.0
#define ZZZ_CLOTH_SPECULAR_RANGE_DEFAULT 1.0
#define ZZZ_CLOTH_SPECULAR_GLOSS_DEFAULT 1.0
#define ZZZ_CLOTH_SPECULAR_COLOR_DEFAULT float3(1.0, 1.0, 1.0)
#define ZZZ_CLOTH_HGSHADOW_STRENGTH_DEFAULT 1.0
#define ZZZ_CLOTH_SHADOW_BRIGHTNESS_DEFAULT 0.5
#define ZZZ_CLOTH_SUBSET "0"

#include "../internal/zzz_cloth_runtime.hlsl"

ZZZ_CLOTH_TECHNIQUE(ZzzClothManualNoTexture, "object", ZZZ_CLOTH_SUBSET, false, false)
ZZZ_CLOTH_TECHNIQUE(ZzzClothManualTexture, "object", ZZZ_CLOTH_SUBSET, true, false)
ZZZ_CLOTH_TECHNIQUE(ZzzClothManualShadowNoTexture, "object_ss", ZZZ_CLOTH_SUBSET, false, true)
ZZZ_CLOTH_TECHNIQUE(ZzzClothManualShadowTexture, "object_ss", ZZZ_CLOTH_SUBSET, true, true)
