# Guion — ¿Dónde estás? GPS en Flutter (1 slide = 1 persona)

**Equipo:** Josheph Martinez (GNSS + paquetes) · Oscar Duque · Sebastian Carrillo
**Duración total:** ~13–15 min + demo. **Regla:** cada slide la explica UNA sola persona, completa. Nadie hace dos slides seguidas (salvo el bloque GNSS S3–S4 de Josheph, que es un solo tema).

> Josheph pidió el GNSS: se queda con **S3 Qué es** y **S4 Cómo funciona** (incluye el video de 20 s de Gemini). Son dos slides completas, cada una suya.

---

## 1. Reparto

| Slide | Tema | Quién | Tiempo |
|---|---|---|---|
| S1 | Portada + hook + presenta equipo | **Josheph** | 1 min |
| S2 | Agenda | **Oscar** | 30 s |
| S3 | Qué es (GNSS vs GPS, paquetes) | **Josheph** | 2 min |
| S4 | Cómo funciona (video 20 s + trilateración + fuentes) | **Josheph** | 2–3 min |
| S5 | Casos de uso reales | **Oscar** | 1.5 min |
| S6 | Paquetes y plataformas | **Josheph** | 1.5 min |
| S7 | Permisos Android + iOS + Web | **Oscar** | 2–3 min |
| S8 | Implementación (flujo + mapa) | **Sebastian** | 2 min |
| S9 | Demo aceptar + negar + fallos | **Sebastian** | 2–3 min |
| S10 | Cierre + repo + créditos | **Sebastian** | 1.5 min |

Balance: Josheph 4 · Oscar 4 · Sebastian 2. Orden intercalado: J → O → J → J → O → J → O → S → O → S. Quedaría: Josheph S1/S3/S4/S6, Oscar S2/S5/S7/S9, Sebastian S8/S10. **Aplícalo así** (ver guion abajo ya ajustado).

### Reparto final (nadie repite seguidas salvo bloque GNSS)

| Slide | Quién |
|---|---|
| S1 Portada | Josheph |
| S2 Agenda | Oscar |
| S3 Qué es | Josheph |
| S4 Cómo funciona | Josheph |
| S5 Casos | Oscar |
| S6 Paquetes | Josheph |
| S7 Permisos | Oscar |
| S8 Implementación | Sebastian |
| S9 Demo | Oscar |
| S10 Cierre | Sebastian |

Balance final: Josheph 4 · Oscar 4 · Sebastian 2.

---

## 2. Guion detallado (qué decir, literal)

### S1 — Portada · JOSHEPH (~1 min)
> "¿Tu celular sabe dónde estás incluso sin internet? Hoy te mostramos cómo tu app en Flutter también puede saberlo. Somos Josheph, Oscar y Sebastian. En 6 paradas pasamos de los satélites a tu primera coordenada, con permiso aceptado y negado en vivo."

- Mira a cámara, sonríe en "incluso sin internet". Gesto: levanta tu celular.
- Pase: "Oscar, ¿qué veremos?"

### S2 — Agenda · OSCAR (~30 s)
> "Seis paradas, un recorrido: qué es, cómo funciona, casos, paquetes, permisos, código y demo en vivo. Arranquemos con lo más alto: los satélites, con Josheph."

- Pasa el dedo por cada item (el editor hará zoom donde señales).

### S3 — Qué es · JOSHEPH (~2 min)
> "GNSS es el sistema, GPS es solo una constelación de EE. UU. Hay 4: GPS, Galileo, GLONASS y BeiDou, unos 30 satélites cada una a 20.200 km. Ojo: **ellos no te rastrean, tú los escuchas**. Cada satélite grita *dónde estoy y qué hora es*. En Flutter, `geolocator` no toca el hardware: le pide la posición a Android, iOS o al navegador. Y `flutter_map` con OpenStreetMap solo dibuja el mapa, sin API Key ni facturación."

- Dinámica: pregunta al público "¿quién cree que el satélite sabe dónde está?" (pausa 2 s) y responde "no, es al revés". Señala cada constelación en la slide.

### S4 — Cómo funciona · JOSHEPH (~2–3 min)
> "Miren estos 20 segundos, pongan atención al cuarto satélite. [VIDEO GEMINI] ¿Vieron? Tres distancias son tres esferas que se cruzan en tu punto. Pero tu reloj es barato: 1 microsegundo de error son 300 metros. El cuarto satélite no te ubica, **te calibra el reloj**. El error baja de ±320 m a ±6 m."

