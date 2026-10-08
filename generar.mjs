// Genera el fondo de pantalla del mes (o de todo el año) como imagen PNG.
//   node generar.mjs                 -> mes actual (hora de Chile)
//   node generar.mjs --mes=7 --anio=2026
//   node generar.mjs --todo          -> los 12 meses del año actual
import { chromium } from 'playwright';
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL, fileURLToPath } from 'node:url';

const raiz = path.dirname(fileURLToPath(import.meta.url));
const leer = (f) => JSON.parse(fs.readFileSync(path.join(raiz, f), 'utf8'));
const config = leer('config.json');
const temas = leer('temas.json');
const feriados = leer('feriados.json');

const args = Object.fromEntries(
  process.argv.slice(2).map((a) => {
    const [k, v] = a.replace(/^--/, '').split('=');
    return [k, v ?? true];
  })
);

// Mes y año actuales según la hora de Chile (no la del servidor)
const partes = new Intl.DateTimeFormat('en-CA', { timeZone: 'America/Santiago', year: 'numeric', month: '2-digit' })
  .formatToParts(new Date());
const anioActual = Number(partes.find((p) => p.type === 'year').value);
const mesActual = Number(partes.find((p) => p.type === 'month').value);

const anio = Number(args.anio ?? anioActual);
const pedidos = args.todo
  ? Array.from({ length: 12 }, (_, i) => ({ anio, mes: i + 1 }))
  : [{ anio, mes: Number(args.mes ?? mesActual) }];

function imagenesDelMes(mes) {
  const dir = path.join(raiz, 'imagenes', String(mes).padStart(2, '0'));
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir)
    .filter((f) => /\.(jpe?g|png|webp|gif|avif)$/i.test(f))
    .sort()
    .map((f) => pathToFileURL(path.join(dir, f)).href);
}

const salida = path.join(raiz, 'salida');
fs.mkdirSync(salida, { recursive: true });

const escala = (config.ancho || 1920) / 1920;
const browser = await chromium.launch({ executablePath: process.env.CHROME_PATH || undefined });

for (const { anio: a, mes } of pedidos) {
  const tema = temas[String(mes)];
  if (!tema) throw new Error(`No hay tema para el mes ${mes} en temas.json`);
  if (!feriados[String(a)]) {
    console.warn(`Aviso: no hay feriados de ${a} en feriados.json, el calendario saldrá sin feriados marcados.`);
  }

  const contexto = await browser.newContext({ viewport: { width: 1920, height: 1080 }, deviceScaleFactor: escala });
  const pagina = await contexto.newPage();
  const datos = {
    anio: a,
    mes,
    tema,
    feriados: feriados[String(a)] ?? null,
    cumpleanios: config.cumpleanios ?? null,
    imagenes: imagenesDelMes(mes),
  };
  await pagina.addInitScript((d) => { window.__DATOS__ = d; }, datos);
  await pagina.goto(pathToFileURL(path.join(raiz, 'plantilla', 'index.html')).href, { waitUntil: 'networkidle' });
  await pagina.waitForFunction(() => window.__LISTO__ === true, null, { timeout: 30000 });

  const nombre = `fondo-${a}-${String(mes).padStart(2, '0')}.png`;
  const destino = path.join(salida, nombre);
  await pagina.screenshot({ path: destino, clip: { x: 0, y: 0, width: 1920, height: 1080 } });
  console.log(`Listo: salida/${nombre}`);

  if (a === anioActual && mes === mesActual) {
    fs.copyFileSync(destino, path.join(salida, 'actual.png'));
    console.log('Listo: salida/actual.png (mes en curso)');
  }
  await contexto.close();
}

await browser.close();
