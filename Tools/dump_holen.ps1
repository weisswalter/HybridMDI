# ============================================================================
#  Serverstand holen und lokal einspielen
#
#  ENTSCHEIDUNG (Walter, 03.08.2026): Massgeblich ist die netcup-Datenbank.
#  Lokal ist eine Arbeitskopie, die gelegentlich aufgefrischt wird — dieses
#  Skript ist dieses "gelegentlich".
#
#  ES BAUT SEINEN EIGENEN TUNNEL auf einem freien Port und raeumt ihn wieder
#  weg. Einen festen Port zu nehmen waere die Falle, in die wir schon zweimal
#  gelaufen sind: Horcht dort zufaellig etwas anderes, landet der Dump
#  stillschweigend auf der falschen Datenbank.
#
#  Aufruf:
#     .\dump_holen.ps1                     # holen und lokal einspielen
#     .\dump_holen.ps1 -NurSichern         # nur die Datei, nichts einspielen
#     .\dump_holen.ps1 -LokaleDb TRTtest   # in eine andere lokale DB
# ============================================================================
param(
    [string] $Server      = '159.195.218.117',
    [string] $SshBenutzer = 'wwe123',
    [string] $Schluessel  = "$env:USERPROFILE\.ssh\id_ed25519",
    [string] $DbBenutzer  = 'wwe123',
    [string] $DbPasswort  = '',           # leer = aus PGPASSWORD_SERVER
    [string] $Datenbank   = 'TRTHeisenberg',
    [string] $LokaleDb    = 'TRTHeisenberg',
    [string] $LokalUser   = 'postgres',
    [string] $LokalPass   = 'postgres',
    [switch] $NurSichern
)

$ErrorActionPreference = 'Stop'

if (-not $DbPasswort) { $DbPasswort = $env:PGPASSWORD_SERVER }
if (-not $DbPasswort) {
    throw "Kein Datenbankpasswort. Entweder -DbPasswort angeben oder " +
          "`$env:PGPASSWORD_SERVER setzen."
}

# --- Werkzeuge finden: die hoechste installierte PostgreSQL-Version ---------
$pgBin = Get-ChildItem 'C:\Program Files\PostgreSQL\*\bin\pg_dump.exe' -ErrorAction SilentlyContinue |
         Sort-Object { [int]($_.Directory.Parent.Name) } -Descending |
         Select-Object -First 1
if (-not $pgBin) { throw "pg_dump nicht gefunden (PostgreSQL installiert?)" }
$pgDump = $pgBin.FullName
$psql   = Join-Path $pgBin.Directory 'psql.exe'

# --- Freien lokalen Port suchen --------------------------------------------
function Get-FreierPort([int]$ab = 5460) {
    for ($p = $ab; $p -lt $ab + 50; $p++) {
        $belegt = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue
        if (-not $belegt) { return $p }
    }
    throw "Kein freier Port ab $ab gefunden."
}
$port = Get-FreierPort
Write-Host "Tunnel auf lokalem Port $port"

# --- Tunnel aufbauen --------------------------------------------------------
$sshArgs = @('-N','-o','BatchMode=yes','-o','ExitOnForwardFailure=yes',
             '-o','ServerAliveInterval=30','-i',$Schluessel,
             '-L',"${port}:127.0.0.1:5432","$SshBenutzer@$Server")
$ssh = Start-Process -FilePath 'ssh' -ArgumentList $sshArgs -PassThru -WindowStyle Hidden

try {
    # Warten bis der Port antwortet — vorher darf sich niemand verbinden.
    $bereit = $false
    foreach ($i in 1..60) {
        Start-Sleep -Milliseconds 250
        if (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue) {
            $bereit = $true; break
        }
        if ($ssh.HasExited) { throw "ssh hat sich sofort beendet (Rueckgabe $($ssh.ExitCode))." }
    }
    if (-not $bereit) { throw "Tunnel kam nicht zustande." }

    $stempel = Get-Date -Format 'yyyy-MM-dd_HHmm'
    $datei   = Join-Path $PSScriptRoot "..\dumps\heisenberg_$stempel.dump"
    New-Item -ItemType Directory -Force (Split-Path $datei) | Out-Null

    Write-Host "Sichere $Datenbank vom Server ..."
    $env:PGPASSWORD = $DbPasswort
    # -Fc = eigenes Format, komprimiert und selektiv wiederherstellbar
    & $pgDump -h localhost -p $port -U $DbBenutzer -d $Datenbank -Fc -f $datei
    if ($LASTEXITCODE -ne 0) { throw "pg_dump ist fehlgeschlagen." }

    $mb = [math]::Round((Get-Item $datei).Length / 1MB, 1)
    Write-Host "Gesichert: $datei ($mb MB)"

    if ($NurSichern) { return }

    # --- Lokal einspielen ---------------------------------------------------
    # In eine FRISCHE Datenbank, nicht ueber den Bestand druebe: sonst
    # bleiben geloeschte Zeilen und alte Spalten stehen und man sucht
    # spaeter Unterschiede, die es auf dem Server gar nicht gibt.
    $env:PGPASSWORD = $LokalPass
    $pgRestore = Join-Path $pgBin.Directory 'pg_restore.exe'

    Write-Host "Lege lokale Datenbank $LokaleDb neu an ..."
    & $psql -h localhost -p 5432 -U $LokalUser -d postgres -v ON_ERROR_STOP=1 `
        -c "DROP DATABASE IF EXISTS `"$LokaleDb`" WITH (FORCE);"
    & $psql -h localhost -p 5432 -U $LokalUser -d postgres -v ON_ERROR_STOP=1 `
        -c "CREATE DATABASE `"$LokaleDb`";"

    Write-Host "Spiele ein ..."
    # --no-owner: lokal gibt es die Serverrollen nicht, die Zugehoerigkeit
    # ist fuer eine Arbeitskopie ohne Belang.
    & $pgRestore -h localhost -p 5432 -U $LokalUser -d $LokaleDb --no-owner --no-privileges $datei
    # pg_restore meldet auch bei harmlosen Hinweisen einen Rueckgabewert <> 0,
    # deshalb hier keine harte Pruefung, sondern eine Zaehlung danach.

    $tabellen = & $psql -h localhost -p 5432 -U $LokalUser -d $LokaleDb -A -t `
        -c "SELECT count(*) FROM pg_tables WHERE schemaname='public';"
    Write-Host "Fertig. Lokale Datenbank $LokaleDb hat $tabellen Tabellen."
}
finally {
    if ($ssh -and -not $ssh.HasExited) {
        Stop-Process -Id $ssh.Id -Force
        Write-Host "Tunnel geschlossen."
    }
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}
