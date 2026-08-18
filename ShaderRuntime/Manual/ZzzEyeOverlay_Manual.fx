// ZZZ eye overlay manual material. Set unused subsets to 2147483647.
#define ZZZ_EYE_OVERLAY_RESOURCE "../textures/common/neutral_base.png"
#define ZZZ_EYE_LASH_SUBSET "2147483647"
#define ZZZ_EYE_INNER_SUBSET "2147483647"
#define ZZZ_EYE_HIGHLIGHT_SUBSET "2147483647"
#define ZZZ_EYE_SHADOW_SUBSET "2147483647"

#include "../internal/zzz_eye_controls.inc"

float4x4 ZzzEyeOverlayWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 ZzzEyeOverlayWorld : WORLD;
float3 ZzzEyeOverlayCameraPosition : POSITION < string Object = "Camera"; >;
float4 ZzzEyeOverlayMaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;

// Fade clip-space decal bias with distance so distant overlays cannot jump in front of hair.
#define ZZZ_EYE_OVERLAY_BIAS_NEAR_DISTANCE 8.0
#define ZZZ_EYE_OVERLAY_BIAS_FAR_DISTANCE 24.0

float ZzzEyeInnerOpacity <
    string UIName = "内光透明";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 0.50;

float ZzzEyeInnerBrightness <
    string UIName = "Inner light brightness";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 16.0;
> = 9.0;

float ZzzEyeInnerMaskGain <
    string UIName = "内光遮罩增益";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 8.0;
> = 1.0;

float ZzzEyeInnerMaskCutoff <
    string UIName = "Inner light cutoff";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 0.12;

float ZzzEyeInnerEdgeSoftness <
    string UIName = "内光边缘柔度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 0.25;
> = 0.025;

float ZzzEyeHighlightOpacity <
    string UIName = "外光透明";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 1.0;

float ZzzEyeHighlightBrightness <
    string UIName = "外光明度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 4.0;
> = 1.0;

float ZzzEyeShadowOpacity <
    string UIName = "目影透明";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 0.50;

float ZzzEyeShadowBrightness <
    string UIName = "目影明度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = 1.0;

float ZzzEyeOverlayDepthBias <
    string UIName = "覆盖前移";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 0.002;
> = 0.00020;

texture2D ZzzEyeOverlayTexture <
    string ResourceName = ZZZ_EYE_OVERLAY_RESOURCE;
    string Format = "A8R8G8B8";
>;
sampler2D ZzzEyeOverlaySampler = sampler_state {
    texture = <ZzzEyeOverlayTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = ANISOTROPIC;
    MaxAnisotropy = 8;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

float3 ZzzEyeOverlaySrgbToLinear(float3 color)
{
    return pow(saturate(color), 2.2);
}

float3 ZzzEyeOverlayLinearToSrgb(float3 color)
{
    return pow(max(color, 0.0), 1.0 / 2.2);
}

struct ZzzEyeOverlayAttributes {
    float4 positionOS : POSITION;
    float2 texcoord0 : TEXCOORD0;
};

struct ZzzEyeOverlayVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
};

ZzzEyeOverlayVaryings ZzzEyeOverlayVSCore(
    ZzzEyeOverlayAttributes input,
    float depthOrder)
{
    ZzzEyeOverlayVaryings output = (ZzzEyeOverlayVaryings)0;
    output.positionCS = mul(
        input.positionOS,
        ZzzEyeOverlayWorldViewProjection);
    // Authored overlay geometry must remain in front of the accepted iris.
    // The rank follows the model's real geometry: inner light, eye shadow,
    // then outer highlight from front to back. PMX subset order is unrelated.
    float3 positionWS = mul(input.positionOS, ZzzEyeOverlayWorld).xyz;
    float distanceToCamera = length(
        ZzzEyeOverlayCameraPosition - positionWS);
    float distanceBiasFade = 1.0 - smoothstep(
        ZZZ_EYE_OVERLAY_BIAS_NEAR_DISTANCE,
        ZZZ_EYE_OVERLAY_BIAS_FAR_DISTANCE,
        distanceToCamera);
    output.positionCS.z -= max(ZzzEyeOverlayDepthBias, 0.0)
        * distanceBiasFade * depthOrder * output.positionCS.w;
    output.uv = input.texcoord0;
    return output;
}