**La matriz, fila por fila (justo después del video, ~1 min):**
> "Ahora lean esta matriz conmigo: 4 fuentes, 3 columnas —precisión, batería e interiores. Fila 1, **GNSS** en verde: precisión de metros, pero batería ALTA y en interiores MAL —es el más preciso y el más tragón, bajo techo se pierde. Fila 2, **Wi-Fi**: decenas de metros, batería baja y SÍ funciona dentro —en un centro comercial manda el Wi-Fi, no el satélite. Fila 3, **Torres**: cientos de metros, batería baja y sí en interiores —grueso, pero siempre disponible. Fila 4, **Sensores**: no dan posición, suavizan —el acelerómetro y el giroscopio rellenan los huecos cuando el resto falla. Moraleja, y apúntenla: **más precisión implica más batería**. Por eso en el código pedimos `high` solo cuando el caso lo necesita. Android fusiona todo esto con Fused Location y iOS con Core Location; tú eliges precisión, no fuente."

- Dinámica: congela el video en el "±6 m" y celébralo con el dedo. Luego toca CADA fila de la matriz al nombrarla (el editor le pondrá highlight). Baja la voz en "más precisión implica más batería" —es la frase que el jurado debe recordar.

### S5 — Casos reales · OSCAR (~1.5 min)
> "¿Dónde paga esto? Delivery calcula tu ETA con `distanceBetween`. Strava sigue tu ruta cada 10 m. Un botón SOS manda lat, lon y precisión aunque sea gruesa. Geocercas: si estás a menos de 100 m, marca llegada. Retail con COARSE basta. Y cada foto guarda altitud y hora."

- Dinámica: un ejemplo por dedo (6 dedos). Ritmo rápido, como subasta.

### S6 — Paquetes · JOSHEPH (~1.5 min)
> "Necesitaremos 2 paquetes. **Geolocator** se encarga de todo lo que es ubicación: pedir el permiso, leer tu posición actual, seguirla en vivo con un stream y calcular distancia y rumbo entre puntos. Y junto con **FlutterMap** nos permite ver todo eso en un mapa: FlutterMap es el lienzo, **TileLayer** trae las imágenes del mapa de OpenStreetMap, **MarkerLayer** pone el pin de dónde estás y **PolylineLayer** dibuja tu ruta al caminar. Instalación en una línea: `flutter pub add geolocator flutter_map latlong2`."

- Dinámica: cuenta "2 paquetes" con dos dedos. Al nombrar cada capa (lienzo, imágenes, pin, ruta), señala la parte del mapa en la slide. Escribe el comando en vivo o mímalo tecleando.

### S7 — Permisos · OSCAR (~2–3 min, el corazón de la rúbrica)
> "Misma API, tres contratos. En Android son hijos del manifest: FINE para preciso, COARSE para aproximado, y el sistema pone el diálogo en ejecución. Ojo: `deniedForever` solo se conoce después de pedir. En iOS tú escribes el diálogo con `NSLocationWhenInUseUsageDescription`; sin esa clave, nada funciona, y el fondo exige capability y texto Always. Y en web no hay archivo: lo pide el navegador, solo con HTTPS. No existen última conocida ni abrir ajustes. Permiso por dominio, sin segundo plano."

- Dinámica: recorre las 3 tarjetas con la mano (verde → morado → naranja). Cierra mirando a cámara: "Misma API, tres contratos."

### S8 — Implementación · SEBASTIAN (~2 min)
> "El flujo es servicio, permiso, lectura. Si el GPS está apagado, avisa y no lee. Si niegan, error controlado. Si niegan para siempre, a Ajustes. Lectura con `high` y timeout de 15 segundos. Stream cada 10 m y `cancel()` al detener. Y el mapa: `FlutterMap` con tiles OSM, marcador de tu posición y `PolylineLayer` con tu ruta. Cada punto nuevo mueve la cámara con `map.move`. Sin keys."

- Dinámica: recita el flujo con 3 dedos (servicio-permiso-lectura). Dibuja la ruta en el aire.

### S9 — Demo · OSCAR (~2–3 min, grabación real obligatoria)
> "Vamos a lo real. Primero acepto: miren, lat, lon y ±6 m. Abro Mapa: ahí estoy, y la ruta se dibuja al caminar. Ahora revoco el permiso y reintento: tarjeta 'Sin ubicación', botón Reintentar y Abrir ajustes. En `deniedForever` solo Ajustes te salva. Y si falla: servicio apagado se avisa, timeout se reintenta, sin internet los tiles no cargan pero la lectura sigue."

- Dinámica: graba manos + emulador. Reacciona de verdad ("¡miren, ahí está!"). Haz las DOS pasadas: aceptar y negar (la rúbrica lo exige).

