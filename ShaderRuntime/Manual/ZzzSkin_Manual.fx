// ZZZ skin manual material. Edit only this public configuration block.
// Face and skin must share the same Ramp values.
#define ZZZ_SKIN_NORMAL_RESOURCE "../textures/common/neutral_normal.png"
#define ZZZ_SKIN_MATERIAL_RESOURCE "../textures/common/neutral_material.png"
#define ZZZ_SKIN_ATTRIBUTE_RESOURCE "../textures/common/neutral_attributes.png"
#define ZZZ_SKIN_SUBSET "0"

#include "Profiles/ZzzFaceSkin_Ramp_Manual.inc"
#include "../zzz_hgshadow_bridge.hlsl"
#include "../zzz_face_skin_ramp_shared.hlsl"
#include "../internal/zzz_face_skin_controls.inc"

float4x4 ZzzSkinWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 ZzzSkinWorld : WORLD;
float4x4 ZzzSkinView : VIEW;
float4x4 ZzzSkinProjection : PROJECTION;
float3 ZzzSkinLightDirection : DIRECTION < string Object = "Light"; >;
float4 ZzzSkinMaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;
float3 ZzzSkinCameraPosition : POSITION < string Object = "Camera"; >;

float ZzzSkinSpecularStrength <
    string UIName = "肌高光強";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 4.0;
> = 1.0;

float ZzzSkinSpecularRange <
    string UIName = "肌高光幅";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 4.0;
> = 1.0;

float ZzzSkinSpecularGlossiness <
    string UIName = "肌高光硬";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = 1.0;

bool ZzzSkinSpecularDebug <
    string UIName = "肌高光診断";
    string UIWidget = "CheckBox";
> = false;

float ZzzSkinRimStrength <
    string UIName = "肌辺光強";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = 0.28;

float ZzzSkinRimWidth <
    string UIName = "肌辺光幅";
    string UIWidget = "Slider";
    float UIMin = 0.05;
    float UIMax = 2.0;
> = 0.85;

float ZzzSkinRimContrast <
    string UIName = "肌辺光硬";
    string UIWidget = "Slider";
    float UIMin = 0.1;
    float UIMax = 4.0;
> = 1.20;

bool ZzzSkinRimDebug <
    string UIName = "肌辺光診断";
    string UIWidget = "CheckBox";
> = false;

texture2D ZzzSkinDiffuseTexture : MATERIALTEXTURE <
    string Format = "A8R8G8B8";
