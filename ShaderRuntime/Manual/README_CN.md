# ZZZ 无 GUI 手写材质入口

这一目录是给不使用 ZZZ Material Studio 的用户准备的。它不依赖官方 JSON，也不依赖 GUI；只要把 FX 放进角色工程，修改顶部的贴图路径、Subset 和少量参数，就可以编译出完整的 ZZZ 材质。

## 文件

| 文件 | 用途 |
| --- | --- |
| `ZzzHair_Manual.fx` | 头发基础色、二分明暗、HgShadow、中央高光、屏幕边缘光和刘海偏移阴影 |
| `ZzzFace_Manual.fx` | 面部 FaceLight/SDF、鼻影、高光和共享 Ramp |
| `ZzzSkin_Manual.fx` | 皮肤 N/M/A、HgShadow、皮肤高光和共享 Ramp |
| `ZzzCloth_Manual.fx` | 衣装 N/M/A、二分明暗、HgShadow、直接高光和五槽 MatCap |
| `ZzzEyeBase_Manual.fx` | 虹膜或眼白基础材质 |
| `ZzzEyeOverlay_Manual.fx` | 睫毛、眉毛、瞳内光、瞳外高光和眼影 |
| `Profiles/ZzzCloth_5Slot_Manual.inc` | 五个 MatCap 的贴图、启用状态、颜色、强度和混合方式 |
| `Profiles/ZzzFaceSkin_Ramp_Manual.inc` | 面部和皮肤共用的 Ramp 颜色，不能拆成两份 |

## 使用顺序

1. 将 `ZZZ_MME` 目录中的 `internal`、`ZZZshadow`、`ZZZEyeThrough`、`ZZZPost` 和 `textures/common` 复制到角色 FX 工程。
2. 复制对应的 Manual FX。
3. 修改 FX 顶部的 `Resource` 和 `Subset`。
4. 先在 MME 中确认基础色、二分明暗和阴影，再调高光与 MatCap。
5. 需要眼透时，编辑 `ZZZEyeThrough/ZZZEyeThrough_Capture.fxsub` 与 `ZZZEyeThrough_HairMask.fxsub` 顶部的 Subset 列表。
6. 最后加载三个正式附件：`ZZZshadow.x`、`ZZZEyeThrough.x`、`ZZZPost.x`。

## 参数优先级

```text
手写 FX 明确值
    > GUI 中的手动值
    > 官方 JSON 建议值
    > Runtime 推荐默认值
```

控制器不改变这个优先级。控制器只是对 FX 的静态值进行实时乘数或偏移；不加载控制器时，FX 中的默认值仍然完整生效。

## 必须修改的值

### Face

```hlsl
#define ZZZ_FACE_DIFFUSE_RESOURCE "../textures/角色/face_base.png"
#define ZZZ_FACE_LIGHT_RESOURCE "../textures/角色/face_light.png"
#define ZZZ_FACE_HEAD_BONE "頭"
#define ZZZ_FACE_SUBSET "3"
```

### Skin

```hlsl
#define ZZZ_SKIN_NORMAL_RESOURCE "../textures/角色/body_n.png"
#define ZZZ_SKIN_MATERIAL_RESOURCE "../textures/角色/body_m.png"
#define ZZZ_SKIN_ATTRIBUTE_RESOURCE "../textures/角色/body_a.png"
#define ZZZ_SKIN_SUBSET "15,17,21"
```

### Hair

```hlsl
#define ZZZ_NORMAL_RESOURCE "../textures/角色/hair_n.png"
#define ZZZ_MATERIAL_RESOURCE "../textures/角色/hair_m.png"
#define ZZZ_ATTRIBUTE_RESOURCE "../textures/角色/hair_a.png"
#define ZZZ_HEAD_BONE "頭"
#define ZZZ_HAIR_SUBSET "13,14"
```

### Cloth

```hlsl
#define ZZZ_CLOTH_NORMAL_RESOURCE "../textures/角色/cloth_n.png"
#define ZZZ_CLOTH_MATERIAL_RESOURCE "../textures/角色/cloth_m.png"
#define ZZZ_CLOTH_AUX_RESOURCE "../textures/角色/cloth_a.png"
#define ZZZ_CLOTH_SUBSET "8"
```

### Eye base and overlays

`ZzzEyeBase_Manual.fx` 使用 `ZZZ_EYE_BASE_SUBSET`。`ZzzEyeOverlay_Manual.fx` 分别使用四个 Subset：

```hlsl
#define ZZZ_EYE_LASH_SUBSET "4"
#define ZZZ_EYE_INNER_SUBSET "7"
#define ZZZ_EYE_HIGHLIGHT_SUBSET "8"
#define ZZZ_EYE_SHADOW_SUBSET "9"
```

没有对应材质时必须保留 `2147483647`，这样不会误命中其他 Subset。

## Ramp 约束

面部和皮肤必须共同包含同一份 `Profiles/ZzzFaceSkin_Ramp_Manual.inc`。如果两者分别改颜色，就会出现面部和脖子之间的色差。

## 眼透约束

`ZZZEyeThrough_Capture.fxsub` 中的眼白默认不捕获。只把虹膜、睫毛、眉毛、瞳光和眼影加入对应列表；不要把眼白或整个眼眶加入捕获，否则会出现远处凸出、眼白穿透和眼球外壳浮出的现象。

## MatCap

五个 MatCap 槽独立配置。手动指定贴图优先于 JSON；空槽使用中性贴图。先打开一个槽确认遮罩，再逐个调 `ColorBurst`、`AlphaBurst`、`BlendMode` 和 Tint。

## 编码

FX 的宏和资源路径使用 ASCII；骨骼名、控制器名和 MME UI 名称使用 CP936/日文兼容汉字。说明文档使用 UTF-8。不要把绝对路径写入发行包。
