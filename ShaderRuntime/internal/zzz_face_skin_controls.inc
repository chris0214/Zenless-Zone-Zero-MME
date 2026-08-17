#ifndef ZZZ_FACE_SKIN_CONTROLS_INCLUDED
#define ZZZ_FACE_SKIN_CONTROLS_INCLUDED

#define ZZZ_FACE_SKIN_CONTROLLER_NAME "ZzzFaceSkin_controller.pmx"
#define ZZZ_FACE_SKIN_CONTROL(symbol, morphName) \
    float symbol : CONTROLOBJECT < \
        string name = ZZZ_FACE_SKIN_CONTROLLER_NAME; \
        string item = morphName; \
    >

ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlBrightnessP, "ñ ñæìx+");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlBrightnessM, "ñ ñæìx-");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlSdfPositionP, "SDFà íu+");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlSdfPositionM, "SDFà íu-");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlSdfSoftnessP, "SDFè_+");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlSdfSoftnessM, "SDFè_-");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlAoP, "ñ AO+");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlAoM, "ñ AO-");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlNoseStrengthP, "ï@âeã≠+");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlNoseStrengthM, "ï@âeã≠-");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlNoseLengthP, "ï@âeí∑+");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlNoseLengthM, "ï@âeí∑-");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlHighlightStrengthP, "ñ çÇåıã≠+");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlHighlightStrengthM, "ñ çÇåıã≠-");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlHighlightWidthP, "ñ çÇåıïù+");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlHighlightWidthM, "ñ çÇåıïù-");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlHighlightHardnessP, "ñ çÇåıçd+");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceCtrlHighlightHardnessM, "ñ çÇåıçd-");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceSkinCtrlRampStrengthP, "îßêFã≠+");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceSkinCtrlRampStrengthM, "îßêFã≠-");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceSkinCtrlRampSmoothP, "îßêFâﬂìn+");
ZZZ_FACE_SKIN_CONTROL(ZzzFaceSkinCtrlRampSmoothM, "îßêFâﬂìn-");
ZZZ_FACE_SKIN_CONTROL(ZzzSkinCtrlSpecularStrengthP, "îÁçÇåıã≠+");
ZZZ_FACE_SKIN_CONTROL(ZzzSkinCtrlSpecularStrengthM, "îÁçÇåıã≠-");
ZZZ_FACE_SKIN_CONTROL(ZzzSkinCtrlSpecularRangeP, "îÁçÇåıîÕàÕ+");
ZZZ_FACE_SKIN_CONTROL(ZzzSkinCtrlSpecularRangeM, "îÁçÇåıîÕàÕ-");
ZZZ_FACE_SKIN_CONTROL(ZzzSkinCtrlGlossinessP, "îÁçÇåıåıää+");
ZZZ_FACE_SKIN_CONTROL(ZzzSkinCtrlGlossinessM, "îÁçÇåıåıää-");
ZZZ_FACE_SKIN_CONTROL(ZzzSkinCtrlRimStrengthP, "îÁï”åıã≠+");
ZZZ_FACE_SKIN_CONTROL(ZzzSkinCtrlRimStrengthM, "îÁï”åıã≠-");
ZZZ_FACE_SKIN_CONTROL(ZzzSkinCtrlRimWidthP, "îÁï”åıïù+");
ZZZ_FACE_SKIN_CONTROL(ZzzSkinCtrlRimWidthM, "îÁï”åıïù-");
ZZZ_FACE_SKIN_CONTROL(ZzzSkinCtrlRimHardnessP, "îÁï”åıçd+");
ZZZ_FACE_SKIN_CONTROL(ZzzSkinCtrlRimHardnessM, "îÁï”åıçd-");
#undef ZZZ_FACE_SKIN_CONTROL

float ZzzFaceSkinCtrlSigned(float positive, float negative)
{
    return saturate(positive) - saturate(negative);
}

float ZzzFaceSkinCtrlBounded(
    float baseValue,
    float positive,
    float negative,
    float minimumValue,
    float maximumValue)
{
    float neutral = clamp(baseValue, minimumValue, maximumValue);
    float control = ZzzFaceSkinCtrlSigned(positive, negative);
    return clamp(
        neutral
            + (maximumValue - neutral) * max(control, 0.0)
            - (neutral - minimumValue) * max(-control, 0.0),
        minimumValue,
        maximumValue);
}

float ZzzFaceControlledBrightness(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzFaceCtrlBrightnessP, ZzzFaceCtrlBrightnessM, 0.0, 3.0);
}

float ZzzFaceControlledThresholdOffset(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzFaceCtrlSdfPositionP, ZzzFaceCtrlSdfPositionM, -0.5, 0.5);
}

float ZzzFaceControlledSoftness(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzFaceCtrlSdfSoftnessP, ZzzFaceCtrlSdfSoftnessM, 0.001, 0.5);
}

float ZzzFaceControlledAo(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzFaceCtrlAoP, ZzzFaceCtrlAoM, 0.0, 2.0);
}

float ZzzFaceControlledNoseStrength(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzFaceCtrlNoseStrengthP, ZzzFaceCtrlNoseStrengthM, 0.0, 4.0);
}

float ZzzFaceControlledNoseLength(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzFaceCtrlNoseLengthP, ZzzFaceCtrlNoseLengthM, 0.0, 4.0);
}

float ZzzFaceControlledHighlightStrength(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzFaceCtrlHighlightStrengthP, ZzzFaceCtrlHighlightStrengthM, 0.0, 10.0);
}

float ZzzFaceControlledHighlightWidth(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzFaceCtrlHighlightWidthP, ZzzFaceCtrlHighlightWidthM, 0.01, 1.0);
}

float ZzzFaceControlledHighlightHardness(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzFaceCtrlHighlightHardnessP, ZzzFaceCtrlHighlightHardnessM, 0.1, 8.0);
}

float ZzzFaceSkinControlledRampStrength(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzFaceSkinCtrlRampStrengthP, ZzzFaceSkinCtrlRampStrengthM, 0.0, 2.0);
}

float ZzzFaceSkinControlledRampSmoothness(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzFaceSkinCtrlRampSmoothP, ZzzFaceSkinCtrlRampSmoothM, 0.001, 0.5);
}

float ZzzSkinControlledSpecularStrength(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzSkinCtrlSpecularStrengthP, ZzzSkinCtrlSpecularStrengthM, 0.0, 4.0);
}

float ZzzSkinControlledSpecularRange(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzSkinCtrlSpecularRangeP, ZzzSkinCtrlSpecularRangeM, 0.0, 2.0);
}

float ZzzSkinControlledGlossiness(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzSkinCtrlGlossinessP, ZzzSkinCtrlGlossinessM, 0.0, 1.0);
}

float ZzzSkinControlledRimStrength(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzSkinCtrlRimStrengthP, ZzzSkinCtrlRimStrengthM, 0.0, 4.0);
}

float ZzzSkinControlledRimWidth(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzSkinCtrlRimWidthP, ZzzSkinCtrlRimWidthM, 0.05, 4.0);
}

float ZzzSkinControlledRimContrast(float value)
{
    return ZzzFaceSkinCtrlBounded(value, ZzzSkinCtrlRimHardnessP, ZzzSkinCtrlRimHardnessM, 0.1, 8.0);
}

#endif
