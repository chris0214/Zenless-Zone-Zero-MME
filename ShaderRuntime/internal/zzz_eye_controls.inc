#ifndef ZZZ_EYE_CONTROLS_INCLUDED
#define ZZZ_EYE_CONTROLS_INCLUDED

#define ZZZ_EYE_CONTROLLER_NAME "ZzzEye_controller.pmx"
#define ZZZ_EYE_CONTROL(symbol, morphName) \
    float symbol : CONTROLOBJECT < \
        string name = ZZZ_EYE_CONTROLLER_NAME; \
        string item = morphName; \
    >

ZZZ_EYE_CONTROL(ZzzEyeCtrlBrightnessP, "ä·ãÖñæìx+");
ZZZ_EYE_CONTROL(ZzzEyeCtrlBrightnessM, "ä·ãÖñæìx-");
ZZZ_EYE_CONTROL(ZzzEyeCtrlSoftLightP, "ä·ãÖéÛåı+");
ZZZ_EYE_CONTROL(ZzzEyeCtrlSoftLightM, "ä·ãÖéÛåı-");
ZZZ_EYE_CONTROL(ZzzEyeCtrlInnerStrengthP, "ìµì‡åıã≠+");
ZZZ_EYE_CONTROL(ZzzEyeCtrlInnerStrengthM, "ìµì‡åıã≠-");
ZZZ_EYE_CONTROL(ZzzEyeCtrlInnerOpacityP, "ìµì‡åıìßñæ+");
ZZZ_EYE_CONTROL(ZzzEyeCtrlInnerOpacityM, "ìµì‡åıìßñæ-");
ZZZ_EYE_CONTROL(ZzzEyeCtrlInnerMaskP, "ìµì‡åıé’ï¡+");
ZZZ_EYE_CONTROL(ZzzEyeCtrlInnerMaskM, "ìµì‡åıé’ï¡-");
ZZZ_EYE_CONTROL(ZzzEyeCtrlHighlightStrengthP, "ä·çÇåıã≠+");
ZZZ_EYE_CONTROL(ZzzEyeCtrlHighlightStrengthM, "ä·çÇåıã≠-");
ZZZ_EYE_CONTROL(ZzzEyeCtrlHighlightOpacityP, "ä·çÇåıìßñæ+");
ZZZ_EYE_CONTROL(ZzzEyeCtrlHighlightOpacityM, "ä·çÇåıìßñæ-");
ZZZ_EYE_CONTROL(ZzzEyeCtrlThroughStrengthP, "ä·ìßã≠+");
ZZZ_EYE_CONTROL(ZzzEyeCtrlThroughStrengthM, "ä·ìßã≠-");
ZZZ_EYE_CONTROL(ZzzEyeCtrlThroughGainP, "ä·ìßñæìx+");
ZZZ_EYE_CONTROL(ZzzEyeCtrlThroughGainM, "ä·ìßñæìx-");
ZZZ_EYE_CONTROL(ZzzEyeCtrlThroughCutoffP, "ä·ìßã´äE+");
ZZZ_EYE_CONTROL(ZzzEyeCtrlThroughCutoffM, "ä·ìßã´äE-");
ZZZ_EYE_CONTROL(ZzzEyeCtrlThroughFeatherP, "ä·ìßè_+");
ZZZ_EYE_CONTROL(ZzzEyeCtrlThroughFeatherM, "ä·ìßè_-");
#undef ZZZ_EYE_CONTROL

float ZzzEyeCtrlSigned(float positive, float negative)
{
    return saturate(positive) - saturate(negative);
}

float ZzzEyeCtrlBounded(
    float baseValue,
    float positive,
    float negative,
    float minimumValue,
    float maximumValue)
{
    float neutral = clamp(baseValue, minimumValue, maximumValue);
    float control = ZzzEyeCtrlSigned(positive, negative);
    return clamp(
        neutral
            + (maximumValue - neutral) * max(control, 0.0)
            - (neutral - minimumValue) * max(-control, 0.0),
        minimumValue,
        maximumValue);
}

float ZzzEyeControlledBrightness(float value)
{
    return ZzzEyeCtrlBounded(value, ZzzEyeCtrlBrightnessP, ZzzEyeCtrlBrightnessM, 0.0, 3.0);
}

float ZzzEyeControlledSoftLight(float value)
{
    return ZzzEyeCtrlBounded(value, ZzzEyeCtrlSoftLightP, ZzzEyeCtrlSoftLightM, 0.0, 1.0);
}

float ZzzEyeControlledInnerBrightness(float value)
{
    return ZzzEyeCtrlBounded(value, ZzzEyeCtrlInnerStrengthP, ZzzEyeCtrlInnerStrengthM, 0.0, 16.0);
}

float ZzzEyeControlledInnerOpacity(float value)
{
    return ZzzEyeCtrlBounded(value, ZzzEyeCtrlInnerOpacityP, ZzzEyeCtrlInnerOpacityM, 0.0, 1.0);
}

float ZzzEyeControlledInnerMask(float value)
{
    return ZzzEyeCtrlBounded(value, ZzzEyeCtrlInnerMaskP, ZzzEyeCtrlInnerMaskM, 0.0, 8.0);
}

float ZzzEyeControlledHighlightBrightness(float value)
{
    return ZzzEyeCtrlBounded(value, ZzzEyeCtrlHighlightStrengthP, ZzzEyeCtrlHighlightStrengthM, 0.0, 4.0);
}

float ZzzEyeControlledHighlightOpacity(float value)
{
    return ZzzEyeCtrlBounded(value, ZzzEyeCtrlHighlightOpacityP, ZzzEyeCtrlHighlightOpacityM, 0.0, 1.0);
}

float ZzzEyeControlledThroughStrength(float value)
{
    return ZzzEyeCtrlBounded(value, ZzzEyeCtrlThroughStrengthP, ZzzEyeCtrlThroughStrengthM, 0.0, 1.0);
}

float ZzzEyeControlledThroughGain(float value)
{
    return ZzzEyeCtrlBounded(value, ZzzEyeCtrlThroughGainP, ZzzEyeCtrlThroughGainM, 0.5, 2.0);
}

float ZzzEyeControlledThroughCutoff(float value)
{
    return ZzzEyeCtrlBounded(value, ZzzEyeCtrlThroughCutoffP, ZzzEyeCtrlThroughCutoffM, 0.0, 1.0);
}

float ZzzEyeControlledThroughFeather(float value)
{
    return ZzzEyeCtrlBounded(value, ZzzEyeCtrlThroughFeatherP, ZzzEyeCtrlThroughFeatherM, 0.001, 0.5);
}

#endif
