#ifndef ZZZ_HAIR_ZZZSHADOW_RIM_INCLUDED
#define ZZZ_HAIR_ZZZSHADOW_RIM_INCLUDED

// ZMD release-template screen-space hair rim, adapted only to the ZZZshadow
// render-target names. The accepted Test 14 main pass is not evaluated here.

float4x4 ZzzShadowView : VIEW;
float4x4 ZzzShadowProjection : PROJECTION;
float4x4 ZzzShadowWorldInverse : WORLDINVERSE;
float2 ZzzShadowViewportSize : VIEWPORTPIXELSIZE;
bool ZzzShadowValid : CONTROLOBJECT < string name = "ZZZshadow.x"; >;

shared texture2D ZZZshadow_ViewportMap2 : RENDERCOLORTARGET;
sampler2D ZzzShadowViewportSampler = sampler_state {
    texture = <ZZZshadow_ViewportMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

// Same Range5 morph contract as the released ZMD hair controller.
float ZzzHairRimStrengthP : CONTROLOBJECT <
    string name = "ZzzHair_controller.pmx";
    string item = "•ÓŒõ‹­+";
>;
float ZzzHairRimStrengthM : CONTROLOBJECT <
    string name = "ZzzHair_controller.pmx";
    string item = "•ÓŒõ‹­-";
>;
float ZzzHairRimWidthP : CONTROLOBJECT <
    string name = "ZzzHair_controller.pmx";
    string item = "•ÓŒõ•+";
>;
float ZzzHairRimWidthM : CONTROLOBJECT <
    string name = "ZzzHair_controller.pmx";
    string item = "•ÓŒõ•-";
>;
float ZzzHairRimContrastP : CONTROLOBJECT <
    string name = "ZzzHair_controller.pmx";
    string item = "•ÓŒõd+";
>;
float ZzzHairRimContrastM : CONTROLOBJECT <
    string name = "ZzzHair_controller.pmx";
    string item = "•ÓŒõd-";
>;
float ZzzHairRimRP : CONTROLOBJECT <
    string name = "ZzzHair_controller.pmx";
    string item = "•ÓŒõÔ+";
>;
float ZzzHairRimRM : CONTROLOBJECT <
    string name = "ZzzHair_controller.pmx";
    string item = "•ÓŒõÔ-";
>;
float ZzzHairRimGP : CONTROLOBJECT <
    string name = "ZzzHair_controller.pmx";
    string item = "•ÓŒõ—Î+";
>;
float ZzzHairRimGM : CONTROLOBJECT <
    string name = "ZzzHair_controller.pmx";
    string item = "•ÓŒõ—Î-";
>;
float ZzzHairRimBP : CONTROLOBJECT <
    string name = "ZzzHair_controller.pmx";
    string item = "•ÓŒõÂ+";
>;
float ZzzHairRimBM : CONTROLOBJECT <
    string name = "ZzzHair_controller.pmx";
    string item = "•ÓŒõÂ-";
>;

static const float ZZZ_ZMD_RIM_WIDTH_X = 0.028000;
static const float ZZZ_ZMD_RIM_WIDTH_Y = 0.012500;
static const float ZZZ_ZMD_RIM_VIEW_SCALE = 0.1;
static const float ZZZ_ZMD_RIM_MODEL_SCALE = 10.0;
static const float ZZZ_ZMD_RIM_DEPTH_SCALE = 0.8;
static const float ZZZ_ZMD_RIM_DEPTH_MAX = 4.0;
static const float ZZZ_ZMD_RIM_FRESNEL_POWER = 4.0;
static const float ZZZ_ZMD_RIM_DIRECTIONAL_ATTENUATION = 0.961783409;
static const float ZZZ_ZMD_RIM_LIMITATION_STRENGTH = 0.35;
static const float ZZZ_ZMD_RIM_COLOR_STRENGTH = 0.35;

float ZzzHairRimSigned(float positive, float negative)
{
    return saturate(positive) - saturate(negative);
}

float ZzzHairRimPositiveMultiplier(float control)
{
    return lerp(1.0, 5.0, saturate(control));
}

float ZzzHairRimWidthMultiplier()
{
    float positiveScale = ZzzHairRimPositiveMultiplier(ZzzHairRimWidthP);
    float negativeScale = lerp(1.0, 0.2, saturate(ZzzHairRimWidthM));
    return max(0.05, positiveScale * negativeScale);
}

float ZzzHairRimStrengthMultiplier()
{
    return ZzzHairRimPositiveMultiplier(ZzzHairRimStrengthP)
        * (1.0 - saturate(ZzzHairRimStrengthM));
}

float ZzzHairRimContrast()
{
    float control = ZzzHairRimSigned(
        ZzzHairRimContrastP, ZzzHairRimContrastM);
    return clamp(
        1.0 + 7.0 * max(control, 0.0)
            - 0.75 * max(-control, 0.0),
        0.25, 8.0);
}

float3 ZzzHairRimColor()
{
    // Jane's three hair materials have black EDGECOLOR. The ZMD authored rim
    // is white, so this ZZZ port starts from the manual white ZMD constant.
    float3 color = float3(1.0, 1.0, 1.0);
    return saturate(
        color + (1.0 - color) * saturate(float3(
            ZzzHairRimRP, ZzzHairRimGP, ZzzHairRimBP))
        - color * saturate(float3(
            ZzzHairRimRM, ZzzHairRimGM, ZzzHairRimBM)));
}

float ZzzHairRimApplyContrast(float mask, float contrast)
{
    return pow(saturate(mask), max(contrast, 0.0001));
}

float2 ZzzShadowViewportUv(float4 clipPosition)
{
    float2 ndc = clipPosition.xy / clipPosition.w;
    float2 uv = float2(
        (1.0 + ndc.x) * 0.5,
        (1.0 - ndc.y) * 0.5);
    return uv + 0.5 / max(ZzzShadowViewportSize, 1.0);
}

float ZzzEvaluateZmdDepthRim(
    float3 positionWS,
    float3 geometryNormalWS,
    float4 screenPosition,
    float widthMultiplier)
{
    if (!ZzzShadowValid || abs(screenPosition.w) < 0.000001) {
        return 0.0;
    }

    float3 positionVS = mul(
        float4(positionWS, 1.0), ZzzShadowView).xyz;
    float3 normalVS = ZzzSafeNormalize(
        mul(geometryNormalWS, (float3x3)ZzzShadowView),
        float3(0.0, 0.0, 1.0));
    float3 rimOffsetVS = float3(
        normalVS.x * ZZZ_ZMD_RIM_WIDTH_X
            * ZZZ_ZMD_RIM_VIEW_SCALE
            * ZZZ_ZMD_RIM_MODEL_SCALE
            * widthMultiplier,
        normalVS.y * ZZZ_ZMD_RIM_WIDTH_Y
            * ZZZ_ZMD_RIM_VIEW_SCALE
            * ZZZ_ZMD_RIM_MODEL_SCALE
            * widthMultiplier,
        0.0);
    float4 offsetClip = mul(
        float4(positionVS + rimOffsetVS, 1.0),
        ZzzShadowProjection);
    if (abs(offsetClip.w) < 0.000001) {
        return 0.0;
    }

    float centerDepth = tex2D(
        ZzzShadowViewportSampler,
        ZzzShadowViewportUv(screenPosition)).g;
    float offsetDepth = tex2D(
        ZzzShadowViewportSampler,
        ZzzShadowViewportUv(offsetClip)).g;
    return clamp(
        (offsetDepth - centerDepth) * ZZZ_ZMD_RIM_DEPTH_SCALE,
        0.0,
        ZZZ_ZMD_RIM_DEPTH_MAX);
}

float ZzzEvaluateZmdScreenRim(
    float3 positionWS,
    float3 geometryNormalWS,
    float3 normalWS,
    float3 viewDirectionWS,
    float4 screenPosition)
{
    float depthRim = ZzzEvaluateZmdDepthRim(
        positionWS,
        geometryNormalWS,
        screenPosition,
        ZzzHairRimWidthMultiplier());
    float noV = saturate(dot(
        ZzzSafeNormalize(normalWS, geometryNormalWS),
        ZzzSafeNormalize(viewDirectionWS, geometryNormalWS)));
    float fresnel = pow(
        saturate(1.0 - noV),
        ZZZ_ZMD_RIM_FRESNEL_POWER);
    float vertical = geometryNormalWS.y * 0.5 + 0.5;
    float3 lightWS = ZzzSafeNormalize(
        -ZzzLightDirection,
        float3(0.0, 0.70710678, -0.70710678));
    float noL = saturate(dot(normalWS, lightWS));
    float directional = lerp(
        1.0 - ZZZ_ZMD_RIM_DIRECTIONAL_ATTENUATION,
        1.0,
        noL);
    float3 normalOS = mul(
        normalWS, (float3x3)ZzzShadowWorldInverse);
    float limitation = saturate(normalOS.x);
    float limitationMix = lerp(
        1.0,
        limitation,
        ZZZ_ZMD_RIM_LIMITATION_STRENGTH);
    return ZzzHairRimApplyContrast(
        saturate(depthRim * fresnel * vertical
            * directional * limitationMix),
        ZzzHairRimContrast());
}

float4 ZzzHairZzzShadowRimPS(
    ZzzVaryings input,
    float facing : VFACE,
    uniform bool useTexture) : COLOR0
{
    float2 uv = input.uv.xy;
    float4 baseColor = ZzzSampleBase(uv, useTexture);
    clip(baseColor.a - ZZZ_ALPHA_CUTOFF);
    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 geometryNormalWS = ZzzSafeNormalize(
        input.geometricNormalWS,
        float3(0.0, 1.0, 0.0));
    float3 normalWS = ZzzReconstructNormal(
        input.positionWS, geometryNormalWS, uv) * faceSign;
    float3 viewDirectionWS = ZzzSafeNormalize(
        input.viewDirectionWS, geometryNormalWS);
    float rimMask = ZzzEvaluateZmdScreenRim(
        input.positionWS,
        geometryNormalWS,
        normalWS,
        viewDirectionWS,
        input.screenPosition);
    float3 rimLinear = ZzzSrgbToLinear(ZzzHairRimColor())
        * ZZZ_ZMD_RIM_COLOR_STRENGTH
        * rimMask
        * ZzzHairRimStrengthMultiplier();
    return float4(max(rimLinear, 0.0), 0.0);
}

#endif
