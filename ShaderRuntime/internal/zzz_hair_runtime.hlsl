#ifndef ZZZ_HAIR05_TEST_RUNTIME_INCLUDED
#define ZZZ_HAIR05_TEST_RUNTIME_INCLUDED

#ifndef ZZZ_HAIR_VIEW_GATE_GAIN
#define ZZZ_HAIR_VIEW_GATE_GAIN 1.0
#endif

#ifndef ZZZ_HAIR_TEST_VIEW
#define ZZZ_HAIR_TEST_VIEW 5
#endif

#ifndef ZZZ_HAIR_TOON_THRESHOLD_DEFAULT
#define ZZZ_HAIR_TOON_THRESHOLD_DEFAULT 0.5
#endif
#ifndef ZZZ_HAIR_TOON_SOFTNESS_DEFAULT
#define ZZZ_HAIR_TOON_SOFTNESS_DEFAULT 0.04
#endif
#ifndef ZZZ_HAIR_HEAD_CENTER_UP_DEFAULT
#define ZZZ_HAIR_HEAD_CENTER_UP_DEFAULT 1.0
#endif
#ifndef ZZZ_HAIR_HEAD_CENTER_FORWARD_DEFAULT
#define ZZZ_HAIR_HEAD_CENTER_FORWARD_DEFAULT 0.8
#endif
#ifndef ZZZ_HAIR_SPHERE_RADIUS_DEFAULT
#define ZZZ_HAIR_SPHERE_RADIUS_DEFAULT 1.0
#endif
#ifndef ZZZ_HAIR_SPHERE_TRANSITION_DEFAULT
#define ZZZ_HAIR_SPHERE_TRANSITION_DEFAULT 0.5
#endif
#ifndef ZZZ_HAIR_SHAPE_SOFTNESS_DEFAULT
#define ZZZ_HAIR_SHAPE_SOFTNESS_DEFAULT 0.1
#endif
#ifndef ZZZ_HAIR_SPECULAR_INTENSITY_DEFAULT
#define ZZZ_HAIR_SPECULAR_INTENSITY_DEFAULT 0.1
#endif
#ifndef ZZZ_HAIR_SHADOW_OFFSET_X_DEFAULT
#define ZZZ_HAIR_SHADOW_OFFSET_X_DEFAULT 0.055
#endif
#ifndef ZZZ_HAIR_SHADOW_OFFSET_Y_DEFAULT
#define ZZZ_HAIR_SHADOW_OFFSET_Y_DEFAULT 0.090
#endif
#ifndef ZZZ_HAIR_SHADOW_OPACITY_DEFAULT
#define ZZZ_HAIR_SHADOW_OPACITY_DEFAULT 0.32
#endif
#ifndef ZZZ_HAIR_SHADOW_COLOR_DEFAULT
#define ZZZ_HAIR_SHADOW_COLOR_DEFAULT float3(0.36, 0.25, 0.28)
#endif

#ifndef ZZZ_HAIR_APPLY_VIEW_GATE
#define ZZZ_HAIR_APPLY_VIEW_GATE 0
#endif

#ifndef ZZZ_HAIR_APPLY_CENTER_MASK
#define ZZZ_HAIR_APPLY_CENTER_MASK 0
#endif

#ifndef ZZZ_HAIR_CENTER_POWER
#define ZZZ_HAIR_CENTER_POWER 5.0
#endif

#ifndef ZZZ_HAIR_COMPOSITE_GAIN_OVERRIDE
#define ZZZ_HAIR_COMPOSITE_GAIN_OVERRIDE -1.0
#endif

#ifndef ZZZ_HAIR_HIGHLIGHT_SHAPE_1
#define ZZZ_HAIR_HIGHLIGHT_SHAPE_1 0.0
#endif
#ifndef ZZZ_HAIR_HIGHLIGHT_SHAPE_2
#define ZZZ_HAIR_HIGHLIGHT_SHAPE_2 0.0
#endif
#ifndef ZZZ_HAIR_HIGHLIGHT_SHAPE_3
#define ZZZ_HAIR_HIGHLIGHT_SHAPE_3 0.0
#endif
#ifndef ZZZ_HAIR_HIGHLIGHT_SHAPE_4
#define ZZZ_HAIR_HIGHLIGHT_SHAPE_4 0.0
#endif
#ifndef ZZZ_HAIR_HIGHLIGHT_SHAPE_5
#define ZZZ_HAIR_HIGHLIGHT_SHAPE_5 0.0
#endif

#ifndef ZZZ_HAIR_SPECULAR_COLOR_1
#define ZZZ_HAIR_SPECULAR_COLOR_1 float3(1.0, 1.0, 1.0)
#endif
#ifndef ZZZ_HAIR_SPECULAR_COLOR_2
#define ZZZ_HAIR_SPECULAR_COLOR_2 float3(1.0, 1.0, 1.0)
#endif
#ifndef ZZZ_HAIR_SPECULAR_COLOR_3
#define ZZZ_HAIR_SPECULAR_COLOR_3 float3(1.0, 1.0, 1.0)
#endif
#ifndef ZZZ_HAIR_SPECULAR_COLOR_4
#define ZZZ_HAIR_SPECULAR_COLOR_4 float3(1.0, 1.0, 1.0)
#endif
#ifndef ZZZ_HAIR_SPECULAR_COLOR_5
#define ZZZ_HAIR_SPECULAR_COLOR_5 float3(1.0, 1.0, 1.0)
#endif

#ifndef ZZZ_HAIR_TOON_SPECULAR_1
#define ZZZ_HAIR_TOON_SPECULAR_1 0.01
#endif
#ifndef ZZZ_HAIR_TOON_SPECULAR_2
#define ZZZ_HAIR_TOON_SPECULAR_2 0.01
#endif
#ifndef ZZZ_HAIR_TOON_SPECULAR_3
#define ZZZ_HAIR_TOON_SPECULAR_3 0.01
#endif
#ifndef ZZZ_HAIR_TOON_SPECULAR_4
#define ZZZ_HAIR_TOON_SPECULAR_4 0.01
#endif
#ifndef ZZZ_HAIR_TOON_SPECULAR_5
#define ZZZ_HAIR_TOON_SPECULAR_5 0.01
#endif

