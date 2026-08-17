#ifndef ZZZ_COMMON_INCLUDED
#define ZZZ_COMMON_INCLUDED

#define ZZZ_DOMAIN_BODY 0
#define ZZZ_DOMAIN_FACE 1
#define ZZZ_DOMAIN_DEBUG 2

#ifndef ZZZ_DOMAIN
#define ZZZ_DOMAIN ZZZ_DOMAIN_BODY
#endif
#ifndef ZZZ_USE_TEXTURE
#define ZZZ_USE_TEXTURE 1
#endif
#ifndef ZZZ_USE_NORMAL
#define ZZZ_USE_NORMAL 0
#endif
#ifndef ZZZ_USE_MATERIAL
#define ZZZ_USE_MATERIAL 0
#endif
#ifndef ZZZ_USE_ATTRIBUTES
#define ZZZ_USE_ATTRIBUTES 0
#endif
#ifndef ZZZ_USE_FACELIGHT
#define ZZZ_USE_FACELIGHT 0
#endif
#ifndef ZZZ_USE_HGSHADOW
#define ZZZ_USE_HGSHADOW 1
#endif
#ifndef ZZZ_USE_ALPHA_CLIP
#define ZZZ_USE_ALPHA_CLIP 0
#endif
#ifndef ZZZ_ALPHA_CUTOFF
#define ZZZ_ALPHA_CUTOFF 0.5
#endif
#ifndef ZZZ_FACE_STRENGTH
#define ZZZ_FACE_STRENGTH 1.0
#endif
#ifndef ZZZ_BODY_STRENGTH
#define ZZZ_BODY_STRENGTH 1.0
#endif
#ifndef ZZZ_NORMAL_STRENGTH
#define ZZZ_NORMAL_STRENGTH 1.0
#endif
#ifndef ZZZ_NORMAL_Y_SIGN
#define ZZZ_NORMAL_Y_SIGN 1.0
#endif
#ifndef ZZZ_HEAD_BONE
#define ZZZ_HEAD_BONE "Head"
#endif

float4x4 ZZZ_WorldViewProjection : WORLDVIEWPROJECTION;
float4x4 ZZZ_World : WORLD;
float3 ZZZ_LightDirection : DIRECTION < string Object = "Light"; >;
float3 ZZZ_LightColor : SPECULAR < string Object = "Light"; >;
float3 ZZZ_CameraPosition : POSITION < string Object = "Camera"; >;
float4 ZZZ_MaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;
float2 ZZZ_ViewportSize : VIEWPORTPIXELSIZE;

float ZZZ_Brightness <
    string UIName = "ZZZ Brightness";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 3.0;
> = 1.0;
float ZZZ_ToonThreshold <
    string UIName = "ZZZ Toon Threshold";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 0.5;
float ZZZ_ToonSoftness <
    string UIName = "ZZZ Toon Softness";
    string UIWidget = "Slider";
    float UIMin = 0.001;
    float UIMax = 0.5;
> = 0.04;
float ZZZ_FaceLightYaw <
    string UIName = "ZZZ FaceLight Yaw";
    string UIWidget = "Slider";
    float UIMin = -1.0;
    float UIMax = 1.0;
> = 0.0;

texture2D ZZZ_DiffuseTexture : MATERIALTEXTURE <
    string Format = "A8R8G8B8";
>;
sampler2D ZZZ_DiffuseSampler = sampler_state {
    texture = <ZZZ_DiffuseTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 8;
    AddressU = WRAP;
    AddressV = WRAP;
};

#if ZZZ_USE_HGSHADOW
#include "zzz_hgshadow_bridge.hlsl"
#else
float ZZZ_SampleHgShadow(float4 screenPosition, bool useSelfShadow)
{
    return 1.0;
}
float ZZZ_SampleHgShadowOffset(
    float4 screenPosition,
    bool useSelfShadow,
    float2 uvOffset)
{
    return 1.0;
}
#endif
#include "zzz_hgsao_contract.hlsl"

float3 ZZZ_SrgbToLinear(float3 color)
{
    return pow(saturate(color), 2.2);
}

float3 ZZZ_LinearToSrgb(float3 color)
{
    return pow(max(color, 0.0), 1.0 / 2.2);
}

float3 ZZZ_SafeNormalize(float3 value, float3 fallbackValue)
{
    float lengthSquared = dot(value, value);
    return lengthSquared < 1e-8 ? fallbackValue : value * rsqrt(lengthSquared);
}

#include "zzz_decode.hlsl"

float4 ZZZ_SampleBase(float2 uv, bool useTexture)
{
    float4 color = saturate(ZZZ_MaterialDiffuse);
    if (useTexture) {
        float4 texel = tex2D(ZZZ_DiffuseSampler, uv);
        color.rgb *= ZZZ_SrgbToLinear(texel.rgb);
        color.a *= texel.a;
    }
    return color;
}

