// Manual five-slot MatCap profile. Official JSON is optional.
// Enable only slots used by the selected material ID mask.
#ifndef ZZZ_CLOTH_MANUAL_PROFILE_INCLUDED
#define ZZZ_CLOTH_MANUAL_PROFILE_INCLUDED

#define ZZZ_JSON_MATCAP_SLOT_1_RESOURCE "../../textures/common/neutral_base.png"
#define ZZZ_JSON_MATCAP_SLOT_2_RESOURCE "../../textures/common/neutral_base.png"
#define ZZZ_JSON_MATCAP_SLOT_3_RESOURCE "../../textures/common/neutral_base.png"
#define ZZZ_JSON_MATCAP_SLOT_4_RESOURCE "../../textures/common/neutral_base.png"
#define ZZZ_JSON_MATCAP_SLOT_5_RESOURCE "../../textures/common/neutral_base.png"

static const float ZZZ_JsonMatcapMasterEnabled = 1.0;
static const float ZZZ_JsonMatcapUseMask = 1.0;
static const float ZZZ_JsonSpecularHighlights = 1.0;
static const float ZZZ_JsonSpecularIntensity = 0.1;
static const float ZZZ_JsonMetallic = 1.0;
static const float ZZZ_JsonGlossiness = 1.0;

#define ZZZ_MANUAL_MATCAP_SLOT(slot, enabled, tint, intensity, alpha, blend, channel) \
    static const float ZZZ_JsonMatcapEnabled##slot = enabled; \
    static const float3 ZZZ_JsonMatcapTint##slot = tint; \
    static const float ZZZ_JsonMatcapColorBurst##slot = intensity; \
    static const float ZZZ_JsonMatcapAlphaBurst##slot = alpha; \
    static const float ZZZ_JsonMatcapBlendMode##slot = blend; \
    static const float ZZZ_JsonMatcapTexId##slot = 100.0; \
    static const float ZZZ_JsonMatcapRefract##slot = 0.0; \
    static const float ZZZ_JsonMatcapUSpeed##slot = 0.0; \
    static const float ZZZ_JsonMatcapVSpeed##slot = 0.0; \
    static const float ZZZ_JsonMatcapMaskChannel##slot = channel; \
    static const float ZZZ_JsonMatcapRotation##slot = 0.0; \
    static const float2 ZZZ_JsonMatcapScale##slot = float2(1.0, 1.0); \
    static const float2 ZZZ_JsonMatcapOffset##slot = float2(0.0, 0.0); \
    static const float3 ZZZ_JsonSpecularColor##slot = float3(1.0, 1.0, 1.0); \
    static const float ZZZ_JsonSpecularRange##slot = 1.0; \
    static const float ZZZ_JsonToonSpecular##slot = 0.01; \
    static const float ZZZ_JsonModelSize##slot = 1.0;

// blend: 0 alpha, 1 add, 2 overlay, 3 replace, 4 multiply.
// channel: 0 R, 1 G, 2 B, 3 A, 4 RGB, 5 RGBA.
ZZZ_MANUAL_MATCAP_SLOT(1, 0.0, float3(1.0, 1.0, 1.0), 0.60, 0.35, 2.0, 3.0)
ZZZ_MANUAL_MATCAP_SLOT(2, 0.0, float3(1.0, 1.0, 1.0), 0.60, 0.35, 2.0, 3.0)
ZZZ_MANUAL_MATCAP_SLOT(3, 0.0, float3(1.0, 1.0, 1.0), 0.60, 0.35, 2.0, 3.0)
ZZZ_MANUAL_MATCAP_SLOT(4, 0.0, float3(1.0, 1.0, 1.0), 0.60, 0.35, 2.0, 3.0)
ZZZ_MANUAL_MATCAP_SLOT(5, 0.0, float3(1.0, 1.0, 1.0), 0.60, 0.35, 2.0, 3.0)

#undef ZZZ_MANUAL_MATCAP_SLOT
#endif
