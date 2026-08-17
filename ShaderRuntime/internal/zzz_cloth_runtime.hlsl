// Generic cloth base/shadows plus independent direct specular and five-slot
// MatCap. Generated material FX files override all resource macros below.

#ifndef ZZZ_CLOTH_NORMAL_RESOURCE
#define ZZZ_CLOTH_NORMAL_RESOURCE "textures/common/neutral_normal.png"
#endif
#ifndef ZZZ_CLOTH_MATERIAL_RESOURCE
#define ZZZ_CLOTH_MATERIAL_RESOURCE "textures/common/neutral_material.png"
#endif
#ifndef ZZZ_CLOTH_AUX_RESOURCE
#define ZZZ_CLOTH_AUX_RESOURCE "textures/common/neutral_attributes.png"
#endif
#ifndef ZZZ_CLOTH_USE_JSON_MATCAP
#define ZZZ_CLOTH_USE_JSON_MATCAP 0
#endif
#ifndef ZZZ_CLOTH_MATCAP_STRENGTH_DEFAULT
#define ZZZ_CLOTH_MATCAP_STRENGTH_DEFAULT 1.0
#endif
#ifndef ZZZ_CLOTH_BRIGHTNESS_DEFAULT
#define ZZZ_CLOTH_BRIGHTNESS_DEFAULT 1.0
#endif
#ifndef ZZZ_CLOTH_NORMAL_STRENGTH_DEFAULT
#define ZZZ_CLOTH_NORMAL_STRENGTH_DEFAULT 1.0
#endif
#ifndef ZZZ_CLOTH_SHADOW_NORMAL_DEFAULT
#define ZZZ_CLOTH_SHADOW_NORMAL_DEFAULT 0.45
#endif
#ifndef ZZZ_CLOTH_SHADOW_BIAS_DEFAULT
#define ZZZ_CLOTH_SHADOW_BIAS_DEFAULT 0.0
#endif
#ifndef ZZZ_CLOTH_SHADOW_SOFTNESS_DEFAULT
#define ZZZ_CLOTH_SHADOW_SOFTNESS_DEFAULT 0.05
#endif
#ifndef ZZZ_CLOTH_RAMP_STRENGTH_DEFAULT
#define ZZZ_CLOTH_RAMP_STRENGTH_DEFAULT 1.0
#endif
#ifndef ZZZ_CLOTH_SPECULAR_STRENGTH_DEFAULT
#define ZZZ_CLOTH_SPECULAR_STRENGTH_DEFAULT 1.0
#endif
#ifndef ZZZ_CLOTH_SPECULAR_MASK_DEFAULT
#define ZZZ_CLOTH_SPECULAR_MASK_DEFAULT 1.0
#endif
#ifndef ZZZ_CLOTH_SPECULAR_RANGE_DEFAULT
#define ZZZ_CLOTH_SPECULAR_RANGE_DEFAULT 1.0
#endif
#ifndef ZZZ_CLOTH_SPECULAR_GLOSS_DEFAULT
#define ZZZ_CLOTH_SPECULAR_GLOSS_DEFAULT 1.0
#endif
#ifndef ZZZ_CLOTH_SPECULAR_COLOR_DEFAULT
#define ZZZ_CLOTH_SPECULAR_COLOR_DEFAULT float3(1.0, 1.0, 1.0)
#endif
#ifndef ZZZ_CLOTH_HGSHADOW_STRENGTH_DEFAULT
#define ZZZ_CLOTH_HGSHADOW_STRENGTH_DEFAULT 1.0
#endif
#ifndef ZZZ_CLOTH_SHADOW_BRIGHTNESS_DEFAULT
#define ZZZ_CLOTH_SHADOW_BRIGHTNESS_DEFAULT 0.5
#endif