float ZZZ_ToonAttenuation(float3 normalWS, float3 lightDirectionWS, float bias)
{
    float lambert = saturate(dot(normalWS, lightDirectionWS) + bias);
    return smoothstep(
        ZZZ_ToonThreshold - ZZZ_ToonSoftness,
        ZZZ_ToonThreshold + ZZZ_ToonSoftness,
        lambert);
}

struct ZZZ_Attributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord0 : TEXCOORD0;
    float4 texcoord1 : TEXCOORD1;
};

struct ZZZ_Varyings {
    float4 positionCS : POSITION;
    float4 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 geometricNormalWS : TEXCOORD2;
    float3 viewDirectionWS : TEXCOORD3;
    float4 screenPosition : TEXCOORD4;
};

ZZZ_Varyings ZZZ_VS(ZZZ_Attributes input)
{
    ZZZ_Varyings output = (ZZZ_Varyings)0;
    output.positionCS = mul(input.positionOS, ZZZ_WorldViewProjection);
    output.positionWS = mul(input.positionOS, ZZZ_World).xyz;
    output.geometricNormalWS = ZZZ_SafeNormalize(
        mul(input.normalOS, (float3x3)ZZZ_World), float3(0, 1, 0));
    output.viewDirectionWS = ZZZ_CameraPosition - output.positionWS;
    output.uv = float4(input.texcoord0, input.texcoord1.xy);
    output.screenPosition = output.positionCS;
    return output;
}

float3 ZZZ_ShadeBody(
    float4 baseColor,
    float3 normalWS,
    float3 viewDirectionWS,
    float shadow,
    float bias)
{
    float3 L = ZZZ_SafeNormalize(-ZZZ_LightDirection, float3(0, 1, 0));
    float attenuation = ZZZ_ToonAttenuation(normalWS, L, bias);
    attenuation *= lerp(0.35, 1.0, saturate(shadow));
    float3 shadowColor = baseColor.rgb * float3(0.55, 0.58, 0.68);
    float3 direct = lerp(shadowColor, baseColor.rgb, attenuation);
    float rim = pow(saturate(1.0 - dot(normalWS, viewDirectionWS)), 4.0) * 0.06;
    return (direct + rim.xxx) * max(ZZZ_BODY_STRENGTH, 0.0);
}

float3 ZZZ_ShadeFace(
    float4 baseColor,
    float3 geometricNormalWS,
    float3 viewDirectionWS)
{
    float3 L = ZZZ_SafeNormalize(-ZZZ_LightDirection, float3(0, 1, 0));
    float3 N = ZZZ_SafeNormalize(geometricNormalWS, float3(0, 0, 1));
    float facing = saturate(dot(N, L) * 0.5 + 0.5);
    float3 ramp = lerp(baseColor.rgb * float3(0.72, 0.74, 0.82), baseColor.rgb, facing);
    return ramp * max(ZZZ_FACE_STRENGTH, 0.0);
}

float4 ZZZ_PS(
    ZZZ_Varyings input,
    float facing : VFACE,
    uniform bool useTexture,
    uniform bool useSelfShadow) : COLOR0
{
    float2 uv = input.uv.xy;
    float4 baseColor = ZZZ_SampleBase(uv, useTexture);
#if ZZZ_USE_ALPHA_CLIP
    clip(baseColor.a - ZZZ_ALPHA_CUTOFF);
#endif
    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 geometricNormalWS = ZZZ_SafeNormalize(
        input.geometricNormalWS, float3(0, 1, 0)) * faceSign;
    float3 viewDirectionWS = ZZZ_SafeNormalize(
        input.viewDirectionWS, geometricNormalWS);
#if ZZZ_DOMAIN == ZZZ_DOMAIN_BODY
    float3 normalWS = ZZZ_ReconstructNormal(
        input.positionWS, geometricNormalWS, uv);
    float shadow = ZZZ_SampleHgShadow(input.screenPosition, useSelfShadow);
    float3 color = ZZZ_ShadeBody(
        baseColor, normalWS, viewDirectionWS, shadow, ZZZ_DiffuseBias(uv));
#elif ZZZ_DOMAIN == ZZZ_DOMAIN_FACE
    float3 color = ZZZ_ShadeFace(
        baseColor, geometricNormalWS, viewDirectionWS);
#else
    ZZZ_MaterialChannels channels = ZZZ_DecodeMaterialChannels(uv);
    float3 color = float3(
        channels.materialId * 0.25,
        channels.metallic,
        channels.smoothness);
#endif
    return float4(
        ZZZ_LinearToSrgb(max(color * max(ZZZ_Brightness, 0.0), 0.0)),
        saturate(baseColor.a));
}

#endif
