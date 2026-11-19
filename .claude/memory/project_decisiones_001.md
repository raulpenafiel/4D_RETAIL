# Decisiones de arquitectura — ERP 4D 21.x

> Archivo 001. Una entrada por decisión: fecha, decisión, motivo.

## 2026-11-18 — Migración al modelo de la nota `project_modelo_datos_001.md`
- **Se regeneró el catálogo completo** (17 tablas) y se **descartó el archivo de datos** anterior. Respaldo en `D:\PROYECTOS_IA\4D_RETAIL_Data_respaldo_2026-11-18`. Motivo: cambiar `EmpresaID` de Longint a Alpha(5) y renombrar tablas y llaves dejaba inservibles los datos de prueba.
- **Permisos en tablas (`Roles` + `Accesos`)** en lugar de reglas fijas en `Seg_Permiso`. El rol llamado `ADMIN` conserva acceso total para no quedarse sin acceso al configurar roles. `Seg_Bootstrap` crea los roles ADMIN, SUPERVISOR, CAJERO y CONSULTA con los permisos que tenía la versión anterior.
- **Todo cambio de stock pasa por `ds.InventarioMovimientos.registrar()`**, llamado dentro de la transacción del documento. El stock no se edita en el formulario de productos; el stock inicial se carga con un ajuste de entrada.
- **Las anulaciones crean movimientos contrarios con `Anulacion = True`** en lugar de borrar movimientos, para mantener el kardex completo.
- **Las cuentas de los asientos automáticos se guardan en `Empresas.Cta*`** mientras no exista plan de cuentas. Seg_Bootstrap pone códigos de ejemplo que deben ajustarse.
- **Costo promedio ponderado** en `InventarioFicha.Costo`: se recalcula con cada compra. Al anular una compra no se recalcula.
- **Se agregaron tablas de líneas** `ClientesFacturaDetalle` y `ProveedoresFacturaDetalle` (estaban como pendientes en la nota). Las líneas de un ajuste son sus movimientos.
- **Nombres de campos sin tildes** y `Activo` en todos los maestros, incluida `Empresas`, porque el código genérico `Maestro_*` lo usa para todas las tablas.
- **La lógica de las clases ORDA no usa `<>Usuario` ni `Form`**: en cliente/servidor esas funciones se ejecutan en el servidor, así que reciben empresa, sucursal y usuario como parámetros.
- **Bloqueos con reintento** (`Tx_Bloquear`, ~1 s): el número de asiento es un secuencial único por empresa y lo comparten todas las cajas.
- **Sin índices únicos compuestos**: la unicidad por empresa se valida con `Val_Existe`.

## 2026-11-18 — Acceso `usuario@dominio` sin el sistema operativo
- **Ya no se usa el dominio ni el usuario del equipo** (se borró `Seg_UsuarioSO`). El inicio de sesión pide `usuario@dominio` y clave en el formulario `LOGIN`. Motivo: decisión del usuario; el ERP no depende del dominio de Windows.
- **`Usuarios.Login` se renombró a `NombreAcceso`** (mismo uuid en el catálogo) en lugar de añadir un campo duplicado.
- **La clave es obligatoria también en escritorio.** Sin el SO, cualquiera podría escribir un nombre ajeno. `Maestro_Guardar` no deja guardar un usuario sin clave y el bootstrap pide la clave del administrador dos veces.
- **El mensaje de error del inicio de sesión es genérico** para no revelar si existe el dominio o el usuario.
- **La web usa el mismo formato** `usuario@dominio`.

## 2026-11-18 — Correcciones de la revisión de código (seguridad)
- **Una sola lógica de autenticación**, `Seg_Autenticar`, para escritorio y web. Motivo: la web no revisaba el rol activo porque era una copia.
- **`Usuarios`, `Roles`, `Accesos` y `ClaveHash` ocultos en REST.** Motivo: cualquier usuario web podía leer los hashes de clave de todas las empresas.
- **`index.html` usa `textContent`.** Motivo: XSS con nombres de clientes o productos.
- **El bootstrap usa `validar()` y `Val_Guardar`**, y vuelve a revisar que la base esté vacía dentro de la transacción. Motivo: las reglas estaban duplicadas, los `save()` no se revisaban y dos estaciones podían inicializar a la vez.
- **Clave con confirmación y mínimo 6 caracteres.** El hash se asigna después de `validar()`.

## 2026-11-18 — Plan de cuentas y Parámetros Contables
- **Tabla `ParametrosContables` (una fila por empresa)** con la máscara, los grupos principales y las cuentas `Cta*`, que **se quitaron de `Empresas`**. Motivo: pedido del usuario; los parámetros contables van en "Parámetros del Sistema", no en la ficha de la empresa.
- **Máscara con 9 por dígito y un solo separador** (`.` o `-`). El código guarda los separadores; `Nivel` y `Grupo` se calculan al validar.
- **La cuenta superior debe existir y no ser de movimiento**; no se cambia el código de una cuenta con subcuentas, asientos o usada en los parámetros.
- **Las `Cta*` deben ser cuentas activas de movimiento.** Si la empresa no tiene parámetros, facturas, compras y ajustes no se registran.
- **`Seg_Modulos` admite `formulario`** para módulos sin lista (PARAMCONTABLE abre `PARAMCONTABLE_DETALLE`).
- **`Seg_Bootstrap` crea los parámetros y un plan básico** (`Cta_PlanBase`) con las mismas cuentas de ejemplo que antes.
- **`FichaBancos` se renombró a `BancosFicha`** (mismo uuid en el catálogo), para seguir el patrón `<Entidad>Ficha`.
- **Las cuentas de todo asiento se validan en `ContabilidadPrincipal.registrar`** con `Cta_Validar` (regla única, sin `<>Usuario`). Motivo: un solo punto por donde pasan asientos manuales y automáticos. Al anular no se revalida: el asiento solo se marca ANULADO.
