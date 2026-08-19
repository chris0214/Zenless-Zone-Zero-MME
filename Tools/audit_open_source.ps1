param(
    [string]$Root = ""
)

$ErrorActionPreference = "Stop"
$releaseRoot = if ([string]::IsNullOrWhiteSpace($Root)) {
    [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
} else {
    [System.IO.Path]::GetFullPath($Root)
}

if (-not (Test-Path -LiteralPath $releaseRoot -PathType Container)) {
    throw "Release root does not exist: $releaseRoot"
}

$errors = [System.Collections.Generic.List[string]]::new()
$files = Get-ChildItem -LiteralPath $releaseRoot -Recurse -File

$forbiddenSegments = @("bin", "obj", "artifacts", "build", "__pycache__")
foreach ($file in $files) {
    $relative = [System.IO.Path]::GetRelativePath($releaseRoot, $file.FullName)
    $segments = $relative -split '[\\/]'
    foreach ($segment in $forbiddenSegments) {
        if ($segments -contains $segment) {
            $errors.Add("Forbidden generated directory: $relative")
        }
    }
    if ($file.Name -match '(?i)goo') {
        $errors.Add("Forbidden public file name: $relative")
    }
    if ($file.Extension -in @(".blend", ".pmd", ".fbx")) {
        $errors.Add("Forbidden model asset: $relative")
    }
}

$expectedControllers = @(
    "ZzzShadow_controller.pmx",
    "ZzzHair_controller.pmx",
    "ZzzFaceSkin_controller.pmx",
    "ZzzClothMatCap_controller.pmx",
    "ZzzEye_controller.pmx",
    "ZzzPost_controller.pmx"
)
$controllerRoot = Join-Path $releaseRoot "ShaderRuntime\controller"
$controllerFiles = Get-ChildItem -LiteralPath $controllerRoot -File -Filter *.pmx |
    Select-Object -ExpandProperty Name
$missing = $expectedControllers | Where-Object { $_ -notin $controllerFiles }
$unexpected = $controllerFiles | Where-Object { $_ -notin $expectedControllers }
foreach ($name in $missing) { $errors.Add("Missing controller: $name") }
foreach ($name in $unexpected) { $errors.Add("Unexpected controller: $name") }

$allPmx = $files | Where-Object { $_.Extension -eq ".pmx" }
foreach ($file in $allPmx) {
    $relative = [System.IO.Path]::GetRelativePath($releaseRoot, $file.FullName)
    $expectedRelative = "ShaderRuntime\controller\$($file.Name)"
    if ($relative -ne $expectedRelative -or $file.Name -notin $expectedControllers) {
        $errors.Add("PMX outside the six-controller contract: $relative")
    }
}

$contractPath = Join-Path $controllerRoot "controller-contract.json"
if (-not (Test-Path -LiteralPath $contractPath -PathType Leaf)) {
    $errors.Add("Missing controller-contract.json")
} else {
    $contract = Get-Content -LiteralPath $contractPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $contractNames = @($contract.controllers | ForEach-Object { $_.file })
    $morphCount = ($contract.controllers | Measure-Object -Property morphCount -Sum).Sum
    if ($contractNames.Count -ne 6) { $errors.Add("Controller contract count is $($contractNames.Count), expected 6") }
    if ($morphCount -ne 207) { $errors.Add("Controller Morph total is $morphCount, expected 207") }
    foreach ($entry in $contract.controllers) {
        $path = Join-Path $controllerRoot $entry.file
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { continue }
        $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
        if ($actual -ne $entry.sha256) {
            $errors.Add("Controller hash mismatch: $($entry.file)")
        }
    }
}

$textExtensions = @(".cs", ".xaml", ".ps1", ".py", ".md", ".json", ".fx", ".fxsub", ".hlsl", ".inc", ".txt")
foreach ($file in $files | Where-Object { $_.Extension -in $textExtensions }) {
    try {
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $text = [System.Text.Encoding]::UTF8.GetString($bytes)
        if ($text -match '(?i)M:\\MMD相关的\\zzz|C:\\Users\\RELIC') {
            $relative = [System.IO.Path]::GetRelativePath($releaseRoot, $file.FullName)
            $errors.Add("Local absolute path: $relative")
        }
    } catch {
        $errors.Add("Cannot audit text file: $($file.FullName)")
    }
}

foreach ($required in @(
    "LICENSE",
    "THIRD_PARTY_NOTICES.md",
    "ASSET_LICENSE_BOUNDARY_CN.md",
    "licenses\HgShadow_v004_Readme_CP932.txt",
    "licenses\HoyoToon_GPL-3.0.txt"
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $releaseRoot $required) -PathType Leaf)) {
        $errors.Add("Missing legal file: $required")
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    throw "Open-source audit failed with $($errors.Count) error(s)."
}

Write-Host "ZZZ_OPEN_SOURCE_AUDIT_PASSED"
Write-Host "Files: $($files.Count)"
Write-Host "Controllers: 6"
Write-Host "Morphs: 207"
