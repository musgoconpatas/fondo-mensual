# Quita la tarea programada (el fondo actual se queda como está).
Unregister-ScheduledTask -TaskName 'FondoMensual' -Confirm:$false -ErrorAction SilentlyContinue
Write-Host 'Tarea FondoMensual eliminada.' -ForegroundColor Green
Read-Host 'Presiona Enter para cerrar'
