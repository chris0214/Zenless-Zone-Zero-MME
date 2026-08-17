# 资产与许可边界

## 开源包内允许分发

- 项目自有 C#、Python、PowerShell、HLSL/FX 源码和文档。
- 六个项目自制 PMX 控制器及 `controller-contract.json`。
- 项目自制中性占位贴图。
- HgShadow 允许二次配布的文件及其原始说明。
- ZZZshadow、ZZZEyeThrough、ZZZPost 的项目自有包装层。

## 明确不进入开源包

- 任意角色 PMX、PMD、Blend、FBX 或派生模型。
- 官方游戏 Material JSON、纹理、MatCap、LUT 或其他解包资产。
- 角色专用 `.zzzstudio.json`、EMM、生成 FX、Profile 和测试截图。
- 本地绝对路径、个人目录、构建缓存、`bin/`、`obj/`、`artifacts/`、`__pycache__/`。
- 未确认允许再分发的参考工程资源。

## 用户责任

GUI 只读取用户指定的本地模型、JSON 与贴图，并把必要数据转换为角色包内的静态参数。工具能够读取文件不代表用户自动获得再分发权。公开角色包前，应分别确认模型、贴图、MatCap、动作、音频和场景资产的许可。

## 商标说明

ZZZ 仅用于描述兼容的渲染风格和参数体系。本项目不是游戏开发商的官方产品，也不附带其游戏资产。
