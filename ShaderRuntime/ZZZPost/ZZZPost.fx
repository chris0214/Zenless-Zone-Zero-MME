// ZZZ MME formal post-processing: four-layer NapBloom plus GT tonemap.
// GT runs in an ACEScg/AP1 working space before the final sRGB display transform.

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

float ZzzPostExposure <
    string UIName = "˜Io";
    string UIWidget = "Slider";
    float UIMin = 0.25;
    float UIMax = 3.0;
    float UIStep = 0.01;
> = 1.0;

float ZzzPostBloomIntensity <
    string UIName = "‹PŒõ‹­“x";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 3.0;
    float UIStep = 0.01;
> = 1.3;

float ZzzPostBloomThreshold <
    string UIName = "‹PŒõ‹«ŠE";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 2.0;
    float UIStep = 0.01;
> = 0.44922;

float ZzzPostBloomSoftKnee <
    string UIName = "‹PŒõ_“î";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
    float UIStep = 0.01;
> = 0.0;

float ZzzPostBloomRadius <
    string UIName = "‹PŒõ”ÍˆÍ";
    string UIWidget = "Slider";
    float UIMin = 0.25;
    float UIMax = 3.0;
    float UIStep = 0.01;
> = 1.0;

float ZzzNapBloomSuppression <
    string UIName = "‰ß—º—}§";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
    float UIStep = 0.01;
> = 1.0;

float ZzzNapBloomView <
    string UIName = "•\Ž¦";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 5.0;
    float UIStep = 1.0;
> = 0.0;

float ZzzPostGTLinearSectionStart <
    string UIName = "GTüŒ`‹N“_";
    string UIWidget = "Slider";
    float UIMin = 0.02;
    float UIMax = 0.8;
    float UIStep = 0.01;
> = 0.22;

float ZzzPostGTContrast <
    string UIName = "GT‘Î”ä";
    string UIWidget = "Slider";
    float UIMin = 0.2;
    float UIMax = 3.0;
    float UIStep = 0.01;
> = 1.2;

float ZzzPostGTBlackBrightness <
    string UIName = "GTˆÃ•”";
    string UIWidget = "Slider";
    float UIMin = 0.2;
    float UIMax = 4.0;
    float UIStep = 0.01;
> = 1.33;

float ZzzPostGTMaximumBrightness <
    string UIName = "GTÅ‘å‹P“x";
    string UIWidget = "Slider";
    float UIMin = 0.5;
    float UIMax = 3.0;
    float UIStep = 0.01;
> = 1.0;

float ZzzPostGTLinearSectionLength <
    string UIName = "GTüŒ`’·";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 0.95;
    float UIStep = 0.01;
> = 0.4;

#define ZZZ_POST_CONTROLLER_NAME "ZzzPost_controller.pmx"

float ZzzPostControlTonemap : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "GTF’²";
>;
float ZzzPostControlGTLinearStartP : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "GTüŒ`‹N“_+";
>;
float ZzzPostControlGTLinearStartM : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "GTüŒ`‹N“_-";
>;
float ZzzPostControlGTContrastP : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "GT‘Î”ä+";
>;
float ZzzPostControlGTContrastM : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "GT‘Î”ä-";
>;
float ZzzPostControlGTBlackBrightnessP : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "GTˆÃ•”+";
>;
float ZzzPostControlGTBlackBrightnessM : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "GTˆÃ•”-";
>;
float ZzzPostControlGTMaximumBrightnessP : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "GTÅ‘å‹P“x+";
>;
float ZzzPostControlGTMaximumBrightnessM : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "GTÅ‘å‹P“x-";
>;
float ZzzPostControlGTLinearLengthP : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "GTüŒ`’·+";
>;
float ZzzPostControlGTLinearLengthM : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "GTüŒ`’·-";
>;
float ZzzPostControlExposureP : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "˜Io+";
>;
float ZzzPostControlExposureM : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "˜Io-";
>;
float ZzzPostControlBloomIntensityP : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "‹PŒõ‹­+";
>;
float ZzzPostControlBloomIntensityM : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "‹PŒõ‹­-";
>;
float ZzzPostControlBloomThresholdP : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "‹PŒõ‹«ŠE+";
>;
float ZzzPostControlBloomThresholdM : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "‹PŒõ‹«ŠE-";
>;
float ZzzPostControlBloomSoftKneeP : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "‹PŒõ_“î+";
>;
float ZzzPostControlBloomSoftKneeM : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "‹PŒõ_“î-";
>;
float ZzzPostControlBloomRadiusP : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "‹PŒõ”ÍˆÍ+";
>;
float ZzzPostControlBloomRadiusM : CONTROLOBJECT <
    string name = ZZZ_POST_CONTROLLER_NAME;
    string item = "‹PŒõ”ÍˆÍ-";
