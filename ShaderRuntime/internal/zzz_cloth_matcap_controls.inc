#ifndef ZZZ_CLOTH_MATCAP_CONTROLS_INCLUDED
#define ZZZ_CLOTH_MATCAP_CONTROLS_INCLUDED

#define ZZZ_CLOTH_CONTROLLER_NAME "ZzzClothMatCap_controller.pmx"
#define ZZZ_CLOTH_CONTROL(symbol, morphName) \
    float symbol : CONTROLOBJECT < \
        string name = ZZZ_CLOTH_CONTROLLER_NAME; \
        string item = morphName; \
    >

ZZZ_CLOTH_CONTROL(ZzzClothCtrlBrightnessP, "ˆß‘•–¾“x+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlBrightnessM, "ˆß‘•–¾“x-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlShadowPositionP, "ˆß‘•‰A‰eˆÊ’u+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlShadowPositionM, "ˆß‘•‰A‰eˆÊ’u-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlShadowSoftnessP, "ˆß‘•‰A‰e_+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlShadowSoftnessM, "ˆß‘•‰A‰e_-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlShadowStrengthP, "ˆß‘•‰A‰e‹­+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlShadowStrengthM, "ˆß‘•‰A‰e‹­-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlSpecularStrengthP, "ˆß‘•‚Œõ‹­+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlSpecularStrengthM, "ˆß‘•‚Œõ‹­-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlSpecularMaskP, "ˆß‘•‚ŒõÕ•Á+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlSpecularMaskM, "ˆß‘•‚ŒõÕ•Á-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlSpecularRangeP, "ˆß‘•‚Œõ”ÍˆÍ+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlSpecularRangeM, "ˆß‘•‚Œõ”ÍˆÍ-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlGlossinessP, "ˆß‘•‚ŒõŒõŠŠ+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlGlossinessM, "ˆß‘•‚ŒõŒõŠŠ-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlSpecularRP, "ˆß‘•‚ŒõÔ+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlSpecularRM, "ˆß‘•‚ŒõÔ-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlSpecularGP, "ˆß‘•‚Œõ—Î+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlSpecularGM, "ˆß‘•‚Œõ—Î-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlSpecularBP, "ˆß‘•‚ŒõÂ+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlSpecularBM, "ˆß‘•‚ŒõÂ-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlRimStrengthP, "ˆß‘••ÓŒõ‹­+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlRimStrengthM, "ˆß‘••ÓŒõ‹­-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlRimWidthP, "ˆß‘••ÓŒõ•+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlRimWidthM, "ˆß‘••ÓŒõ•-");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlRimHardnessP, "ˆß‘••ÓŒõd+");
ZZZ_CLOTH_CONTROL(ZzzClothCtrlRimHardnessM, "ˆß‘••ÓŒõd-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlMasterP, "‹…–Ê‘S‘Ì‹­+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlMasterM, "‹…–Ê‘S‘Ì‹­-");

ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlStrengthP1, "‹…–Ê‘…1‹­+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlStrengthM1, "‹…–Ê‘…1‹­-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlBrightnessP1, "‹…–Ê‘…1–¾+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlBrightnessM1, "‹…–Ê‘…1–¾-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlMaskP1, "‹…–Ê‘…1Õ•Á+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlMaskM1, "‹…–Ê‘…1Õ•Á-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlDisable1, "‹…–Ê‘…1•Â");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlStrengthP2, "‹…–Ê‘…2‹­+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlStrengthM2, "‹…–Ê‘…2‹­-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlBrightnessP2, "‹…–Ê‘…2–¾+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlBrightnessM2, "‹…–Ê‘…2–¾-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlMaskP2, "‹…–Ê‘…2Õ•Á+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlMaskM2, "‹…–Ê‘…2Õ•Á-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlDisable2, "‹…–Ê‘…2•Â");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlStrengthP3, "‹…–Ê‘…3‹­+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlStrengthM3, "‹…–Ê‘…3‹­-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlBrightnessP3, "‹…–Ê‘…3–¾+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlBrightnessM3, "‹…–Ê‘…3–¾-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlMaskP3, "‹…–Ê‘…3Õ•Á+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlMaskM3, "‹…–Ê‘…3Õ•Á-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlDisable3, "‹…–Ê‘…3•Â");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlStrengthP4, "‹…–Ê‘…4‹­+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlStrengthM4, "‹…–Ê‘…4‹­-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlBrightnessP4, "‹…–Ê‘…4–¾+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlBrightnessM4, "‹…–Ê‘…4–¾-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlMaskP4, "‹…–Ê‘…4Õ•Á+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlMaskM4, "‹…–Ê‘…4Õ•Á-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlDisable4, "‹…–Ê‘…4•Â");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlStrengthP5, "‹…–Ê‘…5‹­+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlStrengthM5, "‹…–Ê‘…5‹­-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlBrightnessP5, "‹…–Ê‘…5–¾+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlBrightnessM5, "‹…–Ê‘…5–¾-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlMaskP5, "‹…–Ê‘…5Õ•Á+");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlMaskM5, "‹…–Ê‘…5Õ•Á-");
ZZZ_CLOTH_CONTROL(ZzzMatcapCtrlDisable5, "‹…–Ê‘…5•Â");
#undef ZZZ_CLOTH_CONTROL

