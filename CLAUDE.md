# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Qué es

ERP retail multiempresa en **4D 21.x, modo proyecto** (`Project/4D_RETAIL.4DProject`), escrito en lenguaje 4D con ORDA. El código, los nombres y los mensajes están en español. Corre en 4D Server + 4D Remote y tiene una consulta web vía REST (`WebFolder/index.html`).

La memoria del proyecto está en `.claude/memory/` (índice en `MEMORY.md`). **`project_modelo_datos_001.md` es la referencia del modelo de datos** y `project_decisiones_001.md` explica por qué se diseñó así. Actualízalas si cambias el modelo.

## Compilar y ejecutar

No hay build, lint ni tests por línea de comandos. Se abre el `.4DProject` en 4D y se compila desde Diseño > Compilador. Claude no puede ejecutar ni compilar: edita `.4dm`, `.4DForm` y `catalog.4DCatalog` como texto, y el usuario lo verifica en 4D.

- `Data/` (archivo de datos) y `Project/DerivedData/` los genera 4D: no editarlos.
- `Temporal/` (en la raíz del proyecto) la creó el usuario para dejar archivos de referencia y capturas de pantalla (p. ej. `Foto01.png`) para analizar problemas. Cuando mencione una foto o archivo, búscalo ahí y léelo. No forma parte del proyecto 4D: no editar ni borrar su contenido.
- `Project/Sources/catalog.4DCatalog` es el esquema en XML. Se edita solo con 4D cerrado. Cada tabla, campo, relación e índice lleva su propio `uuid`.
- Los métodos de proyecto empiezan con la línea `//%attributes = {}`. Hay que conservarla.
- Los métodos de formulario y de objeto **deben declararse en el JSON**, o 4D no los ejecuta (Check Syntax no lo detecta). Raíz del formulario: `"method": "method.4dm"` y `"events": [...]` con cada `On X` que use el método. Cada objeto con `ObjectMethods/<objeto>.4dm`: `"method": "ObjectMethods/<objeto>.4dm"` y sus `"events"` (botón `onClick`, entrada `onDataChange`, lista `onDoubleClick`).
- Para renombrar, usa un script y termina con un grep de los nombres antiguos que dé 0 resultados (preferencia del usuario).

## Git

Repositorio en GitHub, rama principal `main`. Se usa para abrir el proyecto en otros equipos.
- **Cada commit lleva el nombre del equipo**: el hook `.githooks/prepare-commit-msg` agrega `Equipo: <COMPUTERNAME>` al final del mensaje. Se activa una vez por equipo, después de clonar: `git config core.hooksPath .githooks`.
- No se suben (`.gitignore`): `Data/`, `Project/DerivedData/`, `Logs/`, `userPreferences.*/`. `Temporal/` sí se sube. En otro equipo, 4D pide crear un archivo de datos nuevo y `Seg_Bootstrap` inicializa la base.
- `.gitattributes` con `* -text`: git no cambia los finales de línea de los fuentes de 4D.

## Modelo de datos (resumen)

`Empresas` es la raíz. **`EmpresaID` es Alpha(5)**: es la PK de `Empresas` y está en todas las tablas. Las demás PK son Longint autoincrementales con el nombre de la tabla sin `Ficha`/`Principal` + `ID` (`ClientesFicha.ClientesID`, `ClientesFacturaPrincipal.ClientesFacturaID`, `FichaBancos.BancosID`). Cada FK se llama igual que la PK a la que apunta. Las relaciones ORDA usan N→1 en singular (`empresa`, `sucursal`, `cliente`, `inventario`, `asiento`) y 1→N en plural (`detalles`, `movimientos`, `accesos`). Los campos no llevan tildes.

## Arquitectura