>;

float4 ZzzPostSceneClearColor = float4(1.0, 1.0, 1.0, 0.0);
float4 ZzzPostBloomClearColor = float4(0.0, 0.0, 0.0, 0.0);
float ZzzPostClearDepth = 1.0;
float2 ZzzPostViewportSize : VIEWPORTPIXELSIZE;

static const float ZZZ_NAP_LEVEL0_RATIO = 0.140625;
static const float ZZZ_NAP_LEVEL1_RATIO = 0.0625;
static const float ZZZ_NAP_LEVEL2_RATIO = 0.03125;
static const float ZZZ_NAP_LEVEL3_RATIO = 0.015625;

texture2D ZzzPostSceneMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = { 1.0, 1.0 };
    int MipLevels = 1;
    string Format = "A16B16G16R16F";
>;

texture2D ZzzNapBloomLevel0Map : RENDERCOLORTARGET <
    float2 ViewPortRatio = { 0.140625, 0.140625 };
    int MipLevels = 1;
    string Format = "A16B16G16R16F";
>;
texture2D ZzzNapBloomLevel0TempMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = { 0.140625, 0.140625 };
    int MipLevels = 1;
    string Format = "A16B16G16R16F";
>;

texture2D ZzzNapBloomLevel1Map : RENDERCOLORTARGET <
    float2 ViewPortRatio = { 0.0625, 0.0625 };
    int MipLevels = 1;
    string Format = "A16B16G16R16F";
>;
texture2D ZzzNapBloomLevel1TempMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = { 0.0625, 0.0625 };
    int MipLevels = 1;
    string Format = "A16B16G16R16F";
>;

texture2D ZzzNapBloomLevel2Map : RENDERCOLORTARGET <
    float2 ViewPortRatio = { 0.03125, 0.03125 };
    int MipLevels = 1;
    string Format = "A16B16G16R16F";
>;
texture2D ZzzNapBloomLevel2TempMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = { 0.03125, 0.03125 };
    int MipLevels = 1;
    string Format = "A16B16G16R16F";
>;

texture2D ZzzNapBloomLevel3Map : RENDERCOLORTARGET <
    float2 ViewPortRatio = { 0.015625, 0.015625 };
    int MipLevels = 1;
    string Format = "A16B16G16R16F";
>;
texture2D ZzzNapBloomLevel3TempMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = { 0.015625, 0.015625 };
    int MipLevels = 1;
    string Format = "A16B16G16R16F";
>;

texture2D ZzzPostDepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = { 1.0, 1.0 };
    string Format = "D24S8";
>;

#define ZZZ_NAP_SAMPLER(name, textureName) \
sampler2D name = sampler_state { \
    texture = <textureName>; \
    MinFilter = LINEAR; \
    MagFilter = LINEAR; \
    MipFilter = NONE; \
    AddressU = CLAMP; \
    AddressV = CLAMP; \
};

ZZZ_NAP_SAMPLER(ZzzPostSceneSampler, ZzzPostSceneMap)
ZZZ_NAP_SAMPLER(ZzzNapBloomLevel0Sampler, ZzzNapBloomLevel0Map)
ZZZ_NAP_SAMPLER(ZzzNapBloomLevel0TempSampler, ZzzNapBloomLevel0TempMap)
ZZZ_NAP_SAMPLER(ZzzNapBloomLevel1Sampler, ZzzNapBloomLevel1Map)
ZZZ_NAP_SAMPLER(ZzzNapBloomLevel1TempSampler, ZzzNapBloomLevel1TempMap)
ZZZ_NAP_SAMPLER(ZzzNapBloomLevel2Sampler, ZzzNapBloomLevel2Map)
ZZZ_NAP_SAMPLER(ZzzNapBloomLevel2TempSampler, ZzzNapBloomLevel2TempMap)
ZZZ_NAP_SAMPLER(ZzzNapBloomLevel3Sampler, ZzzNapBloomLevel3Map)
ZZZ_NAP_SAMPLER(ZzzNapBloomLevel3TempSampler, ZzzNapBloomLevel3TempMap)

