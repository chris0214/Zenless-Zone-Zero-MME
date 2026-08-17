// ZZZ Eye 01: sclera and iris base-color acceptance pass.
// This stage intentionally excludes shadow maps, AO, specular, overlays,
// parallax and EyeThrough so the authored eye atlas can be judged alone.

#define ZZZ_EYE_DIFFUSE_RESOURCE "textures/Unagi_Face_D.png"

#include "internal/zzz_eye_controls.inc"

float4x4 ZzzEyeWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 ZzzEyeWorld : WORLD;
float3 ZzzEyeLightDirection : DIRECTION < string Object = "Light"; >;
float4 ZzzEyeMaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;

float ZzzEyeBrightness <
    string UIName = "眼睛明度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 3.0;
> = 1.0;

float ZzzEyeSoftLightStrength <
    string UIName = "柔光强度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 0.10;

bool ZzzEyeSoftLightDebug <
    string UIName = "柔光诊断";
    string UIWidget = "CheckBox";
> = false;

texture2D ZzzEyeDiffuseTexture <
    string ResourceName = ZZZ_EYE_DIFFUSE_RESOURCE;
    string Format = "A8R8G8B8";
>;
sampler2D ZzzEyeDiffuseSampler = sampler_state {
    texture = <ZzzEyeDiffuseTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 8;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

float3 ZzzEyeSafeNormalize(float3 value, float3 fallbackValue)
{
    float lengthSquared = dot(value, value);
    return lengthSquared < 1e-8
        ? fallbackValue
        : value * rsqrt(lengthSquared);
}

float3 ZzzEyeSrgbToLinear(float3 color)
{
    return pow(saturate(color), 2.2);
}

float3 ZzzEyeLinearToSrgb(float3 color)
{
    return pow(max(color, 0.0), 1.0 / 2.2);
}

struct ZzzEyeAttributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord0 : TEXCOORD0;
};

struct ZzzEyeVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
};

ZzzEyeVaryings ZzzEyeVS(ZzzEyeAttributes input)
{
    ZzzEyeVaryings output = (ZzzEyeVaryings)0;
    output.positionCS = mul(input.positionOS, ZzzEyeWorldViewProjection);
    output.uv = input.texcoord0;
    output.normalWS = ZzzEyeSafeNormalize(
        mul(input.normalOS, (float3x3)ZzzEyeWorld),
        float3(0.0, 0.0, 1.0));
    return output;
}

float4 ZzzEyePS(
    ZzzEyeVaryings input,
    float facing : VFACE,
    uniform bool useTexture) : COLOR0
{
    float4 materialColor = saturate(ZzzEyeMaterialDiffuse);
    float4 texel = tex2D(ZzzEyeDiffuseSampler, input.uv);
    float3 baseSrgb = useTexture
        ? materialColor.rgb * texel.rgb
        : materialColor.rgb;
    float outputAlpha = useTexture
        ? materialColor.a * texel.a
        : materialColor.a;

    float faceSign = facing >= 0.0 ? 1.0 : -1.0;
    float3 normalWS = ZzzEyeSafeNormalize(
        input.normalWS * faceSign,
        float3(0.0, 0.0, 1.0));
    // MMD DIRECTION points along the ray, so negate it for surface-to-light.
    float3 lightWS = ZzzEyeSafeNormalize(
        -ZzzEyeLightDirection,
        float3(0.0, 0.0, 1.0));

    // HoyoToon keeps the base eye path outside the body shadow/specular
    // chain. The only response here is a deliberately broad, low-energy
    // modulation so the sclera never develops a hard toon boundary.
    float wideLight = smoothstep(
        0.05,
        0.95,
        dot(normalWS, lightWS) * 0.5 + 0.5);
    if (ZzzEyeSoftLightDebug) {
        return float4(wideLight.xxx, 1.0);
    }

    float strength = saturate(
        ZzzEyeControlledSoftLight(ZzzEyeSoftLightStrength));
    float lightGain = lerp(
        1.0 - strength * 0.20,
        1.0 + strength * 0.08,
        wideLight);
    float3 colorLinear = ZzzEyeSrgbToLinear(baseSrgb) * lightGain;
    colorLinear *= max(ZzzEyeControlledBrightness(ZzzEyeBrightness), 0.0);

    return float4(
        ZzzEyeLinearToSrgb(colorLinear),
        saturate(outputAlpha));
}

#define ZZZ_EYE_TECHNIQUE(name, passName, useTextureValue) \
    technique name < string MMDPass = passName; string Subset = "1,2,3"; \
        string Script = "RenderColorTarget0=;Pass=DrawObject;"; \
        bool UseTexture = useTextureValue; bool UseSelfShadow = false; > { \
        pass DrawObject { \
            ZEnable = true; ZWriteEnable = true; ZFunc = LESSEQUAL; \
            CullMode = NONE; AlphaBlendEnable = false; \
            AlphaTestEnable = false; \
            VertexShader = compile vs_3_0 ZzzEyeVS(); \
            PixelShader = compile ps_3_0 ZzzEyePS(useTextureValue); \
        } \
    }

ZZZ_EYE_TECHNIQUE(ZzzEye01NoTexture, "object", false)
ZZZ_EYE_TECHNIQUE(ZzzEye01Texture, "object", true)
ZZZ_EYE_TECHNIQUE(ZzzEye01ShadowNoTexture, "object_ss", false)
ZZZ_EYE_TECHNIQUE(ZzzEye01ShadowTexture, "object_ss", true)

