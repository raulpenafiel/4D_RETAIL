# Modelo de datos — ERP 4D 21.x

> **Implementado** en `Project/Sources/catalog.4DCatalog` el 2026-11-18 (antes era solo propuesta). Pendiente de abrir y probar en 4D.
> Archivo 001. Límite: 200 líneas / 25 KB. Al superarlo, continuar en `project_modelo_datos_002.md` y registrarlo en `MEMORY.md`.
> Nombres de campos sin tildes (Codigo, Direccion, StockMinimo…) para evitar problemas en código y REST.

## Convenciones
- **Empresas es la raíz del modelo.** El ERP maneja 1 o varias empresas. Toda relación de negocio parte de `Empresas` mediante el campo **`EmpresaID`**.
- **`EmpresaID`: Alpha de 5 caracteres** (`type="10" limiting_length="5"` en el catálogo). Es la llave primaria de `Empresas` y la llave foránea en **todas** las demás tablas, con el mismo tipo y longitud.
- Las demás tablas usan como llave primaria un Longint autoincremental llamado **nombre de la tabla sin los sufijos `Ficha` ni `Principal` + `ID`** (p. ej. `ClientesFicha.ClientesID`, `ClientesFacturaPrincipal.ClientesFacturaID`, `BancosFicha.BancosID`).
- Las llaves foráneas llevan **el mismo nombre que la llave primaria de la tabla referenciada**.
- Relaciones ORDA: N→1 en singular, 1→N en plural.
- `EmpresaID` indexado en todas las tablas. Códigos y documentos son únicos **por empresa**: se valida en código con `Val_Existe` (no hay índices únicos compuestos en el catálogo).
- Aunque haya una sola empresa, el diseño es igual: no se omite `EmpresaID`.
- Los maestros usan `Activo` (también `Empresas.Activo`, no `Activa`) porque el código genérico `Maestro_*` lo usa para todas las tablas.

## Raíz

| Tabla | Campos clave | Relaciones |
|---|---|---|
| **Empresas** | **EmpresaID** (Alpha 5, PK, sin autoincremento), RUC, RazonSocial, NombreComercial, Direccion, Telefono, Email, Dominio (único), SecuencialAsiento, Activo | 1→N hacia todas las tablas del modelo |

Las cuentas de los asientos automáticos ya no están en `Empresas`: se trasladaron a `ParametrosContables` (2026-11-18).

## Seguridad y organización

| Tabla | Campos clave | Relaciones |
|---|---|---|
| Sucursales | SucursalesID, EmpresaID, Codigo, Nombre, Direccion, Telefono, Establecimiento, PuntoEmision, SecuencialFactura, Activo | N→1 empresa |
| Roles | RolesID, EmpresaID, Nombre, Activo | N→1 empresa; 1→N `accesos`, `usuarios` |
| Accesos | AccesosID, EmpresaID, RolesID, Modulo, Leer, Crear, Editar, Anular | N→1 empresa, `rol` |
| Usuarios | UsuariosID, EmpresaID, SucursalesID, RolesID, NombreAcceso, Nombres, Email, ClaveHash (obligatoria), Activo, UltimoAcceso, UltimoAccesoHora | N→1 empresa, `sucursal`, `rol`. NombreAcceso único por empresa |