float ZzzClothCtrlSigned(float positive, float negative)
{
    return saturate(positive) - saturate(negative);
}

float ZzzClothCtrlBounded(
    float baseValue,
    float positive,
    float negative,
    float minimumValue,
    float maximumValue)
{
    float neutral = clamp(baseValue, minimumValue, maximumValue);
    float control = ZzzClothCtrlSigned(positive, negative);
    return clamp(
        neutral
            + (maximumValue - neutral) * max(control, 0.0)
            - (neutral - minimumValue) * max(-control, 0.0),
        minimumValue,
        maximumValue);
}

float ZzzClothCtrlMultiplier(float positive, float negative, float maximumValue)
{
    return lerp(1.0, maximumValue, saturate(positive))
        * (1.0 - saturate(negative));
}

float3 ZzzClothCtrlRgb(float3 positive, float3 negative, float maximumValue)
{
    return max(
        lerp(1.0.xxx, maximumValue.xxx, saturate(positive))
            * (1.0.xxx - saturate(negative)),
        0.0.xxx);
}

float ZzzClothControlledBrightness(float value)
{
    return ZzzClothCtrlBounded(value, ZzzClothCtrlBrightnessP, ZzzClothCtrlBrightnessM, 0.0, 3.0);
}

float ZzzClothControlledShadowBias(float value)
{
    return ZzzClothCtrlBounded(value, ZzzClothCtrlShadowPositionP, ZzzClothCtrlShadowPositionM, -1.0, 1.0);
}

float ZzzClothControlledShadowSoftness(float value)
{
    return ZzzClothCtrlBounded(value, ZzzClothCtrlShadowSoftnessP, ZzzClothCtrlShadowSoftnessM, 0.001, 0.5);
}

float ZzzClothControlledShadowStrength(float value)
{
    return ZzzClothCtrlBounded(value, ZzzClothCtrlShadowStrengthP, ZzzClothCtrlShadowStrengthM, 0.0, 1.0);
}

float ZzzClothControlledSpecularStrength(float value)
{
    return ZzzClothCtrlBounded(value, ZzzClothCtrlSpecularStrengthP, ZzzClothCtrlSpecularStrengthM, 0.0, 4.0);
}

float ZzzClothControlledSpecularMask(float value)
{
    return ZzzClothCtrlBounded(value, ZzzClothCtrlSpecularMaskP, ZzzClothCtrlSpecularMaskM, 0.0, 4.0);
}

float ZzzClothControlledSpecularRange(float value)
{
    return ZzzClothCtrlBounded(value, ZzzClothCtrlSpecularRangeP, ZzzClothCtrlSpecularRangeM, 0.1, 2.0);
}

float ZzzClothControlledGlossiness(float value)
{
    return ZzzClothCtrlBounded(value, ZzzClothCtrlGlossinessP, ZzzClothCtrlGlossinessM, 0.0, 1.0);
}

float3 ZzzClothControlledSpecularColor(float3 value)
{
    return max(value, 0.0.xxx) * ZzzClothCtrlRgb(
        float3(ZzzClothCtrlSpecularRP, ZzzClothCtrlSpecularGP, ZzzClothCtrlSpecularBP),
        float3(ZzzClothCtrlSpecularRM, ZzzClothCtrlSpecularGM, ZzzClothCtrlSpecularBM),
        4.0);
}