struct ZzzPostVaryings {
    float4 position : POSITION;
    float2 uv : TEXCOORD0;
};

ZzzPostVaryings ZzzPostVS(
    float4 position : POSITION,
    float4 texcoord : TEXCOORD0)
{
    ZzzPostVaryings output = (ZzzPostVaryings)0;
    output.position = position;
    output.uv = texcoord.xy;
    return output;
}

float2 ZzzPostSceneTexel()
{
    return 1.0 / max(ZzzPostViewportSize, float2(1.0, 1.0));
}

float2 ZzzNapBloomTexel(float ratio)
{
    return ZzzPostSceneTexel() / ratio;
}

float ZzzPostControllerSigned(float positive, float negative)
{
    return saturate(positive) - saturate(negative);
}

float ZzzPostControllerBounded(
    float baseValue,
    float positive,
    float negative,
    float minimumValue,
    float maximumValue)
{
    float neutral = clamp(baseValue, minimumValue, maximumValue);
    float control = ZzzPostControllerSigned(positive, negative);
    return clamp(
        neutral
            + (maximumValue - neutral) * max(control, 0.0)
            - (neutral - minimumValue) * max(-control, 0.0),
        minimumValue,
        maximumValue);
}

float ZzzPostEffectiveExposure()
{
    return ZzzPostControllerBounded(
        ZzzPostExposure,
        ZzzPostControlExposureP,
        ZzzPostControlExposureM,
        0.25,
        3.0);
}

float ZzzPostEffectiveBloomIntensity()
{
    return ZzzPostControllerBounded(
        ZzzPostBloomIntensity,
        ZzzPostControlBloomIntensityP,
        ZzzPostControlBloomIntensityM,
        0.0,
        3.0);
}

float ZzzPostEffectiveBloomThreshold()
{
    return ZzzPostControllerBounded(
        ZzzPostBloomThreshold,
        ZzzPostControlBloomThresholdP,
        ZzzPostControlBloomThresholdM,
        0.0,
        2.0);
}

float ZzzPostEffectiveBloomSoftKnee()
{
    return ZzzPostControllerBounded(
        ZzzPostBloomSoftKnee,
        ZzzPostControlBloomSoftKneeP,
        ZzzPostControlBloomSoftKneeM,
        0.0,
        1.0);
}

float ZzzPostEffectiveBloomRadius()
{
    return ZzzPostControllerBounded(
        ZzzPostBloomRadius,
        ZzzPostControlBloomRadiusP,
        ZzzPostControlBloomRadiusM,
        0.25,
        3.0);
}

float ZzzPostTonemapAmount()
{
    return saturate(ZzzPostControlTonemap);
}

float ZzzPostEffectiveGTLinearSectionStart()
{
    return ZzzPostControllerBounded(
        ZzzPostGTLinearSectionStart,
        ZzzPostControlGTLinearStartP,
        ZzzPostControlGTLinearStartM,
        0.02,
        0.8);
}

float ZzzPostEffectiveGTContrast()
{
    return ZzzPostControllerBounded(
        ZzzPostGTContrast,
        ZzzPostControlGTContrastP,
        ZzzPostControlGTContrastM,
        0.2,
        3.0);
}

float ZzzPostEffectiveGTBlackBrightness()
{
    return ZzzPostControllerBounded(
        ZzzPostGTBlackBrightness,
        ZzzPostControlGTBlackBrightnessP,
        ZzzPostControlGTBlackBrightnessM,
        0.2,
        4.0);
}

float ZzzPostEffectiveGTMaximumBrightness()
{
    return ZzzPostControllerBounded(
        ZzzPostGTMaximumBrightness,
        ZzzPostControlGTMaximumBrightnessP,
        ZzzPostControlGTMaximumBrightnessM,
        0.5,
        3.0);
}

float ZzzPostEffectiveGTLinearSectionLength()
{
    return ZzzPostControllerBounded(
        ZzzPostGTLinearSectionLength,
        ZzzPostControlGTLinearLengthP,
        ZzzPostControlGTLinearLengthM,
        0.0,
        0.95);
}

float3 ZzzPostSrgbToLinear(float3 color)
{
    float3 low = color / 12.92;
    float3 high = pow(max((color + 0.055) / 1.055, 1e-6), 2.4);
    return lerp(low, high, step(0.04045, color));
}

