#ifndef ZZZ_HAIR_CONTROLS_INCLUDED
#define ZZZ_HAIR_CONTROLS_INCLUDED

#define ZZZ_HAIR_CONTROLLER_NAME "ZzzHair_controller.pmx"
#define ZZZ_HAIR_CONTROL(symbol, morphName) \
    float symbol : CONTROLOBJECT < \
        string name = ZZZ_HAIR_CONTROLLER_NAME; \
        string item = morphName; \
    >

ZZZ_HAIR_CONTROL(ZzzHairBaseRP, "ŠîFÔ+");
ZZZ_HAIR_CONTROL(ZzzHairBaseRM, "ŠîFÔ-");
ZZZ_HAIR_CONTROL(ZzzHairBaseGP, "ŠîF—Î+");
ZZZ_HAIR_CONTROL(ZzzHairBaseGM, "ŠîF—Î-");
ZZZ_HAIR_CONTROL(ZzzHairBaseBP, "ŠîFÂ+");
ZZZ_HAIR_CONTROL(ZzzHairBaseBM, "ŠîFÂ-");
ZZZ_HAIR_CONTROL(ZzzHairBaseSaturationP, "ŠîFÊ“x+");
ZZZ_HAIR_CONTROL(ZzzHairBaseSaturationM, "ŠîFÊ“x-");
ZZZ_HAIR_CONTROL(ZzzHairBaseBrightnessP, "ŠîF–¾“x+");
ZZZ_HAIR_CONTROL(ZzzHairBaseBrightnessM, "ŠîF–¾“x-");
ZZZ_HAIR_CONTROL(ZzzHairBaseExposureP, "ŠîF˜Io+");
ZZZ_HAIR_CONTROL(ZzzHairBaseExposureM, "ŠîF˜Io-");

ZZZ_HAIR_CONTROL(ZzzHairShadowStrengthP, "‰A‰e‹­+");
ZZZ_HAIR_CONTROL(ZzzHairShadowStrengthM, "‰A‰e‹­-");
ZZZ_HAIR_CONTROL(ZzzHairShadowThresholdP, "‰A‰e‹«ŠE+");
ZZZ_HAIR_CONTROL(ZzzHairShadowThresholdM, "‰A‰e‹«ŠE-");
ZZZ_HAIR_CONTROL(ZzzHairShadowSoftnessP, "‰A‰e_+");
ZZZ_HAIR_CONTROL(ZzzHairShadowSoftnessM, "‰A‰e_-");

ZZZ_HAIR_CONTROL(ZzzHairHighlightStrengthP, "‚Œõ‹­+");
ZZZ_HAIR_CONTROL(ZzzHairHighlightStrengthM, "‚Œõ‹­-");
ZZZ_HAIR_CONTROL(ZzzHairHighlightUp, "‚ŒõãˆÚ");
ZZZ_HAIR_CONTROL(ZzzHairHighlightDown, "‚Œõ‰ºˆÚ");
ZZZ_HAIR_CONTROL(ZzzHairHighlightWidthP, "‚Œõ•+");
ZZZ_HAIR_CONTROL(ZzzHairHighlightWidthM, "‚Œõ•-");
ZZZ_HAIR_CONTROL(ZzzHairHighlightHardnessP, "‚Œõd+");
ZZZ_HAIR_CONTROL(ZzzHairHighlightHardnessM, "‚Œõd-");
ZZZ_HAIR_CONTROL(ZzzHairHighlightRP, "‚ŒõÔ+");
ZZZ_HAIR_CONTROL(ZzzHairHighlightRM, "‚ŒõÔ-");
ZZZ_HAIR_CONTROL(ZzzHairHighlightGP, "‚Œõ—Î+");
ZZZ_HAIR_CONTROL(ZzzHairHighlightGM, "‚Œõ—Î-");
ZZZ_HAIR_CONTROL(ZzzHairHighlightBP, "‚ŒõÂ+");
ZZZ_HAIR_CONTROL(ZzzHairHighlightBM, "‚ŒõÂ-");

ZZZ_HAIR_CONTROL(ZzzHairFaceShadowOffsetXP, "‘O”¯‰e‰¡+");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowOffsetXM, "‘O”¯‰e‰¡-");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowOffsetYP, "‘O”¯‰ec+");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowOffsetYM, "‘O”¯‰ec-");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowLightP, "‘O”¯‰eóŒõ+");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowLightM, "‘O”¯‰eóŒõ-");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowDepthP, "‘O”¯‰e[“x+");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowDepthM, "‘O”¯‰e[“x-");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowOpacityP, "‘O”¯‰e”Z“x+");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowOpacityM, "‘O”¯‰e”Z“x-");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowRP, "‘O”¯‰eÔ+");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowRM, "‘O”¯‰eÔ-");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowGP, "‘O”¯‰e—Î+");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowGM, "‘O”¯‰e—Î-");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowBP, "‘O”¯‰eÂ+");
ZZZ_HAIR_CONTROL(ZzzHairFaceShadowBM, "‘O”¯‰eÂ-");
#undef ZZZ_HAIR_CONTROL

float ZzzHairControlSigned(float positive, float negative)
{
    return saturate(positive) - saturate(negative);
}

float ZzzHairControlMultiplier(float positive, float negative)
{
    return lerp(1.0, 5.0, saturate(positive))
        * (1.0 - saturate(negative));
}

