# Fondo mensual automático

Cada mes GitHub genera un fondo de pantalla nuevo (calendario + tema del mes) y tu PC con Windows lo descarga y lo pone solo.

## Cómo funciona

1. **GitHub** (día 1 de cada mes): dibuja el fondo del mes y lo guarda en `salida/actual.png`.
2. **Tu PC**: una tarea programada revisa al iniciar sesión y todos los días a las 10:00 si hay un fondo nuevo. Si lo hay, lo descarga y lo aplica.

## Instalación (una sola vez)

### Parte 1: GitHub

1. Crea una cuenta en https://github.com (si ya tienes, entra).
2. Crea un repositorio nuevo llamado **fondo-mensual**, marcado como **Public**.
3. Sube todo el contenido de esta carpeta al repositorio. Lo más fácil es **GitHub Desktop** (https://desktop.github.com): "Add local repository" → elige esta carpeta → "Publish repository". Así se sube también la carpeta oculta `.github`.
4. En el repositorio, ve a la pestaña **Actions**. Si pide activar los flujos de trabajo, acepta.
5. Entra a **Fondo mensual** → **Run workflow** → marca "Generar los 12 meses" → **Run workflow**. En unos 2 minutos aparecen las imágenes en la carpeta `salida/`.

### Parte 2: tu PC

1. Descarga la carpeta `pc/` (o copia esos archivos al PC).
2. Abre `actualizar-fondo.ps1` con el Bloc de notas y cambia `TU_USUARIO_DE_GITHUB` por tu usuario. Guarda.
3. Clic derecho en `instalar.ps1` → **Ejecutar con PowerShell**. Listo: la tarea queda instalada y el fondo se cambia en el momento.

Para desinstalar: clic derecho en `desinstalar.ps1` → Ejecutar con PowerShell.

## Personalizar

| Quiero cambiar... | Archivo |
|---|---|
| Colores, frase o motivo de un mes | `temas.json` |
| Poner mis propias imágenes | carpeta `imagenes/` (lee `imagenes/LEEME.txt`) |
| Fecha de mi cumpleaños | `config.json` → `"dia": null` por el número del día (ej. `"dia": 21`) |
| Feriados de un año nuevo | `feriados.json` (copia el formato de 2026) |
| Resolución de pantalla | `config.json` → `"ancho"` (1920 por defecto; 2560 para 2560×1440) |
| El diseño (posiciones, tamaños) | `plantilla/index.html` |

Cada vez que cambias algo de esa lista y lo subes, GitHub regenera el fondo solo.

## Cosas a tener en cuenta

- **Feriados**: están cargados los de 2026 y 2027. A fines de 2027 hay que agregar los de 2028 en `feriados.json` (copia el formato); si falta el año, el calendario sale igual, solo que sin feriados marcados. Conviene revisar las fechas con el calendario oficial cuando se acerque cada año, porque algunas se trasladan.
- **Repositorio público**: las imágenes que pongas en `imagenes/` las puede ver cualquiera.
- **Pantalla**: el diseño es 16:9. En pantallas de otra proporción Windows recorta un poco los bordes.
- GitHub pausa las tareas programadas si el repositorio pasa 60 días sin actividad. Como el fondo se guarda cada mes, normalmente no ocurre; si pasa, se reactiva en la pestaña Actions.

## Probar en tu computador (opcional)

```
npm install
npx playwright install chromium
node generar.mjs --todo
```
