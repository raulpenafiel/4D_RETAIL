//%attributes = {}
//Abre el documento seleccionado (Form.actual) en modo solo lectura
var $data; $l : Object
var $e; $d : 4D.Entity
var $deb; $cre : Real

If (Form.actual=Null)
	ALERT("Seleccione un registro.")
	return
End if
$e:=Form.actual
$data:=Doc_DatosBase("ver")
$data.fecha:=$e.Fecha

Case of
	: (Form.modulo="FACTURA")
		$data.numero:=$e.Numero+"  ["+$e.Estado+"]"
		$data.formaPago:=$e.FormaPago
		$data.observacion:=$e.Observacion
		$data.subtotal:=$e.Subtotal
		$data.descuento:=$e.Descuento
		$data.iva:=$e.Impuesto
		$data.total:=$e.Total
		If ($e.cliente#Null)
			$data.terIdent:=$e.cliente.Identificacion
			$data.terNombre:=$e.cliente.Nombre
		End if
		For each ($d; $e.detalles)
			$data.lineas.push(New object("inventarioID"; $d.InventarioID; "codigo"; $d.inventario.Codigo; "nombre"; $d.inventario.Nombre; \
			"cantidad"; $d.Cantidad; "precio"; $d.PrecioUnitario; "descuento"; $d.Descuento; "iva"; $d.PorcentajeIVA; "total"; $d.Total))
		End for each

	: (Form.modulo="COMPRA")
		$data.numero:=$e.Numero+"  ["+$e.Estado+"]"
		$data.formaPago:=$e.FormaPago
		$data.observacion:=$e.Observacion
		$data.subtotal:=$e.Subtotal
		$data.descuento:=$e.Descuento
		$data.iva:=$e.Impuesto
		$data.total:=$e.Total
		If ($e.proveedor#Null)
			$data.terIdent:=$e.proveedor.Identificacion
			$data.terNombre:=$e.proveedor.Nombre
		End if
		For each ($d; $e.detalles)
			$data.lineas.push(New object("inventarioID"; $d.InventarioID; "codigo"; $d.inventario.Codigo; "nombre"; $d.inventario.Nombre; \
			"cantidad"; $d.Cantidad; "precio"; $d.CostoUnitario; "descuento"; $d.Descuento; "iva"; $d.PorcentajeIVA; "total"; $d.Total))
		End for each

	: (Form.modulo="AJUSTE")
		$data.numero:=String($e.InventarioAjustesID)+"  ["+$e.Estado+"]"
		$data.motivo:=$e.Motivo
		//Las líneas del ajuste son sus movimientos originales (no los de reverso)
		For each ($d; $e.movimientos.query("Anulacion = :1"; False))
			$data.lineas.push(New object("inventarioID"; $d.InventarioID; "codigo"; $d.inventario.Codigo; "nombre"; $d.inventario.Nombre; \
			"tipo"; $d.Tipo; "cantidad"; $d.Cantidad; "precio"; $d.CostoUnit; "total"; Round($d.Cantidad*$d.CostoUnit; 2)))
		End for each

	: (Form.modulo="CONTABILIDAD")
		$data.numero:=String($e.Numero)+"  ["+$e.Estado+"] "+$e.Origen
		$data.concepto:=$e.Concepto
		For each ($d; $e.detalles)
			$data.lineas.push(New object("cuenta"; $d.Cuenta; "referencia"; $d.Referencia; "debito"; $d.Debito; "credito"; $d.Credito))
			$deb+=$d.Debito
			$cre+=$d.Credito
		End for each
		$data.totDebito:=$deb
		$data.totCredito:=$cre
		$data.diferencia:=Round($deb-$cre; 2)
End case

Doc_Abrir($data)
