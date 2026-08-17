#ifndef ZZZ_EYE_THROUGH_CONTRACT_INCLUDED
#define ZZZ_EYE_THROUGH_CONTRACT_INCLUDED

// Endfield reference pattern: facial features are captured into a separate
// transparent RT and composited later. Generated character wrappers replace
// the subset lists; the checked-in defaults intentionally match no subset.
#define ZZZ_EYE_THROUGH_CAPTURE_RT "ZZZ_EyeEyeThrough_RT"
#define ZZZ_EYE_THROUGH_CAPTURE_EFFECT "ZZZEyeThrough_Capture.fxsub"
#define ZZZ_EYE_THROUGH_MASK_EFFECT "ZZZEyeThrough_Mask.fxsub"
#define ZZZ_EYE_THROUGH_NO_MATCH "2147483647"

#ifndef ZZZ_EYE_THROUGH_HEAD_BONE
#define ZZZ_EYE_THROUGH_HEAD_BONE "頭"
#endif

#ifndef ZZZ_EYE_THROUGH_EYE_SUBSETS
#define ZZZ_EYE_THROUGH_EYE_SUBSETS ZZZ_EYE_THROUGH_NO_MATCH
#endif

#ifndef ZZZ_EYE_THROUGH_HIGHLIGHT_SUBSETS
#define ZZZ_EYE_THROUGH_HIGHLIGHT_SUBSETS ZZZ_EYE_THROUGH_NO_MATCH
#endif

#ifndef ZZZ_EYE_THROUGH_OVERLAY_SUBSETS
#define ZZZ_EYE_THROUGH_OVERLAY_SUBSETS ZZZ_EYE_THROUGH_NO_MATCH
#endif

#ifndef ZZZ_EYE_THROUGH_SCLERA_SUBSETS
#define ZZZ_EYE_THROUGH_SCLERA_SUBSETS ZZZ_EYE_THROUGH_NO_MATCH
#endif

#ifndef ZZZ_EYE_THROUGH_BROW_SUBSETS
#define ZZZ_EYE_THROUGH_BROW_SUBSETS ZZZ_EYE_THROUGH_NO_MATCH
#endif

#ifndef ZZZ_EYE_THROUGH_IGNORED_SUBSETS
#define ZZZ_EYE_THROUGH_IGNORED_SUBSETS ZZZ_EYE_THROUGH_NO_MATCH
#endif

#ifndef ZZZ_EYE_THROUGH_HAIR_DEPTH_SUBSETS
#define ZZZ_EYE_THROUGH_HAIR_DEPTH_SUBSETS ZZZ_EYE_THROUGH_NO_MATCH
#endif

#ifndef ZZZ_EYE_THROUGH_SHIFTED_SUBSETS
#define ZZZ_EYE_THROUGH_SHIFTED_SUBSETS ZZZ_EYE_THROUGH_NO_MATCH
#endif

float ZZZ_EyeEyeThroughStrength <
    string UIName = "眼透强度";
    string UIWidget = "Slider";
    float UIMin = 0.0;
    float UIMax = 1.0;
> = 0.38;
float ZZZ_EyeEyeThroughColorGain <
    string UIName = "眼透颜色增益";
    string UIWidget = "Slider";
    float UIMin = 0.5;
    float UIMax = 2.0;
> = 1.0;

float ZZZ_EyeEyeThroughAlpha(float materialAlpha)
{
    return saturate(materialAlpha)
        * saturate(ZZZ_EyeEyeThroughStrength);
}

#endif