float3 ZzzPostLinearToSrgb(float3 color)
{
    color = max(color, 0.0);
    float3 low = color * 12.92;
    float3 high = 1.055 * pow(max(color, 1e-6), 1.0 / 2.4) - 0.055;
    return lerp(low, high, step(0.0031308, color));
}

float3 ZzzPostLinearSrgbToAcesCg(float3 color)
{
    const float3x3 linearSrgbToAcesCg = {
        0.61309740, 0.33952315, 0.04737945,
        0.07019372, 0.91635388, 0.01345240,
        0.02061559, 0.10956977, 0.86981463
    };
    return mul(linearSrgbToAcesCg, color);
}

float3 ZzzPostAcesCgToLinearSrgb(float3 color)
{
    const float3x3 acesCgToLinearSrgb = {
         1.70505154, -0.62179068, -0.08325840,
        -0.13025714,  1.14080285, -0.01054853,
        -0.02400328, -0.12896898,  1.15297165
    };
    return mul(acesCgToLinearSrgb, color);
}

float3 ZzzNapBloomPrefilter(float3 color)
{
    float threshold = ZzzPostEffectiveBloomThreshold();
    float3 hardThreshold = max(color - threshold, 0.0);

    float brightness = max(color.r, max(color.g, color.b));
    float softKnee = ZzzPostEffectiveBloomSoftKnee();
    float knee = max(threshold * max(softKnee, 1e-4), 1e-5);
    float soft = brightness - threshold + knee;
    soft = clamp(soft, 0.0, 2.0 * knee);
    soft = soft * soft / (4.0 * knee + 1e-5);
    float contribution = max(soft, brightness - threshold);
    contribution /= max(brightness, 1e-5);
    float3 softThreshold = color * contribution;

    return lerp(hardThreshold, softThreshold, softKnee);
}

float3 ZzzPostGT(float3 color)
{
    const float epsilon = 1e-4;
    float P = max(ZzzPostEffectiveGTMaximumBrightness(), 0.5);
    float a = max(ZzzPostEffectiveGTContrast(), epsilon);
    float m = clamp(
        ZzzPostEffectiveGTLinearSectionStart(),
        epsilon,
        P - epsilon);
    float l = clamp(ZzzPostEffectiveGTLinearSectionLength(), 0.0, 0.95);
    float c = max(ZzzPostEffectiveGTBlackBrightness(), epsilon);
    const float b = 0.0;

    color = max(color, 0.0);

    float l0 = ((P - m) * l) / a;
    float L0 = m - m / a;
    float L1 = m + (1.0 - m) / a;
    float S0 = m + l0;
    float S1 = m + a * l0;
    float C2 = (a * P) / (P - S1);
    float CP = -C2 / P;

    float3 w0 = 1.0 - smoothstep(0.0, m, color);
    float3 w2 = step(m + l0, color);
    float3 w1 = 1.0 - w0 - w2;

    float3 toe = m * pow(max(color / m, 0.0), c) + b;
    float3 linearSegment = m + a * (color - m);
    float3 shoulder = P - (P - S1) * exp(CP * (color - S0));
    return max(toe * w0 + linearSegment * w1 + shoulder * w2, 0.0);
}

float3 ZzzNapDownsample4(
    sampler2D sourceSampler,
    float2 uv,
    float2 sourceTexel)
{
    float2 center = uv + sourceTexel * 0.5;
    float3 color = 0.0;
    color += tex2D(sourceSampler, center + sourceTexel * float2(-0.5, -0.5)).rgb;
    color += tex2D(sourceSampler, center + sourceTexel * float2( 0.5, -0.5)).rgb;
    color += tex2D(sourceSampler, center + sourceTexel * float2(-0.5,  0.5)).rgb;
    color += tex2D(sourceSampler, center + sourceTexel * float2( 0.5,  0.5)).rgb;
    return color * 0.25;
}

