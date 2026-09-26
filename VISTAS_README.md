# ECOSALUD — Vistas (Tailwind, basadas en TailAdmin)

Este documento explica lo que se agrego al proyecto Spring Boot para cubrir las
**25 vistas HTML** pedidas, reutilizando el estilo visual de la plantilla
`tailadmin-free-tailwind-dashboard-template`.

## Como se implemento

La plantilla TailAdmin original usa un build con Webpack + `posthtml-include` +
Tailwind compilado localmente, lo cual no es compatible directamente con
Thymeleaf/Spring Boot. Para no depender de ese pipeline de build, se replico el
mismo lenguaje visual (colores de marca `#465fff`, tipografia Outfit, layout de
sidebar + topbar, cards, tablas, badges) usando:

- **Tailwind CSS via CDN** (`cdn.tailwindcss.com`) con la config de colores de marca.
- **Alpine.js** (CDN) para interactividad: sidebar responsive, modo oscuro,
  dropdowns y **modales** (varias acciones del enunciado se resuelven con
  modales en vez de paginas nuevas, tal como se pidio).
- **Lucide Icons** (CDN) para iconografia consistente.
- **Chart.js** (CDN) para los graficos del Dashboard gerencial e Indicadores.
- **Fragmentos de Thymeleaf** (`th:replace`) para no repetir sidebar, topbar,
  head y scripts en cada una de las 25 vistas.

> Nota: se usan CDNs porque no hay acceso a `npm install` en este entorno. Si
> el proyecto necesita funcionar sin internet, se puede migrar facilmente a
> Tailwind compilado localmente (webpack/vite) reemplazando el `<script>` de
> `cdn.tailwindcss.com` — todas las clases usadas son utilidades estandar de
> Tailwind, no dependen del build de TailAdmin.

## Estructura de carpetas

```
src/main/resources/templates/
├── fragments/
│   └── layout.html          # fragments: assets, sidebar(active), overlay, topbar(pageTitle,pageSubtitle), scripts
├── home/            index.html
├── marketing/       pacientes.html, servicios.html, solicitudes-cita.html, citas.html
├── atencion/        agenda.html, recepcion.html
├── operaciones/     atenciones.html, atencion-detalle.html, agenda-especialistas.html, agenda-equipos.html, informes.html
├── logistica/       inventario.html, movimientos.html, compras.html, proveedores.html
├── mantenimiento/   equipos.html, mantenimiento.html, historial-equipo.html
├── gerencia/        dashboard-gerencial.html, indicadores.html, reportes.html
└── administracion/  usuarios.html, roles.html, permisos.html

src/main/resources/static/
├── css/app.css       # utilidades de soporte (scrollbar, menu-item, badges, card, form-input, btn...)
└── js/                (libre para JS propio si luego se separa de los <script> inline)

src/main/java/com/gestor/ECOSALUD/
├── web/ViewController.java     # 1 @GetMapping por cada una de las 25 rutas
└── config/SecurityConfig.java  # deja el sitio abierto (TEMPORAL) para poder navegar las vistas
```

Total: **25 archivos HTML principales** + 1 fragmento compartido (`fragments/layout.html`).

## Los 25 HTML y su ruta

| # | Modulo | Vista | Ruta |
|---|--------|-------|------|
| 1 | — | Inicio | `/` |
| 2 | Marketing y Ventas | Pacientes | `/pacientes` |
| 3 | Marketing y Ventas | Servicios | `/servicios` |
| 4 | Marketing y Ventas | Solicitudes de cita | `/solicitudes-cita` |
| 5 | Marketing y Ventas | Citas | `/citas` |
| 6 | Atencion | Agenda | `/agenda` |
| 7 | Atencion | Recepcion | `/recepcion` |
| 8 | Operaciones | Atenciones | `/atenciones` |
| 9 | Operaciones | Detalle de atencion | `/atencion-detalle` |
| 10 | Operaciones | Agenda de especialistas | `/agenda-especialistas` |
| 11 | Operaciones | Agenda de equipos | `/agenda-equipos` |
| 12 | Operaciones | Informes | `/informes` |
| 13 | Logistica y Almacen | Inventario | `/inventario` |
| 14 | Logistica y Almacen | Movimientos | `/movimientos` |
| 15 | Logistica y Almacen | Compras | `/compras` |
| 16 | Logistica y Almacen | Proveedores | `/proveedores` |
| 17 | Mantenimiento | Equipos | `/equipos` |
| 18 | Mantenimiento | Mantenimiento | `/mantenimiento` |
| 19 | Mantenimiento | Historial de equipo | `/historial-equipo` |
| 20 | Gerencia | Dashboard gerencial | `/dashboard-gerencial` |
| 21 | Gerencia | Indicadores | `/indicadores` |
| 22 | Gerencia | Reportes | `/reportes` |
| 23 | Administracion | Usuarios | `/usuarios` |
| 24 | Administracion | Roles | `/roles` |
| 25 | Administracion | Permisos | `/permisos` |

## Los 6 recorridos de negocio (como probarlos clic a clic)

1. **Captacion y venta**: Pacientes → Servicios → Solicitudes → Citas
2. **Recepcion**: Agenda → Recepcion → Atenciones
3. **Prestacion del servicio**: Atenciones → Detalle de atencion → Agenda de especialistas → Agenda de equipos
4. **Informe**: Detalle de atencion (boton "Generar informe") → Informes
5. **Logistica**: Proveedores → Compras → Movimientos → Inventario
6. **Gestion gerencial**: Dashboard gerencial → Indicadores → Reportes

Todos estos saltos ya estan enlazados con `th:href="@{...}"` dentro de las
vistas (botones de accion, filas de tabla, etc.), ademas del menu lateral.

## Modales usados (en vez de crear una pagina nueva)

- Pacientes: registrar / editar paciente
- Servicios: registrar / editar servicio
- Citas: asistente "Nueva cita" (3 pasos: paciente/servicio → disponibilidad → confirmar)
- Operaciones/Atencion-detalle: registrar resultado
- Inventario: registrar insumo, registrar consumo
- Movimientos: registrar movimiento
- Proveedores: registrar / editar proveedor
- Compras: registrar compra
- Mantenimiento: programar mantenimiento
- Equipos (mantenimiento): registrar / editar equipo
- Usuarios: nuevo usuario
- Roles: nuevo rol

## Como ejecutar

```bash
./mvnw spring-boot:run
```

Y abrir `http://localhost:8080/`. La navegacion completa funciona sin backend
real: los datos que se ven son de ejemplo (mock) directamente en el HTML,
listos para reemplazarse por `th:each` sobre listas que vengan del `Model`
cuando se conecten los `Service`/`Repository` de cada modulo.

## Siguientes pasos sugeridos

1. Crear entidades JPA + repositorios por modulo (Paciente, Servicio, Cita, etc.).
2. Reemplazar las filas de tabla "hardcodeadas" por `th:each="x : ${lista}"`.
3. Conectar los formularios de los modales a controladores `@PostMapping`.
4. Reemplazar `SecurityConfig` temporal por la configuracion real de
   autenticacion, una vez este listo el modulo de Usuarios/Roles/Permisos.
