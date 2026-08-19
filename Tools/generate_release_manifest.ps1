param(
    [string]$Root = ""
)

$ErrorActionPreference = "Stop"
$releaseRoot = if ([string]::IsNullOrWhiteSpace($Root)) {
    [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
} else {
    [System.IO.Path]::GetFullPath($Root)
}

function Get-RelativePath([string]$BasePath, [string]$Path) {
    $base = [System.IO.Path]::GetFullPath($BasePath).TrimEnd([char]92, [char]47)
    $full = [System.IO.Path]::GetFullPath($Path)
    $prefix = $base + [System.IO.Path]::DirectorySeparatorChar
    if ($full.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $full.Substring($prefix.Length)
    }
    return $full
}

$contractPath = Join-Path $releaseRoot "ShaderRuntime\controller\controller-contract.json"
$contract = Get-Content -LiteralPath $contractPath -Raw -Encoding UTF8 | ConvertFrom-Json
$controllerMorphs = ($contract.controllers | Measure-Object -Property morphCount -Sum).Sum

$manifest = [ordered]@{
    schemaVersion = 1
    format = "ZZZ.MME.OpenSourceAssetManifest"
    releaseDate = "2026-08-19"
    license = "GPL-3.0-only"
    projectAuthor = "克里斯提亚娜"
    included = @(
        [ordered]@{ path = "ShaderRuntime/Manual"; kind = "project-source"; note = "GUI-independent material FX and editable profiles" },
        [ordered]@{ path = "ShaderRuntime/internal"; kind = "project-source"; note = "Shared material runtime" },
        [ordered]@{ path = "ShaderRuntime/controller"; kind = "project-controller"; note = "Six neutral PMX controllers" },
        [ordered]@{ path = "ShaderRuntime/ZZZshadow"; kind = "mixed"; note = "Project wrapper plus redistributed HgShadow files" },
        [ordered]@{ path = "ShaderRuntime/ZZZEyeThrough"; kind = "project-source"; note = "Dynamic EyeThrough runtime" },
        [ordered]@{ path = "ShaderRuntime/ZZZPost"; kind = "project-source"; note = "GT Tonemap and Bloom" },
        [ordered]@{ path = "Source/ZZZMaterialStudio"; kind = "project-source"; note = "GUI and package generator" },
        [ordered]@{ path = "Tools"; kind = "project-source"; note = "Build, controller and audit tools" }
    )
    excluded = @(
        "Character PMX/PMD/Blend/FBX",
        "Official game Material JSON",
        "Official or character textures and MatCaps",
        "Character profiles, EMM files and generated FX",
        "Build caches and local absolute paths"
    )
    thirdParty = @(
        [ordered]@{ name = "HgShadow v0.0.4"; author = "針金P / HariganeP"; notice = "licenses/HgShadow_v004_Readme_CP932.txt" },
        [ordered]@{ name = "HoyoToon 5.2.7"; role = "GPL-compatible implementation reference"; license = "licenses/HoyoToon_GPL-3.0.txt" },
        [ordered]@{ name = "HS_Snow"; role = "MME and HgShadow integration reference"; notice = "licenses/HS_Snow_README_CN.md" }
    )
    controllers = [ordered]@{
        count = @($contract.controllers).Count
        morphCount = $controllerMorphs
        files = @($contract.controllers | ForEach-Object { $_.file })
    }
}

$manifestPath = Join-Path $releaseRoot "ASSET_MANIFEST.json"
$json = $manifest | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText(
    $manifestPath,
    $json + [Environment]::NewLine,
    [System.Text.UTF8Encoding]::new($false))

$hashPath = Join-Path $releaseRoot "SHA256SUMS.txt"
$forbiddenSegments = @("bin", "obj", "artifacts", "build", "__pycache__", ".appdata", ".dotnet_home", ".nuget", "release")
$hashFiles = Get-ChildItem -LiteralPath $releaseRoot -Recurse -File |
    Where-Object {
        $_.FullName -ne $hashPath -and
        (((Get-RelativePath $releaseRoot $_.FullName) -split '[\\/]') |
            Where-Object { $_ -in $forbiddenSegments }).Count -eq 0
    } |
    Sort-Object FullName
$lines = foreach ($file in $hashFiles) {
    $relative = (Get-RelativePath $releaseRoot $file.FullName).Replace('\', '/')
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash  $relative"
}
[System.IO.File]::WriteAllLines(
    $hashPath,
    $lines,
    [System.Text.UTF8Encoding]::new($false))

Write-Host "ZZZ_RELEASE_MANIFEST_WRITTEN"
Write-Host "FILES=$($hashFiles.Count)"