float3 ZzzNapGaussian6(
    sampler2D sourceSampler,
    float2 uv,
    float2 sourceTexel,
    float2 direction)
{
    float2 center = uv + sourceTexel * 0.5;
    float2 user = sourceTexel * direction * ZzzPostEffectiveBloomRadius();
    float3 color = 0.0;
    color += tex2D(sourceSampler, center + user * -2.2226281).rgb * 0.1334844;
    color += tex2D(sourceSampler, center + user * -4.0952849).rgb * 0.0057047;
    color += tex2D(sourceSampler, center + user * -0.4378030).rgb * 0.5018920;
    color += tex2D(sourceSampler, center + user *  1.3207670).rgb * 0.3234969;
    color += tex2D(sourceSampler, center + user *  3.1479740).rgb * 0.0348785;
    color += tex2D(sourceSampler, center + user *  5.0000000).rgb * 0.0005436;
    return color;
}

float3 ZzzNapGaussian9(
    sampler2D sourceSampler,
    float2 uv,
    float2 sourceTexel,
    float2 direction)
{
    float2 center = uv + sourceTexel * 0.5;
    float2 user = sourceTexel * direction * ZzzPostEffectiveBloomRadius();
    float3 color = 0.0;
    color += tex2D(sourceSampler, center + user * -5.2274981).rgb * 0.0151298;
    color += tex2D(sourceSampler, center + user * -7.1588202).rgb * 0.0009649;
    color += tex2D(sourceSampler, center + user * -3.3147621).rgb * 0.1009583;
    color += tex2D(sourceSampler, center + user * -1.4174120).rgb * 0.2889000;
    color += tex2D(sourceSampler, center + user *  0.4722446).rgb * 0.3564036;
    color += tex2D(sourceSampler, center + user *  2.3645480).rgb * 0.1897708;
    color += tex2D(sourceSampler, center + user *  4.2688980).rgb * 0.0434656;
    color += tex2D(sourceSampler, center + user *  6.1908078).rgb * 0.0042536;
    color += tex2D(sourceSampler, center + user *  8.0000000).rgb * 0.0001532;
    return color;
}

float3 ZzzNapGaussian16(
    sampler2D sourceSampler,
    float2 uv,
    float2 sourceTexel,
    float2 direction)
{
    float2 center = uv + sourceTexel * 0.5;
    float2 user = sourceTexel * direction * ZzzPostEffectiveBloomRadius();
    float3 color = 0.0;
    color += tex2D(sourceSampler, center + user * -12.2933798).rgb * 0.0009471;
    color += tex2D(sourceSampler, center + user * -14.2650900).rgb * 0.0001463;
    color += tex2D(sourceSampler, center + user * -10.3233604).rgb * 0.0046463;
    color += tex2D(sourceSampler, center + user *  -8.3548632).rgb * 0.0172796;
    color += tex2D(sourceSampler, center + user *  -6.3876772).rgb * 0.0487266;
    color += tex2D(sourceSampler, center + user *  -4.4215422).rgb * 0.1042022;
    color += tex2D(sourceSampler, center + user *  -2.4561620).rgb * 0.1690129;
    color += tex2D(sourceSampler, center + user *  -0.4912108).rgb * 0.2079370;
    color += tex2D(sourceSampler, center + user *   1.4736540).rgb * 0.1940565;
    color += tex2D(sourceSampler, center + user *   3.4387779).rgb * 0.1373738;
    color += tex2D(sourceSampler, center + user *   5.4044962).rgb * 0.0737621;
    color += tex2D(sourceSampler, center + user *   7.3711209).rgb * 0.0300379;
    color += tex2D(sourceSampler, center + user *   9.3389330).rgb * 0.0092757;
    color += tex2D(sourceSampler, center + user *  11.3081703).rgb * 0.0021717;
    color += tex2D(sourceSampler, center + user *  13.2790203).rgb * 0.0003854;
    color += tex2D(sourceSampler, center + user *  15.0000000).rgb * 0.000038788519;
    return color;
}

