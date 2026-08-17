#ifndef ZZZ_DECODE_INCLUDED
#define ZZZ_DECODE_INCLUDED

// Exact Phase 2 channel reconstruction derived from the audited reference node
// groups. D is handled by ZZZ_SampleBase; this file owns N/M/A/FaceLight.

#if ZZZ_USE_NORMAL
texture2D ZZZ_NormalTexture < string ResourceName = ZZZ_NORMAL_RESOURCE; >;
sampler2D ZZZ_NormalSampler = sampler_state {
    texture = <ZZZ_NormalTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = WRAP; AddressV = WRAP;
};
#endif

#if ZZZ_USE_MATERIAL
texture2D ZZZ_MaterialTexture < string ResourceName = ZZZ_MATERIAL_RESOURCE; >;
sampler2D ZZZ_MaterialSampler = sampler_state {
    texture = <ZZZ_MaterialTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = WRAP; AddressV = WRAP;
};
#endif

#if ZZZ_USE_ATTRIBUTES
texture2D ZZZ_AttributeTexture < string ResourceName = ZZZ_ATTRIBUTE_RESOURCE; >;
sampler2D ZZZ_AttributeSampler = sampler_state {
    texture = <ZZZ_AttributeTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = WRAP; AddressV = WRAP;
};
#endif

#if ZZZ_USE_FACELIGHT
texture2D ZZZ_FaceLightTexture < string ResourceName = ZZZ_FACELIGHT_RESOURCE; >;
sampler2D ZZZ_FaceLightSampler = sampler_state {
    texture = <ZZZ_FaceLightTexture>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
    AddressU = CLAMP; AddressV = CLAMP;
};

float4x4 ZZZ_HeadBone : CONTROLOBJECT <
    string name = "(self)";
    string item = ZZZ_HEAD_BONE;
>;
#endif

struct ZZZ_MaterialChannels {
    float materialId;
    float metallic;
    float specularMask;
    float smoothness;
    float matCapMask;
};

struct ZZZ_FaceLightChannels {
    float angleMapping;
    float angleFunction;
    float angleMapMask;
    float angleThreshold;
};

float4 ZZZ_SampleNormalData(float2 uv)
{
#if ZZZ_USE_NORMAL
    return tex2D(ZZZ_NormalSampler, uv);
#else
    return float4(0.5, 0.5, 0.5, 1.0);
#endif
}

float4 ZZZ_SampleMaterial(float2 uv)
{
#if ZZZ_USE_MATERIAL
    return tex2D(ZZZ_MaterialSampler, uv);
#else
    // M.r=0.8 decodes to MaterialId 0. M.b keeps the neutral specular mask.
    return float4(0.8, 0.0, 1.0, 1.0);
#endif
}

float4 ZZZ_SampleAttributes(float2 uv)
{
#if ZZZ_USE_ATTRIBUTES
    return tex2D(ZZZ_AttributeSampler, uv);
#else
    return float4(0.0, 0.5, 0.0, 1.0);
#endif
}

float3 ZZZ_ReconstructNormal(
    float3 positionWS,
    float3 geometricNormalWS,
    float2 uv)
{
#if ZZZ_USE_NORMAL
    float3 N = ZZZ_SafeNormalize(geometricNormalWS, float3(0, 1, 0));
    float3 dpdx = ddx(positionWS);
    float3 dpdy = ddy(positionWS);
    float2 duvdx = ddx(uv);
    float2 duvdy = ddy(uv);
    float determinant = duvdx.x * duvdy.y - duvdx.y * duvdy.x;
    float orientation = determinant < 0.0 ? -1.0 : 1.0;
    float3 tangent = (dpdx * duvdy.y - dpdy * duvdx.y) * orientation;
    float3 bitangent = (dpdy * duvdx.x - dpdx * duvdy.x) * orientation;
    float3 T = ZZZ_SafeNormalize(tangent, float3(1, 0, 0));
    float3 B = ZZZ_SafeNormalize(bitangent, cross(N, T));

    // DecodeLightTex: N.rg * 2 - 1, apply BumpScale, then reconstruct Z.
    float2 mapXY = (ZZZ_SampleNormalData(uv).rg * 2.0 - 1.0)
        * ZZZ_NORMAL_STRENGTH;
    mapXY.y *= ZZZ_NORMAL_Y_SIGN;
    float mapZ = sqrt(1.0 - min(dot(mapXY, mapXY), 1.0));
    return ZZZ_SafeNormalize(
        T * mapXY.x + B * mapXY.y + N * mapZ,
        N);
#else
    return ZZZ_SafeNormalize(geometricNormalWS, float3(0, 1, 0));
#endif
}

float ZZZ_DiffuseBias(float2 uv)
{
#if ZZZ_USE_NORMAL
    // DecodeLightTex routes the already signed B channel through Multiply(2).
    return (ZZZ_SampleNormalData(uv).b * 2.0 - 1.0) * 2.0;
#else
    return 0.0;
#endif
}

float ZZZ_DecodeMaterialId(float packedMaterialId)
{
    // DecodeOtherTex: max(4 - floor(M.r * 5), 0).
    return max(4.0 - floor(saturate(packedMaterialId) * 5.0), 0.0);
}

