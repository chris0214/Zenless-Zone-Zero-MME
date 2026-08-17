# ZZZ MME 开源版使用教程

本项目提供一套面向 MikuMikuDance / MikuMikuEffect 的 ZZZ 风格角色材质运行时。Shader 本身可以独立工作；GUI 只是自动分类、读取官方 JSON 建议值、复制资源、生成 FX/EMM 和执行检查的辅助工具。

## 一、目录结构

```text
ShaderRuntime/
  Manual/              不依赖 GUI 的六类手写 FX 和 Profile
  internal/            共享 HLSL/FXSub
  textures/common/     中性占位贴图
  controller/          六个正式 PMX 控制器
  ZZZshadow/           HgShadow 后端和 ZZZshadow.x
  ZZZEyeThrough/       眼透运行时和 ZZZEyeThrough.x
  ZZZPost/             GT Tonemap、Bloom 和 ZZZPost.x
Source/ZZZMaterialStudio/
  GUI 和打包器源码
Tools/                 编译、JSON、控制器、审计和清单工具
docs/                  架构、构建、控制器和发布说明
```

正式运行时附件只有三个：`ZZZshadow.x`、`ZZZEyeThrough.x`、`ZZZPost.x`。六个 PMX 控制器是可选的运行时调节器，不会增加附件数量。

## 二、最快上手：不使用 GUI

1. 将 `ShaderRuntime` 复制到你的 MME 效果目录。
2. 复制 `ShaderRuntime/Manual/` 中与材质对应的 FX。
3. 打开 FX 顶部的公开配置区，修改角色贴图路径和 Subset。
4. 先只加载材质 FX，确认基础色、二分明暗和阴影。
5. 再加载 `ZZZshadow.x`，确认身体、衣服和头发的投影。
6. 需要眼透时，修改 `ZZZEyeThrough/ZZZEyeThrough_Capture.fxsub` 与 `ZZZEyeThrough_HairMask.fxsub` 的 Subset 列表，再加载 `ZZZEyeThrough.x`。
7. 最后加载 `ZZZPost.x`。后处理默认保持 Tonemap 关闭，按需要启用 Bloom 和 GT Tonemap。
8. 需要实时调节时，将对应控制器 PMX 拖入 MMD；不加载控制器时，FX 默认值仍然完整生效。

### 必改配置

```hlsl
// Hair
#define ZZZ_NORMAL_RESOURCE "../textures/角色/hair_n.png"
#define ZZZ_MATERIAL_RESOURCE "../textures/角色/hair_m.png"
#define ZZZ_ATTRIBUTE_RESOURCE "../textures/角色/hair_a.png"
#define ZZZ_HEAD_BONE "頭"
#define ZZZ_HAIR_SUBSET "13,14"

// Face
#define ZZZ_FACE_DIFFUSE_RESOURCE "../textures/角色/face_base.png"
#define ZZZ_FACE_LIGHT_RESOURCE "../textures/角色/face_light.png"
#define ZZZ_FACE_HEAD_BONE "頭"
#define ZZZ_FACE_SUBSET "3"

// Skin
#define ZZZ_SKIN_NORMAL_RESOURCE "../textures/角色/body_n.png"
#define ZZZ_SKIN_MATERIAL_RESOURCE "../textures/角色/body_m.png"
#define ZZZ_SKIN_ATTRIBUTE_RESOURCE "../textures/角色/body_a.png"
#define ZZZ_SKIN_SUBSET "15,17,21"

// Cloth
#define ZZZ_CLOTH_NORMAL_RESOURCE "../textures/角色/cloth_n.png"
#define ZZZ_CLOTH_MATERIAL_RESOURCE "../textures/角色/cloth_m.png"
#define ZZZ_CLOTH_AUX_RESOURCE "../textures/角色/cloth_a.png"
#define ZZZ_CLOTH_SUBSET "8"
```

没有对应材质时，Eye Overlay 的 Subset 必须保持 `2147483647`，不能填一个可能命中其他材质的数字。

## 三、调参顺序

建议按以下顺序验收：

1. 基础色和透明度。
2. 二分明暗、Ramp 和 FaceLight/SDF。
3. HgShadow 自阴影与投影。
4. 头发中央高光、MatCap、屏幕空间边缘光和刘海偏移阴影。
5. 面部鼻影、面部高光和 Face/Skin 共用 Ramp。
6. 眼睛、睫毛、眉毛、瞳内光和眼透深度关系。
7. 衣装直接高光和五槽 MatCap。
8. ZZZPost 的 GT Tonemap、Bloom 和最终亮度。