float3 ZzzNapGaussian20(
    sampler2D sourceSampler,
    float2 uv,
    float2 sourceTexel,
    float2 direction)
{
    float2 center = uv + sourceTexel * 0.5;
    float2 user = sourceTexel * direction * ZzzPostEffectiveBloomRadius();
    float3 color = 0.0;
    color += tex2D(sourceSampler, center + user * -16.3224392).rgb * 0.0003934;
    color += tex2D(sourceSampler, center + user * -18.3031006).rgb * 0.000082805367;
    color += tex2D(sourceSampler, center + user * -14.3424101).rgb * 0.0015638;
    color += tex2D(sourceSampler, center + user * -12.3629599).rgb * 0.0052015;
    color += tex2D(sourceSampler, center + user * -10.3840103).rgb * 0.0144784;
    color += tex2D(sourceSampler, center + user *  -8.4055147).rgb * 0.0337260;
    color += tex2D(sourceSampler, center + user *  -6.4273849).rgb * 0.0657471;
    color += tex2D(sourceSampler, center + user *  -4.4495420).rgb * 0.1072673;
    color += tex2D(sourceSampler, center + user *  -2.4719019).rgb * 0.1464697;
    color += tex2D(sourceSampler, center + user *  -0.4943747).rgb * 0.1673879;
    color += tex2D(sourceSampler, center + user *   1.4831300).rgb * 0.1601027;
    color += tex2D(sourceSampler, center + user *   3.4607019).rgb * 0.1281654;
    color += tex2D(sourceSampler, center + user *   5.4384332).rgb * 0.0858689;
    color += tex2D(sourceSampler, center + user *   7.4164090).rgb * 0.0481489;
    color += tex2D(sourceSampler, center + user *   9.3947134).rgb * 0.0225949;
    color += tex2D(sourceSampler, center + user *  11.3734198).rgb * 0.0088735;
    color += tex2D(sourceSampler, center + user *  13.3526201).rgb * 0.0029162;
    color += tex2D(sourceSampler, center + user *  15.3323498).rgb * 0.0008020;
    color += tex2D(sourceSampler, center + user *  17.3126907).rgb * 0.0001846;
    color += tex2D(sourceSampler, center + user *  19.0000000).rgb * 0.00002509824;
    return color;
}

float4 ZzzNapPrefilterPS(float2 uv : TEXCOORD0) : COLOR0
{
    float2 sourceTexel = ZzzPostSceneTexel();
    float2 center = uv + sourceTexel * 0.5;
    float3 color = 0.0;
    color += ZzzPostSrgbToLinear(tex2D(
        ZzzPostSceneSampler,
        center + sourceTexel * float2(-0.5, -0.5)).rgb);
    color += ZzzPostSrgbToLinear(tex2D(
        ZzzPostSceneSampler,
        center + sourceTexel * float2( 0.5, -0.5)).rgb);
    color += ZzzPostSrgbToLinear(tex2D(
        ZzzPostSceneSampler,
        center + sourceTexel * float2(-0.5,  0.5)).rgb);
    color += ZzzPostSrgbToLinear(tex2D(
        ZzzPostSceneSampler,
        center + sourceTexel * float2( 0.5,  0.5)).rgb);
    color = color * 0.25 * ZzzPostEffectiveExposure();
    return float4(ZzzNapBloomPrefilter(color), 1.0);
}

float4 ZzzNapLevel0HPS(float2 uv : TEXCOORD0) : COLOR0
{
    return float4(ZzzNapGaussian6(
        ZzzNapBloomLevel0Sampler,
        uv,
        ZzzNapBloomTexel(ZZZ_NAP_LEVEL0_RATIO),
        float2(1.0, 0.0)), 1.0);
}

float4 ZzzNapLevel0VPS(float2 uv : TEXCOORD0) : COLOR0
{
    return float4(ZzzNapGaussian6(
        ZzzNapBloomLevel0TempSampler,
        uv,
        ZzzNapBloomTexel(ZZZ_NAP_LEVEL0_RATIO),
        float2(0.0, 1.0)), 1.0);
}

float4 ZzzNapLevel1DownPS(float2 uv : TEXCOORD0) : COLOR0
{
    return float4(ZzzNapDownsample4(
        ZzzNapBloomLevel0Sampler,
        uv,
        ZzzNapBloomTexel(ZZZ_NAP_LEVEL0_RATIO)), 1.0);
}

float4 ZzzNapLevel1HPS(float2 uv : TEXCOORD0) : COLOR0
{
    return float4(ZzzNapGaussian9(
        ZzzNapBloomLevel1Sampler,
        uv,
        ZzzNapBloomTexel(ZZZ_NAP_LEVEL1_RATIO),
        float2(1.0, 0.0)), 1.0);
}

float4 ZzzNapLevel1VPS(float2 uv : TEXCOORD0) : COLOR0
{
    return float4(ZzzNapGaussian9(
        ZzzNapBloomLevel1TempSampler,
        uv,
        ZzzNapBloomTexel(ZZZ_NAP_LEVEL1_RATIO),
        float2(0.0, 1.0)), 1.0);
}

