#ifndef ZZZ_MATCAP_INCLUDED
#define ZZZ_MATCAP_INCLUDED

#ifndef ZZZ_MATCAP_ADD_RESOURCE
#define ZZZ_MATCAP_ADD_RESOURCE ""
#endif
#ifndef ZZZ_MATCAP_OVERLAY_RESOURCE
#define ZZZ_MATCAP_OVERLAY_RESOURCE ""
#endif

float4x4 ZZZ_MatcapView : VIEW;

texture2D ZZZ_MatcapAddTexture <
    string ResourceName = ZZZ_MATCAP_ADD_RESOURCE;
>;
sampler2D ZZZ_MatcapAddSampler = sampler_state {
    texture = <ZZZ_MatcapAddTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D ZZZ_MatcapOverlayTexture <
    string ResourceName = ZZZ_MATCAP_OVERLAY_RESOURCE;
>;
sampler2D ZZZ_MatcapOverlaySampler = sampler_state {
    texture = <ZZZ_MatcapOverlayTexture>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

float ZZZ_MatcapStrength <
    string UIName = "Hair MatCap Strength";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = 1.0;
float ZZZ_MatcapAddStrength <
    string UIName = "Hair MatCap Add Strength";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = 1.0;
float ZZZ_MatcapAddNarrowness <
    string UIName = "Hair MatCap Add Narrowness";
    string UIWidget = "Slider";
    float UIMin = 1.0;
    float UIMax = 8.0;
> = 2.0;
float ZZZ_MatcapOverlayStrength <
    string UIName = "Hair MatCap Overlay Strength";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = 1.0;

float2 ZZZ_MatcapUv(float3 normalWS)
{
    float3 normalVS = ZZZ_SafeNormalize(
        mul(normalWS, (float3x3)ZZZ_MatcapView),
        float3(0.0, 0.0, 1.0));
    return saturate(normalVS.xy * float2(0.5, -0.5) + 0.5);
}

float3 ZZZ_Overlay(float3 baseColor, float3 blendColor)
{
    float3 low = 2.0 * baseColor * blendColor;
    float3 high = 1.0
        - 2.0 * (1.0 - baseColor) * (1.0 - blendColor);
    return lerp(low, high, step(0.5, baseColor));
}

float3 ZZZ_ApplyHairMatcap(
    float3 baseColor,
    float3 normalWS,
    float specularMask,
    float matcapMask,
    float shadowVisibility)
{
    float visibility = saturate(shadowVisibility)
        * max(ZZZ_MatcapStrength, 0.0);
    float2 matcapUv = ZZZ_MatcapUv(normalWS);

    // Jane reference hair MatCap slot 1:
    // Eff_Matcap_013, ColorBurst=1.09, AlphaBurst=0.84, BlendMode=Add.
    float3 addTex = ZZZ_SrgbToLinear(
        tex2D(ZZZ_MatcapAddSampler, matcapUv).rgb);
    float addLuminance = max(dot(
        addTex, float3(0.2126, 0.7152, 0.0722)), 1e-5);
    float narrowedLuminance = pow(
        saturate(addLuminance),
        max(ZZZ_MatcapAddNarrowness, 1.0));
    addTex *= narrowedLuminance / addLuminance;
    // Hair's A.b is nearly empty. M.b is the authored hair-highlight
    // coverage, while the sampled MatCap remains the sole view-driven shape.
    float addMask = saturate(specularMask * visibility * 0.84
        * max(ZZZ_MatcapAddStrength, 0.0));
    float3 color = baseColor + addTex * 1.09 * addMask;

    // Jane reference hair MatCap slot 4:
    // Eff_Matcap_047, ColorBurst=0.64, AlphaBurst=0.37,
    // BlendMode=Overlay. This follows the audited ShadeMatCap node chain.
    float3 overlayTex = ZZZ_SrgbToLinear(
        tex2D(ZZZ_MatcapOverlaySampler, matcapUv).rgb);
    float overlayMask = saturate(matcapMask * visibility * 0.37
        * max(ZZZ_MatcapOverlayStrength, 0.0));
    float3 overlayAdjusted = overlayTex
        + (overlayTex - 0.5) * 0.64;
    float3 overlayBlend = lerp(0.5.xxx, overlayAdjusted, overlayMask);
    return ZZZ_Overlay(color, overlayBlend);
}

#endif