#if !ZZZ_CLOTH_USE_JSON_MATCAP
#define ZZZ_JSON_MATCAP_SLOT_1_RESOURCE ""
#define ZZZ_JSON_MATCAP_SLOT_2_RESOURCE ""
#define ZZZ_JSON_MATCAP_SLOT_3_RESOURCE ""
#define ZZZ_JSON_MATCAP_SLOT_4_RESOURCE ""
#define ZZZ_JSON_MATCAP_SLOT_5_RESOURCE ""
static const float ZZZ_JsonMatcapMasterEnabled = 0.0;
static const float ZZZ_JsonMatcapUseMask = 1.0;
static const float ZZZ_JsonSpecularHighlights = 1.0;
static const float ZZZ_JsonSpecularIntensity = 0.1;
static const float ZZZ_JsonMetallic = 1.0;
static const float ZZZ_JsonGlossiness = 1.0;
static const float ZZZ_JsonMatcapEnabled1 = 0.0;
static const float ZZZ_JsonMatcapEnabled2 = 0.0;
static const float ZZZ_JsonMatcapEnabled3 = 0.0;
static const float ZZZ_JsonMatcapEnabled4 = 0.0;
static const float ZZZ_JsonMatcapEnabled5 = 0.0;
static const float3 ZZZ_JsonMatcapTint1 = float3(1.0, 1.0, 1.0);
static const float3 ZZZ_JsonMatcapTint2 = float3(1.0, 1.0, 1.0);
static const float3 ZZZ_JsonMatcapTint3 = float3(1.0, 1.0, 1.0);
static const float3 ZZZ_JsonMatcapTint4 = float3(1.0, 1.0, 1.0);
static const float3 ZZZ_JsonMatcapTint5 = float3(1.0, 1.0, 1.0);
static const float ZZZ_JsonMatcapColorBurst1 = 1.0;
static const float ZZZ_JsonMatcapColorBurst2 = 1.0;
static const float ZZZ_JsonMatcapColorBurst3 = 1.0;
static const float ZZZ_JsonMatcapColorBurst4 = 1.0;
static const float ZZZ_JsonMatcapColorBurst5 = 1.0;
static const float ZZZ_JsonMatcapAlphaBurst1 = 1.0;
static const float ZZZ_JsonMatcapAlphaBurst2 = 1.0;
static const float ZZZ_JsonMatcapAlphaBurst3 = 1.0;
static const float ZZZ_JsonMatcapAlphaBurst4 = 1.0;
static const float ZZZ_JsonMatcapAlphaBurst5 = 1.0;
static const float ZZZ_JsonMatcapBlendMode1 = 0.0;
static const float ZZZ_JsonMatcapBlendMode2 = 0.0;
static const float ZZZ_JsonMatcapBlendMode3 = 0.0;
static const float ZZZ_JsonMatcapBlendMode4 = 0.0;
static const float ZZZ_JsonMatcapBlendMode5 = 0.0;
static const float ZZZ_JsonMatcapTexId1 = 100.0;
static const float ZZZ_JsonMatcapTexId2 = 100.0;
static const float ZZZ_JsonMatcapTexId3 = 100.0;
static const float ZZZ_JsonMatcapTexId4 = 100.0;
static const float ZZZ_JsonMatcapTexId5 = 100.0;
static const float ZZZ_JsonMatcapUSpeed1 = 0.0;
static const float ZZZ_JsonMatcapUSpeed2 = 0.0;
static const float ZZZ_JsonMatcapUSpeed3 = 0.0;
static const float ZZZ_JsonMatcapUSpeed4 = 0.0;
static const float ZZZ_JsonMatcapUSpeed5 = 0.0;
static const float ZZZ_JsonMatcapVSpeed1 = 0.0;
static const float ZZZ_JsonMatcapVSpeed2 = 0.0;
static const float ZZZ_JsonMatcapVSpeed3 = 0.0;
static const float ZZZ_JsonMatcapVSpeed4 = 0.0;
static const float ZZZ_JsonMatcapVSpeed5 = 0.0;
static const float ZZZ_JsonMatcapMaskChannel1 = 2.0;
static const float ZZZ_JsonMatcapMaskChannel2 = 2.0;
static const float ZZZ_JsonMatcapMaskChannel3 = 2.0;
static const float ZZZ_JsonMatcapMaskChannel4 = 2.0;
static const float ZZZ_JsonMatcapMaskChannel5 = 2.0;
static const float ZZZ_JsonMatcapRotation1 = 0.0;
static const float ZZZ_JsonMatcapRotation2 = 0.0;
static const float ZZZ_JsonMatcapRotation3 = 0.0;
static const float ZZZ_JsonMatcapRotation4 = 0.0;
static const float ZZZ_JsonMatcapRotation5 = 0.0;
static const float2 ZZZ_JsonMatcapScale1 = float2(1.0, 1.0);
static const float2 ZZZ_JsonMatcapScale2 = float2(1.0, 1.0);
static const float2 ZZZ_JsonMatcapScale3 = float2(1.0, 1.0);
static const float2 ZZZ_JsonMatcapScale4 = float2(1.0, 1.0);
static const float2 ZZZ_JsonMatcapScale5 = float2(1.0, 1.0);
static const float2 ZZZ_JsonMatcapOffset1 = float2(0.0, 0.0);
static const float2 ZZZ_JsonMatcapOffset2 = float2(0.0, 0.0);
static const float2 ZZZ_JsonMatcapOffset3 = float2(0.0, 0.0);
static const float2 ZZZ_JsonMatcapOffset4 = float2(0.0, 0.0);
static const float2 ZZZ_JsonMatcapOffset5 = float2(0.0, 0.0);
static const float3 ZZZ_JsonSpecularColor1 = float3(1.0, 1.0, 1.0);
static const float3 ZZZ_JsonSpecularColor2 = float3(1.0, 1.0, 1.0);
static const float3 ZZZ_JsonSpecularColor3 = float3(1.0, 1.0, 1.0);
static const float3 ZZZ_JsonSpecularColor4 = float3(1.0, 1.0, 1.0);
static const float3 ZZZ_JsonSpecularColor5 = float3(1.0, 1.0, 1.0);
static const float ZZZ_JsonSpecularRange1 = 1.0;
static const float ZZZ_JsonSpecularRange2 = 1.0;
static const float ZZZ_JsonSpecularRange3 = 1.0;
static const float ZZZ_JsonSpecularRange4 = 1.0;
static const float ZZZ_JsonSpecularRange5 = 1.0;
static const float ZZZ_JsonToonSpecular1 = 0.01;
static const float ZZZ_JsonToonSpecular2 = 0.01;
static const float ZZZ_JsonToonSpecular3 = 0.01;
static const float ZZZ_JsonToonSpecular4 = 0.01;
static const float ZZZ_JsonToonSpecular5 = 0.01;
static const float ZZZ_JsonModelSize1 = 1.0;
static const float ZZZ_JsonModelSize2 = 1.0;
static const float ZZZ_JsonModelSize3 = 1.0;
static const float ZZZ_JsonModelSize4 = 1.0;
static const float ZZZ_JsonModelSize5 = 1.0;
#endif

#ifndef ZZZ_CLOTH_FORCE_SPECULAR_DEBUG
#define ZZZ_CLOTH_FORCE_SPECULAR_DEBUG 0
#endif
#ifndef ZZZ_CLOTH_SPECULAR_DEBUG_GAIN
#define ZZZ_CLOTH_SPECULAR_DEBUG_GAIN 1.0
#endif
#ifndef ZZZ_CLOTH_SPECULAR_DEBUG_COLOR_R
#define ZZZ_CLOTH_SPECULAR_DEBUG_COLOR_R 1.0
#endif
#ifndef ZZZ_CLOTH_SPECULAR_DEBUG_COLOR_G
#define ZZZ_CLOTH_SPECULAR_DEBUG_COLOR_G 1.0
#endif
#ifndef ZZZ_CLOTH_SPECULAR_DEBUG_COLOR_B
#define ZZZ_CLOTH_SPECULAR_DEBUG_COLOR_B 1.0
#endif
#ifndef ZZZ_CLOTH_FORCE_MATCAP_DEBUG
#define ZZZ_CLOTH_FORCE_MATCAP_DEBUG 0
#endif
#ifndef ZZZ_CLOTH_SCREEN_RIM_ENABLED
#define ZZZ_CLOTH_SCREEN_RIM_ENABLED 1
#endif
#ifndef ZZZ_CLOTH_SCREEN_RIM_STRENGTH
#define ZZZ_CLOTH_SCREEN_RIM_STRENGTH 0.55
#endif
#ifndef ZZZ_CLOTH_SCREEN_RIM_WIDTH
#define ZZZ_CLOTH_SCREEN_RIM_WIDTH 0.75
#endif
#ifndef ZZZ_CLOTH_SCREEN_RIM_CONTRAST
#define ZZZ_CLOTH_SCREEN_RIM_CONTRAST 1.35
#endif
#ifndef ZZZ_CLOTH_SCREEN_RIM_FRESNEL_POWER
#define ZZZ_CLOTH_SCREEN_RIM_FRESNEL_POWER 4.0
#endif
#ifndef ZZZ_CLOTH_SCREEN_RIM_LIGHT_START
#define ZZZ_CLOTH_SCREEN_RIM_LIGHT_START 0.0
#endif
#ifndef ZZZ_CLOTH_SCREEN_RIM_LIGHT_END
#define ZZZ_CLOTH_SCREEN_RIM_LIGHT_END 0.5
#endif
#ifndef ZZZ_CLOTH_SCREEN_RIM_COLOR
#define ZZZ_CLOTH_SCREEN_RIM_COLOR float3(1.0, 1.0, 1.0)
#endif

#include "zzz_hgshadow_bridge.hlsl"
#include "zzz_cloth_matcap_controls.inc"

float4x4 ZzzClothWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 ZzzClothWorld : WORLD;
float4x4 ZzzClothView : VIEW;
float4x4 ZzzClothProjection : PROJECTION;
float3 ZzzClothLightDirection : DIRECTION < string Object = "Light"; >;
float4 ZzzClothMaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;
float3 ZzzClothCameraPosition : POSITION < string Object = "Camera"; >;
float ZzzClothTime : TIME;

float ZzzClothBrightness <
    string UIName = "衣装明度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 3.0;
> = ZZZ_CLOTH_BRIGHTNESS_DEFAULT;

float ZzzClothNormalStrength <
    string UIName = "法线强度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = ZZZ_CLOTH_NORMAL_STRENGTH_DEFAULT;