float4 ZzzNapLevel2DownPS(float2 uv : TEXCOORD0) : COLOR0
{
    return float4(ZzzNapDownsample4(
        ZzzNapBloomLevel1Sampler,
        uv,
        ZzzNapBloomTexel(ZZZ_NAP_LEVEL1_RATIO)), 1.0);
}

float4 ZzzNapLevel2HPS(float2 uv : TEXCOORD0) : COLOR0
{
    return float4(ZzzNapGaussian16(
        ZzzNapBloomLevel2Sampler,
        uv,
        ZzzNapBloomTexel(ZZZ_NAP_LEVEL2_RATIO),
        float2(1.0, 0.0)), 1.0);
}

float4 ZzzNapLevel2VPS(float2 uv : TEXCOORD0) : COLOR0
{
    return float4(ZzzNapGaussian16(
        ZzzNapBloomLevel2TempSampler,
        uv,
        ZzzNapBloomTexel(ZZZ_NAP_LEVEL2_RATIO),
        float2(0.0, 1.0)), 1.0);
}

float4 ZzzNapLevel3DownPS(float2 uv : TEXCOORD0) : COLOR0
{
    return float4(ZzzNapDownsample4(
        ZzzNapBloomLevel2Sampler,
        uv,
        ZzzNapBloomTexel(ZZZ_NAP_LEVEL2_RATIO)), 1.0);
}

float4 ZzzNapLevel3HPS(float2 uv : TEXCOORD0) : COLOR0
{
    return float4(ZzzNapGaussian20(
        ZzzNapBloomLevel3Sampler,
        uv,
        ZzzNapBloomTexel(ZZZ_NAP_LEVEL3_RATIO),
        float2(1.0, 0.0)), 1.0);
}

float4 ZzzNapLevel3VPS(float2 uv : TEXCOORD0) : COLOR0
{
    return float4(ZzzNapGaussian20(
        ZzzNapBloomLevel3TempSampler,
        uv,
        ZzzNapBloomTexel(ZZZ_NAP_LEVEL3_RATIO),
        float2(0.0, 1.0)), 1.0);
}

float3 ZzzNapSuppressBloom(float3 bloom)
{
    const float threshold = 0.3;
    float3 compressed = pow(max(bloom / threshold, 0.0), 1.0 / 3.0)
        - (1.0 - threshold);
    float3 selected = lerp(bloom, compressed, step(threshold, bloom));
    return lerp(bloom, selected, saturate(ZzzNapBloomSuppression));
}

float ZzzNapModeWeight(float mode, float center)
{
    return step(center - 0.49, mode) * (1.0 - step(center + 0.49, mode));
}

float4 ZzzNapFinalPS(float2 uv : TEXCOORD0) : COLOR0
{
    float2 sceneTexel = ZzzPostSceneTexel();
    float2 level0Texel = ZzzNapBloomTexel(ZZZ_NAP_LEVEL0_RATIO);
    float2 level1Texel = ZzzNapBloomTexel(ZZZ_NAP_LEVEL1_RATIO);
    float2 level2Texel = ZzzNapBloomTexel(ZZZ_NAP_LEVEL2_RATIO);
    float2 level3Texel = ZzzNapBloomTexel(ZZZ_NAP_LEVEL3_RATIO);

    float4 scene = tex2D(ZzzPostSceneSampler, uv + sceneTexel * 0.5);
    float3 sceneLinear = ZzzPostSrgbToLinear(scene.rgb)
        * ZzzPostEffectiveExposure();

    float3 bloom0 = tex2D(
        ZzzNapBloomLevel0Sampler, uv + level0Texel * 0.5).rgb;
    float3 bloom1 = tex2D(
        ZzzNapBloomLevel1Sampler, uv + level1Texel * 0.5).rgb;
    float3 bloom2 = tex2D(
        ZzzNapBloomLevel2Sampler, uv + level2Texel * 0.5).rgb;
    float3 bloom3 = tex2D(
        ZzzNapBloomLevel3Sampler, uv + level3Texel * 0.5).rgb;

    float3 bloomRaw =
        bloom0 * 0.29688
        + bloom1 * 0.29688
        + bloom2 * 0.25781
        + bloom3 * 0.14844;
    float3 bloom = ZzzNapSuppressBloom(bloomRaw)
        * ZzzPostEffectiveBloomIntensity();

    float3 combined = sceneLinear + bloom;
    float3 gtWorking = ZzzPostLinearSrgbToAcesCg(combined);
    float3 gtMapped = ZzzPostAcesCgToLinearSrgb(
        ZzzPostGT(gtWorking));
    float3 mapped = lerp(
        combined,
        gtMapped,
        ZzzPostTonemapAmount());
    float3 finalColor = saturate(ZzzPostLinearToSrgb(mapped));

    float mode = floor(ZzzNapBloomView + 0.5);
    float wFinal = ZzzNapModeWeight(mode, 0.0);
    float w0 = ZzzNapModeWeight(mode, 1.0);
    float w1 = ZzzNapModeWeight(mode, 2.0);
    float w2 = ZzzNapModeWeight(mode, 3.0);
    float w3 = ZzzNapModeWeight(mode, 4.0);
    float wCombined = ZzzNapModeWeight(mode, 5.0);
    float3 debugColor =
        bloom0 * w0
        + bloom1 * w1
        + bloom2 * w2
        + bloom3 * w3
        + bloom * wCombined;
    float3 outputColor = finalColor * wFinal
        + saturate(ZzzPostLinearToSrgb(debugColor)) * (1.0 - wFinal);
    return float4(outputColor, scene.a);
}

