# 架构说明

## 数据流

```text
PMX + 角色贴图 + 可选官方 JSON
            |
            v
ZZZ Material Studio
  - PMX 材质读取
  - 角色分类与贴图匹配
  - JSON 建议值解析
  - 手动覆盖与验证
            |
            v
角色专用静态 Profile + 材质 FX + EMM
            |
            v
ShaderRuntime + 六个 PMX 控制器 + 三个功能附件
```

## 模块边界

- `EndfieldMaterialStudio.Core`：历史工程名保留在程序集内部，负责 PMX、JSON、模板、验证和打包。
- `EndfieldMaterialStudio.App`：产品显示名与程序集名为 `ZZZMaterialStudio`。
- `ShaderRuntime/internal`：各材质共享 HLSL，不包含角色资产。
- `ShaderRuntime/Manual`：六类无需 GUI 的公开 FX 入口，以及 Face/Skin Ramp 和五槽 MatCap Profile。
- `ShaderRuntime/controller`：运行时参数控制合同。
- `ZZZshadow`：HgShadow 后端与单一阴影附件。
- `ZZZEyeThrough`：动态 Subset Capture/HairMask 与单一眼透附件。
- `ZZZPost`：GT Tonemap、分层 Bloom 与单一后处理附件。

## 通用性原则

- Runtime 不按角色名分支。
- Shader Runtime 本身是完整产品；GUI 只负责自动分类、JSON 导入、资源复制、生成和防错。
- 手写 FX 的明确值优先于 GUI 手动值、JSON 建议值和 Runtime 默认值。
- 材质分类以 PMX 材质信息、贴图契约和用户确认共同决定。
- 手动 MatCap 选择优先，JSON 只提供候选和初值。
- 五槽 MatCap 每个材质独立保存。
- Face 与 Skin 必须使用同一组 Ramp 默认值和同一控制器，避免颈部色差。
- EyeThrough 由当前 PMX 的实际 Subset 动态生成，不使用派生角色 PMX。
- 输出包只使用相对路径。

## 兼容边界

运行目标为 Direct3D 9 / Shader Model 3.0。源码中的 UTF-8、CP932 与 CP936 文件由规范化器显式识别，生成 FX 使用 MME 可读取的代码页，控制器 Morph 名直接从 PMX 字节读取。
