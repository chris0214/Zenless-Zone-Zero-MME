#ifndef ZZZ_HOYOTOON_HAIR_SPECULAR_INCLUDED
#define ZZZ_HOYOTOON_HAIR_SPECULAR_INCLUDED

// Hair specular acceptance stage derived from HoyoToon 5.2.7
// zzz-common.hlsl::specular(). Jane's material-ID 5 parameters are the
// defaults. MatCap is intentionally excluded from this module.

float ZZZ_HoyoHairSpecularIntensity <
    string UIName = "Hoyo Hair Specular Intensity";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 0.1;

float ZZZ_HoyoHairSpecularRange <
    string UIName = "Hoyo Hair Specular Range";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
> = 1.0;

float ZZZ_HoyoHairShapeSoftness <
    string UIName = "Hoyo Hair Shape Softness";
    string UIWidget = "Slider";
    float UIMin = 0.01;
    float UIMax = 1.0;
> = 0.1;

float ZZZ_HoyoHairMetallic <
    string UIName = "Hoyo Hair Metallic";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 1.0;

float ZZZ_HoyoHairGlossiness <
    string UIName = "Hoyo Hair Glossiness";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 1.0;

float ZZZ_HoyoHairModelSize <
    string UIName = "Hoyo Hair Model Size";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 5.0;
> = 3.0;

float3 ZZZ_HoyoHairSpecularColor = float3(
    0.26224878, 0.40197811, 0.35640028);

float ZZZ_HoyoHairUseHeadSphere <
    string UIName = "Hoyo Hair Head Sphere";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 1.0;

float ZZZ_HoyoHairHeadSphereRange <
    string UIName = "Hoyo Hair Head Sphere Range";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 0.1;

float ZZZ_HoyoHairDebugView <
    string UIName = "Hoyo Hair Debug View";
    string UIWidget = "Numeric";
    float UIMin = 0.0;
    float UIMax = 4.0;
> = 0.0;

float4x4 ZZZ_HoyoHairHeadBone : CONTROLOBJECT <
    string name = "(self)";
    string item = ZZZ_HEAD_BONE;
>;

struct ZZZ_HoyoHairSpecularResult {
    float authoredMask;
    float shapeMask;
    float shadowTerm;
    float3 color;
};

float ZZZ_HoyoHairShadowSignal(
    float normalBlue,
    float3 normalWS,
    float3 lightDirectionWS,
    float shadowVisibility)
{
    // HoyoToon shadow_body(): LightTex.B participates in the raw shadow
    // signal before specular() converts it to a shape attenuation term.
    float visibility = saturate(shadowVisibility);
    float aoTex = saturate(normalBlue) * visibility;
    aoTex = aoTex * 2.0 - 1.0;
    float ndotl = dot(normalWS, lightDirectionWS) * visibility;
    float shad = aoTex * 2.0 + ndotl;
    return saturate(shad * 1.5 + 0.5);
}

ZZZ_HoyoHairSpecularResult ZZZ_HoyoHairSpecular(
    float3 positionWS,
    float3 normalWS,
    float3 viewDirectionWS,
    float2 uv,
    float3 shadedBaseColor,
    float shadowVisibility)
{
    ZZZ_HoyoHairSpecularResult result;
    ZZZ_MaterialChannels channels =
        ZZZ_DecodeMaterialChannels(uv);
    float4 normalData = ZZZ_SampleNormalData(uv);

    float3 N = ZZZ_SafeNormalize(normalWS, float3(0.0, 1.0, 0.0));
    float3 V = ZZZ_SafeNormalize(viewDirectionWS, N);
    float3 L = ZZZ_SafeNormalize(
        -ZZZ_LightDirection, float3(0.0, 1.0, 0.0));
    float3 H = ZZZ_SafeNormalize(L + V, N);

    result.authoredMask = saturate(channels.specularMask);
    result.shadowTerm = ZZZ_HoyoHairShadowSignal(
        normalData.b, N, L, shadowVisibility);

    float3 specularNormal = N;
    float shapeWeight = result.shadowTerm;
    if (ZZZ_HoyoHairUseHeadSphere > 0.5) {
        float3 headCenterWS = ZZZ_HoyoHairHeadBone._41_42_43;
        float3 centerToPixel = positionWS - headCenterWS;
        float distanceToCenter = length(centerToPixel);
        float sphereBlend = 1.0 - saturate(
            20.0 * (distanceToCenter
                - max(ZZZ_HoyoHairHeadSphereRange, 0.0)));
        float3 sphereNormal = ZZZ_SafeNormalize(centerToPixel, N);
        specularNormal = ZZZ_SafeNormalize(
            lerp(N, sphereNormal, sphereBlend), N);
        shapeWeight = sqrt(saturate(
            dot(L, specularNormal) * 0.5 + 0.5));
    }

    // HoyoToon HighlightShape path:
    // saturate((M.B - (1 - biasedNdotH * weight)) / softness).
    float biasedNdotH = saturate(dot(specularNormal, H) * 0.5 + 0.5);
    float shapeEdge = 1.0 - biasedNdotH * shapeWeight;
    result.shapeMask = saturate(
        (result.authoredMask - shapeEdge)
        / max(ZZZ_HoyoHairShapeSoftness, 1e-4));

    float metallic = saturate(
        channels.metallic * ZZZ_HoyoHairMetallic);
    float smoothness = saturate(
        channels.smoothness * ZZZ_HoyoHairGlossiness);
    float3 baseColor = saturate(shadedBaseColor);
    float3 reflectance = lerp(0.04.xxx, baseColor, metallic);

    // This is the HighlightShape=true scalar branch used after HoyoToon's
    // mask construction. Preserve its range-dependent amplification, while
    // retaining the already accepted HgShadow suppression explicitly.
    float rangeValue = max(ZZZ_HoyoHairSpecularRange, 0.0);
    float rangeNdotL = saturate(
        dot(N, L) * rangeValue * 0.75 + 0.25);
    float rangeLdotH = max(
        0.1,
        saturate(dot(L, H) * rangeValue * 0.75 + 0.25));
    float toonScale = min(1.0, 0.166663334 / rangeLdotH)
        * rangeNdotL * 100.0;
    float smoothnessGuard = lerp(0.65, 1.0, smoothness);
    float modelScale = max(ZZZ_HoyoHairModelSize, 0.0) / 3.0;

    result.color = result.shapeMask
        * (max(ZZZ_HoyoHairSpecularIntensity, 0.0) * 10.0)
        * (ZZZ_HoyoHairSpecularColor * 0.5)
        * reflectance
        * toonScale
        * smoothnessGuard
        * modelScale
        * baseColor
        * saturate(shadowVisibility);
    return result;
}

float3 ZZZ_HoyoHairDebugColor(
    ZZZ_HoyoHairSpecularResult specular,
    float3 compositeColor)
{
    float view = floor(ZZZ_HoyoHairDebugView + 0.5);
    if (view == 1.0) return specular.authoredMask.xxx;
    if (view == 2.0) return specular.shapeMask.xxx;
    if (view == 3.0) return specular.shadowTerm.xxx;
    if (view == 4.0) return specular.color;
    return compositeColor;
}

#endif
