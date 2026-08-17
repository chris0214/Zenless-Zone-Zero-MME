// ZZZ face manual material. Edit only this public configuration block.
// Base: face diffuse atlas. FaceLight: the character FaceLight/SDF texture.
#define ZZZ_FACE_DIFFUSE_RESOURCE "../textures/common/neutral_base.png"
#define ZZZ_FACE_LIGHT_RESOURCE "../textures/common/neutral_facelight.png"
#define ZZZ_FACE_HEAD_BONE "頭"
#define ZZZ_FACE_SUBSET "0"

#include "Profiles/ZzzFaceSkin_Ramp_Manual.inc"
#include "../zzz_face_skin_ramp_shared.hlsl"
#include "../internal/zzz_face_skin_controls.inc"

#ifndef ZZZ_FACE_HAIR_SHADOW_RECEIVER
#define ZZZ_FACE_HAIR_SHADOW_RECEIVER 1
#endif

#ifndef ZZZ_FACE_RAMP_ENABLE
#define ZZZ_FACE_RAMP_ENABLE 1
#endif

float4x4 ZzzFaceWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 ZzzFaceWorld : WORLD;
float3 ZzzFaceLightDirection : DIRECTION < string Object = "Light"; >;
float3 ZzzFaceCameraPosition : POSITION < string Object = "Camera"; >;
float4 ZzzFaceMaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;

float ZzzFaceBrightness <
    string UIName = "面部明度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 3.0;
> = 1.0;

float ZzzFaceThresholdOffset <
    string UIName = "阴影位置";
    string UIWidget = "Slider";
    float UIMin = -0.5;
    float UIMax = 0.5;
> = 0.0;

float ZzzFaceSoftness <
    string UIName = "阴影柔和";
    string UIWidget = "Slider";
    float UIMin = 0.001;
    float UIMax = 0.5;
> = 0.035;

bool ZzzFaceLightDebug <
    string UIName = "面光诊断";
    string UIWidget = "CheckBox";
> = false;

float ZzzFaceAoStrength <
    string UIName = "面部AO强度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = 1.0;

bool ZzzFaceAoDebug <
    string UIName = "面部AO诊断";
    string UIWidget = "CheckBox";
> = false;

float ZzzFaceNoseStrength <
    string UIName = "鼻线强度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 4.0;
> = 1.25;

float ZzzFaceNoseStart <
    string UIName = "鼻线开始";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 0.20;

float ZzzFaceNoseEnd <
    string UIName = "鼻线结束";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 0.65;

float ZzzFaceNoseLength <
    string UIName = "鼻线长度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 4.0;
> = 1.6;

bool ZzzFaceNoseDebug <
    string UIName = "鼻线诊断";
    string UIWidget = "CheckBox";
> = false;

float ZzzFaceHighlightStrength <
    string UIName = "面部高光强度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 10.0;
> = 1.0;

float ZzzFaceHighlightWidth <
    string UIName = "面部高光宽度";
    string UIWidget = "Slider";
    float UIMin = 0.01;
    float UIMax = 1.0;
> = 0.16;

float ZzzFaceHighlightHardness <
    string UIName = "面部高光硬度";
    string UIWidget = "Slider";
    float UIMin = 0.1;
    float UIMax = 8.0;
> = 2.0;

bool ZzzFaceHighlightDebug <
    string UIName = "面部高光诊断";
    string UIWidget = "CheckBox";
> = false;

bool ZzzFaceRampDebug <
    string UIName = "面部Ramp诊断";
    string UIWidget = "CheckBox";
> = false;

float ZzzFaceRampStrength <
    string UIName = "面部红润强度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = ZZZ_FACE_SKIN_RAMP_STRENGTH_DEFAULT;

float ZzzFaceAlbedoSmoothness <
    string UIName = "红润过渡";
    string UIWidget = "Slider";
    float UIMin = 0.001;
    float UIMax = 0.5;
> = ZZZ_FACE_SKIN_RAMP_SMOOTHNESS_DEFAULT;

float3 ZzzFaceShallowColor <
    string UIName = "Ramp浅色";
    string UIWidget = "Color";
> = ZZZ_FACE_SKIN_SHALLOW_COLOR_DEFAULT;

float3 ZzzFaceShadowColor <
    string UIName = "Ramp阴影色";
    string UIWidget = "Color";
