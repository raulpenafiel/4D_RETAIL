//%attributes = {}
//Seg_Modulos -> colección de {codigo; nombre; grupo}
//Catálogo único de módulos: lo usan el menú, el menú principal, los permisos y el formulario de Roles.
//Cada módulo X tiene los formularios X_LISTA y X_DETALLE (KARDEX solo X_LISTA).
#DECLARE() : Collection
var $c : Collection

$c:=New collection
$c.push(New object("codigo"; "INVENTARIO"; "nombre"; "Productos"; "grupo"; "Inventarios"))
$c.push(New object("codigo"; "AJUSTE"; "nombre"; "Ajustes de inventario"; "grupo"; "Inventarios"))
$c.push(New object("codigo"; "KARDEX"; "nombre"; "Kardex"; "grupo"; "Inventarios"))
$c.push(New object("codigo"; "CLIENTE"; "nombre"; "Clientes"; "grupo"; "Clientes"))
$c.push(New object("codigo"; "FACTURA"; "nombre"; "Facturación"; "grupo"; "Clientes"))
$c.push(New object("codigo"; "PROVEEDOR"; "nombre"; "Proveedores"; "grupo"; "Proveedores"))
$c.push(New object("codigo"; "COMPRA"; "nombre"; "Compras"; "grupo"; "Proveedores"))
$c.push(New object("codigo"; "CONTABILIDAD"; "nombre"; "Asientos contables"; "grupo"; "Contabilidad"))
$c.push(New object("codigo"; "BANCO"; "nombre"; "Bancos"; "grupo"; "Contabilidad"))
$c.push(New object("codigo"; "EMPRESA"; "nombre"; "Empresa"; "grupo"; "Administración"))
$c.push(New object("codigo"; "SUCURSAL"; "nombre"; "Sucursales"; "grupo"; "Administración"))
$c.push(New object("codigo"; "ROL"; "nombre"; "Roles"; "grupo"; "Administración"))
$c.push(New object("codigo"; "USUARIO"; "nombre"; "Usuarios"; "grupo"; "Administración"))
return $c