float ZzzClothShadowNormalStrength <
    string UIName = "阴影法线强度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = ZZZ_CLOTH_SHADOW_NORMAL_DEFAULT;

float ZzzClothDiffuseBiasStrength <
    string UIName = "贴图明暗";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = 0.0;

float ZzzClothShadowBias <
    string UIName = "明暗位置";
    string UIWidget = "Slider";
    float UIMin = -1.0;
    float UIMax = 1.0;
> = ZZZ_CLOTH_SHADOW_BIAS_DEFAULT;

float ZzzClothAlbedoSmoothness <
    string UIName = "明暗柔和";
    string UIWidget = "Slider";
    float UIMin = 0.001;
    float UIMax = 0.5;
> = ZZZ_CLOTH_SHADOW_SOFTNESS_DEFAULT;

float ZzzClothShadowRampStrength <
    string UIName = "阴影Ramp强度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = ZZZ_CLOTH_RAMP_STRENGTH_DEFAULT;

bool ZzzClothToneDebug <
    string UIName = "二分诊断";
    string UIWidget = "CheckBox";
> = false;

bool ZzzClothMaterialIdDebug <
    string UIName = "材质ID诊断";
    string UIWidget = "CheckBox";
> = false;

int ZzzClothMaterialChannelDebug <
    string UIName = "材质图诊断";
    string UIWidget = "Numeric";
    int UIMin = 0;
    int UIMax = 4;
> = 0;

float ZzzClothSpecularStrength <
    string UIName = "高光强度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 4.0;
> = ZZZ_CLOTH_SPECULAR_STRENGTH_DEFAULT;

float ZzzClothSpecularMaskGain <
    string UIName = "高光遮罩";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 4.0;
> = ZZZ_CLOTH_SPECULAR_MASK_DEFAULT;

float ZzzClothSpecularRange <
    string UIName = "高光范围";
    string UIWidget = "Slider";
    float UIMin = 0.1;
    float UIMax = 2.0;
> = ZZZ_CLOTH_SPECULAR_RANGE_DEFAULT;

float ZzzClothSpecularGlossiness <
    string UIName = "高光光滑";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = ZZZ_CLOTH_SPECULAR_GLOSS_DEFAULT;

float3 ZzzClothSpecularColor <
    string UIName = "高光颜色";
    string UIWidget = "Color";
> = ZZZ_CLOTH_SPECULAR_COLOR_DEFAULT;

bool ZzzClothSpecularDebug <
    string UIName = "高光诊断";
    string UIWidget = "CheckBox";
> = false;

float ZzzClothMatcapStrength <
    string UIName = "MatCap强度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 5.0;
> = ZZZ_CLOTH_MATCAP_STRENGTH_DEFAULT;

bool ZzzClothMatcapDebug <
    string UIName = "球面反光诊断";
    string UIWidget = "CheckBox";
> = false;

float ZzzClothHgShadowStrength <
    string UIName = "投影强度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = ZZZ_CLOTH_HGSHADOW_STRENGTH_DEFAULT;

float ZzzClothShadowBrightness <
    string UIName = "阴影明度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = ZZZ_CLOTH_SHADOW_BRIGHTNESS_DEFAULT;

bool ZzzClothHgShadowDebug <
    string UIName = "投影诊断";
    string UIWidget = "CheckBox";
> = false;

texture2D ZzzClothDiffuseTexture : MATERIALTEXTURE <
    string Format = "A8R8G8B8";