technique ZZZPost <
    string Script =
        "RenderColorTarget0=ZzzPostSceneMap;"
        "RenderDepthStencilTarget=ZzzPostDepthBuffer;"
        "ClearSetColor=ZzzPostSceneClearColor;"
        "ClearSetDepth=ZzzPostClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"

        "RenderColorTarget0=ZzzNapBloomLevel0Map;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=ZzzPostBloomClearColor;"
        "Clear=Color;"
        "Pass=NapPrefilter;"
        "RenderColorTarget0=ZzzNapBloomLevel0TempMap;"
        "Clear=Color;"
        "Pass=NapLevel0H;"
        "RenderColorTarget0=ZzzNapBloomLevel0Map;"
        "Clear=Color;"
        "Pass=NapLevel0V;"

        "RenderColorTarget0=ZzzNapBloomLevel1Map;"
        "Clear=Color;"
        "Pass=NapLevel1Down;"
        "RenderColorTarget0=ZzzNapBloomLevel1TempMap;"
        "Clear=Color;"
        "Pass=NapLevel1H;"
        "RenderColorTarget0=ZzzNapBloomLevel1Map;"
        "Clear=Color;"
        "Pass=NapLevel1V;"

        "RenderColorTarget0=ZzzNapBloomLevel2Map;"
        "Clear=Color;"
        "Pass=NapLevel2Down;"
        "RenderColorTarget0=ZzzNapBloomLevel2TempMap;"
        "Clear=Color;"
        "Pass=NapLevel2H;"
        "RenderColorTarget0=ZzzNapBloomLevel2Map;"
        "Clear=Color;"
        "Pass=NapLevel2V;"

        "RenderColorTarget0=ZzzNapBloomLevel3Map;"
        "Clear=Color;"
        "Pass=NapLevel3Down;"
        "RenderColorTarget0=ZzzNapBloomLevel3TempMap;"
        "Clear=Color;"
        "Pass=NapLevel3H;"
        "RenderColorTarget0=ZzzNapBloomLevel3Map;"
        "Clear=Color;"
        "Pass=NapLevel3V;"

        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=NapFinal;";
> {
    pass NapPrefilter < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapPrefilterPS();
    }
    pass NapLevel0H < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapLevel0HPS();
    }
    pass NapLevel0V < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapLevel0VPS();
    }
    pass NapLevel1Down < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapLevel1DownPS();
    }
    pass NapLevel1H < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapLevel1HPS();
    }
    pass NapLevel1V < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapLevel1VPS();
    }
    pass NapLevel2Down < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapLevel2DownPS();
    }
    pass NapLevel2H < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapLevel2HPS();
    }
    pass NapLevel2V < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapLevel2VPS();
    }
    pass NapLevel3Down < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapLevel3DownPS();
    }
    pass NapLevel3H < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapLevel3HPS();
    }
    pass NapLevel3V < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapLevel3VPS();
    }
    pass NapFinal < string Script = "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 ZzzPostVS();
        PixelShader = compile ps_3_0 ZzzNapFinalPS();
    }
}