ZzzEyeOverlayVaryings ZzzEyeInnerVS(ZzzEyeOverlayAttributes input)
{
    return ZzzEyeOverlayVSCore(input, 4.0);
}

ZzzEyeOverlayVaryings ZzzEyeLashVS(ZzzEyeOverlayAttributes input)
{
    return ZzzEyeOverlayVSCore(input, 5.0);
}

ZzzEyeOverlayVaryings ZzzEyeHighlightVS(ZzzEyeOverlayAttributes input)
{
    return ZzzEyeOverlayVSCore(input, 2.0);
}

ZzzEyeOverlayVaryings ZzzEyeShadowVS(ZzzEyeOverlayAttributes input)
{
    return ZzzEyeOverlayVSCore(input, 3.0);
}

float4 ZzzEyeOverlayColor(
    float2 uv,
    float opacity,
    float brightness,
    bool useTexture,
    bool useTextureAlpha,
    float textureAlphaGain,
    float baseMaterialAlpha)
{
    float4 materialColor = saturate(ZzzEyeOverlayMaterialDiffuse);
    float4 texel = tex2D(ZzzEyeOverlaySampler, uv);
    float3 baseSrgb = useTexture
        ? texel.rgb * materialColor.rgb
        : materialColor.rgb;
    // Preserve the authored reference opacity while still allowing PMX material
    // morphs to hide a layer. Eye shadow already stores 0.5 in PMX, whereas
    // inner light stores 1.0 and receives its 0.5 from the reference shader.
    float materialVisibility = saturate(
        materialColor.a / max(baseMaterialAlpha, 0.001));
    float coverage = saturate(opacity) * materialVisibility;
    if (useTexture && useTextureAlpha) {
        coverage *= saturate(texel.a * max(textureAlphaGain, 0.0));
    }
    clip(coverage - 0.001);

    float3 colorLinear = ZzzEyeOverlaySrgbToLinear(baseSrgb);
    colorLinear *= max(brightness, 0.0);
    return float4(
        ZzzEyeOverlayLinearToSrgb(colorLinear),
        saturate(coverage));
}

float4 ZzzEyeInnerPS(
    ZzzEyeOverlayVaryings input,
    uniform bool useTexture) : COLOR0
{
    float4 materialColor = saturate(ZzzEyeOverlayMaterialDiffuse);
    float4 texel = tex2D(ZzzEyeOverlaySampler, input.uv);
    float materialVisibility = saturate(materialColor.a);
    float coverage = saturate(
        ZzzEyeControlledInnerOpacity(ZzzEyeInnerOpacity))
        * materialVisibility;
    if (useTexture) {
        float maskAlpha = saturate(
            texel.a * max(
                ZzzEyeControlledInnerMask(ZzzEyeInnerMaskGain), 0.0));
        float edgeWidth = max(ZzzEyeInnerEdgeSoftness, 0.001);
        float sharpMask = smoothstep(
            saturate(ZzzEyeInnerMaskCutoff - edgeWidth),
            saturate(ZzzEyeInnerMaskCutoff + edgeWidth),
            maskAlpha);
        coverage *= sharpMask;
    }
    clip(coverage - 0.001);

    // Inner light is an unlit emissive decal. Its RGB must not be multiplied
    // by the PMX diffuse color; the atlas Alpha alone defines its shape.
    float3 sourceSrgb = useTexture ? texel.rgb : 1.0.xxx;
    float3 emissionLinear = ZzzEyeOverlaySrgbToLinear(sourceSrgb)
        * max(ZzzEyeControlledInnerBrightness(
            ZzzEyeInnerBrightness), 0.0);
    return float4(
        ZzzEyeOverlayLinearToSrgb(emissionLinear),
        coverage);
}

float4 ZzzEyeLashPS(
    ZzzEyeOverlayVaryings input,
    uniform bool useTexture) : COLOR0
{
    return ZzzEyeOverlayColor(
        input.uv,
        1.0,
        1.0,
        useTexture,
        true,
        1.0,
        1.0);
}