float ZzzClothControlledRimStrength(float value)
{
    return ZzzClothCtrlBounded(value, ZzzClothCtrlRimStrengthP, ZzzClothCtrlRimStrengthM, 0.0, 4.0);
}

float ZzzClothControlledRimWidth(float value)
{
    return ZzzClothCtrlBounded(value, ZzzClothCtrlRimWidthP, ZzzClothCtrlRimWidthM, 0.05, 4.0);
}

float ZzzClothControlledRimContrast(float value)
{
    return ZzzClothCtrlBounded(value, ZzzClothCtrlRimHardnessP, ZzzClothCtrlRimHardnessM, 0.1, 8.0);
}

float ZzzMatcapSelect5(float slotId, float a, float b, float c, float d, float e)
{
    float w1 = 1.0 - step(0.5, slotId);
    float w2 = step(0.5, slotId) * (1.0 - step(1.5, slotId));
    float w3 = step(1.5, slotId) * (1.0 - step(2.5, slotId));
    float w4 = step(2.5, slotId) * (1.0 - step(3.5, slotId));
    float w5 = step(3.5, slotId);
    return a * w1 + b * w2 + c * w3 + d * w4 + e * w5;
}

float ZzzMatcapControlledMasterStrength()
{
    return ZzzClothCtrlMultiplier(ZzzMatcapCtrlMasterP, ZzzMatcapCtrlMasterM, 4.0);
}

float ZzzMatcapControlledSlotStrength(float slotId)
{
    float positive = ZzzMatcapSelect5(slotId,
        ZzzMatcapCtrlStrengthP1, ZzzMatcapCtrlStrengthP2, ZzzMatcapCtrlStrengthP3,
        ZzzMatcapCtrlStrengthP4, ZzzMatcapCtrlStrengthP5);
    float negative = ZzzMatcapSelect5(slotId,
        ZzzMatcapCtrlStrengthM1, ZzzMatcapCtrlStrengthM2, ZzzMatcapCtrlStrengthM3,
        ZzzMatcapCtrlStrengthM4, ZzzMatcapCtrlStrengthM5);
    return ZzzClothCtrlMultiplier(positive, negative, 4.0);
}

float ZzzMatcapControlledSlotBrightness(float slotId)
{
    float positive = ZzzMatcapSelect5(slotId,
        ZzzMatcapCtrlBrightnessP1, ZzzMatcapCtrlBrightnessP2, ZzzMatcapCtrlBrightnessP3,
        ZzzMatcapCtrlBrightnessP4, ZzzMatcapCtrlBrightnessP5);
    float negative = ZzzMatcapSelect5(slotId,
        ZzzMatcapCtrlBrightnessM1, ZzzMatcapCtrlBrightnessM2, ZzzMatcapCtrlBrightnessM3,
        ZzzMatcapCtrlBrightnessM4, ZzzMatcapCtrlBrightnessM5);
    return ZzzClothCtrlMultiplier(positive, negative, 4.0);
}

float ZzzMatcapControlledSlotMask(float slotId)
{
    float positive = ZzzMatcapSelect5(slotId,
        ZzzMatcapCtrlMaskP1, ZzzMatcapCtrlMaskP2, ZzzMatcapCtrlMaskP3,
        ZzzMatcapCtrlMaskP4, ZzzMatcapCtrlMaskP5);
    float negative = ZzzMatcapSelect5(slotId,
        ZzzMatcapCtrlMaskM1, ZzzMatcapCtrlMaskM2, ZzzMatcapCtrlMaskM3,
        ZzzMatcapCtrlMaskM4, ZzzMatcapCtrlMaskM5);
    return ZzzClothCtrlMultiplier(positive, negative, 2.0);
}

float ZzzMatcapControlledSlotEnabled(float slotId)
{
    return 1.0 - saturate(ZzzMatcapSelect5(slotId,
        ZzzMatcapCtrlDisable1, ZzzMatcapCtrlDisable2, ZzzMatcapCtrlDisable3,
        ZzzMatcapCtrlDisable4, ZzzMatcapCtrlDisable5));
}

#endif