Acceso: `NombreAcceso@Dominio` + clave (escritorio y web). `Empresas.Dominio` es obligatorio y único. Dominio y NombreAcceso se guardan en minúsculas, sin espacios, `@` ni `\`.

`Accesos.Modulo` usa los códigos de `Seg_Modulos` (INVENTARIO, AJUSTE, KARDEX, CLIENTE, FACTURA, PROVEEDOR, COMPRA, PLANCUENTA, CONTABILIDAD, BANCO, EMPRESA, SUCURSAL, ROL, USUARIO, PARAMCONTABLE).

## Inventarios

| Tabla | Campos clave | Relaciones |
|---|---|---|
| InventarioFicha | InventarioID, EmpresaID, Codigo, CodigoBarras, Nombre, Descripcion, Categoria, Unidad, Costo (promedio), Precio, PorcentajeIVA, Stock, StockMinimo, Activo | N→1 empresa; 1→N `movimientos`, `lineasFacturaCliente`, `lineasFacturaProveedor` |
| InventarioAjustesPrincipal | InventarioAjustesID, EmpresaID, SucursalesID, UsuariosID, Fecha, Motivo, Estado (APLICADO/ANULADO), ContabilidadID | N→1 empresa, `sucursal`, `usuario`, `asiento`; 1→N `movimientos` |
| InventarioMovimientos | InventarioMovimientosID, EmpresaID, SucursalesID, InventarioID, Fecha, Tipo (ENTRADA/SALIDA), Cantidad, CostoUnit, **TipoOrigen** (CLIENTE/PROVEEDOR/AJUSTE), ClientesID, ProveedoresID, InventarioAjustesID, ClientesFacturaID, ProveedoresFacturaID, Anulacion | N→1 empresa, `sucursal`, `inventario`, `cliente`, `proveedor`, `ajuste`, `facturaCliente`, `facturaProveedor` |

**Regla de InventarioMovimientos:** según `TipoOrigen` se llena **solo una** de `ClientesID`, `ProveedoresID`, `InventarioAjustesID`; las otras quedan en 0. Se valida en `InventarioMovimientosEntity.validar()`.
- `Stock` de InventarioFicha solo cambia mediante `ds.InventarioMovimientos.registrar()` (no se edita en el formulario).
- Las líneas de un ajuste **son** sus movimientos (no hay tabla de líneas de ajuste).
- Al anular un documento se crean movimientos contrarios con `Anulacion = True`; los originales no se borran.

## Clientes

| Tabla | Campos clave | Relaciones |
|---|---|---|
| ClientesFicha | ClientesID, EmpresaID, Codigo, TipoIdentificacion (CI/RU/PA), Identificacion, Nombre, Direccion, Telefono, Email, Activo | N→1 empresa; 1→N `facturas`, `movimientos` |
| ClientesFacturaPrincipal | ClientesFacturaID, EmpresaID, SucursalesID, UsuariosID, ClientesID, Numero (EEE-PPP-000000000), Fecha, Hora, Subtotal, Descuento, Impuesto, Total, FormaPago, Estado (EMITIDA/ANULADA), Observacion, ContabilidadID | N→1 empresa, `sucursal`, `usuario`, `cliente`, `asiento`; 1→N `detalles`, `movimientos` |
| ClientesFacturaDetalle | ClientesFacturaDetalleID, EmpresaID, ClientesFacturaID, InventarioID, Cantidad, PrecioUnitario, Descuento, PorcentajeIVA, Subtotal, ValorIVA, Total | N→1 empresa, `factura`, `inventario` |

## Proveedores

| Tabla | Campos clave | Relaciones |
|---|---|---|
| ProveedoresFicha | ProveedoresID, EmpresaID, Codigo, TipoIdentificacion, Identificacion, Nombre, Direccion, Telefono, Email, Activo | N→1 empresa; 1→N `facturas`, `movimientos` |
| ProveedoresFacturaPrincipal | ProveedoresFacturaID, EmpresaID, SucursalesID, UsuariosID, ProveedoresID, Numero (del proveedor), Fecha, Subtotal, Descuento, Impuesto, Total, FormaPago, Estado (REGISTRADA/ANULADA), Observacion, ContabilidadID | N→1 empresa, `sucursal`, `usuario`, `proveedor`, `asiento`; 1→N `detalles`, `movimientos` |
| ProveedoresFacturaDetalle | ProveedoresFacturaDetalleID, EmpresaID, ProveedoresFacturaID, InventarioID, Cantidad, CostoUnitario, Descuento, PorcentajeIVA, Subtotal, ValorIVA, Total | N→1 empresa, `factura`, `inventario` |

## Contabilidad

| Tabla | Campos clave | Relaciones |
|---|---|---|
| ContabilidadPrincipal | ContabilidadID, EmpresaID, SucursalesID, Fecha, Numero (secuencial por empresa), Concepto, Origen (MANUAL/FACTURA_CLIENTE/FACTURA_PROVEEDOR/AJUSTE), Estado (REGISTRADO/ANULADO) | N→1 empresa, `sucursal`; 1→N `detalles`, `facturasClientes`, `facturasProveedores`, `ajustes` |
| ContabilidadDetalle | ContabilidadDetalleID, EmpresaID, ContabilidadID, Cuenta, Debito, Credito, Referencia | N→1 empresa, `asiento` |
| PlanCuentas | PlanCuentasID, EmpresaID, Codigo, Nombre, Nivel, Grupo, Naturaleza (DEUDORA/ACREEDORA), Movimiento, Activo | N→1 empresa |
| ParametrosContables | ParametrosContablesID, EmpresaID (uno por empresa), Mascara, GrupoActivo, GrupoPasivo, GrupoPatrimonio, GrupoIngresos, GrupoCostos, GrupoGastos, `CtaCaja`, `CtaCxC`, `CtaVentas`, `CtaIVAVentas`, `CtaInventario`, `CtaCostoVentas`, `CtaCxP`, `CtaIVACompras`, `CtaAjusteInventario` | N→1 empresa (`Empresas.parametrosContables`) |

Plan de cuentas: el código sigue la máscara (`9.9.99.999`: un 9 por dígito, separador `.` o `-`); `Nivel` y `Grupo` se calculan; el primer nivel debe ser un grupo principal; la cuenta superior debe existir y no ser de movimiento. `ContabilidadDetalle.Cuenta` guarda el código; `ContabilidadPrincipal.registrar` lo valida con `Cta_Validar` (existe, activa, de movimiento) en asientos manuales y automáticos.

Regla: en cada asiento, suma de Debito = suma de Credito (`ds.ContabilidadPrincipal.registrar`). Facturas, compras y ajustes generan su asiento **dentro de su transacción**; al anular el documento, el asiento queda ANULADO.

## Bancos

| Tabla | Campos clave | Relaciones |
|---|---|---|
| BancosFicha | BancosID, EmpresaID, Banco, NumeroCuenta, Tipo (AHORROS/CORRIENTE), Moneda (ISO 3), Activo | N→1 empresa |

## Nómina
Sin tablas definidas todavía (también llevarán `EmpresaID`).

## Relaciones 1→N desde Empresas
`sucursales`, `roles`, `accesos`, `usuarios`, `inventarios`, `inventarioAjustes`, `inventarioMovimientos`, `clientes`, `clientesFacturas`, `clientesFacturaDetalles`, `proveedores`, `proveedoresFacturas`, `proveedoresFacturaDetalles`, `asientos`, `contabilidadDetalles`, `bancos`, `planCuentas`, `parametrosContables`. Todas las hijas tienen `empresa` (N→1).

## Reglas de integridad por EmpresaID
- Toda consulta de negocio filtra por el `EmpresaID` de la sesión (`<>Usuario.empresaID`; en web `Session.storage.usuario.empresaID`).
- En tablas hijas, `EmpresaID` debe ser **igual** al de su registro padre: `Val_MismaEmpresa(entidad; relaciones)` y comprobaciones en las funciones de documentos.
- Un registro nunca se relaciona con otro de distinta empresa.

## Pendiente de definir
- **Movimientos bancarios** (Bancos solo tiene la ficha).
- **Nómina**: empleados, conceptos, roles de pago.
- Stock por sucursal (hoy `InventarioFicha.Stock` es global; los movimientos sí guardan la sucursal).
- Filtro por empresa en REST (hoy la consulta web muestra datos de todas las empresas).

## No verificado en 4D
- Que 4D abra el catálogo generado: `EmpresaID` Alpha(5) como llave primaria de `Empresas` y como FK en las relaciones.
- Índices únicos compuestos (`EmpresaID` + código): no se crearon; la unicidad se valida en código.
- `hide_in_REST="true"` en `Usuarios`, `Roles`, `Accesos` y `Usuarios.ClaveHash`: comprobar en el inspector que "Exponer como recurso REST" esté desmarcado.
