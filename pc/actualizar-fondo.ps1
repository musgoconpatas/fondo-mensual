# Descarga el fondo del mes desde GitHub y lo pone como fondo de pantalla.
# Solo cambia el fondo si la imagen es distinta a la que ya tienes puesta.

# ===== CAMBIA ESTO =====
$usuario = 'musgoconpatas'
$repo    = 'fondo-mensual'
# =======================

$ErrorActionPreference = 'Stop'

try {
    $url = "https://raw.githubusercontent.com/$usuario/$repo/main/salida/actual.png"
    $carpeta = Join-Path $env:LOCALAPPDATA 'FondoMensual'
    New-Item -ItemType Directory -Force -Path $carpeta | Out-Null

    $descarga = Join-Path $carpeta 'descarga.png'
    $nocache = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    Invoke-WebRequest -Uri "${url}?t=$nocache" -OutFile $descarga -UseBasicParsing

    $hash = (Get-FileHash $descarga -Algorithm SHA256).Hash
    $archivoHash = Join-Path $carpeta 'ultimo.hash'
    if ((Test-Path $archivoHash) -and ((Get-Content $archivoHash -Raw).Trim() -eq $hash)) {
        exit 0   # Ya está puesto este fondo
    }

    $final = Join-Path $carpeta ("fondo-" + $hash.Substring(0, 8) + ".png")
    Copy-Item $descarga $final -Force

    # Ajuste "Rellenar" para que no se estire ni se repita
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value '10'
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value '0'

    Add-Type @"
using System.Runtime.InteropServices;
public class FondoWin {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    # 20 = cambiar fondo, 3 = guardar el cambio y avisar al sistema
    [FondoWin]::SystemParametersInfo(20, 0, $final, 3) | Out-Null

    Set-Content -Path $archivoHash -Value $hash

    # Borra fondos anteriores para no acumular archivos
    Get-ChildItem $carpeta -Filter 'fondo-*.png' | Where-Object { $_.FullName -ne $final } | Remove-Item -Force
}
catch {
    # Sin internet o error de descarga: se reintenta en la próxima ejecución
    exit 1
}