**Sesión.** No se usa el usuario ni el dominio del sistema operativo. `onStartup` → `Seg_Login` abre el formulario `LOGIN` (vía `Seg_Dialogo`, hasta 3 intentos), que pide `usuario@dominio` y la clave. El `dominio` identifica la empresa (`Empresas.Dominio`, obligatorio y único) y el `usuario` es `Usuarios.NombreAcceso` de esa empresa. La validación completa está en **`Seg_Autenticar(acceso; clave)`**, que comparten el escritorio y la web: empresa activa, usuario activo, clave correcta contra `Usuarios.ClaveHash` y rol activo. Si algo falla, el mensaje es genérico. Con un acceso válido, carga los accesos del rol en el interproceso `<>Usuario` (`id, nombreAcceso, rol, accesos, empresaID, sucursalID, dominio, ...`). Con la base vacía, `Seg_Bootstrap` pide EmpresaID, dominio, nombre de acceso y clave del administrador, y crea la empresa, la sucursal MATRIZ, los roles base y el usuario administrador. El bootstrap valida con `validar()` de cada entidad, revisa cada `save()` con `Val_Guardar` y, si algo falla, cancela la transacción completa. Dominio y NombreAcceso se guardan en minúsculas, sin espacios, `@` ni `\`. Un usuario no se puede guardar sin clave, y la clave pide confirmación y al menos 6 caracteres.

**Módulos y permisos.** `Seg_Modulos()` es el catálogo único de módulos (código, nombre, grupo). Lo usan `Menu_Construir`, `MENU_PRINCIPAL`, `Seg_Permiso` y el formulario de Roles. `Seg_Permiso(modulo; accion)` lee `<>Usuario.accesos`, que viene de la tabla `Accesos`; el rol `ADMIN` tiene acceso total. El módulo `X` usa los formularios `X_LISTA`/`X_DETALLE` (KARDEX solo tiene lista). `Modulo_Abrir("X")` abre `X_LISTA` en su propio proceso. **Para añadir un módulo:** agrégalo en `Seg_Modulos`, crea sus formularios y, si va en el menú principal, un botón `b<CODIGO>`.

**Maestros (`Maestro_*`).** El `On Load` de `X_LISTA` fija `Form.tabla` (dataclass), `Form.modulo`, `Form.campoBusqueda` y `Form.orden`. `Maestro_Refrescar` filtra por `EmpresaID = <>Usuario.empresaID`. `Maestro_Abrir` abre `Form.modulo+"_DETALLE"` con `{entidad; tabla; modulo}`. `Maestro_Guardar` llama a `Form.entidad.validar()` y luego `save()`, así que **cada `<Tabla>Entity` de un maestro debe implementar `validar() : Text`**. La unicidad por empresa se comprueba con `Val_Existe(entidad; campo)` y que las relaciones sean de la misma empresa con `Val_MismaEmpresa(entidad; relaciones)`. Los casos especiales por tabla (hash de clave de Usuarios, accesos de Roles, PK de Empresas) están como `Case of Form.tabla` en `Maestro_Nuevo`, `Maestro_DetalleCargar` y `Maestro_Guardar`. No se borran registros: `Maestro_Desactivar` alterna `Activo`.

**Documentos (`Doc_*`): FACTURA, COMPRA, AJUSTE, CONTABILIDAD.** Los `*_DETALLE` trabajan sobre `Form.lineas` (colección en memoria) con las propiedades de `Doc_DatosBase`. `Doc_Registrar` arma la cabecera y las líneas y llama a la función de la DataClass. `Doc_Anular` llama a `<Tabla>Entity.anular()`. `Doc_DetalleCargar` pone el formulario en modo "ver" según la convención de nombres de objeto: `b*` (botones) se desactivan salvo `bCerrar`, y `i*`/`lb*` dejan de ser editables.

**Lógica transaccional (clases ORDA, se ejecutan en el servidor).**
- `ClientesFacturaPrincipal.emitir`, `ProveedoresFacturaPrincipal.registrar`, `InventarioAjustesPrincipal.registrar`: trabajan en **una transacción**. Graban cabecera y detalle, mueven el stock y generan el asiento.
- **Todo cambio de stock pasa por `ds.InventarioMovimientos.registrar()`**, que valida la regla de `TipoOrigen` y actualiza `Stock` y el costo promedio. No hay que tocar `InventarioFicha.Stock` directamente.
- Los asientos se crean con `ds.ContabilidadPrincipal.registrar()`, que exige Debe = Haber y numera con `Empresas.SecuencialAsiento`. Las cuentas automáticas salen de `Empresas.Cta*`.
- Para anular un documento se crean movimientos contrarios con `Anulacion = True` y se llama a `asiento.marcarAnulado()`.
- Patrón de error: `return Tx_Fallar($res; mensaje; [entidadesBloqueadas])`, que desbloquea y hace `CANCEL TRANSACTION`. Para bloquear se usa `Tx_Bloquear` (reintenta durante ~1 s).
- Estas funciones **no deben usar `<>Usuario` ni `Form`**: reciben empresa, sucursal y usuario como parámetros. Tampoco deben modificar `This` para devolver datos al cliente.

**Web/REST.** `onWebAuthentication` acepta `usuario@dominio` y una clave, los valida con `Seg_Autenticar` (igual que el escritorio) y guarda el usuario en `Session.storage.usuario`. Las tablas `Usuarios`, `Roles` y `Accesos` y el campo `ClaveHash` no se exponen por REST (`hide_in_REST="true"` en el catálogo). `WebFolder/index.html` muestra los datos con `textContent`, nunca con `innerHTML`. `onMobileAppAuthentication` valida por `Usuarios.Email`. Las consultas REST todavía no filtran por empresa.
