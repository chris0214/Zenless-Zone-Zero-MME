// ZZZ EyeThrough compositor. Capture and mask are dispatched by the
// OFFSCREENRENDERTARGET default effect; this root pass only composites it.
#include "../internal/zzz_eye_controls.inc"
#include "../internal/zzz_eye_through_contract.hlsl"

float4 ZZZ_EyeEyeThroughClearColor = float4(0.0, 0.0, 0.0, 0.0);
float ZZZ_EyeEyeThroughClearDepth = 1.0;

texture2D ZZZ_EyeEyeThrough_RT : OFFSCREENRENDERTARGET <
    string Description = "ZZZ facial-feature capture";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = {0.0, 0.0, 0.0, 0.0};
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    int MipLevels = 1;
    string Format = "A8R8G8B8";
    string DefaultEffect = "* = ZZZEyeThrough_Capture.fxsub;";
>;

sampler2D ZZZ_EyeEyeThroughSampler = sampler_state {
    texture = <ZZZ_EyeEyeThrough_RT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

// Keep color filtering smooth, but read alpha from the actual RT pixel.
// Linear alpha filtering lets a front-facing brow bleed into side/back
// pixels when the feature becomes only a few pixels wide at distance.
sampler2D ZZZ_EyeEyeThroughAlphaSampler = sampler_state {
    texture = <ZZZ_EyeEyeThrough_RT>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D ZZZ_EyeHairMask_RT : OFFSCREENRENDERTARGET <
    string Description = "ZZZ fringe visibility mask";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = {0.0, 0.0, 0.0, 0.0};
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    int MipLevels = 1;
    string Format = "A8R8G8B8";
    string DefaultEffect = "* = ZZZEyeThrough_HairMask.fxsub;";
>;

sampler2D ZZZ_EyeHairMaskSampler = sampler_state {
    texture = <ZZZ_EyeHairMask_RT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

// Reject the low-coverage fringe produced by the anti-aliased hair mask.
// This prevents a distant one-pixel mask halo from lifting brows in front
// of the fringe while retaining a small inner edge feather.
float ZZZ_EyeHairMaskCutoff = 0.55;
float ZZZ_EyeHairMaskFeather = 0.30;

float ZZZ_EyeEyeThroughScript : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

float4 ZZZ_EyeEyeThroughMaterialDiffuse : DIFFUSE <
    string Object = "Geometry";
>;
float2 ZZZ_EyeEyeThroughViewportSize : VIEWPORTPIXELSIZE;

struct ZZZ_EyeEyeThroughQuadVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
};

ZZZ_EyeEyeThroughQuadVaryings ZZZ_EyeEyeThroughQuadVS(
    float4 positionCS : POSITION,
    float2 uv : TEXCOORD0)
{
    ZZZ_EyeEyeThroughQuadVaryings output;
    output.positionCS = positionCS;
    output.uv = uv + 0.5 / max(ZZZ_EyeEyeThroughViewportSize, 1.0);
    return output;
}

float4 ZZZ_EyeEyeThroughCompositePS(
    ZZZ_EyeEyeThroughQuadVaryings input) : COLOR0
{
    float4 feature = tex2D(ZZZ_EyeEyeThroughSampler, input.uv);
    float captureAlpha = tex2D(
        ZZZ_EyeEyeThroughAlphaSampler, input.uv).a;
    feature.a = min(feature.a, captureAlpha);
    float hairCoverage = tex2D(ZZZ_EyeHairMaskSampler, input.uv).a;
    hairCoverage = smoothstep(
        saturate(ZzzEyeControlledThroughCutoff(
            ZZZ_EyeHairMaskCutoff)),
        saturate(ZzzEyeControlledThroughCutoff(
            ZZZ_EyeHairMaskCutoff)
            + max(ZzzEyeControlledThroughFeather(
                ZZZ_EyeHairMaskFeather), 0.001)),
        hairCoverage);
    feature.rgb = saturate(feature.rgb * max(
        ZzzEyeControlledThroughGain(ZZZ_EyeEyeThroughColorGain), 0.0));
    feature.a *= saturate(
        ZzzEyeControlledThroughStrength(ZZZ_EyeEyeThroughStrength));
    feature.a *= saturate(ZZZ_EyeEyeThroughMaterialDiffuse.a);
    // EyeThrough is only valid where the final scene contains front hair.
    // Uncovered eye pixels must remain untouched to avoid double exposure.
    feature.a *= saturate(hairCoverage);
    return feature;
}

technique ZZZ_EyeEyeThroughComposite <
    string MMDPass = "object";
    string Script =
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=ZZZ_EyeEyeThroughClearColor;"
        "ClearSetDepth=ZZZ_EyeEyeThroughClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=Composite;";
> {
    pass Composite < string Script = "Draw=Buffer;"; > {
        ZEnable = false;
        ZWriteEnable = false;
        CullMode = NONE;
        AlphaTestEnable = false;
        AlphaBlendEnable = true;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
        BlendOp = ADD;
        VertexShader = compile vs_3_0 ZZZ_EyeEyeThroughQuadVS();
        PixelShader = compile ps_3_0 ZZZ_EyeEyeThroughCompositePS();
    }
}
