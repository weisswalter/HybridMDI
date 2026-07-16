Add-Type -AssemblyName System.Drawing

function New-Bmp32 {
    param([int]$size)
    $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    return @{ Bmp = $bmp; G = $g }
}

$colBody   = [System.Drawing.Color]::FromArgb(255, 55, 71, 79)     # dunkles Blaugrau
$colAccent = [System.Drawing.Color]::FromArgb(255, 0, 172, 193)    # Teal
$colPaper  = [System.Drawing.Color]::FromArgb(255, 250, 250, 250)
$colLine   = [System.Drawing.Color]::FromArgb(255, 176, 190, 197)
$colDb     = [System.Drawing.Color]::FromArgb(255, 63, 81, 181)    # Indigo
$colDbTop  = [System.Drawing.Color]::FromArgb(255, 92, 107, 214)

function Draw-Scanner {
    param($g, [int]$s)
    $bBody = New-Object System.Drawing.SolidBrush($colBody)
    $bPaper = New-Object System.Drawing.SolidBrush($colPaper)
    $bAccent = New-Object System.Drawing.SolidBrush($colAccent)
    $pLine = New-Object System.Drawing.Pen($colLine, [Math]::Max(1, $s / 16))

    # Scanner-Korpus (unten)
    $bodyH = [int]($s * 0.42)
    $g.FillRectangle($bBody, 1, $s - $bodyH - 1, $s - 2, $bodyH)

    # Papier (oben links, leicht überlappend)
    $paperW = [int]($s * 0.6)
    $paperH = [int]($s * 0.55)
    $px = [int]($s * 0.12)
    $py = [int]($s * 0.04)
    $g.FillRectangle($bPaper, $px, $py, $paperW, $paperH)
    $g.DrawRectangle($pLine, $px, $py, $paperW, $paperH)
    for ($i = 0; $i -lt 3; $i++) {
        $ly = $py + [int]($paperH * (0.3 + $i * 0.22))
        $g.DrawLine($pLine, $px + [int]($paperW*0.15), $ly, $px + [int]($paperW*0.85), $ly)
    }

    # Scan-Balken (Akzentfarbe) auf dem Korpus
    $g.FillRectangle($bAccent, 1, $s - $bodyH - 1, $s - 2, [Math]::Max(2, $s / 10))

    $bBody.Dispose(); $bPaper.Dispose(); $bAccent.Dispose(); $pLine.Dispose()
}

function Draw-Database {
    param($g, [int]$s)
    $bDb = New-Object System.Drawing.SolidBrush($colDb)
    $bDbTop = New-Object System.Drawing.SolidBrush($colDbTop)
    $pOutline = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255,255,255,255), [Math]::Max(1, $s/24))

    $cx = [int]($s * 0.1)
    $cw = [int]($s * 0.8)
    $ellH = [int]($s * 0.22)
    $bodyTop = [int]($s * 0.22)
    $bodyBottom = [int]($s * 0.78)

    # Zylinderkoerper
    $g.FillRectangle($bDb, $cx, $bodyTop, $cw, $bodyBottom - $bodyTop)

    # untere Ellipse (Abschluss)
    $g.FillEllipse($bDb, $cx, $bodyBottom - $ellH/2, $cw, $ellH)

    # Trennlinien (Ringe)
    $ring1 = $bodyTop + [int](($bodyBottom-$bodyTop)*0.33)
    $ring2 = $bodyTop + [int](($bodyBottom-$bodyTop)*0.66)
    $g.DrawEllipse($pOutline, $cx, $ring1 - $ellH/2, $cw, $ellH)
    $g.DrawEllipse($pOutline, $cx, $ring2 - $ellH/2, $cw, $ellH)

    # obere Ellipse (Deckel, hellere Farbe)
    $g.FillEllipse($bDbTop, $cx, $bodyTop - $ellH/2, $cw, $ellH)
    $g.DrawEllipse($pOutline, $cx, $bodyTop - $ellH/2, $cw, $ellH)

    $bDb.Dispose(); $bDbTop.Dispose(); $pOutline.Dispose()
}

function Save-Icon {
    param([string]$name, [scriptblock]$draw)
    foreach ($sz in @(32,16)) {
        $ctx = New-Bmp32 -size $sz
        & $draw $ctx.G $sz
        $ctx.G.Dispose()
        $suffix = if ($sz -eq 32) { 'L' } else { 'S' }
        $path = "C:\Users\weiss\source\repos\Heisenberg\Ribbon\res\${name}_${suffix}.bmp"
        $ctx.Bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Bmp)
        $ctx.Bmp.Dispose()
        Write-Output "Saved $path"
    }
}

Save-Icon -name 'Scanner' -draw { param($g,$s) Draw-Scanner -g $g -s $s }
Save-Icon -name 'PGManager' -draw { param($g,$s) Draw-Database -g $g -s $s }
