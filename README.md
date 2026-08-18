# ZZZ MME Open Source

面向 MikuMikuDance / MikuMikuEffect 的通用 ZZZ 风格角色材质、阴影、眼透与后处理工具链。

第一次使用请先阅读 [使用教程_CN.md](使用教程_CN.md)。教程同时覆盖无 GUI 手改 FX、GUI + JSON、五槽 MatCap、眼透、控制器、后处理和发布自检。

本目录包含可审计 Shader Runtime、六个 PMX 控制器、ZZZ Material Studio 源码、构建工具和第三方声明。角色模型、官方游戏贴图、官方 Material JSON、角色专用 MatCap 和测试成品不在开源包内。

## 当前交付

- `ShaderRuntime/`：头发、面部、皮肤、眼睛、衣装、五槽 MatCap、HgShadow、EyeThrough、GT Tonemap 与 Bloom。
- `ShaderRuntime/Manual/`：六类不依赖 GUI 的手写材质 FX 与两个共享 Profile；直接修改 FX 顶部的资源路径、Subset 和公开宏即可编译使用。
- `ShaderRuntime/controller/`：六个正式控制器，共 195 个 Morph。
- `Source/ZZZMaterialStudio/`：GUI 与打包器源码，工程 Schema 6。
- `Tools/`：控制器生成、JSON Profile、FX 编译与合同验证工具。
- `docs/`：架构、构建、控制器、JSON 工作流和发布审计说明。
- `licenses/`：被包含或明确参考的第三方许可证与原始说明。

## 六个控制器

```text
ZzzShadow_controller.pmx
ZzzHair_controller.pmx
ZzzFaceSkin_controller.pmx
ZzzClothMatCap_controller.pmx
ZzzEye_controller.pmx
ZzzPost_controller.pmx
```

其中 `ZzzClothMatCap_controller.pmx` 为每个 MatCap 槽提供独立的强度、明度、遮蔽和关闭控制。JSON 决定初始贴图与基础参数，PMX Morph 负责运行时微调；两者互不覆盖。

详见 [CONTROLLERS_CN.md](CONTROLLERS_CN.md) 和 [JSON_PARAMETER_WORKFLOW_CN.md](JSON_PARAMETER_WORKFLOW_CN.md)。

## 快速构建

要求：Windows、.NET 8 SDK、MMD 9.31 x64、MME。FX 编译验证可选用 Windows SDK 的 `fxc.exe`。

```powershell
cd Source\ZZZMaterialStudio
dotnet build EndfieldMaterialStudio.slnx -c Release
dotnet run --project EndfieldMaterialStudio.Tests\EndfieldMaterialStudio.Tests.csproj -c Release
```

运行 GUI：

```powershell
dotnet run --project EndfieldMaterialStudio.App\EndfieldMaterialStudio.App.csproj -c Release
```

GUI 中选择 `ShaderRuntime/` 作为 ZZZ Runtime，导入普通 PMX，然后按材质指定角色分类、贴图与 MatCap。手动 MatCap 始终优先；官方 JSON 只提供建议值和初始化值。

没有 GUI 时，直接使用 `ShaderRuntime/Manual/` 的入口 FX。GUI 只负责自动分类、JSON 导入、资源复制和生成配置，不是 Shader Runtime 的前置依赖。

## 运行时附件

正式 EMM 只需要三个功能附件：

```text
ZZZshadow\ZZZshadow.x
ZZZEyeThrough\ZZZEyeThrough.x
ZZZPost\ZZZPost.x
```

六个控制器作为 PMX 模型加载，不增加材质附件数量。SAO 未纳入正式链路。

## 发布边界

本项目不包含任何角色 PMX/Blend、官方 JSON、官方贴图或角色专用 MatCap。用户必须只处理自己有权使用的模型与资产。详见 [ASSET_LICENSE_BOUNDARY_CN.md](ASSET_LICENSE_BOUNDARY_CN.md)。

项目整体采用 `GPL-3.0-only`。HgShadow 文件保留針金P原始再分发条款与说明，见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

## 状态

发布日期：2026-08-18

已完成三套不同角色的本地回归，但这些角色资源不随项目发布。正式验收标准见 [docs/RELEASE_AUDIT_CN.md](docs/RELEASE_AUDIT_CN.md)。
