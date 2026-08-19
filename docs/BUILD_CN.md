# 构建说明

## GUI

```powershell
cd Source\ZZZMaterialStudio
dotnet restore EndfieldMaterialStudio.slnx
dotnet build EndfieldMaterialStudio.slnx -c Release --no-restore
dotnet run --project EndfieldMaterialStudio.Tests\EndfieldMaterialStudio.Tests.csproj -c Release --no-build
```

发布单文件 GUI：

```powershell
.\publish-win-x64.ps1 -RuntimeRoot ..\..\ShaderRuntime
```

轻量发布依赖 .NET 8 Desktop Runtime；使用 `-SelfContained` 可生成自包含版本。

## 控制器

```powershell
python Tools\build_zzz_controllers.py --source ShaderRuntime\controller\ZzzHair_controller.pmx --output ShaderRuntime\controller
```

生成后必须核对 `controller-contract.json` 的六个哈希与 Morph 总数 207。

## FX 编译

```powershell
.\Tools\compile_fx.ps1 -Root ShaderRuntime
```

角色材质 FX 由 GUI 生成后再进行完整编译验证；裸 Runtime 只包含共享核心与附件入口。

`ShaderRuntime/Manual` 中的六个 FX 也属于正式编译目标。它们用于验证没有 GUI 和官方 JSON 时，Hair、Face、Skin、Cloth、Eye Base、Eye Overlay 仍能独立编译和使用。
