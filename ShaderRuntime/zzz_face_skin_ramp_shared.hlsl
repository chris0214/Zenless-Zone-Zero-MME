#ifndef ZZZ_FACE_SKIN_RAMP_SHARED_INCLUDED
#define ZZZ_FACE_SKIN_RAMP_SHARED_INCLUDED

// Shared neutral defaults. A generated profile may override these macros,
// but face and skin must consume the same values so the neck seam cannot drift.
#ifndef ZZZ_FACE_SKIN_RAMP_STRENGTH_DEFAULT
#define ZZZ_FACE_SKIN_RAMP_STRENGTH_DEFAULT 0.65
#endif
#ifndef ZZZ_FACE_SKIN_RAMP_SMOOTHNESS_DEFAULT
#define ZZZ_FACE_SKIN_RAMP_SMOOTHNESS_DEFAULT 0.1
#endif
#ifndef ZZZ_FACE_SKIN_BASE_SHADOW_DEFAULT
#define ZZZ_FACE_SKIN_BASE_SHADOW_DEFAULT \
    float3(0.74314, 0.74314, 0.74314)
#endif
#ifndef ZZZ_FACE_SKIN_SHALLOW_COLOR_DEFAULT
#define ZZZ_FACE_SKIN_SHALLOW_COLOR_DEFAULT \
    float3(0.8308, 0.7605, 0.7605)
#endif
#ifndef ZZZ_FACE_SKIN_SHADOW_COLOR_DEFAULT
#define ZZZ_FACE_SKIN_SHADOW_COLOR_DEFAULT \
    float3(0.7454, 0.6038, 0.6038)
#endif

float3 ZzzFaceSkinApplyRamp(
    float3 shadedLinear,
    float lightMask,
    float strength,
    float smoothness,
    float3 shallowColor,
    float3 shadowColor)
{
    const float3 lumaWeights = float3(0.299, 0.587, 0.114);
    float shadowLuma = max(dot(shadowColor, lumaWeights), 0.001);
    float shallowLuma = max(dot(shallowColor, lumaWeights), 0.001);
    float3 shadowTint = shadowColor / shadowLuma;
    float3 shallowTint = shallowColor / shallowLuma;
    float width = max(smoothness, 0.001);
    float shallowWeight = smoothstep(
        0.5 - width * 0.5,
        0.5 + width * 0.5,
        saturate(lightMask));
    float3 rampTint = lerp(shadowTint, shallowTint, shallowWeight);
    return lerp(
        shadedLinear,
        shadedLinear * rampTint,
        saturate(strength));
}

#endif