>;
sampler2D ZzzSkinDiffuseSampler = sampler_state {
    texture = <ZzzSkinDiffuseTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 8;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzSkinNormalMap1Texture <
    string ResourceName = ZZZ_SKIN_NORMAL_RESOURCE;
>;
sampler2D ZzzSkinNormalMap1Sampler = sampler_state {
    texture = <ZzzSkinNormalMap1Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzSkinNormalMap2Texture <
    string ResourceName = ZZZ_SKIN_NORMAL_RESOURCE;
>;
sampler2D ZzzSkinNormalMap2Sampler = sampler_state {
    texture = <ZzzSkinNormalMap2Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzSkinMaterialMap1Texture <
    string ResourceName = ZZZ_SKIN_MATERIAL_RESOURCE;
>;
sampler2D ZzzSkinMaterialMap1Sampler = sampler_state {
    texture = <ZzzSkinMaterialMap1Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzSkinMaterialMap2Texture <
    string ResourceName = ZZZ_SKIN_MATERIAL_RESOURCE;
>;
sampler2D ZzzSkinMaterialMap2Sampler = sampler_state {
    texture = <ZzzSkinMaterialMap2Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzSkinAuxiliaryMap1Texture <
    string ResourceName = ZZZ_SKIN_ATTRIBUTE_RESOURCE;
>;
sampler2D ZzzSkinAuxiliaryMap1Sampler = sampler_state {
    texture = <ZzzSkinAuxiliaryMap1Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzSkinAuxiliaryMap2Texture <
    string ResourceName = ZZZ_SKIN_ATTRIBUTE_RESOURCE;
>;
sampler2D ZzzSkinAuxiliaryMap2Sampler = sampler_state {
    texture = <ZzzSkinAuxiliaryMap2Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

float3 ZzzSkinSafeNormalize(float3 value, float3 fallbackValue)
{
    float lenSq = dot(value, value);
    return lenSq < 1e-8 ? fallbackValue : value * rsqrt(lenSq);
}

float3 ZzzSkinSrgbToLinear(float3 color)
{
    return pow(saturate(color), 2.2);
}

float3 ZzzSkinLinearToSrgb(float3 color)
{
    return pow(max(color, 0.0), 1.0 / 2.2);
}

float2 ZzzSkinSampleNormalXY(float2 uv, bool useMap1)
{
    float2 map1 = tex2D(ZzzSkinNormalMap1Sampler, uv).rg;
    float2 map2 = tex2D(ZzzSkinNormalMap2Sampler, uv).rg;
    return (useMap1 ? map1 : map2) * 2.0 - 1.0;
}

float3 ZzzSkinReconstructNormal(
    float3 positionWS,
    float3 geometricNormalWS,
    float2 uv,
    bool useMap1)
{
    float3 dpdx = ddx(positionWS);
    float3 dpdy = ddy(positionWS);
    float2 duvdx = ddx(uv);
    float2 duvdy = ddy(uv);
    float determinant = duvdx.x * duvdy.y - duvdx.y * duvdy.x;
    float orientation = determinant < 0.0 ? -1.0 : 1.0;
    float3 tangent = (dpdx * duvdy.y - dpdy * duvdx.y) * orientation;
    float3 bitangent = (dpdy * duvdx.x - dpdx * duvdy.x) * orientation;
    float3 tangentWS = ZzzSkinSafeNormalize(tangent, float3(1, 0, 0));
    float3 bitangentWS = ZzzSkinSafeNormalize(
        bitangent,
        cross(geometricNormalWS, tangentWS));
    float2 mapXY = ZzzSkinSampleNormalXY(uv, useMap1);
    float mapZ = sqrt(1.0 - min(dot(mapXY, mapXY), 1.0));
    return ZzzSkinSafeNormalize(
        tangentWS * mapXY.x
            + bitangentWS * mapXY.y
            + geometricNormalWS * mapZ,
        geometricNormalWS);
}

float4 ZzzSkinSampleMaterialData(float2 uv, bool useMap1)
{
    float4 map1 = tex2D(ZzzSkinMaterialMap1Sampler, uv);
    float4 map2 = tex2D(ZzzSkinMaterialMap2Sampler, uv);
    return useMap1 ? map1 : map2;
}

float4 ZzzSkinSampleAuxiliaryData(float2 uv, bool useMap1)
{
    float4 map1 = tex2D(ZzzSkinAuxiliaryMap1Sampler, uv);
    float4 map2 = tex2D(ZzzSkinAuxiliaryMap2Sampler, uv);
    return useMap1 ? map1 : map2;
}

float3 ZzzSkinDirectSpecular(
    float3 positionWS,
    float3 normalWS,
    float3 lightWS,
    float3 shadedLinear,
    float4 materialData,
    float4 auxiliaryData,
    float naturalLight,
    float projectedLight)
{
    float3 viewWS = ZzzSkinSafeNormalize(
        ZzzSkinCameraPosition - positionWS,
        float3(0, 0, 1));
    float3 halfWS = ZzzSkinSafeNormalize(lightWS + viewWS, viewWS);

    float ndotl = dot(normalWS, lightWS);
    float saturatedNdotL = saturate(ndotl);
    float halfLambert = ndotl * 0.5 + 0.5;
    float lightCurve =
        (halfLambert - saturatedNdotL) * 0.5 + saturatedNdotL;

    float3 color = max(shadedLinear, 0.0);
    float maxChannel = max(color.x, max(color.y, color.z));
    float3 normalizedColor = maxChannel > 1.0
        ? color / maxChannel
        : color;
    float luminance = dot(color, float3(0.29, 0.60, 0.11));
    float powerBase = luminance * 0.2875 + 1.4375;
    float colorPower = lightCurve * (1.0 - powerBase) + powerBase;
    float3 poweredColor = pow(saturate(normalizedColor), colorPower);
    float3 preparedColor = color
        + (poweredColor - color) * (0.5 + saturatedNdotL * 0.5);

    float metallic = saturate(materialData.g);
    float3 f0 = lerp(float3(0.04, 0.04, 0.04), preparedColor, metallic);
    float glossiness = saturate(
        ZzzSkinControlledGlossiness(ZzzSkinSpecularGlossiness));
    float smoothness = saturate(auxiliaryData.g);
    float roughness = max(1.0 - smoothness * glossiness, 0.00001);
    float roughnessSq = roughness * roughness;

    float specularRange = max(
        ZzzSkinControlledSpecularRange(ZzzSkinSpecularRange), 0.0);
    float noL = saturate(ndotl * specularRange * 0.75 + 0.25);
    float noH = saturate(
        dot(normalWS, halfWS) * specularRange * 0.75 + 0.25);
    float loH = saturate(
        dot(lightWS, halfWS) * specularRange * 0.75 + 0.25);
    float distributionDenominator =
        noH * noH * (roughnessSq - 1.0) + 1.00001001;
    distributionDenominator *= distributionDenominator;
    distributionDenominator *= max(0.1, loH * loH);
    distributionDenominator *= roughness * 4.0 + 2.0;
    float distribution = roughnessSq
        / max(distributionDenominator, 0.00001);

    // Jane Body Map2 skin uses HighlightShape=false, ToonSpecular=0.01,
    // ModelSize=2, SpecularColor=white, then HoyoToon applies skin * 0.1.
    float toonLobe = saturate(distribution - smoothness * glossiness);
    toonLobe *= noL / roughness;
    toonLobe *= 0.02;
    toonLobe = saturate(toonLobe * 10.0) * 100.0;

    float maskEnergy = saturate(materialData.b)
        * max(ZzzSkinControlledSpecularStrength(
            ZzzSkinSpecularStrength), 0.0);
    float3 specular = toonLobe
        * maskEnergy
        * 0.5
        * f0
        * color;
    float directVisibility = smoothstep(0.0, 0.15, ndotl)
        * saturate(naturalLight)
        * saturate(projectedLight);
    return max(specular, 0.0) * directVisibility * 0.1;
}

struct ZzzSkinAttributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord0 : TEXCOORD0;
};

struct ZzzSkinVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
    float4 screenPosition : TEXCOORD3;
};

ZzzSkinVaryings ZzzSkinVS(ZzzSkinAttributes input)
{
    ZzzSkinVaryings output = (ZzzSkinVaryings)0;
    output.positionCS = mul(input.positionOS, ZzzSkinWorldViewProjection);
    output.uv = input.texcoord0;
    output.positionWS = mul(input.positionOS, ZzzSkinWorld).xyz;
    output.normalWS = mul(input.normalOS, (float3x3)ZzzSkinWorld);
    output.screenPosition = output.positionCS;
    return output;
}

float4 ZzzSkinPS(
    ZzzSkinVaryings input,
    float facing : VFACE,
    uniform bool useTexture,
    uniform bool useSelfShadow,
    uniform bool useMap1) : COLOR0
{
    float4 materialColor = saturate(ZzzSkinMaterialDiffuse);
    float4 diffuseTexel = tex2D(ZzzSkinDiffuseSampler, input.uv);
    float3 baseSrgb = useTexture
        ? materialColor.rgb * diffuseTexel.rgb
        : materialColor.rgb;
    float outputAlpha = useTexture
        ? materialColor.a * diffuseTexel.a
        : materialColor.a;
    clip(outputAlpha - 0.001);

    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 geometricNormalWS = ZzzSkinSafeNormalize(
        input.normalWS * faceSign,
        float3(0, 1, 0));
    float3 normalWS = ZzzSkinReconstructNormal(
        input.positionWS,
        geometricNormalWS,
        input.uv,
        useMap1);
    float3 lightWS = ZzzSkinSafeNormalize(
        -ZzzSkinLightDirection,
        float3(0, 1, 0));
    float naturalLight = smoothstep(
        -0.05,
        0.05,
        dot(normalWS, lightWS));
    float projectedLight = ZZZ_EyeSampleHgShadow(
        input.screenPosition,
        useSelfShadow);
    float lightMask = min(naturalLight, projectedLight);

    float3 baseLinear = ZzzSkinSrgbToLinear(baseSrgb);
    float3 shadowLinear =
        baseLinear * ZZZ_FACE_SKIN_BASE_SHADOW_DEFAULT;
    float3 shadedLinear = lerp(shadowLinear, baseLinear, lightMask);
    shadedLinear = ZzzFaceSkinApplyRamp(
        shadedLinear,
        lightMask,
        ZzzFaceSkinControlledRampStrength(
            ZZZ_FACE_SKIN_RAMP_STRENGTH_DEFAULT),
        ZzzFaceSkinControlledRampSmoothness(
            ZZZ_FACE_SKIN_RAMP_SMOOTHNESS_DEFAULT),
        ZZZ_FACE_SKIN_SHALLOW_COLOR_DEFAULT,
        ZZZ_FACE_SKIN_SHADOW_COLOR_DEFAULT);

    float4 materialData = ZzzSkinSampleMaterialData(input.uv, useMap1);
    float4 auxiliaryData = ZzzSkinSampleAuxiliaryData(input.uv, useMap1);
    float3 specularLinear = ZzzSkinDirectSpecular(
        input.positionWS,
        normalWS,
        lightWS,
        shadedLinear,
        materialData,
        auxiliaryData,
        naturalLight,
        projectedLight);
    if (ZzzSkinSpecularDebug) {
        float specularEnergy = max(
            specularLinear.x,
            max(specularLinear.y, specularLinear.z));
        float debugMask = 1.0 - exp2(-specularEnergy * 128.0);
        return float4(debugMask.xxx, 1.0);
    }
    if (ZzzSkinRimDebug) {
        return float4(0.0, 0.0, 0.0, saturate(outputAlpha));
    }
    float3 finalLinear = shadedLinear + specularLinear;

    return float4(
        ZzzSkinLinearToSrgb(max(finalLinear, 0.0)),
        saturate(outputAlpha));
}

float2 ZzzSkinScreenRimViewportUv(float4 clipPosition)
{
    float2 ndc = clipPosition.xy / clipPosition.w;
    float2 uv = float2(
        (1.0 + ndc.x) * 0.5,
        (1.0 - ndc.y) * 0.5);
    return uv + 0.5 / max(ZZZ_EyeHgShadowViewportSize, 1.0);
}

float ZzzSkinScreenDepthRim(
    float3 positionWS,
    float3 geometryNormalWS,
    float4 screenPosition)
{
    if (!ZZZ_EyeHgShadowValid || abs(screenPosition.w) < 1e-6) {
        return 0.0;
    }

    float3 positionVS = mul(
        float4(positionWS, 1.0), ZzzSkinView).xyz;
    float3 normalVS = ZzzSkinSafeNormalize(
        mul(geometryNormalWS, (float3x3)ZzzSkinView),
        float3(0, 0, 1));
    float width = max(ZzzSkinControlledRimWidth(ZzzSkinRimWidth), 0.05);
    float3 rimOffsetVS = float3(
        normalVS.x * 0.028 * width,
        normalVS.y * 0.018 * width,
        0.0);
    float4 offsetClip = mul(
        float4(positionVS + rimOffsetVS, 1.0),
        ZzzSkinProjection);
    if (abs(offsetClip.w) < 1e-6) {
        return 0.0;
    }

    float centerDepth = tex2D(
        ZZZ_EyeHgShadowSampler,
        ZzzSkinScreenRimViewportUv(screenPosition)).g;
    float offsetDepth = tex2D(
        ZZZ_EyeHgShadowSampler,
        ZzzSkinScreenRimViewportUv(offsetClip)).g;
    return saturate((offsetDepth - centerDepth) * 0.8);
}

float4 ZzzSkinScreenRimPS(
    ZzzSkinVaryings input,
    float facing : VFACE) : COLOR0
{
    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 normalWS = ZzzSkinSafeNormalize(
        input.normalWS * faceSign,
        float3(0, 1, 0));
    float depthRim = ZzzSkinScreenDepthRim(
        input.positionWS,
        input.normalWS,
        input.screenPosition);
    float3 viewWS = ZzzSkinSafeNormalize(
        ZzzSkinCameraPosition - input.positionWS,
        normalWS);
    float3 lightWS = ZzzSkinSafeNormalize(
        -ZzzSkinLightDirection,
        float3(0, 1, 0));
    float fresnel = pow(
        saturate(1.0 - dot(normalWS, viewWS)),
        3.0);
    float lightMask = smoothstep(
        -0.10,
        0.50,
        dot(normalWS, lightWS));
    float rimMask = saturate(depthRim * fresnel * lightMask);
    rimMask = pow(
        rimMask,
        max(ZzzSkinControlledRimContrast(ZzzSkinRimContrast), 0.001));
    float3 rimColor = float3(1.0, 0.830770552, 0.791298389)
        * max(ZzzSkinControlledRimStrength(ZzzSkinRimStrength), 0.0)
        * rimMask;
    return float4(rimColor, 0.0);
}

#define ZZZ_SKIN_OBJECT_SCRIPT \
    "RenderColorTarget0=;Pass=DrawObject;Pass=DrawSkinScreenRim;"

#define ZZZ_SKIN_RIM_PASS \
    pass DrawSkinScreenRim { \
        ZEnable = true; \
        ZWriteEnable = false; \
        ZFunc = LESSEQUAL; \
        CullMode = NONE; \
        AlphaTestEnable = false; \
        AlphaBlendEnable = true; \
        SrcBlend = ONE; \
        DestBlend = ONE; \
        BlendOp = ADD; \
        VertexShader = compile vs_3_0 ZzzSkinVS(); \
        PixelShader = compile ps_3_0 ZzzSkinScreenRimPS(); \
    }

#define ZZZ_SKIN_TECHNIQUE( \
    name, passName, subsetValue, useTextureValue, \
    useSelfShadowValue, useMap1Value) \
    technique name < \
        string MMDPass = passName; \
        string Subset = subsetValue; \
        string Script = ZZZ_SKIN_OBJECT_SCRIPT; \
        bool UseTexture = useTextureValue; \
        bool UseSelfShadow = useSelfShadowValue; \
    > { \
        pass DrawObject { \
            ZEnable = true; \
            ZWriteEnable = true; \
            CullMode = NONE; \
            AlphaBlendEnable = false; \
            AlphaTestEnable = false; \
            VertexShader = compile vs_3_0 ZzzSkinVS(); \
            PixelShader = compile ps_3_0 ZzzSkinPS( \
                useTextureValue, useSelfShadowValue, useMap1Value); \
        } \
        ZZZ_SKIN_RIM_PASS \
    }

ZZZ_SKIN_TECHNIQUE(ZzzSkinManualNoTexture, "object", ZZZ_SKIN_SUBSET, false, false, true)
ZZZ_SKIN_TECHNIQUE(ZzzSkinManualTexture, "object", ZZZ_SKIN_SUBSET, true, false, true)
ZZZ_SKIN_TECHNIQUE(ZzzSkinManualShadowNoTexture, "object_ss", ZZZ_SKIN_SUBSET, false, true, true)
ZZZ_SKIN_TECHNIQUE(ZzzSkinManualShadowTexture, "object_ss", ZZZ_SKIN_SUBSET, true, true, true)
