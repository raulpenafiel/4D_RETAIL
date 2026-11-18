//%attributes = {}
//Agrega el producto de Form.codigo (código o código de barras) a Form.lineas
//FACTURA usa el precio de venta; COMPRA y AJUSTE el costo promedio.
var $p : cs.InventarioFichaEntity
var $l : Object
var $precio : Real

If (Form.codigo="")
	return
End if

$p:=ds.InventarioFicha.query("EmpresaID = :1 AND Activo = :2 AND (Codigo = :3 OR CodigoBarras = :3)"; <>Usuario.empresaID; True; Form.codigo).first()
If ($p=Null)
	ALERT("Producto no encontrado.")
	Form.codigo:=""
	return
End if

For each ($l; Form.lineas)
	If (($l.inventarioID=$p.InventarioID) && ((Form.modulo#"AJUSTE") || ($l.tipo=Form.tipo)))
		$l.cantidad:=$l.cantidad+1
		Doc_Recalcular
		Form.codigo:=""
		return
	End if
End for each

$precio:=$p.Costo
If (Form.modulo="FACTURA")
	$precio:=$p.Precio
End if

Form.lineas.push(New object(\
"inventarioID"; $p.InventarioID; "codigo"; $p.Codigo; "nombre"; $p.Nombre; "tipo"; Form.tipo; \
"cantidad"; 1; "precio"; $precio; "descuento"; 0; "iva"; $p.PorcentajeIVA; "total"; 0))
Doc_Recalcular
Form.codigo:=""
