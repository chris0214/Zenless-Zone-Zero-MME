#ifndef ZZZ_HGSAO_CONTRACT_INCLUDED
#define ZZZ_HGSAO_CONTRACT_INCLUDED

// HgSAO_v002 is a separate post-process. This file deliberately contains no
// AO sampling so Body/Face shaders cannot accidentally double-apply AO.
#define ZZZ_HGSAO_NAME "HgSAO_v002"
#define ZZZ_HGSAO_NML_RT "HgSAO_NmlRT"
#define ZZZ_HGSAO_DEPTH_RT "HgSAO_DepRT"
#define ZZZ_HGSAO_RAW_RT "SSAO_Tex"
#define ZZZ_HGSAO_BLUR_RT "SSAO_Tex2"

bool ZZZ_HgSAOEnabled : CONTROLOBJECT <
    string name = "(self)";
    string item = "HgSAO";
>;
float ZZZ_HgSAOCancel : CONTROLOBJECT <
    string name = "(self)";
    string item = "HgSAOCancel";
>;

float ZZZ_HgSAOFactor(float materialCancel)
{
    // The actual AO factor is applied by HgSAO's PS_MixScreen. Material-side
    // cancellation is expressed as metadata for the future mask/capture pass.
    return lerp(1.0, saturate(materialCancel), saturate(ZZZ_HgSAOCancel));
}

#endif
