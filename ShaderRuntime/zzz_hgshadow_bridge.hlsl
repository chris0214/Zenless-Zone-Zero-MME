#ifndef ZZZ_HGSHADOW_BRIDGE_INCLUDED
#define ZZZ_HGSHADOW_BRIDGE_INCLUDED

// Compatibility bridge for early material tests. ZZZshadow now owns the
// HgShadow generator and publishes both shadow visibility and scene depth.
#define ZZZ_HGSHADOW_CONTROLLER "ZZZshadow.x"
#define ZZZ_SHADOW_SLIDER_CONTROLLER "ZzzShadow_controller.pmx"

float ZzzShadowControlStrengthP : CONTROLOBJECT <
    string name = ZZZ_SHADOW_SLIDER_CONTROLLER;
    string item = "“Š‰e‹­+";
>;
float ZzzShadowControlStrengthM : CONTROLOBJECT <
    string name = ZZZ_SHADOW_SLIDER_CONTROLLER;
    string item = "“Š‰e‹­-";
>;
float ZzzShadowControlHardnessP : CONTROLOBJECT <
    string name = ZZZ_SHADOW_SLIDER_CONTROLLER;
    string item = "“Š‰ed+";
>;
float ZzzShadowControlHardnessM : CONTROLOBJECT <
    string name = ZZZ_SHADOW_SLIDER_CONTROLLER;
    string item = "“Š‰ed-";
>;
float ZzzShadowControlDisable : CONTROLOBJECT <
    string name = ZZZ_SHADOW_SLIDER_CONTROLLER;
    string item = "“Š‰e•Â";
>;

bool ZZZ_EyeHgShadowValid : CONTROLOBJECT <
    string name = ZZZ_HGSHADOW_CONTROLLER;
>;
float ZZZ_EyeHgShadowDensityUp : CONTROLOBJECT <
    string name = "(self)";
    string item = "ShadowDen+";
>;
float ZZZ_EyeHgShadowDensityDown : CONTROLOBJECT <
    string name = "(self)";
    string item = "ShadowDen-";
>;
float ZZZ_EyeHgShadowRotation : CONTROLOBJECT <
    string name = ZZZ_HGSHADOW_CONTROLLER;
    string item = "Rx";
>;

shared texture2D ZZZshadow_ViewportMap2 : RENDERCOLORTARGET;
sampler2D ZZZ_EyeHgShadowSampler = sampler_state {
    texture = <ZZZshadow_ViewportMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

float2 ZZZ_EyeHgShadowViewportSize : VIEWPORTPIXELSIZE;

float ZZZ_EyeHgShadowDensity()
{
    return max(
        (degrees(ZZZ_EyeHgShadowRotation)
            + 5.0 * ZZZ_EyeHgShadowDensityUp + 1.0)
            * (1.0 - ZZZ_EyeHgShadowDensityDown),
        0.0);
}

float ZzzShadowControlledAmount(float shadowAmount)
{
    float strength = lerp(1.0, 2.0, saturate(ZzzShadowControlStrengthP))
        * (1.0 - saturate(ZzzShadowControlStrengthM));
    float hardness = lerp(1.0, 4.0, saturate(ZzzShadowControlHardnessP))
        * lerp(1.0, 0.25, saturate(ZzzShadowControlHardnessM));
    float shaped = pow(saturate(shadowAmount), 1.0 / max(hardness, 0.001));
    return saturate(shaped * strength)
        * (1.0 - saturate(ZzzShadowControlDisable));
}

float ZZZ_EyeSampleHgShadow(float4 screenPosition, bool useSelfShadow)
{
    if (!useSelfShadow || !ZZZ_EyeHgShadowValid
        || abs(screenPosition.w) < 1e-6) {
        return 1.0;
    }
    float2 ndc = screenPosition.xy / screenPosition.w;
    float2 uv = float2(
        (1.0 + ndc.x) * 0.5,
        (1.0 - ndc.y) * 0.5);
    uv += 0.5 / max(ZZZ_EyeHgShadowViewportSize, 1.0);
    float shadowAmount = ZzzShadowControlledAmount(
        tex2D(ZZZ_EyeHgShadowSampler, uv).r);
    float visibility = 1.0 - shadowAmount;
    return 1.0 - (1.0 - visibility)
        * min(ZZZ_EyeHgShadowDensity(), 1.0);
}

float ZZZ_EyeSampleHgShadowOffset(
    float4 screenPosition,
    bool useSelfShadow,
    float2 uvOffset)
{
    if (!useSelfShadow || !ZZZ_EyeHgShadowValid
        || abs(screenPosition.w) < 1e-6) {
        return 1.0;
    }
    float2 ndc = screenPosition.xy / screenPosition.w;
    float2 uv = float2(
        (1.0 + ndc.x) * 0.5,
        (1.0 - ndc.y) * 0.5);
    uv += 0.5 / max(ZZZ_EyeHgShadowViewportSize, 1.0) + uvOffset;
    float shadowAmount = ZzzShadowControlledAmount(
        tex2D(ZZZ_EyeHgShadowSampler, uv).r);
    float visibility = 1.0 - shadowAmount;
    return 1.0 - (1.0 - visibility)
        * min(ZZZ_EyeHgShadowDensity(), 1.0);
}

// Compatibility aliases for the early prototype object entries. Both naming
// families now consume the same ZZZshadow render target and controller.
float ZZZ_HgShadowDensity()
{
    return ZZZ_EyeHgShadowDensity();
}

float ZZZ_SampleHgShadow(float4 screenPosition, bool useSelfShadow)
{
    return ZZZ_EyeSampleHgShadow(screenPosition, useSelfShadow);
}

float ZZZ_SampleHgShadowOffset(
    float4 screenPosition,
    bool useSelfShadow,
    float2 uvOffset)
{
    return ZZZ_EyeSampleHgShadowOffset(
        screenPosition,
        useSelfShadow,
        uvOffset);
}

#endif
