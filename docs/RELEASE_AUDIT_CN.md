# 发布审计

发布前必须满足：

- 六个正式控制器存在，Morph 总数为 207。
- `controller/` 中不存在旧控制器或重复 Post 控制器。
- 不包含角色 PMX/PMD/Blend/FBX。
- 不包含官方 Material JSON、角色贴图、角色 MatCap 或角色 Profile。
- 不包含 `bin/`、`obj/`、`artifacts/`、`build/`、`__pycache__/`。
- 文档和输出配置不包含本地绝对路径。
- 正式文件名不使用第三方工程品牌作为本项目名称。
- HgShadow 原说明、作者和修改记录齐全。
- GUI `dotnet build` 为 0 warning / 0 error。
- 全部自动化测试通过。
- 代表性角色生成包 FX 由 `fxc.exe` 全部编译通过。
- `SHA256SUMS.txt` 与最终目录一致。

自动审计：

```powershell
.\Tools\audit_open_source.ps1
```
