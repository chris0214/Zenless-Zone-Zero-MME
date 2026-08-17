// ZZZ hair manual material. Static FX values are complete without the GUI.
// Required: replace N/M/A paths, head bone and subset for the current model.
#define ZZZ_HAIR_TEST_VIEW 5
#define ZZZ_HAIR_APPLY_CENTER_MASK 1
#define ZZZ_HAIR_CENTER_POWER 7.0
#define ZZZ_HAIR_COMPOSITE_GAIN_OVERRIDE 10.0
#define ZZZ_HAIR_TOON_THRESHOLD_DEFAULT 0.5
#define ZZZ_HAIR_TOON_SOFTNESS_DEFAULT 0.04
#define ZZZ_HAIR_HEAD_CENTER_UP_DEFAULT 1.0
#define ZZZ_HAIR_HEAD_CENTER_FORWARD_DEFAULT 0.8
#define ZZZ_HAIR_SPHERE_RADIUS_DEFAULT 1.0
#define ZZZ_HAIR_SPHERE_TRANSITION_DEFAULT 0.5
#define ZZZ_HAIR_SHAPE_SOFTNESS_DEFAULT 0.1
#define ZZZ_HAIR_SPECULAR_INTENSITY_DEFAULT 0.1
#define ZZZ_HAIR_SHADOW_OFFSET_X_DEFAULT 0.055
#define ZZZ_HAIR_SHADOW_OFFSET_Y_DEFAULT 0.090
#define ZZZ_HAIR_SHADOW_OPACITY_DEFAULT 0.32
#define ZZZ_HAIR_SHADOW_COLOR_DEFAULT float3(0.36, 0.25, 0.28)
#define ZZZ_HAIR_HIGHLIGHT_SHAPE_1 1.0
#define ZZZ_HAIR_HIGHLIGHT_SHAPE_2 0.0
#define ZZZ_HAIR_HIGHLIGHT_SHAPE_3 0.0
#define ZZZ_HAIR_HIGHLIGHT_SHAPE_4 0.0
#define ZZZ_HAIR_HIGHLIGHT_SHAPE_5 0.0
#define ZZZ_HAIR_ZZZSHADOW_RIM 1
#define ZZZ_HAIR_FULL_CONTROLLER 0
#define ZZZ_HAIR_FACE_SHADOW_PASS 1
#define ZZZ_NORMAL_RESOURCE "../textures/common/neutral_normal.png"
#define ZZZ_MATERIAL_RESOURCE "../textures/common/neutral_material.png"
#define ZZZ_ATTRIBUTE_RESOURCE "../textures/common/neutral_attributes.png"
#define ZZZ_HEAD_BONE "頭"
#define ZZZ_HAIR_SUBSET "0"

#include "../internal/zzz_hair_runtime.hlsl"