> = ZZZ_FACE_SKIN_SHADOW_COLOR_DEFAULT;

texture2D ZzzFaceDiffuseTexture <
    string ResourceName = ZZZ_FACE_DIFFUSE_RESOURCE;
    string Format = "A8R8G8B8";
>;
sampler2D ZzzFaceDiffuseSampler = sampler_state {
    texture = <ZzzFaceDiffuseTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 8;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D ZzzFaceLightTexture < string ResourceName = ZZZ_FACE_LIGHT_RESOURCE; >;
sampler2D ZzzFaceLightSampler = sampler_state {
    texture = <ZzzFaceLightTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

float4x4 ZzzFaceHeadBone : CONTROLOBJECT <
    string name = "(self)";
    string item = ZZZ_FACE_HEAD_BONE;
>;

float3 ZzzFaceSafeNormalize(float3 value, float3 fallbackValue)
{
    float lenSq = dot(value, value);
    return lenSq < 1e-8 ? fallbackValue : value * rsqrt(lenSq);
}

void ZzzFaceGetHeadBasis(
    out float3 headFront,
    out float3 headRight,
    out float3 headUp,
    out float valid)
{
    float3 forwardAxis = ZzzFaceHeadBone._31_32_33;
    float3 rightAxis = ZzzFaceHeadBone._11_12_13;
    float forwardLenSq = dot(forwardAxis, forwardAxis);
    float rightLenSq = dot(rightAxis, rightAxis);
    valid = (forwardLenSq > 1e-8 && rightLenSq > 1e-8) ? 1.0 : 0.0;
    if (valid < 0.5) {
        headFront = float3(0, 0, -1);
        headRight = float3(-1, 0, 0);
        headUp = float3(0, 1, 0);
        return;
    }

    // MMD/HS_Snow convention: -row3 is face front, -row1 is face right.
    headFront = -ZzzFaceSafeNormalize(forwardAxis, float3(0, 0, 1));
    headRight = -ZzzFaceSafeNormalize(rightAxis, float3(1, 0, 0));
    headUp = cross(headFront, headRight);
    if (dot(headUp, headUp) < 1e-8) {
        valid = 0.0;
        headFront = float3(0, 0, -1);
        headRight = float3(-1, 0, 0);
        headUp = float3(0, 1, 0);
        return;
    }
    headUp = normalize(headUp);
    headRight = normalize(cross(headUp, headFront));
}

float3 ZzzFaceSrgbToLinear(float3 color)
{
    return pow(saturate(color), 2.2);
}

float3 ZzzFaceLinearToSrgb(float3 color)
{
    return pow(max(color, 0.0), 1.0 / 2.2);
}

struct ZzzFaceAttributes {
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord0 : TEXCOORD0;
};

struct ZzzFaceVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
    float3 positionWS : TEXCOORD2;
};

ZzzFaceVaryings ZzzFaceVS(ZzzFaceAttributes input)
{
    ZzzFaceVaryings output = (ZzzFaceVaryings)0;
    output.positionCS = mul(input.positionOS, ZzzFaceWorldViewProjection);
    output.uv = input.texcoord0;
    output.positionWS = mul(input.positionOS, ZzzFaceWorld).xyz;
    output.normalWS = ZzzFaceSafeNormalize(
        mul(input.normalOS, (float3x3)ZzzFaceWorld), float3(0, 0, 1));
    return output;
}

float4 ZzzFacePS(
    ZzzFaceVaryings input,
    uniform bool useTexture) : COLOR0
{
    float4 materialColor = saturate(ZzzFaceMaterialDiffuse);
    float4 texel = tex2D(ZzzFaceDiffuseSampler, input.uv);
    float3 baseSrgb = useTexture ? materialColor.rgb * texel.rgb : materialColor.rgb;
    float3 baseLinear = ZzzFaceSrgbToLinear(baseSrgb);

    float3 headFront;
    float3 headRight;
    float3 headUp;
    float headValid;
    ZzzFaceGetHeadBasis(headFront, headRight, headUp, headValid);

    // MMD DIRECTION is ray travel direction; negate for surface-to-light.
    float3 lightWS = ZzzFaceSafeNormalize(
        -ZzzFaceLightDirection, -headFront);
    float3 horizontalLight = lightWS - headUp * dot(lightWS, headUp);
    horizontalLight = ZzzFaceSafeNormalize(horizontalLight, -headFront);

    float side = dot(horizontalLight, headRight);
    float front = dot(horizontalLight, headFront);
    // PMX conversion uses the opposite face-light U convention from Unity.
    // Reverse only left/right SDF selection; keep threshold and ramp unchanged.
    float mirrorFlag = step(0.0, -side);
    float2 faceUv = input.uv;
    faceUv.x = lerp(1.0 - input.uv.x, input.uv.x, mirrorFlag);
    float4 faceLight = tex2D(ZzzFaceLightSampler, faceUv);

    // HoyoToon contract: R is the authored face shadow field, A is AO.
    float faceMap = saturate(faceLight.r * 0.9 + 0.1);
    float threshold = saturate(
        1.0 - (front * 0.5 + 0.5)
            + ZzzFaceControlledThresholdOffset(ZzzFaceThresholdOffset));
    float faceSoftness = ZzzFaceControlledSoftness(ZzzFaceSoftness);
    float brightMask = smoothstep(
        threshold - faceSoftness,
        threshold + faceSoftness,
        faceMap);

    // A=1 keeps the accepted SDF unchanged. Lower authored AO values only
    // choose the existing dark branch; no post-color multiply is performed.
    float faceAo = pow(
        max(saturate(faceLight.a), 1e-5),
        max(ZzzFaceControlledAo(ZzzFaceAoStrength), 0.0));
    brightMask = min(brightMask, faceAo);

    if (ZzzFaceLightDebug) {
        return float4(faceMap.xxx, 1.0);
    }
    if (ZzzFaceAoDebug) {
        return float4(faceAo.xxx, 1.0);
    }

    float3 shadowLinear =
        baseLinear * ZZZ_FACE_SKIN_BASE_SHADOW_DEFAULT;
    float3 shadedLinear = lerp(shadowLinear, baseLinear, brightMask);

#if ZZZ_FACE_RAMP_ENABLE != 0
    // The reference ShadeAlbedo uses only ShadowColor and ShallowColor here.
    // SunColor belongs to a later lighting/rim chain and must not enter the
    // face SDF boundary. Preserve luminance so this layer cannot re-darken the
    // accepted base/shadow result or create a pale contour between branches.
    const float3 rampLumaWeights = float3(0.299, 0.587, 0.114);
    float shadowLuma = max(
        dot(ZzzFaceShadowColor, rampLumaWeights), 0.001);
    float shallowLuma = max(
        dot(ZzzFaceShallowColor, rampLumaWeights), 0.001);
    float3 shadowTint = ZzzFaceShadowColor / shadowLuma;
    float3 shallowTint = ZzzFaceShallowColor / shallowLuma;

    // Match the reference AlbedoSmoothness default (0.1). This is a narrow
    // color transition inside the existing accepted SDF transition, not a
    // second broad Ramp spanning the whole face.
    float albedoSmoothness = max(
        ZzzFaceSkinControlledRampSmoothness(ZzzFaceAlbedoSmoothness),
        0.001);
    float shallowWeight = smoothstep(
        0.5 - albedoSmoothness * 0.5,
        0.5 + albedoSmoothness * 0.5,
        saturate(brightMask));
    float3 rampTint = lerp(shadowTint, shallowTint, shallowWeight);
    if (ZzzFaceRampDebug) {
        float3 rampColor = lerp(
            ZzzFaceShadowColor,
            ZzzFaceShallowColor,
            shallowWeight);
        return float4(saturate(rampColor), 1.0);
    }
    shadedLinear = lerp(
        shadedLinear,
        shadedLinear * rampTint,
        saturate(ZzzFaceSkinControlledRampStrength(ZzzFaceRampStrength)));
#endif

    float3 viewWS = ZzzFaceSafeNormalize(
        ZzzFaceCameraPosition - input.positionWS, headFront);

    // Keep the accepted nose-line branch before the independent highlight.
    // This restores the phase-03 face result without changing its parameters.
    float ndotv = pow(
        saturate(dot(ZzzFaceSafeNormalize(input.normalWS, headFront), viewWS)),
        4.0);
    float noseGate = smoothstep(
        min(ZzzFaceNoseStart, ZzzFaceNoseEnd),
        max(ZzzFaceNoseStart, ZzzFaceNoseEnd),
        ndotv);
    float2 noseStep = float2(
        0.0,
        max(fwidth(input.uv.y), 1.0 / 2048.0)
            * max(ZzzFaceControlledNoseLength(ZzzFaceNoseLength), 0.0));
    float noseMaskCenter = 1.0 - saturate(texel.a);
    float noseMaskUp = 1.0 - saturate(
        tex2D(ZzzFaceDiffuseSampler, input.uv + noseStep).a);
    float noseMaskDown = 1.0 - saturate(
        tex2D(ZzzFaceDiffuseSampler, input.uv - noseStep).a);
    float noseMask = max(noseMaskCenter, max(noseMaskUp, noseMaskDown));
    float noseAmount = saturate(
        noseMask * noseGate
            * max(ZzzFaceControlledNoseStrength(ZzzFaceNoseStrength), 0.0));
    if (ZzzFaceNoseDebug) {
        return float4(noseAmount.xxx, 1.0);
    }
    shadedLinear *= lerp(
        float3(1.0, 1.0, 1.0),
        float3(0.45, 0.20, 0.18),
        noseAmount);

    float3 normalWS = ZzzFaceSafeNormalize(input.normalWS, headFront);
    float3 halfWS = ZzzFaceSafeNormalize(lightWS + viewWS, lightWS);
    float ndoth = pow(
        saturate(dot(normalWS, halfWS)),
        max(ZzzFaceControlledHighlightHardness(
            ZzzFaceHighlightHardness), 0.1) * 8.0);

    // HoyoToon keeps face highlight separate from direct diffuse lighting:
    // FaceLight G supplies the authored spot, N.H supplies view-dependent
    // response, and the narrow center gate rejects broad cheek illumination.
    float authoredMask = smoothstep(
        0.5,
        0.5 + max(ZzzFaceControlledHighlightWidth(
            ZzzFaceHighlightWidth), 0.01),
        saturate(faceLight.g));
    float centerMask = step(0.45, faceUv.x) * step(faceUv.x, 0.55);
    float highlightMask = saturate(
        authoredMask * centerMask * ndoth
            * max(ZzzFaceControlledHighlightStrength(
                ZzzFaceHighlightStrength), 0.0));
    if (ZzzFaceHighlightDebug) {
        return float4(highlightMask.xxx, 1.0);
    }
    shadedLinear += highlightMask * float3(1.0, 0.82, 0.68);
    shadedLinear *= max(ZzzFaceControlledBrightness(ZzzFaceBrightness), 0.0);
    float outputAlpha = useTexture
        ? materialColor.a * texel.a
        : materialColor.a;
    return float4(
        ZzzFaceLinearToSrgb(max(shadedLinear, 0.0)),
        saturate(outputAlpha));
}

#if ZZZ_FACE_HAIR_SHADOW_RECEIVER != 0
#define ZZZ_FACE_HAIR_SHADOW_STENCIL \
            StencilEnable = true; StencilFunc = ALWAYS; \
            StencilRef = 1; StencilWriteMask = 1; \
            StencilFail = KEEP; StencilZFail = KEEP; \
            StencilPass = REPLACE;
#else
#define ZZZ_FACE_HAIR_SHADOW_STENCIL
#endif

#define ZZZ_FACE_TECHNIQUE(name, passName, useTextureValue) \
    technique name < string MMDPass = passName; string Subset = ZZZ_FACE_SUBSET; \
        string Script = "RenderColorTarget0=;Pass=DrawObject;"; \
        bool UseTexture = useTextureValue; bool UseSelfShadow = false; > { \
        pass DrawObject { ZEnable = true; ZWriteEnable = true; \
            CullMode = NONE; AlphaBlendEnable = false; AlphaTestEnable = false; \
            ZZZ_FACE_HAIR_SHADOW_STENCIL \
            VertexShader = compile vs_3_0 ZzzFaceVS(); \
            PixelShader = compile ps_3_0 ZzzFacePS(useTextureValue); } }

ZZZ_FACE_TECHNIQUE(ZzzFace06ColorTune_NoTexture, "object", false)
ZZZ_FACE_TECHNIQUE(ZzzFace06ColorTune_Texture, "object", true)
ZZZ_FACE_TECHNIQUE(ZzzFace06ColorTune_ShadowNoTexture, "object_ss", false)
ZZZ_FACE_TECHNIQUE(ZzzFace06ColorTune_ShadowTexture, "object_ss", true)