>;
sampler2D ZzzClothDiffuseSampler = sampler_state {
    texture = <ZzzClothDiffuseTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 8;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzClothNormalTexture <
    string ResourceName = ZZZ_CLOTH_NORMAL_RESOURCE;
>;
sampler2D ZzzClothNormalSampler = sampler_state {
    texture = <ZzzClothNormalTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzClothMaterialTexture <
    string ResourceName = ZZZ_CLOTH_MATERIAL_RESOURCE;
>;
sampler2D ZzzClothMaterialSampler = sampler_state {
    texture = <ZzzClothMaterialTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzClothAuxTexture <
    string ResourceName = ZZZ_CLOTH_AUX_RESOURCE;
>;
sampler2D ZzzClothAuxSampler = sampler_state {
    texture = <ZzzClothAuxTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = WRAP;
    AddressV = WRAP;
};

texture2D ZzzClothMatcapSlot1Texture <
    string ResourceName = ZZZ_JSON_MATCAP_SLOT_1_RESOURCE;
>;
sampler2D ZzzClothMatcapSlot1Sampler = sampler_state {
    texture = <ZzzClothMatcapSlot1Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D ZzzClothMatcapSlot2Texture <
    string ResourceName = ZZZ_JSON_MATCAP_SLOT_2_RESOURCE;
>;
sampler2D ZzzClothMatcapSlot2Sampler = sampler_state {
    texture = <ZzzClothMatcapSlot2Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D ZzzClothMatcapSlot3Texture <
    string ResourceName = ZZZ_JSON_MATCAP_SLOT_3_RESOURCE;
>;
sampler2D ZzzClothMatcapSlot3Sampler = sampler_state {
    texture = <ZzzClothMatcapSlot3Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D ZzzClothMatcapSlot4Texture <
    string ResourceName = ZZZ_JSON_MATCAP_SLOT_4_RESOURCE;
>;
sampler2D ZzzClothMatcapSlot4Sampler = sampler_state {
    texture = <ZzzClothMatcapSlot4Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D ZzzClothMatcapSlot5Texture <
    string ResourceName = ZZZ_JSON_MATCAP_SLOT_5_RESOURCE;
>;
sampler2D ZzzClothMatcapSlot5Sampler = sampler_state {
    texture = <ZzzClothMatcapSlot5Texture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

static const float3 ZzzClothShallowColor1 =
    float3(0.83076447, 0.76052511, 0.76052481);
static const float3 ZzzClothShallowColor2 =
    float3(0.79129297, 0.76815188, 0.68668562);
static const float3 ZzzClothShallowColor3 =
    float3(0.38132334, 0.50288683, 0.57112521);
static const float3 ZzzClothShallowColor4 =
    float3(0.61720252, 0.70837647, 0.79129839);
static const float3 ZzzClothShallowColor5 =
    float3(0.54572105, 0.55834091, 0.68668556);

static const float3 ZzzClothShadowColor1 =
    float3(0.74539959, 0.60382777, 0.60382760);
static const float3 ZzzClothShadowColor2 =
    float3(0.68668097, 0.62396109, 0.55834079);
static const float3 ZzzClothShadowColor3 =
    float3(0.23073851, 0.27049807, 0.30498746);
static const float3 ZzzClothShadowColor4 =
    float3(0.41788211, 0.51491791, 0.60382754);
static const float3 ZzzClothShadowColor5 =
    float3(0.38642684, 0.36625284, 0.60382754);

float3 ZzzClothSafeNormalize(float3 value, float3 fallbackValue)
{
    float lenSq = dot(value, value);
    return lenSq < 1e-8 ? fallbackValue : value * rsqrt(lenSq);
}

float3 ZzzClothSrgbToLinear(float3 color)
{
    return pow(saturate(color), 2.2);
}

float3 ZzzClothLinearToSrgb(float3 color)
{
    return pow(max(color, 0.0), 1.0 / 2.2);
}

float3 ZzzClothSelectShallowColor(float packedMaterialId)
{
    float3 color = ZzzClothShallowColor1;
    color = packedMaterialId < 0.8 ? ZzzClothShallowColor2 : color;
    color = packedMaterialId < 0.6 ? ZzzClothShallowColor3 : color;
    color = packedMaterialId < 0.4 ? ZzzClothShallowColor4 : color;
    color = packedMaterialId < 0.2 ? ZzzClothShallowColor5 : color;
    return color;
}

float3 ZzzClothSelectShadowColor(float packedMaterialId)
{
    float3 color = ZzzClothShadowColor1;
    color = packedMaterialId < 0.8 ? ZzzClothShadowColor2 : color;
    color = packedMaterialId < 0.6 ? ZzzClothShadowColor3 : color;
    color = packedMaterialId < 0.4 ? ZzzClothShadowColor4 : color;
    color = packedMaterialId < 0.2 ? ZzzClothShadowColor5 : color;
    return color;
}

float ZzzClothDecodeMaterialId(float packedMaterialId)
{
    return max(4.0 - floor(saturate(packedMaterialId) * 5.0), 0.0);
}

float3 ZzzClothNormalizeShadowColor(float3 color, float4 weightState)
{
    const float2 magic = float2(0.562750012, 0.437249988);
    color += 0.00006;
    float averageWeight =
        (weightState.x + weightState.y + weightState.z) * 0.333330005;
    if (abs(averageWeight) < 0.00001) {
        averageWeight = averageWeight < 0.0 ? -0.00001 : 0.00001;
    }
    float3 divided = saturate(color / averageWeight);
    return color * magic.y + divided * magic.x;
}

float3 ZzzClothReconstructNormal(
    float3 positionWS,
    float3 geometricNormalWS,
    float2 uv,
    float frontFacing)
{
    float3 normalWS = ZzzClothSafeNormalize(
        geometricNormalWS * frontFacing, float3(0, 1, 0));
    float3 dpdx = ddx(positionWS);
    float3 dpdy = ddy(positionWS);
    float2 duvdx = ddx(uv);
    float2 duvdy = ddy(uv);
    float determinant = duvdx.x * duvdy.y - duvdx.y * duvdy.x;
    float orientation = determinant < 0.0 ? -1.0 : 1.0;
    float3 tangent = (dpdx * duvdy.y - dpdy * duvdx.y) * orientation;
    float3 bitangent = (dpdy * duvdx.x - dpdx * duvdy.x) * orientation;
    float3 tangentWS = ZzzClothSafeNormalize(tangent, float3(1, 0, 0));
    float3 bitangentWS = ZzzClothSafeNormalize(
        bitangent, cross(normalWS, tangentWS));

    float2 mapXY =
        (tex2D(ZzzClothNormalSampler, uv).rg * 2.0 - 1.0)
        * max(ZzzClothNormalStrength, 0.0);
    float mapZ = sqrt(1.0 - min(dot(mapXY, mapXY), 1.0));
    return ZzzClothSafeNormalize(
        tangentWS * mapXY.x
            + bitangentWS * mapXY.y
            + normalWS * mapZ,
        normalWS);
}

float4 ZzzClothShadowBody(
    float3 normalWS,
    float3 lightWS,
    float4 lightData,
    float packedMaterialId,
    float selfShadow)
{
    float4 shadowThresholds;
    float4 temp0;
    float4 temp1;
    float4 temp2;
    float4 temp3;

    float aoTexture = lerp(
        0.5,
        lightData.b,
        saturate(ZzzClothDiffuseBiasStrength));
    aoTexture = aoTexture * 2.0 - 1.0;

    float albedoSmoothness = max(
        0.00001,
        ZzzClothControlledShadowSoftness(ZzzClothAlbedoSmoothness));
    float inverseSmoothness = rcp(albedoSmoothness);
    float ndotl = dot(normalWS, lightWS);
    float shad = aoTexture * 2.0 + ndotl
        + ZzzClothControlledShadowBias(ZzzClothShadowBias);
    float albedoStep = -albedoSmoothness * 3.0 + 2.0;
    albedoStep = 3.0 / albedoStep;

    shadowThresholds.yz =
        albedoSmoothness * float2(0.5, 1.5)
        + float2(-0.333299994, 0.333299994);
    shadowThresholds.x = -1.0;
    shadowThresholds.xyz = -shadowThresholds.xyz + shad;
    temp0.xyw = shadowThresholds.xyz * albedoStep;
    shadowThresholds.xyz =
        -shadowThresholds.xyz * albedoStep + float3(1, 1, 1);
    temp1.xyz =
        float3(0.333299994, -0.333299994, -0.333299994) + shad;
    temp1.xyz =
        temp1.xyz * inverseSmoothness + float3(0.5, 0.5, -0.5);
    temp2.xyz = float3(1, 1, 1) - temp1.xyz;
    temp3.xy = min(temp2.yx, temp0.yx);
    temp0.xz = min(temp1.xz, shadowThresholds.yz);
    temp3.z = shadowThresholds.x;
    temp3.w = temp0.x;
    shadowThresholds.xyz = saturate(temp3.zyw);

    temp3.y = saturate(min(temp2.z, temp1.y));
    temp3.x = saturate(temp3.x);
    temp0.zw = saturate(temp0.zw);
    temp1 = float4(-1.0, 2.0, 1.0, 0.0);
    temp1.y = saturate(min(temp1.y, temp1.w));
    temp1.xz = saturate(temp1.xz);
    temp0.xy = temp1.xy;

    inverseSmoothness = 1.0 - shadowThresholds.x;
    inverseSmoothness -= shadowThresholds.y;
    inverseSmoothness -= shadowThresholds.z;
    inverseSmoothness =
        temp0.x * inverseSmoothness + shadowThresholds.z;
    albedoSmoothness = temp1.y + temp1.z;
    shadowThresholds.zw = temp3.xy * albedoSmoothness;
    albedoSmoothness = temp0.z + temp0.w;
    albedoSmoothness =
        albedoSmoothness * temp0.y + shadowThresholds.w;
    albedoStep = temp1.z * temp0.z;
    shadowThresholds.x += shadowThresholds.y;

    float3 shallowColor = ZzzClothNormalizeShadowColor(
        ZzzClothSelectShallowColor(packedMaterialId), temp0);
    float3 shadowColor = ZzzClothNormalizeShadowColor(
        ZzzClothSelectShadowColor(packedMaterialId), temp1);
    float shadowBrightness = max(ZzzClothShadowBrightness, 0.0);
    const float zzzShallowRamp = 0.79129535;
    const float zzzShadowRamp = 0.61049334;
    float shallowRampRatio = zzzShallowRamp / zzzShadowRamp;
    float shallowBrightness = shadowBrightness * lerp(
        1.0,
        shallowRampRatio,
        saturate(ZzzClothControlledShadowStrength(
            ZzzClothShadowRampStrength)));
    shallowColor *= shallowBrightness;
    shadowColor *= shadowBrightness;

    float3 frontAndSss = albedoStep.xxx;
    frontAndSss += albedoSmoothness.xxx;
    frontAndSss += temp0.www * temp1.zzz;

    float3 finalColor =
        shallowColor * inverseSmoothness
        + shadowColor * shadowThresholds.x;
    finalColor += shallowColor * shadowThresholds.z;
    finalColor += frontAndSss;

    // Scene projection and the Lambert ramp share one final dark branch.
    // Feeding projection into the multi-band ramp creates an extra plateau.
    float projectedShadow = 1.0 - saturate(selfShadow);
    finalColor = lerp(finalColor, shadowColor, projectedShadow);
    return float4(saturate(finalColor), shad);
}

float3 ZzzClothSelectSpecularColor(float packedMaterialId)
{
    float decodedId = ZzzClothDecodeMaterialId(packedMaterialId);
    return float3(
        ZzzMatcapSelect5(decodedId,
            ZZZ_JsonSpecularColor1.x, ZZZ_JsonSpecularColor2.x,
            ZZZ_JsonSpecularColor3.x, ZZZ_JsonSpecularColor4.x,
            ZZZ_JsonSpecularColor5.x),
        ZzzMatcapSelect5(decodedId,
            ZZZ_JsonSpecularColor1.y, ZZZ_JsonSpecularColor2.y,
            ZZZ_JsonSpecularColor3.y, ZZZ_JsonSpecularColor4.y,
            ZZZ_JsonSpecularColor5.y),
        ZzzMatcapSelect5(decodedId,
            ZZZ_JsonSpecularColor1.z, ZZZ_JsonSpecularColor2.z,
            ZZZ_JsonSpecularColor3.z, ZZZ_JsonSpecularColor4.z,
            ZZZ_JsonSpecularColor5.z));
}

float ZzzClothSelectSpecularRange(float packedMaterialId)
{
    return ZzzMatcapSelect5(ZzzClothDecodeMaterialId(packedMaterialId),
        ZZZ_JsonSpecularRange1, ZZZ_JsonSpecularRange2,
        ZZZ_JsonSpecularRange3, ZZZ_JsonSpecularRange4,
        ZZZ_JsonSpecularRange5);
}

float ZzzClothSelectToonSpecularScale(float packedMaterialId)
{
    float decodedId = ZzzClothDecodeMaterialId(packedMaterialId);
    float toonSpecular = ZzzMatcapSelect5(decodedId,
        ZZZ_JsonToonSpecular1, ZZZ_JsonToonSpecular2,
        ZZZ_JsonToonSpecular3, ZZZ_JsonToonSpecular4,
        ZZZ_JsonToonSpecular5);
    float modelSize = ZzzMatcapSelect5(decodedId,
        ZZZ_JsonModelSize1, ZZZ_JsonModelSize2,
        ZZZ_JsonModelSize3, ZZZ_JsonModelSize4,
        ZZZ_JsonModelSize5);
    return max(toonSpecular, 0.0) * max(modelSize, 0.0);
}

float3 ZzzClothDirectSpecular(
    float3 positionWS,
    float3 normalWS,
    float3 lightWS,
    float3 shadedLinear,
    float packedMaterialId,
    float metallicMask,
    float specularMask,
    float smoothnessMask,
    float shadowSignal,
    float selfShadow)
{
    float3 viewWS = ZzzClothSafeNormalize(
        ZzzClothCameraPosition - positionWS,
        float3(0, 0, 1));
    float3 halfWS = ZzzClothSafeNormalize(
        lightWS + viewWS,
        viewWS);

    // Jane reference keeps HighlightShape disabled and uses HoyoToon's standard branch.
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

    float metallic = saturate(metallicMask * max(ZZZ_JsonMetallic, 0.0));
    float3 f0 = lerp(float3(0.04, 0.04, 0.04), preparedColor, metallic);
    float glossiness = saturate(
        ZzzClothControlledGlossiness(ZzzClothSpecularGlossiness)
            * max(ZZZ_JsonGlossiness, 0.0));
    float smoothness = saturate(smoothnessMask);
    float roughness = max(1.0 - smoothness * glossiness, 0.00001);
    float roughnessSq = roughness * roughness;

    float specularRange = max(
        ZzzClothControlledSpecularRange(ZzzClothSpecularRange)
            * ZzzClothSelectSpecularRange(packedMaterialId),
        0.0);
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

    float toonLobe = saturate(distribution - smoothness * glossiness);
    toonLobe *= noL / roughness;
    toonLobe *= ZzzClothSelectToonSpecularScale(packedMaterialId);
    toonLobe = saturate(toonLobe * 10.0) * 100.0;

    float maskEnergy = saturate(specularMask)
        * max(ZzzClothControlledSpecularMask(
            ZzzClothSpecularMaskGain), 0.0)
        * max(ZzzClothControlledSpecularStrength(
            ZzzClothSpecularStrength), 0.0)
        * max(ZZZ_JsonSpecularIntensity, 0.0)
        * 10.0
        * saturate(ZZZ_JsonSpecularHighlights);
    float3 materialSpecularColor =
        ZzzClothSelectSpecularColor(packedMaterialId)
        * ZzzClothControlledSpecularColor(ZzzClothSpecularColor)
        * 0.5;
    float3 specular = toonLobe
        * maskEnergy
        * materialSpecularColor
        * f0
        * color;

    // Preserve the accepted dark branch and projected-shadow color.
    float geometricLight = smoothstep(0.0, 0.15, ndotl);
    float lambertLight = smoothstep(0.0, 0.25, shadowSignal);
    float directVisibility =
        geometricLight * lambertLight * saturate(selfShadow);
    return max(specular, 0.0) * directVisibility;
}
float3 ZzzClothOverlay(float3 baseColor, float3 blendColor)
{
    float3 darkResult = 2.0 * baseColor * blendColor;
    float3 lightResult =
        1.0 - 2.0 * (1.0 - baseColor) * (1.0 - blendColor);
    return lerp(darkResult, lightResult, step(0.5, baseColor));
}

float2 ZzzClothTransformMatcapUv(
    float2 uv,
    float rotationDegrees,
    float2 scaleValue,
    float2 offsetValue,
    float2 scrollSpeed)
{
    float angle = rotationDegrees * 0.01745329252;
    float sineValue = sin(angle);
    float cosineValue = cos(angle);
    float2 centered = uv - 0.5;
    float2 rotated = float2(
        centered.x * cosineValue - centered.y * sineValue,
        centered.x * sineValue + centered.y * cosineValue);
    return saturate(
        rotated / max(abs(scaleValue), float2(0.001, 0.001))
            + 0.5 + offsetValue + scrollSpeed * ZzzClothTime);
}

float ZzzClothSelectMaskChannel(float4 value, float channel)
{
    float result = value.r;
    result = channel >= 0.5 ? value.g : result;
    result = channel >= 1.5 ? value.b : result;
    result = channel >= 2.5 ? value.a : result;
    result = channel >= 3.5
        ? dot(value.rgb, float3(0.33333334, 0.33333334, 0.33333334))
        : result;
    result = channel >= 4.5
        ? dot(value, float4(0.25, 0.25, 0.25, 0.25))
        : result;
    return saturate(result);
}

float3 ZzzClothApplyMatcap(
    float3 normalWS,
    float packedMaterialId,
    float4 matcapMaskData,
    float3 baseLinear,
    out float3 diagnosticLinear)
{
    diagnosticLinear = float3(0.0, 0.0, 0.0);
    float decodedId = ZzzClothDecodeMaterialId(packedMaterialId);
    float w1 = 1.0 - step(0.5, decodedId);
    float w2 = step(0.5, decodedId) * (1.0 - step(1.5, decodedId));
    float w3 = step(1.5, decodedId) * (1.0 - step(2.5, decodedId));
    float w4 = step(2.5, decodedId) * (1.0 - step(3.5, decodedId));
    float w5 = step(3.5, decodedId);

    float3 normalVS = ZzzClothSafeNormalize(
        mul(normalWS, (float3x3)ZzzClothView) + 1e-6,
        float3(0, 0, 1));
    float2 matcapUv = saturate(
        normalVS.xy * float2(0.5, -0.5) + 0.5);

    float2 matcapUv1 = ZzzClothTransformMatcapUv(
        matcapUv, ZZZ_JsonMatcapRotation1,
        ZZZ_JsonMatcapScale1, ZZZ_JsonMatcapOffset1,
        float2(ZZZ_JsonMatcapUSpeed1, ZZZ_JsonMatcapVSpeed1));
    float2 matcapUv2 = ZzzClothTransformMatcapUv(
        matcapUv, ZZZ_JsonMatcapRotation2,
        ZZZ_JsonMatcapScale2, ZZZ_JsonMatcapOffset2,
        float2(ZZZ_JsonMatcapUSpeed2, ZZZ_JsonMatcapVSpeed2));
    float2 matcapUv3 = ZzzClothTransformMatcapUv(
        matcapUv, ZZZ_JsonMatcapRotation3,
        ZZZ_JsonMatcapScale3, ZZZ_JsonMatcapOffset3,
        float2(ZZZ_JsonMatcapUSpeed3, ZZZ_JsonMatcapVSpeed3));
    float2 matcapUv4 = ZzzClothTransformMatcapUv(
        matcapUv, ZZZ_JsonMatcapRotation4,
        ZZZ_JsonMatcapScale4, ZZZ_JsonMatcapOffset4,
        float2(ZZZ_JsonMatcapUSpeed4, ZZZ_JsonMatcapVSpeed4));
    float2 matcapUv5 = ZzzClothTransformMatcapUv(
        matcapUv, ZZZ_JsonMatcapRotation5,
        ZZZ_JsonMatcapScale5, ZZZ_JsonMatcapOffset5,
        float2(ZZZ_JsonMatcapUSpeed5, ZZZ_JsonMatcapVSpeed5));
    float4 matcapTexel =
        tex2D(ZzzClothMatcapSlot1Sampler, matcapUv1) * w1
        + tex2D(ZzzClothMatcapSlot2Sampler, matcapUv2) * w2
        + tex2D(ZzzClothMatcapSlot3Sampler, matcapUv3) * w3
        + tex2D(ZzzClothMatcapSlot4Sampler, matcapUv4) * w4
        + tex2D(ZzzClothMatcapSlot5Sampler, matcapUv5) * w5;
    float enabled = ZZZ_JsonMatcapMasterEnabled * (
        ZZZ_JsonMatcapEnabled1 * w1
        + ZZZ_JsonMatcapEnabled2 * w2
        + ZZZ_JsonMatcapEnabled3 * w3
        + ZZZ_JsonMatcapEnabled4 * w4
        + ZZZ_JsonMatcapEnabled5 * w5)
        * ZzzMatcapControlledSlotEnabled(decodedId);
    float3 tint =
        ZZZ_JsonMatcapTint1 * w1
        + ZZZ_JsonMatcapTint2 * w2
        + ZZZ_JsonMatcapTint3 * w3
        + ZZZ_JsonMatcapTint4 * w4
        + ZZZ_JsonMatcapTint5 * w5;
    float colorBurst =
        ZZZ_JsonMatcapColorBurst1 * w1
        + ZZZ_JsonMatcapColorBurst2 * w2
        + ZZZ_JsonMatcapColorBurst3 * w3
        + ZZZ_JsonMatcapColorBurst4 * w4
        + ZZZ_JsonMatcapColorBurst5 * w5;
    float alphaBurst =
        ZZZ_JsonMatcapAlphaBurst1 * w1
        + ZZZ_JsonMatcapAlphaBurst2 * w2
        + ZZZ_JsonMatcapAlphaBurst3 * w3
        + ZZZ_JsonMatcapAlphaBurst4 * w4
        + ZZZ_JsonMatcapAlphaBurst5 * w5;
    float blendMode =
        ZZZ_JsonMatcapBlendMode1 * w1
        + ZZZ_JsonMatcapBlendMode2 * w2
        + ZZZ_JsonMatcapBlendMode3 * w3
        + ZZZ_JsonMatcapBlendMode4 * w4
        + ZZZ_JsonMatcapBlendMode5 * w5;
    float texId =
        ZZZ_JsonMatcapTexId1 * w1
        + ZZZ_JsonMatcapTexId2 * w2
        + ZZZ_JsonMatcapTexId3 * w3
        + ZZZ_JsonMatcapTexId4 * w4
        + ZZZ_JsonMatcapTexId5 * w5;
    float maskChannel =
        ZZZ_JsonMatcapMaskChannel1 * w1
        + ZZZ_JsonMatcapMaskChannel2 * w2
        + ZZZ_JsonMatcapMaskChannel3 * w3
        + ZZZ_JsonMatcapMaskChannel4 * w4
        + ZZZ_JsonMatcapMaskChannel5 * w5;

    float slotBrightness = ZzzMatcapControlledSlotBrightness(decodedId);
    float3 tintedMatcap =
        ZzzClothSrgbToLinear(matcapTexel.rgb) * tint * slotBrightness;
    float authoredMask = lerp(
        1.0,
        ZzzClothSelectMaskChannel(matcapMaskData, maskChannel),
        saturate(ZZZ_JsonMatcapUseMask));
    float resolvedTexId = texId < 99.0 ? texId : decodedId;
    enabled *= 1.0 - step(50.0, resolvedTexId);
    float sampledMask = saturate(
        matcapTexel.a * authoredMask * alphaBurst
            * ZzzMatcapControlledSlotMask(decodedId)) * enabled;
    float strength = max(ZzzClothMatcapStrength, 0.0)
        * ZzzMatcapControlledMasterStrength();
    colorBurst *= ZzzMatcapControlledSlotStrength(decodedId);
    float3 additive = tintedMatcap * sampledMask * colorBurst;
    float3 overlayBlend = saturate(
        tintedMatcap * (1.0 + colorBurst));
    overlayBlend = lerp(float3(0.5, 0.5, 0.5), overlayBlend, sampledMask);
    float3 overlaid = ZzzClothOverlay(baseLinear, overlayBlend);
    float3 alphaTarget = max(tintedMatcap * colorBurst, 0.0);
    float alphaWeight = saturate(sampledMask * strength);
    float3 alphaResult = lerp(baseLinear, alphaTarget, alphaWeight);
    float3 additiveResult = baseLinear + additive * strength;
    float3 overlayResult = lerp(baseLinear, overlaid, saturate(strength));
    float replaceWeight = saturate(authoredMask * enabled * strength);
    float3 replaceResult = lerp(baseLinear, alphaTarget, replaceWeight);
    float3 multiplyTarget = baseLinear * saturate(alphaTarget);
    float3 multiplyResult = lerp(baseLinear, multiplyTarget, alphaWeight);

    diagnosticLinear = max(
        lerp(baseLinear, alphaTarget, saturate(sampledMask)) - baseLinear,
        0.0) * max(strength, 0.0);
    if (blendMode < 0.5) return alphaResult;
    if (blendMode < 1.5) return additiveResult;
    if (blendMode < 2.5) return overlayResult;
    if (blendMode < 3.5) return replaceResult;
    return multiplyResult;
}
struct ZzzClothAttributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord0 : TEXCOORD0;
};

struct ZzzClothVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
    float4 screenPosition : TEXCOORD3;
};

ZzzClothVaryings ZzzClothVS(ZzzClothAttributes input)
{
    ZzzClothVaryings output = (ZzzClothVaryings)0;
    output.positionCS = mul(input.positionOS, ZzzClothWorldViewProjection);
    output.uv = input.texcoord0;
    output.positionWS = mul(input.positionOS, ZzzClothWorld).xyz;
    output.normalWS = mul(input.normalOS, (float3x3)ZzzClothWorld);
    output.screenPosition = output.positionCS;
    return output;
}

float4 ZzzClothPS(
    ZzzClothVaryings input,
    float facing : VFACE,
    uniform bool useTexture,
    uniform bool useSelfShadow) : COLOR0
{
    float4 materialColor = saturate(ZzzClothMaterialDiffuse);
    float4 diffuseTexel = tex2D(ZzzClothDiffuseSampler, input.uv);
    float4 lightData = tex2D(ZzzClothNormalSampler, input.uv);
    float4 materialData = tex2D(ZzzClothMaterialSampler, input.uv);
    float4 auxiliaryData = tex2D(ZzzClothAuxSampler, input.uv);

    float3 baseSrgb = useTexture
        ? materialColor.rgb * diffuseTexel.rgb
        : materialColor.rgb;
    float outputAlpha = useTexture
        ? materialColor.a * diffuseTexel.a
        : materialColor.a;
    float3 baseLinear = ZzzClothSrgbToLinear(baseSrgb);

    float frontFacing = facing >= 0.0 ? 1.0 : -1.0;
    float3 normalWS = ZzzClothReconstructNormal(
        input.positionWS,
        input.normalWS,
        input.uv,
        frontFacing);
    float3 lightWS = ZzzClothSafeNormalize(
        -ZzzClothLightDirection, float3(0, 1, 0));
    float rawHgShadow = ZZZ_EyeSampleHgShadow(
        input.screenPosition, useSelfShadow);
    float selfShadow = lerp(
        1.0,
        rawHgShadow,
        saturate(ZzzClothHgShadowStrength));
    float3 geometricNormalWS = ZzzClothSafeNormalize(
        mul(input.normalWS, (float3x3)ZzzClothWorld) * frontFacing,
        float3(0, 1, 0));
    float3 shadowNormalWS = ZzzClothSafeNormalize(
        lerp(geometricNormalWS, normalWS,
            saturate(ZzzClothShadowNormalStrength)),
        geometricNormalWS);

    float4 shadow = ZzzClothShadowBody(
        shadowNormalWS, lightWS, lightData, materialData.r, selfShadow);
    float3 acceptedLinear = baseLinear * shadow.rgb;
    float3 specularLinear = ZzzClothDirectSpecular(
        input.positionWS,
        normalWS,
        lightWS,
        acceptedLinear,
        materialData.r,
        materialData.g,
        materialData.b,
        auxiliaryData.g,
        shadow.w,
        selfShadow);
    float3 litBaseLinear = acceptedLinear
        * max(ZzzClothControlledBrightness(ZzzClothBrightness), 0.0);
    float3 matcapDiagnosticLinear;
    float3 matcapLinear = ZzzClothApplyMatcap(
        normalWS,
        materialData.r,
        auxiliaryData,
        litBaseLinear,
        matcapDiagnosticLinear);

    if (ZzzClothMaterialChannelDebug > 0) {
        float channel = materialData.r;
        channel = ZzzClothMaterialChannelDebug == 2
            ? materialData.g
            : channel;
        channel = ZzzClothMaterialChannelDebug == 3
            ? materialData.b
            : channel;
        channel = ZzzClothMaterialChannelDebug == 4
            ? materialData.a
            : channel;
        return float4(channel.xxx, 1.0);
    }

    if (ZzzClothMaterialIdDebug) {
        float materialId = ZzzClothDecodeMaterialId(materialData.r) * 0.25;
        return float4(materialId.xxx, 1.0);
    }
    if (ZzzClothToneDebug) {
        return float4(saturate(shadow.rgb), 1.0);
    }
    if (ZzzClothHgShadowDebug) {
        return float4(selfShadow.xxx, 1.0);
    }
    if (ZzzClothSpecularDebug || ZZZ_CLOTH_FORCE_SPECULAR_DEBUG) {
        float specularEnergy = max(
            specularLinear.x,
            max(specularLinear.y, specularLinear.z));
        float debugMask = 1.0 - exp2(
            -specularEnergy * max(ZZZ_CLOTH_SPECULAR_DEBUG_GAIN, 0.0));
        float3 debugColor = float3(
            ZZZ_CLOTH_SPECULAR_DEBUG_COLOR_R,
            ZZZ_CLOTH_SPECULAR_DEBUG_COLOR_G,
            ZZZ_CLOTH_SPECULAR_DEBUG_COLOR_B);
        return float4(saturate(debugColor * debugMask), 1.0);
    }
    if (ZzzClothMatcapDebug || ZZZ_CLOTH_FORCE_MATCAP_DEBUG) {
        return float4(
            saturate(ZzzClothLinearToSrgb(matcapDiagnosticLinear)),
            1.0);
    }

    float3 finalLinear = matcapLinear + specularLinear;
    return float4(
        ZzzClothLinearToSrgb(max(finalLinear, 0.0)),
        saturate(outputAlpha));
}

#if ZZZ_CLOTH_SCREEN_RIM_ENABLED
struct ZzzClothScreenRimVaryings {
    float4 positionCS : POSITION;
    float3 positionWS : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
    float4 screenPosition : TEXCOORD2;
};

ZzzClothScreenRimVaryings ZzzClothScreenRimVS(
    ZzzClothAttributes input)
{
    ZzzClothScreenRimVaryings output =
        (ZzzClothScreenRimVaryings)0;
    output.positionCS = mul(
        input.positionOS, ZzzClothWorldViewProjection);
    output.positionWS = mul(input.positionOS, ZzzClothWorld).xyz;
    output.normalWS = ZzzClothSafeNormalize(
        mul(input.normalOS, (float3x3)ZzzClothWorld),
        float3(0, 1, 0));
    output.screenPosition = output.positionCS;
    return output;
}

float2 ZzzClothScreenRimViewportUv(float4 clipPosition)
{
    float2 ndc = clipPosition.xy / clipPosition.w;
    float2 uv = float2(
        (1.0 + ndc.x) * 0.5,
        (1.0 - ndc.y) * 0.5);
    return uv + 0.5 / max(ZZZ_EyeHgShadowViewportSize, 1.0);
}

float ZzzClothScreenDepthRim(
    float3 positionWS,
    float3 geometryNormalWS,
    float4 screenPosition)
{
    if (!ZZZ_EyeHgShadowValid || abs(screenPosition.w) < 1e-6) {
        return 0.0;
    }

    float3 positionVS = mul(
        float4(positionWS, 1.0), ZzzClothView).xyz;
    float3 normalVS = ZzzClothSafeNormalize(
        mul(geometryNormalWS, (float3x3)ZzzClothView),
        float3(0, 0, 1));
    float width = max(ZzzClothControlledRimWidth(
        ZZZ_CLOTH_SCREEN_RIM_WIDTH), 0.05);
    float3 rimOffsetVS = float3(
        normalVS.x * 0.028 * width,
        normalVS.y * 0.018 * width,
        0.0);
    float4 offsetClip = mul(
        float4(positionVS + rimOffsetVS, 1.0),
        ZzzClothProjection);
    if (abs(offsetClip.w) < 1e-6) {
        return 0.0;
    }

    float centerDepth = tex2D(
        ZZZ_EyeHgShadowSampler,
        ZzzClothScreenRimViewportUv(screenPosition)).g;
    float offsetDepth = tex2D(
        ZZZ_EyeHgShadowSampler,
        ZzzClothScreenRimViewportUv(offsetClip)).g;
    return saturate((offsetDepth - centerDepth) * 0.8);
}

float4 ZzzClothScreenRimPS(
    ZzzClothScreenRimVaryings input,
    float facing : VFACE) : COLOR0
{
    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 normalWS = ZzzClothSafeNormalize(
        input.normalWS * faceSign,
        float3(0, 1, 0));
    float depthRim = ZzzClothScreenDepthRim(
        input.positionWS,
        input.normalWS,
        input.screenPosition);
    float3 viewWS = ZzzClothSafeNormalize(
        ZzzClothCameraPosition - input.positionWS,
        normalWS);
    float3 lightWS = ZzzClothSafeNormalize(
        -ZzzClothLightDirection,
        float3(0, 1, 0));
    float fresnel = pow(
        saturate(1.0 - dot(normalWS, viewWS)),
        max(ZZZ_CLOTH_SCREEN_RIM_FRESNEL_POWER, 0.001));
    float lightMask = smoothstep(
        ZZZ_CLOTH_SCREEN_RIM_LIGHT_START,
        max(ZZZ_CLOTH_SCREEN_RIM_LIGHT_END,
            ZZZ_CLOTH_SCREEN_RIM_LIGHT_START + 0.001),
        dot(normalWS, lightWS));
    float rimMask = saturate(depthRim * fresnel * lightMask);
    rimMask = pow(
        rimMask,
        max(ZzzClothControlledRimContrast(
            ZZZ_CLOTH_SCREEN_RIM_CONTRAST), 0.001));
    float3 rimColor = max(ZZZ_CLOTH_SCREEN_RIM_COLOR, 0.0)
        * max(ZzzClothControlledRimStrength(
            ZZZ_CLOTH_SCREEN_RIM_STRENGTH), 0.0)
        * rimMask;
    return float4(rimColor, 0.0);
}

#define ZZZ_CLOTH_SCREEN_RIM_PASS \
    pass DrawClothScreenRim { \
        ZEnable = true; \
        ZWriteEnable = false; \
        ZFunc = LESSEQUAL; \
        CullMode = NONE; \
        AlphaTestEnable = false; \
        AlphaBlendEnable = true; \
        SrcBlend = ONE; \
        DestBlend = ONE; \
        BlendOp = ADD; \
        VertexShader = compile vs_3_0 ZzzClothScreenRimVS(); \
        PixelShader = compile ps_3_0 ZzzClothScreenRimPS(); \
    }
#define ZZZ_CLOTH_OBJECT_SCRIPT \
    "RenderColorTarget0=;Pass=DrawObject;Pass=DrawClothScreenRim;"
#else
#define ZZZ_CLOTH_SCREEN_RIM_PASS
#define ZZZ_CLOTH_OBJECT_SCRIPT \
    "RenderColorTarget0=;Pass=DrawObject;"
#endif
#define ZZZ_CLOTH_TECHNIQUE( \
    name, passName, subsetValue, useTextureValue, useSelfShadowValue) \
    technique name < \
        string MMDPass = passName; \
        string Subset = subsetValue; \
        string Script = ZZZ_CLOTH_OBJECT_SCRIPT; \
        bool UseTexture = useTextureValue; \
        bool UseSelfShadow = useSelfShadowValue; \
    > { \
        pass DrawObject { \
            ZEnable = true; \
            ZWriteEnable = true; \
            CullMode = NONE; \
            AlphaBlendEnable = false; \
            AlphaTestEnable = false; \
            VertexShader = compile vs_3_0 ZzzClothVS(); \
            PixelShader = compile ps_3_0 ZzzClothPS( \
                useTextureValue, useSelfShadowValue); \
        } \
        ZZZ_CLOTH_SCREEN_RIM_PASS \
    }

#if ZZZ_CLOTH_ENABLE_SUBSET_14
ZZZ_CLOTH_TECHNIQUE(ZzzCloth_14_NoTexture, "object", "14", false, false)
ZZZ_CLOTH_TECHNIQUE(ZzzCloth_14_Texture, "object", "14", true, false)
ZZZ_CLOTH_TECHNIQUE(ZzzCloth_14_ShadowNoTexture, "object_ss", "14", false, true)
ZZZ_CLOTH_TECHNIQUE(ZzzCloth_14_ShadowTexture, "object_ss", "14", true, true)
#endif
#if ZZZ_CLOTH_ENABLE_SUBSET_16
ZZZ_CLOTH_TECHNIQUE(ZzzCloth_16_NoTexture, "object", "16", false, false)
ZZZ_CLOTH_TECHNIQUE(ZzzCloth_16_Texture, "object", "16", true, false)
ZZZ_CLOTH_TECHNIQUE(ZzzCloth_16_ShadowNoTexture, "object_ss", "16", false, true)
ZZZ_CLOTH_TECHNIQUE(ZzzCloth_16_ShadowTexture, "object_ss", "16", true, true)
#endif
#if ZZZ_CLOTH_ENABLE_SUBSET_17
ZZZ_CLOTH_TECHNIQUE(ZzzCloth_17_NoTexture, "object", "17", false, false)
ZZZ_CLOTH_TECHNIQUE(ZzzCloth_17_Texture, "object", "17", true, false)
ZZZ_CLOTH_TECHNIQUE(ZzzCloth_17_ShadowNoTexture, "object_ss", "17", false, true)
ZZZ_CLOTH_TECHNIQUE(ZzzCloth_17_ShadowTexture, "object_ss", "17", true, true)
#endif
