#ifndef ZZZ_HAIR_HIGHLIGHT_INCLUDED
#define ZZZ_HAIR_HIGHLIGHT_INCLUDED

float ZZZ_HairHighlightStrength <
    string UIName = "Hair Highlight Strength";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 15.0;
> = 3.2;

float ZZZ_HairHighlightPosition <
    string UIName = "Hair Highlight Position";
    string UIWidget = "Slider";
    float UIMin = -0.8;
    float UIMax = 0.8;
> = 0.08;

float ZZZ_HairHighlightWidth <
    string UIName = "Hair Highlight Width";
    string UIWidget = "Slider";
    float UIMin = 0.02;
    float UIMax = 0.8;
> = 0.24;

float3 ZZZ_HairHighlightColor = float3(
    0.26224878, 0.40197811, 0.35640028);

float4x4 ZZZ_HairHighlightHeadBone : CONTROLOBJECT <
    string name = "(self)";
    string item = ZZZ_HEAD_BONE;
>;

float ZZZ_HairReverseSmoothstep(float edge, float value)
{
    float t = saturate((edge - value) / max(edge, 1e-5));
    return t * t * (3.0 - 2.0 * t);
}

void ZZZ_HairUvFrame(
    float3 positionWS,
    float3 normalWS,
    float2 uv,
    out float3 tangentWS,
    out float3 binormalWS,
    out float valid)
{
    float3 dpdx = ddx(positionWS);
    float3 dpdy = ddy(positionWS);
    float2 duvdx = ddx(uv);
    float2 duvdy = ddy(uv);
    float determinant = duvdx.x * duvdy.y - duvdx.y * duvdy.x;
    valid = abs(determinant) > 1e-8 ? 1.0 : 0.0;
    float orientation = determinant < 0.0 ? -1.0 : 1.0;
    float3 tangentRaw =
        (dpdx * duvdy.y - dpdy * duvdx.y) * orientation;
    tangentWS = ZZZ_SafeNormalize(
        tangentRaw - normalWS * dot(normalWS, tangentRaw),
        float3(1.0, 0.0, 0.0));
    binormalWS = ZZZ_SafeNormalize(
        cross(tangentWS, normalWS),
        float3(0.0, 1.0, 0.0));
}

float ZZZ_HairHighlightMask(
    float3 positionWS,
    float3 normalWS,
    float3 viewDirectionWS,
    float2 uv)
{
    float3 tangentWS;
    float3 hairBinormalWS;
    float uvValid;
    ZZZ_HairUvFrame(
        positionWS, normalWS, uv,
        tangentWS, hairBinormalWS, uvValid);

    float3 headUpWS = ZZZ_SafeNormalize(
        ZZZ_HairHighlightHeadBone._21_22_23,
        float3(0.0, 1.0, 0.0));
    float3 azimuthViewWS = viewDirectionWS
        - headUpWS * dot(viewDirectionWS, headUpWS);
    azimuthViewWS = ZZZ_SafeNormalize(
        azimuthViewWS, viewDirectionWS);

    float4 property = ZZZ_SampleAttributes(uv);
    float3 shiftedIncoming = ZZZ_SafeNormalize(
        lerp(
            azimuthViewWS + headUpWS
                * ZZZ_HairHighlightPosition,
            azimuthViewWS,
            saturate(property.r)),
        azimuthViewWS);
    float signedBand = dot(shiftedIncoming, hairBinormalWS);
    float band = ZZZ_HairReverseSmoothstep(
        max(ZZZ_HairHighlightWidth, 1e-4),
        abs(signedBand));
    float3 azimuthNormalWS = normalWS
        - headUpWS * dot(normalWS, headUpWS);
    azimuthNormalWS = ZZZ_SafeNormalize(
        azimuthNormalWS, normalWS);
    float azimuthNoV = saturate(dot(
        azimuthNormalWS, azimuthViewWS));
    float facing = pow(azimuthNoV, 5.0);
    return band
        * lerp(1.0, saturate(property.g), uvValid)
        * facing
        * saturate(property.a);
}

float3 ZZZ_HairHighlight(
    float3 positionWS,
    float3 normalWS,
    float3 viewDirectionWS,
    float2 uv)
{
    ZZZ_MaterialChannels channels =
        ZZZ_DecodeMaterialChannels(uv);
    float mask = ZZZ_HairHighlightMask(
        positionWS, normalWS, viewDirectionWS, uv);
    // Jane's Map2_M.b paints the intended scalloped highlight coverage.
    // Do not retain a procedural floor outside that authored mask.
    float authoredSpecular = saturate(channels.specularMask);
    float3 lightColor = max(ZZZ_LightColor, 0.35);
    return ZZZ_HairHighlightColor
        * lightColor
        * mask
        * authoredSpecular
        * max(ZZZ_HairHighlightStrength, 0.0);
}

#endif
