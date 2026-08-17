# 官方 JSON 参数工作流

## 设计目标

官方 Material JSON 是参数来源，不是运行时依赖。标准 MME 不在每帧读取 JSON；ZZZ Material Studio 在生成阶段解析 JSON、验证贴图、应用人工覆盖，然后写出静态 `.inc` Profile。

## 权威顺序

1. 用户在 GUI 手动指定的 MatCap 和参数。
2. 用户选择的官方 Material JSON 建议值。
3. Shader 的通用中性默认值。

`PreferManualMatCap=true` 时，导入 JSON 不会静默覆盖已有手动贴图。用户可以显式选择覆盖，且每个材质独立保存来源。

## 读取内容

解析器读取 `m_SavedProperties` 下的：

- `m_TexEnvs`：贴图名称、PathID、UV Scale/Offset。
- `m_Floats`：强度、范围、光滑度、MatCap 混合参数。
- `m_Ints`：枚举和开关。
- `m_Colors`：高光色、MatCap Tint、Ramp 颜色候选。

原始属性也会保存在 GUI 工程内，便于以后新增映射，不需要重新解包角色。

## 五槽 MatCap 映射

| 槽 | 纹理 | 颜色 | 强度/遮蔽 | 混合与 UV |
| --- | --- | --- | --- | --- |
| 1 | `_MatCapTex` | `_MatCapColorTint` | `_MatCapColorBurst`, `_MatCapAlphaBurst` | `_MatCapBlendMode`, `_MatCapTexID`, `_MatCapRefract`, `_MatCapUSpeed`, `_MatCapVSpeed` |
| 2..5 | `_MatCapTexN` | `_MatCapColorTintN` | `_MatCapColorBurstN`, `_MatCapAlphaBurstN` | 同名参数加槽号 N |

衣装高光还读取：

```text
_SpecularHighlights
_SpecIntensity
_Metallic
_Glossiness
_SpecularColorN
_SpecularRangeN
_ToonSpecularN
_ModelSizeN
```

这些值先成为 Profile 基础值，再由 `ZzzClothMatCap_controller.pmx` 做运行时乘数微调。

## 手动自由度

GUI 对每槽保留：

- 启用/关闭。
- 手动贴图路径。
- 来源：手动、官方 JSON、默认。
- Mask Channel。
- 强度、Tint、旋转、Scale X/Y、Offset X/Y。
- Blend Mode。

官方 JSON 不完整、贴图名为空或 PathID 无法识别时，GUI 保留警告并使用中性空槽，不猜测一个可能错误的角色贴图。

## 生成结果

每个材质生成独立文件：

```text
generated_json_profiles/Material_NNN_ZZZ.inc
```

其中只包含输出包相对路径和 HLSL 常量，不包含源 JSON 的绝对路径或完整内容。角色公开包是否允许携带由 JSON 推导出的参数，应由发布者按资产许可自行判断；本开源仓库不附带任何官方 JSON 或角色 Profile。

## 推荐 GUI 流程

1. 导入 PMX 并自动分类材质。
2. 自动匹配 Base/N/M/A/FaceLight。
3. 为当前材质选择最匹配的官方 JSON。
4. 检查五槽预览与缺失贴图警告。
5. 对特殊金属、丝袜、头发手动指定 MatCap。
6. 生成黑底高光/MatCap 诊断，确认遮罩和槽位。
7. 生成正式 EMM，在 MMD 中用 PMX 控制器微调。
