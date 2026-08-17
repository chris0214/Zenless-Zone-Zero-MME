param(
    [string]$Root = "",
    [string]$OutputDirectory = "",
    [string]$FxcPath = ""
)

$ErrorActionPreference = "Stop"
$releaseRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$shaderRoot = if ([string]::IsNullOrWhiteSpace($Root)) {
    Join-Path $releaseRoot "ShaderRuntime"
} else {
    [System.IO.Path]::GetFullPath($Root)
}

if (-not (Test-Path -LiteralPath $shaderRoot -PathType Container)) {
    throw "Shader root does not exist: $shaderRoot"
}

if ([string]::IsNullOrWhiteSpace($FxcPath)) {
    $kitsRoot = "C:\Program Files (x86)\Windows Kits\10\bin"
    $candidate = Get-ChildItem -Path $kitsRoot -Recurse -Filter fxc.exe -File -ErrorAction SilentlyContinue |
        Where-Object { $_.DirectoryName -match '\\x64$|\\x86$' } |
        Sort-Object FullName -Descending |
        Select-Object -First 1
    if (-not $candidate) {
        throw "fxc.exe was not found. Install the Windows SDK or pass -FxcPath."
    }
    $FxcPath = $candidate.FullName
}

$output = if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    Join-Path ([System.IO.Path]::GetTempPath()) ("ZZZ_MME_fxc_" + [Guid]::NewGuid().ToString("N"))
} else {
    [System.IO.Path]::GetFullPath($OutputDirectory)
}
New-Item -ItemType Directory -Force -Path $output | Out-Null

$effects = Get-ChildItem -LiteralPath $shaderRoot -Recurse -File |
    Where-Object { $_.Extension -in @(".fx", ".fxsub") } |
    Sort-Object FullName

$failures = [System.Collections.Generic.List[string]]::new()
foreach ($effect in $effects) {
    $relative = [System.IO.Path]::GetRelativePath($shaderRoot, $effect.FullName)
    $outputName = ($relative -replace '[\\/:*?"<>|]', '_') + ".fxo"
    $outputPath = Join-Path $output $outputName
    & $FxcPath /nologo /T fx_2_0 /Fo $outputPath $effect.FullName
    if ($LASTEXITCODE -ne 0) {
        $failures.Add($relative)
    }
}

if ($failures.Count -gt 0) {
    throw "FXC failed for: $($failures -join ', ')"
}

Write-Host "ZZZ_FXC_PASSED"
Write-Host "FX_COUNT=$($effects.Count)"
Write-Host "OUTPUT=$output"
