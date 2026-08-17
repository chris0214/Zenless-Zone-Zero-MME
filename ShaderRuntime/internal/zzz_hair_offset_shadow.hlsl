#ifndef ZZZ_HAIR_OFFSET_SHADOW_INCLUDED
#define ZZZ_HAIR_OFFSET_SHADOW_INCLUDED

float4x4 ZZZ_HairShadowWorld : WORLD;
float4x4 ZZZ_HairShadowView : VIEW;
float4x4 ZZZ_HairShadowProjection : PROJECTION;
float3 ZZZ_HairShadowLightDirection : DIRECTION < string Object = "Light"; >;
float3 ZZZ_HairShadowCameraPosition : POSITION < string Object = "Camera"; >;
float4x4 ZZZ_HairShadowHeadBone : CONTROLOBJECT < string name = "(self)"; string item = "頭"; >;

float ZZZ_HairShadowOffsetX = 0.012;
float ZZZ_HairShadowOffsetY = 0.008;
float ZZZ_HairShadowDepthBias = 0.12;
float ZZZ_HairShadowOpacity = 0.32;
float2 ZZZ_HairShadowViewportSize : VIEWPORTPIXELSIZE;

struct ZZZ_HairShadowVaryings {
    float4 positionCS : POSITION;
    float2 uv : TEXCOORD0;
    float4 sourcePositionCS : TEXCOORD1;
};

ZZZ_HairShadowVaryings ZZZ_HairShadowVS(float4 positionOS : POSITION, float2 uv : TEXCOORD0)
{
    ZZZ_HairShadowVaryings output;
    float3 positionWS = mul(positionOS, ZZZ_HairShadowWorld).xyz;
    float3 positionVS = mul(float4(positionWS, 1.0), ZZZ_HairShadowView).xyz;
    output.sourcePositionCS = mul(float4(positionVS, 1.0), ZZZ_HairShadowProjection);
    float3 lightVS = normalize(mul(-ZZZ_HairShadowLightDirection, (float3x3)ZZZ_HairShadowView));
    float lightX = clamp(lightVS.x, -1.0, 1.0);
    float pitch = 1.0 - smoothstep(-0.25, 0.65,
        dot(normalize(ZZZ_HairShadowCameraPosition - ZZZ_HairShadowHeadBone._41_42_43),
            normalize(ZZZ_HairShadowHeadBone._21_22_23)));
    positionVS.x -= lightX * ZZZ_HairShadowOffsetX;
    positionVS.y -= ZZZ_HairShadowOffsetY * pitch;
    positionVS.z -= max(ZZZ_HairShadowDepthBias, 0.0);
    output.positionCS = mul(float4(positionVS, 1.0), ZZZ_HairShadowProjection);
    output.uv = uv;
    return output;
}

float4 ZZZ_HairShadowPS(ZZZ_HairShadowVaryings input) : COLOR0
{
    float2 sourceNdc = input.sourcePositionCS.xy / max(abs(input.sourcePositionCS.w), 1e-6);
    float2 sourceUv = float2((1.0 + sourceNdc.x) * 0.5, (1.0 - sourceNdc.y) * 0.5);
    sourceUv += 0.5 / max(ZZZ_HairShadowViewportSize, 1.0);
    float4 capturedHair = tex2D(ZZZ_HairVisibilitySampler, sourceUv);
    float capturedDepth = dot(capturedHair.rgb, float3(1.0, 1.0 / 255.0, 1.0 / 65025.0));
    float sourceDepth = saturate(input.sourcePositionCS.z / max(abs(input.sourcePositionCS.w), 1e-6));
    float sourceVisible = step(0.5, capturedHair.a) * step(sourceDepth, capturedDepth + 0.0015);
    clip(sourceVisible - 0.5);
    return float4(0.24, 0.16, 0.18, saturate(ZZZ_HairShadowOpacity));
}

#endif
