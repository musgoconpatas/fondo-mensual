# Crea una tarea programada de Windows que revisa el fondo al iniciar sesión
# y todos los días a las 10:00. Solo cambia el fondo cuando hay uno nuevo.

$script = Join-Path $PSScriptRoot 'actualizar-fondo.ps1'

if (-not (Test-Path $script)) {
    Write-Host 'No encuentro actualizar-fondo.ps1 junto a este archivo.' -ForegroundColor Red
    Read-Host 'Presiona Enter para salir'
    exit 1
}

# Copia el script a una carpeta fija para que la tarea no dependa de dónde lo descargaste
$destino = Join-Path $env:LOCALAPPDATA 'FondoMensual'
New-Item -ItemType Directory -Force -Path $destino | Out-Null
Copy-Item $script (Join-Path $destino 'actualizar-fondo.ps1') -Force
$scriptFijo = Join-Path $destino 'actualizar-fondo.ps1'

$accion = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptFijo`""
$alIniciar = New-ScheduledTaskTrigger -AtLogOn
$cadaDia = New-ScheduledTaskTrigger -Daily -At '10:00'
$ajustes = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

Register-ScheduledTask -TaskName 'FondoMensual' -Action $accion -Trigger @($alIniciar, $cadaDia) `
    -Settings $ajustes -Description 'Actualiza el fondo de pantalla con el calendario del mes' -Force | Out-Null

Start-ScheduledTask -TaskName 'FondoMensual'

Write-Host 'Listo. La tarea FondoMensual quedó instalada y ya se ejecutó una vez.' -ForegroundColor Green
Read-Host 'Presiona Enter para cerrar'
