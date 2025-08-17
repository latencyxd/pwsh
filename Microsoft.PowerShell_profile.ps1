Clear-Host

# --- PSReadLine: cores padrão próximas dos pastéis ---
Import-Module PSReadLine
Set-PSReadLineOption -Colors @{
    Command   = "Magenta"
    Parameter = "Cyan"
    String    = "DarkMagenta"
    Number    = "Blue"
    Operator  = "Cyan"
    Comment   = "Gray"
}

# --- Starship com cache e prompt fantasma ---
$starshipCmd = Get-Command starship -ErrorAction SilentlyContinue
if ($starshipCmd) {
    $starshipCacheFile = "$env:LOCALAPPDATA\starship_full_cache.ps1"

    # Gera cache se não existir ou for mais de 1 dia antigo
    if (-not (Test-Path $starshipCacheFile) -or ((Get-Date) - (Get-Item $starshipCacheFile).LastWriteTime).TotalHours -gt 24) {
        # Executa diretamente, sem criar um job em segundo plano
        & starship init powershell --print-full-init | Out-String | Out-File $starshipCacheFile -Encoding UTF8
    }

    # Define o prompt para usar o Starship
    function prompt {
        & starship prompt
    }
}

# --- PATH mínimo e rápido ---
$essentialPaths = @(
    "$env:USERPROFILE\.bun\bin",
    "C:\fnm",
    "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps"
)
$currentPaths = ($essentialPaths + ($env:PATH -split ';')) | Sort-Object -Unique
$env:PATH = $currentPaths -join ';'

# --- Alias parcel ---
$parcelCmd = "$env:USERPROFILE\.bun\bin\parcel.cmd"
if (Test-Path $parcelCmd) { Set-Alias parcel $parcelCmd -ErrorAction SilentlyContinue }

# --- fnm manual ---
function fnmUse {
    if (Test-Path "C:\fnm\fnm.exe") {
        & "C:\fnm\fnm.exe" use --silent-if-unchanged
    }
}
Set-Alias nodev fnmUse

# --- LS colorido estilo Linux / Powerlevel10k ---
function ls {
    param([string]$path = ".")
    Get-ChildItem $path | ForEach-Object {
        if ($_.PSIsContainer) {
            Write-Host $_.Name -ForegroundColor Cyan
        }
        elseif ($_.Attributes -match "Hidden") {
            Write-Host $_.Name -ForegroundColor Gray
        }
        else {
            switch ($_.Extension.ToLower()) {
                ".txt" { Write-Host $_.Name -ForegroundColor Magenta }
                ".json" { Write-Host $_.Name -ForegroundColor DarkMagenta }
                ".lua" { Write-Host $_.Name -ForegroundColor Cyan }
                ".js" { Write-Host $_.Name -ForegroundColor Magenta }
                ".py" { Write-Host $_.Name -ForegroundColor DarkMagenta }
                ".html" { Write-Host $_.Name -ForegroundColor Cyan }
                ".css" { Write-Host $_.Name -ForegroundColor Blue }
                ".exe" { Write-Host $_.Name -ForegroundColor Magenta }
                ".dll" { Write-Host $_.Name -ForegroundColor DarkMagenta }
                default { Write-Host $_.Name -ForegroundColor White }
            }
        }
    }
}