#ifndef ZZZ_HAIR_MODEL_SIZE_1
#define ZZZ_HAIR_MODEL_SIZE_1 1.0
#endif
#ifndef ZZZ_HAIR_MODEL_SIZE_2
#define ZZZ_HAIR_MODEL_SIZE_2 1.0
#endif
#ifndef ZZZ_HAIR_MODEL_SIZE_3
#define ZZZ_HAIR_MODEL_SIZE_3 1.0
#endif
#ifndef ZZZ_HAIR_MODEL_SIZE_4
#define ZZZ_HAIR_MODEL_SIZE_4 1.0
#endif
#ifndef ZZZ_HAIR_MODEL_SIZE_5
#define ZZZ_HAIR_MODEL_SIZE_5 1.0
#endif

#ifndef ZZZ_HAIR_INDEPENDENT_HIGHLIGHT
#define ZZZ_HAIR_INDEPENDENT_HIGHLIGHT 0
#endif

#ifndef ZZZ_HAIR_INDEPENDENT_GAIN
#define ZZZ_HAIR_INDEPENDENT_GAIN 35.0
#endif

#ifndef ZZZ_HAIR_LAYERED_HIGHLIGHT
#define ZZZ_HAIR_LAYERED_HIGHLIGHT 0
#endif

#ifndef ZZZ_HAIR_ZZZSHADOW_RIM
#define ZZZ_HAIR_ZZZSHADOW_RIM 0
#endif

#ifndef ZZZ_HAIR_FULL_CONTROLLER
#define ZZZ_HAIR_FULL_CONTROLLER 0
#endif

#ifndef ZZZ_HAIR_FACE_SHADOW_PASS
#define ZZZ_HAIR_FACE_SHADOW_PASS 0
#endif

// Public wrappers may override every model-specific resource below.
#ifndef ZZZ_NORMAL_RESOURCE
#define ZZZ_NORMAL_RESOURCE "textures/common/neutral_normal.png"
#endif
#ifndef ZZZ_MATERIAL_RESOURCE
#define ZZZ_MATERIAL_RESOURCE "textures/common/neutral_material.png"
#endif
#ifndef ZZZ_ATTRIBUTE_RESOURCE
#define ZZZ_ATTRIBUTE_RESOURCE "textures/common/neutral_attributes.png"
#endif
#ifndef ZZZ_HEAD_BONE
#define ZZZ_HEAD_BONE "頭"
#endif
#ifndef ZZZ_ALPHA_CUTOFF
#define ZZZ_ALPHA_CUTOFF 0.01
#endif
#ifndef ZZZ_HAIR_SUBSET
#define ZZZ_HAIR_SUBSET "0"
#endif

float4x4 ZzzWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 ZzzWorld : WORLD;
float3 ZzzLightDirection : DIRECTION < string Object = "Light"; >;
float3 ZzzCameraPosition : POSITION < string Object = "Camera"; >;
float4 ZzzMaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;

texture2D ZzzDiffuseTexture : MATERIALTEXTURE <
    string Format = "A8R8G8B8";
