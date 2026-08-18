param(
    [string]$RuntimeRoot = "",
    [string]$OutputDirectory = "",
    [switch]$SelfContained
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceRoot = Split-Path -Parent $root
$repoRoot = Split-Path -Parent $sourceRoot
$workspaceRoot = Split-Path -Parent $repoRoot
$runtimeCandidates = @(
    $RuntimeRoot,
    $env:ZZZ_MME_RUNTIME,
    (Join-Path $workspaceRoot "ZZZ_MME"),
    $env:ENDFIELD_MME_RUNTIME,
    (Join-Path $repoRoot "EndfieldMME")
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
$runtime = $runtimeCandidates |
    ForEach-Object { [System.IO.Path]::GetFullPath($_) } |
    Where-Object { Test-Path -LiteralPath $_ -PathType Container } |
    Select-Object -First 1
if ([string]::IsNullOrWhiteSpace($runtime)) {
    throw "Cannot find ZZZ_MME or legacy EndfieldMME. Pass -RuntimeRoot or set ZZZ_MME_RUNTIME."
}
$runtimeDirectoryName = if (Test-Path -LiteralPath (Join-Path $runtime "internal\zzz_cloth_runtime.hlsl")) {
    "ZZZ_MME"
} else {
    "EndfieldMME"
}

$publish = if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    Join-Path $root "artifacts\release-win-x64"
} else {
    [System.IO.Path]::GetFullPath($OutputDirectory)
}
$stage = Join-Path $root "artifacts\publish-stage-win-x64"
$gui = $publish
$artifactsRoot = [System.IO.Path]::GetFullPath((Join-Path $root "artifacts"))
$artifactsPrefix = $artifactsRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
$env:DOTNET_CLI_HOME = Join-Path $root ".dotnet_home"
$env:APPDATA = Join-Path $env:DOTNET_CLI_HOME "AppData"
$env:LOCALAPPDATA = Join-Path $env:DOTNET_CLI_HOME "LocalAppData"
$env:NUGET_PACKAGES = Join-Path $root ".nuget\packages"

foreach ($path in @($publish, $stage)) {
    $resolved = [System.IO.Path]::GetFullPath($path)
    if (-not $resolved.StartsWith($artifactsPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to delete path outside artifacts: $resolved"
    }
    if (Test-Path -LiteralPath $resolved) { Remove-Item -LiteralPath $resolved -Recurse -Force }
}

dotnet restore (Join-Path $root "ZzzMaterialStudio.App\ZzzMaterialStudio.App.csproj") `
    -r win-x64 --configfile (Join-Path $root "NuGet.Publish.Config") -p:NuGetAudit=false
if ($LASTEXITCODE -ne 0) { throw "dotnet restore failed: $LASTEXITCODE" }
if ($SelfContained) {
    dotnet publish (Join-Path $root "ZzzMaterialStudio.App\ZzzMaterialStudio.App.csproj") `
        -c Release -r win-x64 --self-contained true --no-restore `
        -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true `
        -p:DebugType=None -p:DebugSymbols=false -o $stage
} else {
    dotnet publish (Join-Path $root "ZzzMaterialStudio.App\ZzzMaterialStudio.App.csproj") `
        -c Release -r win-x64 --self-contained false --no-restore `
        -p:PublishSingleFile=true -p:DebugType=None -p:DebugSymbols=false -o $stage
}
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed: $LASTEXITCODE" }

New-Item -ItemType Directory -Force -Path $gui | Out-Null
Copy-Item -LiteralPath (Join-Path $stage "ZZZMaterialStudio.exe") -Destination (Join-Path $gui "ZZZMaterialStudio.exe") -Force
$runtimeDestination = Join-Path $publish $runtimeDirectoryName
if ($runtimeDirectoryName -eq "ZZZ_MME") {
    New-Item -ItemType Directory -Force -Path $runtimeDestination | Out-Null
    $developmentEntryFiles = @(
        "ZZZ_Body.fx",
        "ZZZ_Debug.fx",
        "ZZZ_EyeThrough_Capture.fxsub",
        "ZZZ_EyeThrough_Mask.fxsub",
        "ZZZ_EyeThrough.fx",
        "ZZZ_Face.fx",
        "ZZZ_Hair.fx",
        "ZZZ_HairOffsetShadow.fx",
        "ZZZ_HairVisibility_Capture.fxsub"
    )
    foreach ($directory in @("Manual", "internal", "textures", "controller", "ZZZshadow", "ZZZEyeThrough", "ZZZPost")) {
        $source = Join-Path $runtime $directory
        if (Test-Path -LiteralPath $source -PathType Container) {
            Copy-Item -LiteralPath $source -Destination $runtimeDestination -Recurse -Force
        }
    }
    foreach ($file in Get-ChildItem -LiteralPath $runtime -File) {
        if ($file.Name -in $developmentEntryFiles) { continue }
        $extension = $file.Extension.ToLowerInvariant()
        $isRuntimeFile = $extension -in @(".fx", ".fxsub", ".hlsl", ".fxh", ".inc", ".x", ".png", ".dds") -and
            ($file.Name.StartsWith("ZZZ", [System.StringComparison]::OrdinalIgnoreCase) -or
             $file.Name.StartsWith("Zzz", [System.StringComparison]::OrdinalIgnoreCase) -or
             $file.Name.StartsWith("zzz_", [System.StringComparison]::OrdinalIgnoreCase))
        if ($isRuntimeFile -or $file.Name -in @("README.md", "THIRD_PARTY_NOTICES.md")) {
            Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $runtimeDestination $file.Name) -Force
        }
    }
} else {
    Copy-Item -LiteralPath $runtime -Destination $runtimeDestination -Recurse -Force
}

foreach ($name in @(
    "AUTHORS.md",
    "LICENSE",
    "THIRD_PARTY_NOTICES.md",
    "ASSET_LICENSE_BOUNDARY_CN.md",
    "ASSET_MANIFEST.json",
    "CONTROLLERS_CN.md",
    "JSON_PARAMETER_WORKFLOW_CN.md",
    "使用教程_CN.md",
    "VERSION",
    "REFERENCES.md"
)) {
    $source = Join-Path $repoRoot $name
    if (Test-Path -LiteralPath $source) {
        Copy-Item -LiteralPath $source -Destination (Join-Path $publish $name) -Force
    }
}

$rootReadme = Join-Path $repoRoot "README.md"
if (Test-Path -LiteralPath $rootReadme) {
    Copy-Item -LiteralPath $rootReadme -Destination (Join-Path $publish "README.md") -Force
}
$architecture = Join-Path $repoRoot "docs\GUI_ARCHITECTURE_CN.md"
if (Test-Path -LiteralPath $architecture) {
    Copy-Item -LiteralPath $architecture -Destination (Join-Path $publish "GUI_ARCHITECTURE_CN.md") -Force
}

Remove-Item -LiteralPath $stage -Recurse -Force
Write-Host "Published: $publish"
