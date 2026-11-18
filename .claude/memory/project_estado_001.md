# Estado actual — ERP 4D 21.x (actualizado 2026-11-18)

> Archivo 001. Qué está listo, en curso y pendiente.

## Escrito pero sin probar en 4D (migración del 2026-11-18)
Todo el código se escribió como texto y aún no se ha abierto ni compilado en 4D.
- Administración: Empresa, Sucursales, Roles (con accesos por módulo), Usuarios.
- Inventarios: Productos (InventarioFicha), Ajustes (con asiento), Kardex (solo consulta).
- Clientes: Clientes, Facturación (stock + asiento, anulación con reverso).
- Proveedores: Proveedores, Compras (costo promedio + asiento, anulación con reverso).
- Contabilidad: asientos manuales y automáticos; Bancos (solo ficha).
- Web: consulta REST de productos, clientes, facturas, proveedores y compras.

## Primer paso pendiente
1. Abrir `Project/4D_RETAIL_IA.4DProject` en 4D y crear un archivo de datos nuevo.
2. Compilar (Diseño > Compilador) y corregir los errores de sintaxis que aparezcan.
3. Primer arranque: `Seg_Bootstrap` pide EmpresaID, dominio, nombre de acceso y clave del administrador. Luego entrar con `admin@dominio` y la clave. Probar también una clave errónea, un acceso sin `@` y guardar un usuario sin clave (debe rechazarse).
4. Probar en este orden: cuentas de la empresa, producto, ajuste de entrada, compra, factura, anulaciones y kardex.

## Pendiente (sin diseño)
- Plan de cuentas, movimientos bancarios, nómina.
- Stock por sucursal.
- Filtrar REST por empresa de la sesión.
- Reportes (facturas, kardex valorizado, libro diario).