>;
sampler2D ZzzDiffuseSampler = sampler_state {
    texture = <ZzzDiffuseTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 8;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzNormalTexture < string ResourceName = ZZZ_NORMAL_RESOURCE; >;
sampler2D ZzzNormalSampler = sampler_state {
    texture = <ZzzNormalTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzMaterialTexture < string ResourceName = ZZZ_MATERIAL_RESOURCE; >;
sampler2D ZzzMaterialSampler = sampler_state {
    texture = <ZzzMaterialTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzAttributeTexture < string ResourceName = ZZZ_ATTRIBUTE_RESOURCE; >;
sampler2D ZzzAttributeSampler = sampler_state {
    texture = <ZzzAttributeTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

// ZZZshadow owns both channels used by Hair:
// R = HgShadow visibility data, G = linear scene depth for screen-space Rim.
bool ZzzHgShadowValid : CONTROLOBJECT < string name = "ZZZshadow.x"; >;
float ZzzHgShadowDensityUp : CONTROLOBJECT <
    string name = "(self)";
    string item = "ShadowDen+";
>;
float ZzzHgShadowDensityDown : CONTROLOBJECT <
    string name = "(self)";
    string item = "ShadowDen-";
>;
float ZzzHgShadowRotation : CONTROLOBJECT <
    string name = "ZZZshadow.x";
    string item = "Rx";
>;
#if ZZZ_HAIR_ZZZSHADOW_RIM == 0
shared texture2D ZZZshadow_ViewportMap2 : RENDERCOLORTARGET;
sampler2D ZzzHgShadowSampler = sampler_state {
    texture = <ZZZshadow_ViewportMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
#endif
float2 ZzzHgShadowViewportSize : VIEWPORTPIXELSIZE;

float4x4 ZzzHeadBone : CONTROLOBJECT <
    string name = "(self)";
    string item = ZZZ_HEAD_BONE;
>;

float ZzzToonThreshold <
    string UIName = "Zzz Toon Threshold";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = ZZZ_HAIR_TOON_THRESHOLD_DEFAULT;

float ZzzToonSoftness <
    string UIName = "Zzz Toon Softness";
    string UIWidget = "Slider";
    float UIMin = 0.001;
    float UIMax = 0.5;
> = ZZZ_HAIR_TOON_SOFTNESS_DEFAULT;

float ZzzHeadCenterUp <
    string UIName = "Zzz Head Center Up";
    string UIWidget = "Slider";
    float UIMin = -3.0;
    float UIMax = 3.0;
> = ZZZ_HAIR_HEAD_CENTER_UP_DEFAULT;

float ZzzHeadCenterForward <
    string UIName = "Zzz Head Center Forward";
    string UIWidget = "Slider";
    float UIMin = -3.0;
    float UIMax = 3.0;
> = ZZZ_HAIR_HEAD_CENTER_FORWARD_DEFAULT;

float ZzzHeadSphereRadius <
    string UIName = "Zzz Head Sphere Radius";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 3.0;
> = ZZZ_HAIR_SPHERE_RADIUS_DEFAULT;

float ZzzHeadSphereTransition <
    string UIName = "Zzz Head Sphere Transition";
    string UIWidget = "Slider";
    float UIMin = 0.01;
    float UIMax = 2.0;
> = ZZZ_HAIR_SPHERE_TRANSITION_DEFAULT;

float ZzzShapeSoftness <
    string UIName = "Zzz Shape Softness";
    string UIWidget = "Slider";
    float UIMin = 0.01;
    float UIMax = 1.0;
> = ZZZ_HAIR_SHAPE_SOFTNESS_DEFAULT;

float ZzzSpecularIntensity <
    string UIName = "Zzz Specular Intensity";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = ZZZ_HAIR_SPECULAR_INTENSITY_DEFAULT;

float ZzzSpecularDebugGain <
    string UIName = "Zzz Specular Debug Gain";
    string UIWidget = "Slider";
    float UIMin = 1.0;
    float UIMax = 20.0;
> = 8.0;

float ZzzSpecularCompositeGain <
    string UIName = "Zzz Specular Composite Gain";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 12.0;
> = 4.0;

float ZzzViewGateFull <
    string UIName = "Zzz View Gate Full";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 0.65;

float ZzzViewGateZero <
    string UIName = "Zzz View Gate Zero";
    string UIWidget = "Slider";
    float UIMin = -1.0;
    float UIMax = 1.0;
> = 0.0;

#if ZZZ_HAIR_FULL_CONTROLLER != 0
#include "zzz_hair_controls.inc"
#else
float ZzzHairControlledShadowOffsetX(float baseValue) { return baseValue; }
float ZzzHairControlledShadowOffsetY(float baseValue) { return baseValue; }
float ZzzHairControlledShadowLightInfluence(float baseValue) { return baseValue; }
float ZzzHairControlledShadowDepthBias(float baseValue) { return baseValue; }
float ZzzHairControlledShadowOpacity(float baseValue) { return baseValue; }
float3 ZzzHairControlledShadowColor(float3 baseValue) { return baseValue; }
#endif

float3 ZzzSafeNormalize(float3 value, float3 fallbackValue)
{
    float lengthSquared = dot(value, value);
    return lengthSquared < 1e-8
        ? fallbackValue
        : value * rsqrt(lengthSquared);
}

float3 ZzzSrgbToLinear(float3 color)
{
    return pow(saturate(color), 2.2);
}

float3 ZzzLinearToSrgb(float3 color)
{
    return pow(max(color, 0.0), 1.0 / 2.2);
}

float4 ZzzSampleBase(float2 uv, bool useTexture)
{
    float4 color = saturate(ZzzMaterialDiffuse);
    if (useTexture) {
        float4 texel = tex2D(ZzzDiffuseSampler, uv);
        color.rgb *= ZzzSrgbToLinear(texel.rgb);
        color.a *= texel.a;
    }
    return color;
}

float4 ZzzSampleNormalData(float2 uv)
{
    return tex2D(ZzzNormalSampler, uv);
}

float4 ZzzSampleMaterialData(float2 uv)
{
    return tex2D(ZzzMaterialSampler, uv);
}

float4 ZzzSampleAttributeData(float2 uv)
{
    return tex2D(ZzzAttributeSampler, uv);
}

float3 ZzzReconstructNormal(
    float3 positionWS,
    float3 geometricNormalWS,
    float2 uv)
{
    float3 N = ZzzSafeNormalize(
        geometricNormalWS, float3(0.0, 1.0, 0.0));
    float3 dpdx = ddx(positionWS);
    float3 dpdy = ddy(positionWS);
    float2 duvdx = ddx(uv);
    float2 duvdy = ddy(uv);
    float determinant = duvdx.x * duvdy.y - duvdx.y * duvdy.x;
    float orientation = determinant < 0.0 ? -1.0 : 1.0;
    float3 tangent = (dpdx * duvdy.y - dpdy * duvdx.y) * orientation;
    float3 bitangent = (dpdy * duvdx.x - dpdx * duvdy.x) * orientation;
    float3 T = ZzzSafeNormalize(tangent, float3(1.0, 0.0, 0.0));
    float3 B = ZzzSafeNormalize(bitangent, cross(N, T));
    float2 mapXY = (ZzzSampleNormalData(uv).rg * 2.0 - 1.0) * 0.85;
    float mapZ = sqrt(1.0 - min(dot(mapXY, mapXY), 1.0));
    return ZzzSafeNormalize(T * mapXY.x + B * mapXY.y + N * mapZ, N);
}

float ZzzDiffuseBias(float2 uv)
{
    return (ZzzSampleNormalData(uv).b * 2.0 - 1.0) * 2.0;
}

float ZzzHgShadowDensity()
{
    return max(
        (degrees(ZzzHgShadowRotation)
            + 5.0 * ZzzHgShadowDensityUp + 1.0)
            * (1.0 - ZzzHgShadowDensityDown),
        0.0);
}

float ZzzToonAttenuation(
    float3 normalWS,
    float3 lightDirectionWS,
    float bias)
{
    float lambert = saturate(dot(normalWS, lightDirectionWS) + bias);
    return smoothstep(
        ZzzToonThreshold - ZzzToonSoftness,
        ZzzToonThreshold + ZzzToonSoftness,
        lambert);
}

float3 ZzzShadeBase(
    float4 baseColor,
    float3 normalWS,
    float shadowVisibility,
    float bias)
{
    float3 L = ZzzSafeNormalize(
        -ZzzLightDirection, float3(0.0, 1.0, 0.0));
#if ZZZ_HAIR_FULL_CONTROLLER != 0
    float toonThreshold = ZzzToonThreshold;
    float toonSoftness = ZzzToonSoftness;
    toonThreshold = ZzzHairControlledToonThreshold();
    toonSoftness = ZzzHairControlledToonSoftness();
    float lambert = saturate(dot(normalWS, L) + bias);
    float attenuation = smoothstep(
        toonThreshold - toonSoftness,
        toonThreshold + toonSoftness,
        lambert)
        * shadowVisibility;
    float3 shadowColor = baseColor.rgb * pow(
        float3(0.55, 0.58, 0.68),
        ZzzHairControlledShadowStrength());
#else
    float attenuation = ZzzToonAttenuation(normalWS, L, bias)
        * shadowVisibility;
    float3 shadowColor = baseColor.rgb * float3(0.55, 0.58, 0.68);
#endif
    return lerp(shadowColor, baseColor.rgb, attenuation);
}

void ZzzGetHeadData(
    out float3 centerWS,
    out float3 headUp,
    out float3 headFront)
{
    float3 rightAxis = -ZzzSafeNormalize(
        ZzzHeadBone._11_12_13, float3(1.0, 0.0, 0.0));
    headFront = -ZzzSafeNormalize(
        ZzzHeadBone._31_32_33, float3(0.0, 0.0, 1.0));
    headUp = ZzzSafeNormalize(
        cross(headFront, rightAxis), float3(0.0, 1.0, 0.0));
    centerWS = ZzzHeadBone._41_42_43
        + headUp * ZzzHeadCenterUp
        + headFront * ZzzHeadCenterForward;
#if ZZZ_HAIR_FULL_CONTROLLER != 0
    centerWS += headUp * ZzzHairControlledHighlightOffset();
#endif
}

struct ZzzSpecularResult {
    float authoredMask;
    float shapeMask;
    float shadowTerm;
    float viewGate;
    float centerNoV3;
    float centerNoV5;
    float3 color;
};

ZzzSpecularResult ZzzEvaluateSpecular(
    float3 positionWS,
    float3 normalWS,
    float3 viewDirectionWS,
    float2 uv,
    float3 shadedBaseColor,
    float shadowVisibility)
{
    ZzzSpecularResult result;
    float4 materialData = ZzzSampleMaterialData(uv);
    float4 attributeData = ZzzSampleAttributeData(uv);
    float4 normalData = ZzzSampleNormalData(uv);
    float3 N = ZzzSafeNormalize(normalWS, float3(0.0, 1.0, 0.0));
    float3 V = ZzzSafeNormalize(viewDirectionWS, N);
    float3 L = ZzzSafeNormalize(
        -ZzzLightDirection, float3(0.0, 1.0, 0.0));
    float3 H = ZzzSafeNormalize(L + V, N);

    float decodedId = max(
        4.0 - floor(saturate(materialData.r) * 5.0), 0.0);
    float w1 = 1.0 - step(0.5, decodedId);
    float w2 = step(0.5, decodedId) * (1.0 - step(1.5, decodedId));
    float w3 = step(1.5, decodedId) * (1.0 - step(2.5, decodedId));
    float w4 = step(2.5, decodedId) * (1.0 - step(3.5, decodedId));
    float w5 = step(3.5, decodedId);
    float highlightShape =
        ZZZ_HAIR_HIGHLIGHT_SHAPE_1 * w1
        + ZZZ_HAIR_HIGHLIGHT_SHAPE_2 * w2
        + ZZZ_HAIR_HIGHLIGHT_SHAPE_3 * w3
        + ZZZ_HAIR_HIGHLIGHT_SHAPE_4 * w4
        + ZZZ_HAIR_HIGHLIGHT_SHAPE_5 * w5;
    float shapeEnabled = step(0.5, highlightShape);

    result.authoredMask = saturate(materialData.b);
    float visibility = saturate(shadowVisibility);
    float aoTex = saturate(normalData.b) * visibility;
    aoTex = aoTex * 2.0 - 1.0;
    float rawShadow = aoTex * 2.0 + dot(N, L) * visibility;
    result.shadowTerm = saturate(rawShadow * 1.5 + 0.5);

    float3 headCenterWS;
    float3 headUp;
    float3 headFront;
    ZzzGetHeadData(headCenterWS, headUp, headFront);

    // Horizontal head-space visibility. Camera pitch is deliberately removed,
    // so looking up/down does not hide the highlight. Only left/right orbit
    // controls the fade from front view to side/back view.
    float3 headToCamera = ZzzCameraPosition - headCenterWS;
    float3 horizontalView = headToCamera
        - headUp * dot(headToCamera, headUp);
    horizontalView = ZzzSafeNormalize(horizontalView, headFront);
    float frontView = dot(horizontalView, headFront);
    result.viewGate = smoothstep(
        min(ZzzViewGateZero, ZzzViewGateFull - 0.001),
        max(ZzzViewGateFull, ZzzViewGateZero + 0.001),
        frontView);

    float3 centerToPixel = positionWS - headCenterWS;
    float distanceToCenter = length(centerToPixel);
    float sphereBlend = 1.0 - saturate(
        (distanceToCenter - max(ZzzHeadSphereRadius, 0.0))
        / max(ZzzHeadSphereTransition, 0.01));
    float3 sphereNormal = ZzzSafeNormalize(centerToPixel, N);
    float3 shapeNormal = ZzzSafeNormalize(
        lerp(N, sphereNormal, sphereBlend), N);
    // Per-pixel front-facing limiter. Unlike viewGate, this varies across
    // the head surface, suppressing both sides while retaining the center.
    float centerNoV = saturate(dot(shapeNormal, V));
    result.centerNoV3 = centerNoV * centerNoV * centerNoV;
    result.centerNoV5 = result.centerNoV3 * centerNoV * centerNoV;
    float shapeWeight = sqrt(saturate(dot(L, shapeNormal) * 0.5 + 0.5));
    float biasedNdotH = saturate(dot(shapeNormal, H) * 0.5 + 0.5);
    float shapeEdge = 1.0 - biasedNdotH * shapeWeight;
#if ZZZ_HAIR_FULL_CONTROLLER != 0
    result.shapeMask = saturate(
        (result.authoredMask - shapeEdge)
        / max(ZzzHairControlledShapeSoftness(), 0.0001));
#else
    result.shapeMask = saturate(
        (result.authoredMask - shapeEdge)
        / max(ZzzShapeSoftness, 0.0001));
#endif

    result.shapeMask *= shapeEnabled;

    float metallic = saturate(materialData.g);
    float smoothness = saturate(attributeData.g);
    float3 baseColor = saturate(shadedBaseColor);
    float3 reflectance = lerp(0.04.xxx, baseColor, metallic);
    float3 specularColor =
        ZZZ_HAIR_SPECULAR_COLOR_1 * w1
        + ZZZ_HAIR_SPECULAR_COLOR_2 * w2
        + ZZZ_HAIR_SPECULAR_COLOR_3 * w3
        + ZZZ_HAIR_SPECULAR_COLOR_4 * w4
        + ZZZ_HAIR_SPECULAR_COLOR_5 * w5;
    float toonSpecular =
        ZZZ_HAIR_TOON_SPECULAR_1 * w1
        + ZZZ_HAIR_TOON_SPECULAR_2 * w2
        + ZZZ_HAIR_TOON_SPECULAR_3 * w3
        + ZZZ_HAIR_TOON_SPECULAR_4 * w4
        + ZZZ_HAIR_TOON_SPECULAR_5 * w5;
    float modelSize =
        ZZZ_HAIR_MODEL_SIZE_1 * w1
        + ZZZ_HAIR_MODEL_SIZE_2 * w2
        + ZZZ_HAIR_MODEL_SIZE_3 * w3
        + ZZZ_HAIR_MODEL_SIZE_4 * w4
        + ZZZ_HAIR_MODEL_SIZE_5 * w5;

    float rangeNdotL = saturate(dot(N, L) * 0.75 + 0.25);
    float rangeNdotH = saturate(dot(N, H) * 0.75 + 0.25);
    float rangeLdotH = max(0.1, saturate(dot(L, H) * 0.75 + 0.25));
    float shapeLobe = min(1.0, 0.166663334 / rangeLdotH)
        * rangeNdotL * 100.0;

    float roughness = max(1.0 - smoothness, 0.00001);
    float roughnessSq = roughness * roughness;
    float roughnessFourth = roughnessSq * roughnessSq;
    float distributionDenominator =
        rangeNdotH * rangeNdotH * (roughnessFourth - 1.0)
        + 1.00001001;
    distributionDenominator *= distributionDenominator;
    distributionDenominator *= max(0.1, rangeLdotH * rangeLdotH);
    distributionDenominator *= roughnessSq * 4.0 + 2.0;
    float distribution = roughnessFourth
        / max(distributionDenominator, 0.00001);
    float standardLobe = saturate(distribution - smoothness)
        * rangeNdotL / max(roughnessSq, 0.00001)
        * max(toonSpecular, 0.0)
        * max(modelSize, 0.0);
    standardLobe = saturate(standardLobe * 10.0) * 100.0;

    float specularMask = lerp(
        result.authoredMask, result.shapeMask, shapeEnabled);
    float specularLobe = lerp(standardLobe, shapeLobe, shapeEnabled);
    result.color = specularMask
        * (max(ZzzSpecularIntensity, 0.0) * 10.0)
        * (specularColor * 0.5)
        * reflectance
        * specularLobe
        * baseColor
        * visibility;
    return result;
}

struct ZzzAttributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord0 : TEXCOORD0;
    float4 texcoord1 : TEXCOORD1;
};

struct ZzzVaryings {
    float4 positionCS : POSITION;
    float4 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 geometricNormalWS : TEXCOORD2;
    float3 viewDirectionWS : TEXCOORD3;
    float4 screenPosition : TEXCOORD4;
};

#if ZZZ_HAIR_FACE_SHADOW_PASS != 0
float4x4 ZzzHairShadowView : VIEW;
float4x4 ZzzHairShadowProjection : PROJECTION;

float ZzzHairShadowOffsetX <
    string UIName = "发影偏移X";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 0.2;
> = ZZZ_HAIR_SHADOW_OFFSET_X_DEFAULT;

float ZzzHairShadowOffsetY <
    string UIName = "发影偏移Y";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 0.2;
> = ZZZ_HAIR_SHADOW_OFFSET_Y_DEFAULT;

float ZzzHairShadowLightInfluence <
    string UIName = "发影受光影响";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = 1.0;

float ZzzHairShadowDepthBias <
    string UIName = "发影深度偏移";
    string UIWidget = "Slider";
    float UIMin = -0.2;
    float UIMax = 0.2;
> = 0.0;

float ZzzHairShadowOpacity <
    string UIName = "发影不透明度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = ZZZ_HAIR_SHADOW_OPACITY_DEFAULT;

float3 ZzzHairShadowColor <
    string UIName = "发影颜色";
    string UIWidget = "Color";
> = ZZZ_HAIR_SHADOW_COLOR_DEFAULT;

float ZzzHairShadowPitchMin <
    string UIName = "发影俯仰结束";
    string UIWidget = "Slider";
    float UIMin = -1.0;
    float UIMax = 1.0;
> = -0.25;

float ZzzHairShadowPitchMax <
    string UIName = "发影俯仰结束";
    string UIWidget = "Slider";
    float UIMin = -1.0;
    float UIMax = 1.0;
> = 0.65;

struct ZzzHairFaceShadowVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
};

ZzzHairFaceShadowVaryings ZzzHairFaceShadowVS(ZzzAttributes input)
{
    ZzzHairFaceShadowVaryings output = (ZzzHairFaceShadowVaryings)0;
    float3 positionWS = mul(input.positionOS, ZzzWorld).xyz;
    float3 positionVS = mul(
        float4(positionWS, 1.0), ZzzHairShadowView).xyz;
    float3 lightVS = ZzzSafeNormalize(
        mul(-ZzzLightDirection, (float3x3)ZzzHairShadowView),
        float3(0.0, 0.70710678, -0.70710678));
    float lightX = clamp(lightVS.x, -1.0, 1.0);
    float3 headOriginWS = ZzzHeadBone._41_42_43;
    float3 headUpWS = ZzzSafeNormalize(
        ZzzHeadBone._21_22_23, float3(0.0, 1.0, 0.0));
    float3 cameraToHeadWS = ZzzSafeNormalize(
        ZzzCameraPosition - headOriginWS,
        float3(0.0, 0.0, -1.0));
    float pitch = 1.0 - smoothstep(
        ZzzHairShadowPitchMin,
        ZzzHairShadowPitchMax,
        dot(cameraToHeadWS, headUpWS));
    positionVS.x -= lightX
        * ZzzHairControlledShadowOffsetX(ZzzHairShadowOffsetX)
        * ZzzHairControlledShadowLightInfluence(ZzzHairShadowLightInfluence);
    positionVS.y -= ZzzHairControlledShadowOffsetY(ZzzHairShadowOffsetY) * pitch;
    positionVS.z -= ZzzHairControlledShadowDepthBias(ZzzHairShadowDepthBias);
    output.positionCS = mul(
        float4(positionVS, 1.0), ZzzHairShadowProjection);
    output.uv = input.texcoord0;
    return output;
}

float4 ZzzHairFaceShadowPS(
    ZzzHairFaceShadowVaryings input,
    uniform bool useTexture) : COLOR0
{
    float coverage = saturate(ZzzMaterialDiffuse.a);
    if (useTexture) {
        coverage *= tex2D(ZzzDiffuseSampler, input.uv).a;
    }
    clip(coverage - ZZZ_ALPHA_CUTOFF);
    return float4(
        ZzzHairControlledShadowColor(saturate(ZzzHairShadowColor)),
        saturate(coverage * ZzzHairControlledShadowOpacity(ZzzHairShadowOpacity)));
}

#define ZZZ_HAIR_FACE_SHADOW_PASS_BLOCK(useTextureValue) \
    pass DrawHairFaceShadow { \
        ZEnable = true; ZWriteEnable = false; \
        ZFunc = LESSEQUAL; CullMode = NONE; \
        AlphaTestEnable = false; AlphaBlendEnable = true; \
        SrcBlend = SRCALPHA; DestBlend = INVSRCALPHA; \
        BlendOp = ADD; ColorWriteEnable = 15; \
        StencilEnable = true; StencilFunc = EQUAL; \
        StencilRef = 1; StencilMask = 5; \
        StencilWriteMask = 4; StencilFail = KEEP; \
        StencilZFail = KEEP; StencilPass = INVERT; \
        VertexShader = compile vs_3_0 ZzzHairFaceShadowVS(); \
        PixelShader = compile ps_3_0 ZzzHairFaceShadowPS( \
            useTextureValue); \
    }

#define ZZZ_HAIR_MAIN_STENCIL_STATES \
    StencilEnable = true; StencilFunc = ALWAYS; \
    StencilRef = 2; StencilWriteMask = 2; \
    StencilFail = KEEP; StencilZFail = KEEP; \
    StencilPass = REPLACE;
#else
#define ZZZ_HAIR_FACE_SHADOW_PASS_BLOCK(useTextureValue)
#define ZZZ_HAIR_MAIN_STENCIL_STATES
#endif

#if ZZZ_HAIR_FACE_SHADOW_PASS != 0
#define ZZZ_HAIR_SCRIPT_RIM \
    "RenderColorTarget0=;Pass=DrawHairFaceShadow;Pass=DrawObject;Pass=DrawHairRim;"
#define ZZZ_HAIR_SCRIPT_MAIN \
    "RenderColorTarget0=;Pass=DrawHairFaceShadow;Pass=DrawObject;"
#define ZZZ_HAIR_SCRIPT_LAYERED \
    "RenderColorTarget0=;Pass=DrawHairFaceShadow;Pass=DrawObject;Pass=IndependentHighlight;"
#else
#define ZZZ_HAIR_SCRIPT_RIM \
    "RenderColorTarget0=;Pass=DrawObject;Pass=DrawHairRim;"
#define ZZZ_HAIR_SCRIPT_MAIN \
    "RenderColorTarget0=;Pass=DrawObject;"
#define ZZZ_HAIR_SCRIPT_LAYERED \
    "RenderColorTarget0=;Pass=DrawObject;Pass=IndependentHighlight;"
#endif

ZzzVaryings ZzzVS(ZzzAttributes input)
{
    ZzzVaryings output = (ZzzVaryings)0;
    output.positionCS = mul(input.positionOS, ZzzWorldViewProjection);
    output.positionWS = mul(input.positionOS, ZzzWorld).xyz;
    output.geometricNormalWS = ZzzSafeNormalize(
        mul(input.normalOS, (float3x3)ZzzWorld),
        float3(0.0, 1.0, 0.0));
    output.viewDirectionWS = ZzzCameraPosition - output.positionWS;
    output.uv = float4(input.texcoord0, input.texcoord1.xy);
    output.screenPosition = output.positionCS;
    return output;
}

#if ZZZ_HAIR_ZZZSHADOW_RIM != 0
#include "zzz_hair_zzzshadow_rim.hlsl"
#endif

float ZzzSampleHgShadow(float4 screenPosition, bool useSelfShadow)
{
    if (!useSelfShadow || !ZzzHgShadowValid
        || abs(screenPosition.w) < 1e-6) {
        return 1.0;
    }
    float2 ndc = screenPosition.xy / screenPosition.w;
    float2 uv = float2((1.0 + ndc.x) * 0.5, (1.0 - ndc.y) * 0.5);
    uv += 0.5 / max(ZzzHgShadowViewportSize, 1.0);
#if ZZZ_HAIR_ZZZSHADOW_RIM != 0
    float shadowAmount = saturate(
        tex2D(ZzzShadowViewportSampler, uv).r);
#else
    float shadowAmount = saturate(tex2D(ZzzHgShadowSampler, uv).r);
#endif
    float visibility = 1.0 - shadowAmount;
    return 1.0 - (1.0 - visibility)
        * min(ZzzHgShadowDensity(), 1.0);
}

float4 ZzzHairTestPS(
    ZzzVaryings input,
    float facing : VFACE,
    uniform bool useTexture,
    uniform bool useSelfShadow) : COLOR0
{
    float2 uv = input.uv.xy;
    float4 baseColor = ZzzSampleBase(uv, useTexture);
    clip(baseColor.a - ZZZ_ALPHA_CUTOFF);
    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 geometricNormalWS = ZzzSafeNormalize(
        input.geometricNormalWS, float3(0.0, 1.0, 0.0)) * faceSign;
    float3 normalWS = ZzzReconstructNormal(
        input.positionWS, geometricNormalWS, uv);
    float3 viewDirectionWS = ZzzSafeNormalize(
        input.viewDirectionWS, geometricNormalWS);
    float shadowVisibility = ZzzSampleHgShadow(
        input.screenPosition, useSelfShadow);
#if ZZZ_HAIR_INDEPENDENT_HIGHLIGHT != 0
    // Independent diagnostic layer: the frozen base/shadow pipeline is not
    // evaluated into the output, and the highlight color is not attenuated by
    // baseColor or HgShadow. Only the authored/analytic shape and NoV mask
    // are retained for this pass.
    ZzzSpecularResult specular = ZzzEvaluateSpecular(
        input.positionWS,
        normalWS,
        viewDirectionWS,
        uv,
        1.0.xxx,
        1.0);
    float3 independentTint = 1.0.xxx;
#if ZZZ_HAIR_FULL_CONTROLLER != 0
    independentTint = ZzzHairControlledHighlightColor();
#endif
    float3 independentColor = specular.shapeMask.xxx
        * specular.centerNoV5
        * independentTint
        * max(ZZZ_HAIR_INDEPENDENT_GAIN, 0.0);
    return float4(
        ZzzLinearToSrgb(max(independentColor, 0.0)),
        saturate(specular.shapeMask * specular.centerNoV5));
#else
    float3 baseLit = ZzzShadeBase(
        baseColor, normalWS, shadowVisibility, ZzzDiffuseBias(uv));
    ZzzSpecularResult specular = ZzzEvaluateSpecular(
        input.positionWS,
        normalWS,
        viewDirectionWS,
        uv,
        baseLit,
        shadowVisibility);

#if ZZZ_HAIR_TEST_VIEW == 1
    float3 color = specular.authoredMask.xxx;
#elif ZZZ_HAIR_TEST_VIEW == 2
    float3 color = specular.shapeMask.xxx;
#elif ZZZ_HAIR_TEST_VIEW == 3
    float3 color = specular.shadowTerm.xxx;
#elif ZZZ_HAIR_TEST_VIEW == 4
    float3 color = specular.color * max(ZzzSpecularDebugGain, 1.0);
#elif ZZZ_HAIR_TEST_VIEW == 6
    float3 color = specular.viewGate.xxx
        * ZZZ_HAIR_VIEW_GATE_GAIN;
#elif ZZZ_HAIR_TEST_VIEW == 8
    float3 color = specular.centerNoV3.xxx;
#elif ZZZ_HAIR_TEST_VIEW == 9
    float3 color = specular.centerNoV5.xxx;
#else
#if ZZZ_HAIR_FULL_CONTROLLER != 0
    float centerMask = pow(
        max(specular.centerNoV3, 1e-6),
        max(ZzzHairControlledCenterPower(), 0.001) / 3.0);
#else
    float centerMask = pow(
        max(specular.centerNoV3, 1e-6),
        max(ZZZ_HAIR_CENTER_POWER, 0.001) / 3.0);
#endif
    float3 gatedSpecular = specular.color
        * (ZZZ_HAIR_APPLY_VIEW_GATE != 0
            ? specular.viewGate
            : 1.0)
        * (ZZZ_HAIR_APPLY_CENTER_MASK != 0
            ? centerMask
            : 1.0);
    float compositeGain = ZZZ_HAIR_COMPOSITE_GAIN_OVERRIDE >= 0.0
        ? ZZZ_HAIR_COMPOSITE_GAIN_OVERRIDE
        : ZzzSpecularCompositeGain;
#if ZZZ_HAIR_FULL_CONTROLLER != 0
    float3 color = ZzzHairAdjustBaseColor(baseLit)
        + gatedSpecular * max(compositeGain, 0.0)
            * ZzzHairControlledHighlightStrength()
            * ZzzHairControlledHighlightColor();
#else
    float3 color = baseLit
        + gatedSpecular * max(compositeGain, 0.0);
#endif
#endif

    return float4(ZzzLinearToSrgb(max(color, 0.0)), saturate(baseColor.a));
#endif
}

float4 ZzzHairFrozenBasePS(
    ZzzVaryings input,
    float facing : VFACE,
    uniform bool useTexture,
    uniform bool useSelfShadow) : COLOR0
{
    float2 uv = input.uv.xy;
    float4 baseColor = ZzzSampleBase(uv, useTexture);
    clip(baseColor.a - ZZZ_ALPHA_CUTOFF);
    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 geometricNormalWS = ZzzSafeNormalize(
        input.geometricNormalWS, float3(0.0, 1.0, 0.0)) * faceSign;
    float3 normalWS = ZzzReconstructNormal(
        input.positionWS, geometricNormalWS, uv);
    float shadowVisibility = ZzzSampleHgShadow(
        input.screenPosition, useSelfShadow);
    float3 baseLit = ZzzShadeBase(
        baseColor, normalWS, shadowVisibility, ZzzDiffuseBias(uv));
    return float4(
        ZzzLinearToSrgb(max(baseLit, 0.0)),
        saturate(baseColor.a));
}

float4 ZzzHairIndependentHighlightPS(
    ZzzVaryings input,
    float facing : VFACE,
    uniform bool useTexture,
    uniform bool useSelfShadow) : COLOR0
{
    float2 uv = input.uv.xy;
    float4 baseColor = ZzzSampleBase(uv, useTexture);
    clip(baseColor.a - ZZZ_ALPHA_CUTOFF);
    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 geometricNormalWS = ZzzSafeNormalize(
        input.geometricNormalWS, float3(0.0, 1.0, 0.0)) * faceSign;
    float3 normalWS = ZzzReconstructNormal(
        input.positionWS, geometricNormalWS, uv);
    float3 viewDirectionWS = ZzzSafeNormalize(
        input.viewDirectionWS, geometricNormalWS);
    ZzzSpecularResult specular = ZzzEvaluateSpecular(
        input.positionWS,
        normalWS,
        viewDirectionWS,
        uv,
        1.0.xxx,
        1.0);
    float highlightMask = specular.shapeMask * specular.centerNoV5;
    float3 highlightTint = 1.0.xxx;
#if ZZZ_HAIR_FULL_CONTROLLER != 0
    highlightTint = ZzzHairControlledHighlightColor();
#endif
    float3 highlightColor = highlightMask
        * highlightTint
        * max(ZZZ_HAIR_INDEPENDENT_GAIN, 0.0);
    return float4(
        ZzzLinearToSrgb(max(highlightColor, 0.0)),
        highlightMask);
}

#if ZZZ_HAIR_ZZZSHADOW_RIM != 0
#define ZZZ_HAIR_TEST_TECHNIQUE(name, passName, useTextureValue, shadowValue) \
    technique name < string MMDPass = passName; string Subset = ZZZ_HAIR_SUBSET; \
        string Script = ZZZ_HAIR_SCRIPT_RIM; \
        bool UseTexture = useTextureValue; bool UseSelfShadow = shadowValue; > { \
        ZZZ_HAIR_FACE_SHADOW_PASS_BLOCK(useTextureValue) \
        pass DrawObject { ZEnable = true; ZWriteEnable = true; ZFunc = LESSEQUAL; \
            CullMode = NONE; AlphaBlendEnable = false; AlphaTestEnable = false; \
            ZZZ_HAIR_MAIN_STENCIL_STATES \
            VertexShader = compile vs_3_0 ZzzVS(); \
            PixelShader = compile ps_3_0 ZzzHairTestPS( \
                useTextureValue, shadowValue); } \
        pass DrawHairRim { ZEnable = true; ZWriteEnable = false; \
            ZFunc = LESSEQUAL; CullMode = NONE; AlphaTestEnable = false; \
            AlphaBlendEnable = true; SrcBlend = ONE; DestBlend = ONE; \
            BlendOp = ADD; VertexShader = compile vs_3_0 ZzzVS(); \
            PixelShader = compile ps_3_0 ZzzHairZzzShadowRimPS( \
                useTextureValue); } }
#else
#define ZZZ_HAIR_TEST_TECHNIQUE(name, passName, useTextureValue, shadowValue) \
    technique name < string MMDPass = passName; string Subset = ZZZ_HAIR_SUBSET; \
        string Script = ZZZ_HAIR_SCRIPT_MAIN; \
        bool UseTexture = useTextureValue; bool UseSelfShadow = shadowValue; > { \
        ZZZ_HAIR_FACE_SHADOW_PASS_BLOCK(useTextureValue) \
        pass DrawObject { ZEnable = true; ZWriteEnable = true; ZFunc = LESSEQUAL; \
            CullMode = NONE; AlphaBlendEnable = false; AlphaTestEnable = false; \
            ZZZ_HAIR_MAIN_STENCIL_STATES \
            VertexShader = compile vs_3_0 ZzzVS(); \
            PixelShader = compile ps_3_0 ZzzHairTestPS( \
                useTextureValue, shadowValue); } }
#endif

#define ZZZ_HAIR_INDEPENDENT_TECHNIQUE(name, passName, useTextureValue, shadowValue) \
    technique name < string MMDPass = passName; string Subset = ZZZ_HAIR_SUBSET; \
        string Script = ZZZ_HAIR_SCRIPT_MAIN; \
        bool UseTexture = useTextureValue; bool UseSelfShadow = shadowValue; > { \
        ZZZ_HAIR_FACE_SHADOW_PASS_BLOCK(useTextureValue) \
        pass DrawObject { ZEnable = true; ZWriteEnable = false; ZFunc = LESSEQUAL; \
            CullMode = NONE; AlphaBlendEnable = true; SrcBlend = ONE; \
            ZZZ_HAIR_MAIN_STENCIL_STATES \
            DestBlend = ONE; BlendOp = ADD; AlphaTestEnable = false; \
            VertexShader = compile vs_3_0 ZzzVS(); \
            PixelShader = compile ps_3_0 ZzzHairTestPS( \
                useTextureValue, shadowValue); } }

#define ZZZ_HAIR_LAYERED_TECHNIQUE(name, passName, useTextureValue, shadowValue) \
    technique name < string MMDPass = passName; string Subset = ZZZ_HAIR_SUBSET; \
        string Script = ZZZ_HAIR_SCRIPT_LAYERED; \
        bool UseTexture = useTextureValue; bool UseSelfShadow = shadowValue; > { \
        ZZZ_HAIR_FACE_SHADOW_PASS_BLOCK(useTextureValue) \
        pass DrawObject { ZEnable = true; ZWriteEnable = true; ZFunc = LESSEQUAL; \
            CullMode = NONE; AlphaBlendEnable = false; AlphaTestEnable = false; \
            ZZZ_HAIR_MAIN_STENCIL_STATES \
            VertexShader = compile vs_3_0 ZzzVS(); \
            PixelShader = compile ps_3_0 ZzzHairFrozenBasePS( \
                useTextureValue, shadowValue); } \
        pass IndependentHighlight { ZEnable = true; ZWriteEnable = false; \
            ZFunc = LESSEQUAL; CullMode = NONE; AlphaBlendEnable = true; \
            SrcBlend = ONE; DestBlend = ONE; BlendOp = ADD; \
            AlphaTestEnable = false; VertexShader = compile vs_3_0 ZzzVS(); \
            PixelShader = compile ps_3_0 ZzzHairIndependentHighlightPS( \
                useTextureValue, shadowValue); } }

#if ZZZ_HAIR_INDEPENDENT_HIGHLIGHT != 0
ZZZ_HAIR_INDEPENDENT_TECHNIQUE(ZzzHairIndependentNoTexture, "object", false, false)
ZZZ_HAIR_INDEPENDENT_TECHNIQUE(ZzzHairIndependentTexture, "object", true, false)
ZZZ_HAIR_INDEPENDENT_TECHNIQUE(ZzzHairIndependentShadowNoTexture, "object_ss", false, true)
ZZZ_HAIR_INDEPENDENT_TECHNIQUE(ZzzHairIndependentShadowTexture, "object_ss", true, true)
#else
ZZZ_HAIR_TEST_TECHNIQUE(ZzzHairNoTexture, "object", false, false)
ZZZ_HAIR_TEST_TECHNIQUE(ZzzHairTexture, "object", true, false)
ZZZ_HAIR_TEST_TECHNIQUE(ZzzHairShadowNoTexture, "object_ss", false, true)
ZZZ_HAIR_TEST_TECHNIQUE(ZzzHairShadowTexture, "object_ss", true, true)
#endif

#if ZZZ_HAIR_LAYERED_HIGHLIGHT != 0
ZZZ_HAIR_LAYERED_TECHNIQUE(ZzzHairLayeredNoTexture, "object", false, false)
ZZZ_HAIR_LAYERED_TECHNIQUE(ZzzHairLayeredTexture, "object", true, false)
ZZZ_HAIR_LAYERED_TECHNIQUE(ZzzHairLayeredShadowNoTexture, "object_ss", false, true)
ZZZ_HAIR_LAYERED_TECHNIQUE(ZzzHairLayeredShadowTexture, "object_ss", true, true)
#endif

#endif
