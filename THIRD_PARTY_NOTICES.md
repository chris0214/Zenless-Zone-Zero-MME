# Third-Party Notices

## HoyoToon

本项目的 ZZZ 材质参数命名、五槽 MatCap 参数解释、部分头发/衣装高光数学与材质分类研究参考了 HoyoToon 5.2.7。为保持兼容的开源边界，本项目整体以 `GPL-3.0-only` 发布，并附带参考版本的 GPL v3 文本：

```text
licenses/HoyoToon_GPL-3.0.txt
```

本项目不复制 HoyoToon 的 Unity 编辑器资源、Shader GUI 资源或角色资产。

## HgShadow v0.0.4

以下文件来自或修改自針金P / HariganeP 的 HgShadow v0.0.4：

```text
ShaderRuntime/ZZZshadow/HgShadow_CFSUSM.fxh
ShaderRuntime/ZZZshadow/HgShadow_CLSPSM.fxh
ShaderRuntime/ZZZshadow/HgShadow_Header.fxh
ShaderRuntime/ZZZshadow/JitteredSamp.png
```

修改包括控制对象名调整、4096 阴影图与更高缓冲精度配置，以及与 ZZZshadow 包装层的连接。原说明明确允许使用、修改和二次配布；原始 CP932 说明保存在：

```text
licenses/HgShadow_v004_Readme_CP932.txt
```

作者署名：針金P / HariganeP。

## HS_Snow

ZZZshadow 的附件组织、相机/灯光兼容层和 HgShadow 集成参考了本地 HS_Snow 工程。参考工程作者与致谢信息原样保存在：

```text
licenses/HS_Snow_README_CN.md
```

开源包不包含 HS_Snow 的角色 Shader、控制器、GUI 可执行文件或压缩包。

## Platform Components

MikuMikuDance、MikuMikuEffect、Direct3D 9、Windows SDK 和 .NET Runtime 不随本项目分发，其名称仅用于描述兼容平台。

## Game Assets

官方游戏 Material JSON、角色贴图、模型、MatCap 和其他解包资产不随本项目分发。本项目只提供读取用户本地文件并生成静态 MME Profile 的工具。
