# Kompiliert HeisenbergRibbon.xml (+ Bilder aus res\) neu zu .res/.pas/.h.
# Danach in RAD Studio: Ribbon-Dateien neu laden -> Projekt neu erstellen.

$ErrorActionPreference = 'Stop'

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$Compiler   = 'C:\Users\weiss\source\repos\RibbonFramework\Designer\Bin\RibbonCMDCompiler.exe'
$MarkupFile = Join-Path $ScriptDir 'HeisenbergRibbon.xml'

if (-not (Test-Path $Compiler)) {
    Write-Error "RibbonCMDCompiler.exe nicht gefunden: $Compiler"
}
if (-not (Test-Path $MarkupFile)) {
    Write-Error "HeisenbergRibbon.xml nicht gefunden: $MarkupFile"
}

Set-Location $ScriptDir
& $Compiler 'HeisenbergRibbon.xml' 'APPLICATION'

if ($LASTEXITCODE -ne 0) {
    Write-Error "Ribbon-Kompilierung fehlgeschlagen (Exit Code $LASTEXITCODE)."
}

Write-Output ''
Write-Output 'Fertig. Naechster Schritt in RAD Studio:'
Write-Output '  1) HeisenbergRibbon.pas / .res neu laden (falls die IDE fragt)'
Write-Output '  2) Projekt neu erstellen'