ZZZ_MaterialChannels ZZZ_DecodeMaterialChannels(float2 uv)
{
    float4 material = ZZZ_SampleMaterial(uv);
    float4 attributes = ZZZ_SampleAttributes(uv);
    ZZZ_MaterialChannels decoded;
    decoded.materialId = ZZZ_DecodeMaterialId(material.r);
    decoded.metallic = saturate(material.g);
    decoded.specularMask = saturate(material.b);
    decoded.smoothness = saturate(attributes.g);
    decoded.matCapMask = saturate(attributes.b);

#if ZZZ_DOMAIN == ZZZ_DOMAIN_FACE
    // The reference IsBody gate zeros body-only channels. Smoothness keeps the
    // authored non-body default from DecodeOtherTex2.
    decoded.materialId = 0.0;
    decoded.metallic = 0.0;
    decoded.specularMask = 0.0;
    decoded.smoothness = 0.58;
    decoded.matCapMask = 0.0;
#endif
    return decoded;
}

float ZZZ_SelectFloat5(
    float materialId,
    float value1,
    float value2,
    float value3,
    float value4,
    float value5)
{
    if (materialId > 3.0) return value5;
    if (materialId > 2.0) return value4;
    if (materialId > 1.0) return value3;
    if (materialId > 0.0) return value2;
    return value1;
}

float4 ZZZ_SelectColor5(
    float materialId,
    float4 value1,
    float4 value2,
    float4 value3,
    float4 value4,
    float4 value5)
{
    if (materialId > 3.0) return value5;
    if (materialId > 2.0) return value4;
    if (materialId > 1.0) return value3;
    if (materialId > 0.0) return value2;
    return value1;
}

void ZZZ_GetHeadBasis(
    out float3 headFront,
    out float3 headRight,
    out float3 headUp,
    out float valid)
{
#if ZZZ_USE_FACELIGHT
    float3 forwardAxis = ZZZ_HeadBone._31_32_33;
    float3 rightAxis = ZZZ_HeadBone._11_12_13;
    float forwardLengthSquared = dot(forwardAxis, forwardAxis);
    float rightLengthSquared = dot(rightAxis, rightAxis);
    valid = (forwardLengthSquared > 1e-8 && rightLengthSquared > 1e-8)
        ? 1.0 : 0.0;
    if (valid < 0.5) {
        headFront = float3(0.0, 0.0, -1.0);
        headRight = float3(-1.0, 0.0, 0.0);
        headUp = float3(0.0, 1.0, 0.0);
        return;
    }

    // Endfield/HS_Snow standard MMD head-bone convention.
    headFront = -ZZZ_SafeNormalize(forwardAxis, float3(0, 0, 1));
    headRight = -ZZZ_SafeNormalize(rightAxis, float3(1, 0, 0));
    float3 upAxis = cross(headFront, headRight);
    if (dot(upAxis, upAxis) < 1e-8) {
        valid = 0.0;
        headFront = float3(0.0, 0.0, -1.0);
        headRight = float3(-1.0, 0.0, 0.0);
        headUp = float3(0.0, 1.0, 0.0);
        return;
    }
    headUp = normalize(upAxis);
    headRight = normalize(cross(headUp, headFront));
#else
    headFront = float3(0.0, 0.0, -1.0);
    headRight = float3(-1.0, 0.0, 0.0);
    headUp = float3(0.0, 1.0, 0.0);
    valid = 0.0;
#endif
}

ZZZ_FaceLightChannels ZZZ_DecodeFaceLight(
    float2 uv,
    float3 lightDirectionWS)
{
    ZZZ_FaceLightChannels decoded;
    decoded.angleMapping = 0.0;
    decoded.angleFunction = 0.0;
    decoded.angleMapMask = 0.0;
    decoded.angleThreshold = 0.0;

#if ZZZ_USE_FACELIGHT
    float3 headFront;
    float3 headRight;
    float3 headUp;
    float headBasisValid;
    ZZZ_GetHeadBasis(
        headFront, headRight, headUp, headBasisValid);

    float3 L = ZZZ_SafeNormalize(lightDirectionWS, -headFront);
    float3 horizontalLight = L - headUp * dot(L, headUp);
    horizontalLight = ZZZ_SafeNormalize(horizontalLight, -headFront);
    float rightDot = dot(horizontalLight, headRight);
    float forwardDot = dot(horizontalLight, -headFront);
    float normalizedAngle = atan2(forwardDot, rightDot) / 3.14159265358979323846;

    decoded.angleThreshold = 1.0 - abs(normalizedAngle);
    float useMirroredUv = rightDot > 0.0 ? 1.0 : 0.0;
    float4 normalSample = tex2D(ZZZ_FaceLightSampler, uv);
    float4 mirroredSample = tex2D(
        ZZZ_FaceLightSampler,
        float2(1.0 - uv.x, uv.y));
    float4 selectedSample = lerp(normalSample, mirroredSample, useMirroredUv);
    decoded.angleMapping = selectedSample.r;
    decoded.angleFunction = selectedSample.g;
    decoded.angleMapMask = selectedSample.a;
#endif
    return decoded;
}

#endif