float4 ZzzEyeHighlightPS(
    ZzzEyeOverlayVaryings input,
    uniform bool useTexture) : COLOR0
{
    // Fixed texture-driven highlight: no view fade and no light-direction gate.
    return ZzzEyeOverlayColor(
        input.uv,
        ZzzEyeControlledHighlightOpacity(ZzzEyeHighlightOpacity),
        ZzzEyeControlledHighlightBrightness(ZzzEyeHighlightBrightness),
        useTexture,
        false,
        1.0,
        1.0);
}

float4 ZzzEyeShadowPS(
    ZzzEyeOverlayVaryings input,
    uniform bool useTexture) : COLOR0
{
    return ZzzEyeOverlayColor(
        input.uv,
        ZzzEyeShadowOpacity,
        ZzzEyeShadowBrightness,
        useTexture,
        false,
        1.0,
        0.5);
}

#define ZZZ_EYE_OVERLAY_TECHNIQUE( \
    name, passName, subsetValue, useTextureValue, vertexShaderName, \
    pixelShaderName, zWriteValue, destBlendValue) \
    technique name < \
        string MMDPass = passName; \
        string Subset = subsetValue; \
        string Script = "RenderColorTarget0=;Pass=DrawObject;"; \
        bool UseTexture = useTextureValue; \
        bool UseSelfShadow = false; \
    > { \
        pass DrawObject { \
            ZEnable = true; \
            ZWriteEnable = zWriteValue; \
            ZFunc = LESS; \
            CullMode = NONE; \
            AlphaTestEnable = false; \
            AlphaBlendEnable = true; \
            SrcBlend = SRCALPHA; \
            DestBlend = destBlendValue; \
            BlendOp = ADD; \
            VertexShader = compile vs_3_0 vertexShaderName(); \
            PixelShader = compile ps_3_0 pixelShaderName(useTextureValue); \
        } \
    }

ZZZ_EYE_OVERLAY_TECHNIQUE(
    ZzzEyeLashObject, "object", ZZZ_EYE_LASH_SUBSET, true, ZzzEyeLashVS, ZzzEyeLashPS,
    true, INVSRCALPHA)
ZZZ_EYE_OVERLAY_TECHNIQUE(
    ZzzEyeLashObjectSs, "object_ss", ZZZ_EYE_LASH_SUBSET, true, ZzzEyeLashVS, ZzzEyeLashPS,
    true, INVSRCALPHA)

ZZZ_EYE_OVERLAY_TECHNIQUE(
    ZzzEyeInnerObject, "object", ZZZ_EYE_INNER_SUBSET, true, ZzzEyeInnerVS, ZzzEyeInnerPS,
    false, ONE)
ZZZ_EYE_OVERLAY_TECHNIQUE(
    ZzzEyeInnerObjectSs, "object_ss", ZZZ_EYE_INNER_SUBSET, true, ZzzEyeInnerVS, ZzzEyeInnerPS,
    false, ONE)

ZZZ_EYE_OVERLAY_TECHNIQUE(
    ZzzEyeHighlightObject, "object", ZZZ_EYE_HIGHLIGHT_SUBSET, true,
    ZzzEyeHighlightVS, ZzzEyeHighlightPS, true, INVSRCALPHA)
ZZZ_EYE_OVERLAY_TECHNIQUE(
    ZzzEyeHighlightObjectSs, "object_ss", ZZZ_EYE_HIGHLIGHT_SUBSET, true,
    ZzzEyeHighlightVS, ZzzEyeHighlightPS, true, INVSRCALPHA)

ZZZ_EYE_OVERLAY_TECHNIQUE(
    ZzzEyeShadowObject, "object", ZZZ_EYE_SHADOW_SUBSET, true, ZzzEyeShadowVS, ZzzEyeShadowPS,
    true, INVSRCALPHA)
ZZZ_EYE_OVERLAY_TECHNIQUE(
    ZzzEyeShadowObjectSs, "object_ss", ZZZ_EYE_SHADOW_SUBSET, true,
    ZzzEyeShadowVS, ZzzEyeShadowPS, true, INVSRCALPHA)

technique ZzzEyeOverlayEdge < string MMDPass = "edge"; > { }
technique ZzzEyeOverlayShadow < string MMDPass = "shadow"; > { }
technique ZzzEyeOverlayZPlot < string MMDPass = "zplot"; > { }