### S10 — Cierre · SEBASTIAN (~1.5 min)
> "Cerramos con tres ideas. Uno: los satélites calculan tu posición, las redes y los sensores la complementan, el sistema decide cómo fusionarlo y el usuario decide si tu app puede verlo. El código se parece en las tres plataformas; el permiso, no. Dos: buenas prácticas que aplicamos en la app —pantalla previa antes del diálogo del sistema, pedir solo la precisión que el caso necesita, `distanceFilter` de 10 metros para no drenar batería, botón detener siempre visible y timeout de 15 segundos en la lectura única. Tres: lo que nos llevamos —el permiso bloqueado se detecta distinto en Android y en iOS, y en web manda el navegador con HTTPS. Todo está en el repo en pantalla, con README de instalación y permisos. Somos Josheph, Oscar y Sebastian. ¡Gracias!"

- Los 3 juntos a cámara al final: "¡Gracias!" + sonrisa 2 s (para miniatura). QR + URL del repo 5 s mínimo en pantalla.

---

## 3. Guía para el editor (el compañero que edita)

### Estructura y ritmo
- Total 13–15 min. Cortes cada 4–7 s como máximo; nadie en plano fijo más de 10 s.
- Plantilla: **slide fullscreen 60% + cámara circular del que habla abajo-derecha**. Cambia la cámara en cada slide según el reparto (J O J J O J O S O S).
- Lower thirds la primera vez que habla cada uno: "Josheph · GNSS y paquetes", "Oscar · Casos, permisos y demo", "Sebastian · Código y cierre".
- Música: lo-fi instrumental −22 dB bajo voz, subir +3 dB solo en el video GNSS y en el cierre.

### Por slide (qué poner)
- **S1:** zoom lento a "¿Dónde estás?", pop de los 3 nombres. 1 s de silencio antes del hook.
- **S2:** resalta el item del que se habla (borde celeste). Transición swipe.
- **S3:** overlay de las 4 constelaciones al nombrarlas; subraya "ellos no te rastrean".
- **S4:** el video Gemini va **a pantalla completa con su audio original**, 20 s intactos. Antes: rótulo "Mira el 4.º satélite". Después: freeze 1 s en "±6 m" + efecto *ding*. Recorre la tabla de fuentes con highlight por fila.
- **S5:** un icono pop por caso (moto, corazón, SOS, tractor, bolsa, cámara). Montaje rápido.
- **S6:** tecleado animado del `flutter pub add`. Zoom al `pubspec.yaml`.
- **S7:** recorre las 3 tarjetas con glow (verde → morado → naranja). Rótulo final: "Misma API, tres contratos."
- **S8:** scroll de código con highlight + cursor falso. Zoom a `deniedForever → Ajustes` y a `map.move`.
- **S9:** **grabación real obligatoria**: aceptando Y negando (la rúbrica lo exige). Picture-in-picture de dedos + emulador. Subtítulos en los diálogos del sistema. Congela 1 s cada tarjeta de error.
- **S10:** QR + URL del repo 5 s mínimo. Cierre con los 3 en cámara.

### Audio y video
- Normaliza voces a −14 LUFS, quita ruido y "ehh". Si un bloque sale mal, se regraba solo ese slide (por eso 1 persona por slide).
- Exporta 1080p, 24/30 fps, H.264, audio 48 kHz. Nombra: `GPS-Flutter_GrupoX_FINAL.mp4`.
- Checklist antes de entregar: ☐ los 3 aparecen en cámara ☐ se ve aceptar Y negar ☐ audio nítido ☐ QR/URL legible ☐ dura lo pedido ☐ formato y fecha.

### Archivos que necesitas
- `slides/index.html` (grábalo con scroll suave para B-roll), video Gemini 20 s, grabación del emulador aceptando/negando, URL del repo GitHub.

---

## 4. Tips por persona (para no sonar plano)

| Persona | Sus slides | Cómo brillar |
|---|---|---|
| Josheph (S1, S3, S4, S6) | Portada, GNSS y paquetes | Hook con energía alta; pregunta al público en S3; celebra el ±6 m y recorre la matriz fila por fila en S4; teclea el comando en S6 |
| Oscar (S2, S5, S7, S9) | Agenda, casos, permisos, demo | Agenda en 30 s sin leer; casos como subasta; S7 con la mano recorriendo tarjetas; demo con drama real |
| Sebastian (S8, S10) | Código y cierre | 3 dedos + ruta en el aire en S8; cierre con repo y sonrisa grupal |