不要在基础色和阴影尚未稳定时同时打开高光、MatCap、Bloom，否则很难判断问题来自材质还是后处理。

## 四、MatCap 与官方 JSON

衣装支持五个独立 MatCap 槽位。推荐先在 `Manual/Profiles/ZzzCloth_5Slot_Manual.inc` 手动指定贴图、启用状态、Tint、强度、明度、遮罩通道和混合模式，再逐槽打开测试。

GUI 可以读取官方 Material JSON，用于提供贴图候选和初始建议值，但不会覆盖明确的手动选择。优先级固定为：

```text
FX 中明确写入的值
  > GUI 手动覆盖
  > 官方 JSON 建议值
  > Runtime 默认值
```

因此不同角色使用不同金属或高光 MatCap 时，应由用户确认槽位和贴图，而不是强行假定所有角色共用同一张 MatCap。

## 五、眼透注意事项

- 默认不捕获眼白，避免远距离出现眼球外壳凸出。
- 只把虹膜、睫毛、眉毛、瞳内光和眼影加入对应捕获列表。
- 不要把整个眼眶、眼白或内部眼球材质加入捕获。
- 远处出现穿透时，优先检查 Capture Subset、HairMask Subset、深度写入和 MME 加载顺序。
- 关闭 `ZZZEyeThrough.x` 后仍有透出，说明问题来自普通材质的深度/透明设置，而不是眼透附件本身。

## 六、控制器

正式控制器位于 `ShaderRuntime/controller/`：

```text
ZzzShadow_controller.pmx
ZzzHair_controller.pmx
ZzzFaceSkin_controller.pmx
ZzzClothMatCap_controller.pmx
ZzzEye_controller.pmx
ZzzPost_controller.pmx
```

控制器只做运行时乘数、偏移、开关和诊断，不是 Shader 的前置条件。推荐先用手写 FX 得到稳定画面，再加载控制器微调。

## 七、GUI 工作流

1. 使用 .NET 8 构建 `Source/ZZZMaterialStudio/`。
2. 选择 `ShaderRuntime/` 作为 Runtime 根目录。
3. 导入普通 PMX，确认材质分类。
4. 可选导入官方 Material JSON，检查 MatCap 和高光候选。
5. 手动修正分类、贴图、五槽 MatCap 和 EyeThrough Subset。
6. 生成角色专用 FX、Profile、EMM 和所需控制器。
7. 对生成目录运行 FXC 编译验证，再复制到 MME。

GUI 生成的角色包属于用户自己的工作文件，不应把角色 PMX、官方贴图、官方 JSON 或角色专用 MatCap 放入本开源仓库。

## 八、构建与自检

```powershell
cd ZZZ_MME_OpenSource_20260817_Public
dotnet build Source/ZZZMaterialStudio/EndfieldMaterialStudio.slnx -c Release
dotnet run --project Source/ZZZMaterialStudio/EndfieldMaterialStudio.Tests/EndfieldMaterialStudio.Tests.csproj -c Release
.\Tools\compile_fx.ps1 -Root ShaderRuntime
.\Tools\audit_open_source.ps1
.\Tools\generate_release_manifest.ps1
```

Windows SDK 的 `fxc.exe` 会给出 D3D Effects 弃用警告，这是编译器提示，不是本项目的编译错误。发布前必须确保 `audit_open_source.ps1` 通过，并检查 `ASSET_MANIFEST.json` 与 `SHA256SUMS.txt` 已更新。

## 九、开源边界

本仓库不包含角色模型、官方游戏 Material JSON、官方贴图、角色专用 MatCap、Blend/PMX/PMD/FBX 或生成后的角色 EMM。HgShadow 等第三方内容按 `THIRD_PARTY_NOTICES.md` 和 `licenses/` 中的原始条款使用。

## 十、遇到问题时的最小诊断

- **FX 报错**：先检查 include 相对路径、文件编码、贴图路径和 Subset 字符串。
- **材质全黑**：先关闭后处理和 MatCap，只保留基础色与二分明暗。
- **高光过强**：关闭 Bloom，检查 Specular Gain、MatCap Strength 和 Tint。
- **阴影颜色不一致**：检查 HgShadow 强度、阴影明度和 Face/Skin Ramp 是否使用同一份 Profile。
- **眼睛远处凸出**：检查 EyeThrough Capture 是否捕获眼白或整个眼眶，并检查 HairMask 深度。
- **衣服高光太弱**：逐个打开五个 MatCap 槽，确认遮罩通道和材质 Subset，而不是直接把全局增益乘很大。
