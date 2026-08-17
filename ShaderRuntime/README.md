# ShaderRuntime

该目录是 ZZZ Material Studio 的正式通用运行时，不是角色成品包。

完整安装、调参、眼透、MatCap 和故障排查流程见根目录的 `使用教程_CN.md`。

## 目录

```text
controller/       六个正式 PMX 控制器
internal/         材质共享 HLSL/FXSub
Manual/           不依赖 GUI 的六类手写材质 FX 与 Profile
textures/common/  中性占位贴图
ZZZshadow/        单一阴影附件
ZZZEyeThrough/    单一眼透附件
ZZZPost/          单一后处理附件
```

GUI 生成角色包时会复制必要 Runtime、当前 PMX、角色贴图、静态 Profile 和材质 FX。Runtime 自身不包含角色模型、官方 JSON 或角色贴图。

## 无 GUI 使用

`Manual/` 是正式的手写入口。复制对应的 `Zzz*__Manual.fx`、`Profiles/` 和本目录的 `internal/`、附件、控制器后，直接修改 FX 顶部的资源路径、Subset 与公开宏即可使用；不需要 GUI，也不需要官方 JSON。GUI 只是自动分类、导入 JSON、复制资源和生成这些配置的辅助工具。

静态参数优先级为：手写 FX 明确值 > GUI 手动值 > 官方 JSON 建议值 > Runtime 默认值。未加载控制器时，FX 中的静态值仍然完整生效。

## MatCap

衣装使用五槽 MatCap。空槽指向中性占位贴图，启用槽由 GUI 生成的 `Material_NNN_ZZZ.inc` 定义；PMX 控制器只做运行时强度、明度、遮蔽和关闭调整。

## Face/Skin Ramp

`zzz_face_skin_ramp_shared.hlsl` 提供可由生成 Profile 覆盖的共享默认值。Face 与 Skin 必须使用同一组值，避免颈部接缝色差。

## SAO

SAO 不属于正式运行时，不应默认加载。
