# CleanDataModuleDfm.ps1
# Pre-Build-Schritt: entfernt Form-Eigenschaften, die die RAD-Studio-IDE
# faelschlich in TDataModule-.dfm-Dateien einfuegt (Margins.*, ClientHeight,
# ClientWidth, Color, Font.*, TextHeight, PixelsPerInch). Diese Properties
# gibt es bei TDataModule nicht -> Absturz zur Laufzeit mit EReadError.
#
# Erkennung: nur .dfm-Dateien, deren zugehoerige .pas-Datei eine Klasse
# deklariert, die (direkt oder ueber TdmModuleTemplate) von TDataModule erbt.
# Es werden nur Eigenschaften auf oberster Ebene (vor der ersten verschachtelten
# "object"-Zeile) entfernt, verschachtelte Kind-Komponenten bleiben unberuehrt.

$ProjectDir = $PSScriptRoot

$BadProps = @(
    'Margins\.Left\s*=',
    'Margins\.Top\s*=',
    'Margins\.Right\s*=',
    'Margins\.Bottom\s*=',
    'ClientHeight\s*=',
    'ClientWidth\s*=',
    'Color\s*=\s*clBtnFace',
    'Font\.Charset\s*=',
    'Font\.Color\s*=',
    'Font\.Height\s*=',
    'Font\.Name\s*=',
    'Font\.Style\s*=',
    'TextHeight\s*=',
    'PixelsPerInch\s*='
) -join '|'

Get-ChildItem -Path $ProjectDir -Filter '*.dfm' -Recurse | ForEach-Object {
    $dfmFile = $_.FullName
    $pasFile = [System.IO.Path]::ChangeExtension($dfmFile, '.pas')
    if (-not (Test-Path $pasFile)) { return }

    $pasContent = Get-Content $pasFile -Raw
    if ($pasContent -notmatch 'class\s*\(\s*(TDataModule|TdmModuleTemplate)\s*\)') { return }

    $lines = Get-Content $dfmFile
    $cleaned = New-Object System.Collections.Generic.List[string]
    $inRootLevel = $true

    foreach ($line in $lines) {
        if ($line -match '^\s{2}object\s') { $inRootLevel = $false }

        if ($inRootLevel -and ($line -match "^\s{2}($BadProps)")) {
            continue
        }
        $cleaned.Add($line)
    }

    if ($cleaned.Count -ne $lines.Count) {
        # UTF8 ohne BOM, damit kein unnoetiger Diff bei jedem Build entsteht
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllLines($dfmFile, $cleaned, $utf8NoBom)
        Write-Host "Bereinigt: $($_.Name) ($($lines.Count - $cleaned.Count) Zeile(n) entfernt)"
    }
}
pause