float ZzzHairControlScale(float positive, float negative)
{
    return lerp(1.0, 5.0, saturate(positive))
        * lerp(1.0, 0.2, saturate(negative));
}

float3 ZzzHairControlRgb(float3 positive, float3 negative)
{
    return max(
        lerp(1.0.xxx, 5.0.xxx, saturate(positive))
            * (1.0.xxx - saturate(negative)),
        0.0.xxx);
}

float3 ZzzHairAdjustBaseColor(float3 color)
{
    float3 rgbScale = ZzzHairControlRgb(
        float3(ZzzHairBaseRP, ZzzHairBaseGP, ZzzHairBaseBP),
        float3(ZzzHairBaseRM, ZzzHairBaseGM, ZzzHairBaseBM));
    float saturation = ZzzHairControlMultiplier(
        ZzzHairBaseSaturationP, ZzzHairBaseSaturationM);
    float brightness = ZzzHairControlMultiplier(
        ZzzHairBaseBrightnessP, ZzzHairBaseBrightnessM);
    float exposure = exp2(ZzzHairControlSigned(
        ZzzHairBaseExposureP, ZzzHairBaseExposureM));
    float luminance = dot(color, float3(0.2126, 0.7152, 0.0722));
    return max(
        lerp(luminance.xxx, color, saturation)
            * rgbScale * brightness * exposure,
        0.0.xxx);
}

float ZzzHairControlledToonThreshold()
{
    return saturate(ZzzToonThreshold + 0.25 * ZzzHairControlSigned(
        ZzzHairShadowThresholdP, ZzzHairShadowThresholdM));
}

float ZzzHairControlledToonSoftness()
{
    return max(
        0.001,
        ZzzToonSoftness * ZzzHairControlScale(
            ZzzHairShadowSoftnessP, ZzzHairShadowSoftnessM));
}

float ZzzHairControlledShadowStrength()
{
    return ZzzHairControlMultiplier(
        ZzzHairShadowStrengthP, ZzzHairShadowStrengthM);
}

float ZzzHairControlledCenterPower()
{
    return max(
        0.2,
        ZZZ_HAIR_CENTER_POWER
            / ZzzHairControlScale(
                ZzzHairHighlightWidthP, ZzzHairHighlightWidthM));
}

float ZzzHairControlledShapeSoftness()
{
    return max(
        0.001,
        ZzzShapeSoftness
            / ZzzHairControlScale(
                ZzzHairHighlightHardnessP, ZzzHairHighlightHardnessM));
}

float ZzzHairControlledHighlightOffset()
{
    return 1.25 * (saturate(ZzzHairHighlightUp)
        - saturate(ZzzHairHighlightDown));
}

float ZzzHairControlledHighlightStrength()
{
    return ZzzHairControlMultiplier(
        ZzzHairHighlightStrengthP, ZzzHairHighlightStrengthM);
}

float3 ZzzHairControlledHighlightColor()
{
    return ZzzHairControlRgb(
        float3(
            ZzzHairHighlightRP,
            ZzzHairHighlightGP,
            ZzzHairHighlightBP),
        float3(
            ZzzHairHighlightRM,
            ZzzHairHighlightGM,
            ZzzHairHighlightBM));
}

float ZzzHairControlledShadowOffsetX(float baseValue)
{
    // The controller is a signed displacement around the profile default.
    // Keeping the range symmetric lets the negative morph move the shadow
    // past the neutral position instead of stopping at zero.
    return clamp(baseValue + 0.2 * ZzzHairControlSigned(
        ZzzHairFaceShadowOffsetXP, ZzzHairFaceShadowOffsetXM), -0.2, 0.2);
}

float ZzzHairControlledShadowOffsetY(float baseValue)
{
    // Match the signed height-offset behavior used by the reference hair
    // controller: +/- moves the face-shadow projection in opposite
    // directions, with the neutral value preserved at zero controller input.
    return clamp(baseValue + 0.2 * ZzzHairControlSigned(
        ZzzHairFaceShadowOffsetYP, ZzzHairFaceShadowOffsetYM), -0.2, 0.2);
}

float ZzzHairControlledShadowLightInfluence(float baseValue)
{
    return clamp(baseValue + ZzzHairControlSigned(
        ZzzHairFaceShadowLightP, ZzzHairFaceShadowLightM), 0.0, 2.0);
}

float ZzzHairControlledShadowDepthBias(float baseValue)
{
    return clamp(baseValue + 0.2 * ZzzHairControlSigned(
        ZzzHairFaceShadowDepthP, ZzzHairFaceShadowDepthM), -0.2, 0.2);
}

float ZzzHairControlledShadowOpacity(float baseValue)
{
    float control = ZzzHairControlSigned(
        ZzzHairFaceShadowOpacityP, ZzzHairFaceShadowOpacityM);
    return saturate(baseValue
        + max(control, 0.0) * (1.0 - baseValue)
        - max(-control, 0.0) * baseValue);
}

float3 ZzzHairControlledShadowColor(float3 baseValue)
{
    float3 positive = saturate(float3(
        ZzzHairFaceShadowRP, ZzzHairFaceShadowGP, ZzzHairFaceShadowBP));
    float3 negative = saturate(float3(
        ZzzHairFaceShadowRM, ZzzHairFaceShadowGM, ZzzHairFaceShadowBM));
    return saturate(baseValue + positive * (1.0.xxx - baseValue)
        - negative * baseValue);
}
#endif
