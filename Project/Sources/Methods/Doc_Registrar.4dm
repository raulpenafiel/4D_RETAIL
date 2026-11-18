//%attributes = {}
//Botón Emitir / Registrar / Aplicar de los documentos.
//Arma cabecera y líneas y llama a la función de la DataClass, que trabaja en UNA transacción.
var $cab; $r; $l : Object
var $lineas : Collection

If (Form.lineas.length=0)
	ALERT("Agregue al menos una línea.")
	return
End if
$lineas:=New collection

Case of
	: (Form.modulo="FACTURA")
		If (Form.terceroID=0)
			ALERT("Seleccione un cliente (o 'Consumidor final').")
			return
		End if
		For each ($l; Form.lineas)
			$lineas.push(New object("inventarioID"; $l.inventarioID; "cantidad"; $l.cantidad; "descuento"; $l.descuento))
		End for each
		$cab:=New object("empresaID"; <>Usuario.empresaID; "sucursalID"; <>Usuario.sucursalID; "usuarioID"; <>Usuario.id; \
		"clientesID"; Form.terceroID; "formaPago"; Form.formaPago; "observacion"; Form.observacion)
		$r:=ds.ClientesFacturaPrincipal.emitir($cab; $lineas)

	: (Form.modulo="COMPRA")
		If (Form.terceroID=0)
			ALERT("Seleccione un proveedor.")
			return
		End if
		If (Form.numero="")
			ALERT("Escriba el número de la factura del proveedor.")
			return
		End if
		For each ($l; Form.lineas)
			$lineas.push(New object("inventarioID"; $l.inventarioID; "cantidad"; $l.cantidad; "costo"; $l.precio; "descuento"; $l.descuento))
		End for each
		$cab:=New object("empresaID"; <>Usuario.empresaID; "sucursalID"; <>Usuario.sucursalID; "usuarioID"; <>Usuario.id; \
		"proveedoresID"; Form.terceroID; "numero"; Form.numero; "fecha"; Form.fecha; "formaPago"; Form.formaPago; "observacion"; Form.observacion)
		$r:=ds.ProveedoresFacturaPrincipal.registrar($cab; $lineas)

	: (Form.modulo="AJUSTE")
		If (Form.motivo="")
			ALERT("Escriba el motivo del ajuste.")
			return
		End if
		For each ($l; Form.lineas)
			$lineas.push(New object("inventarioID"; $l.inventarioID; "tipo"; $l.tipo; "cantidad"; $l.cantidad))
		End for each
		$cab:=New object("empresaID"; <>Usuario.empresaID; "sucursalID"; <>Usuario.sucursalID; "usuarioID"; <>Usuario.id; \
		"fecha"; Form.fecha; "motivo"; Form.motivo)
		$r:=ds.InventarioAjustesPrincipal.registrar($cab; $lineas)

	: (Form.modulo="CONTABILIDAD")
		For each ($l; Form.lineas)
			$lineas.push(New object("cuenta"; $l.cuenta; "referencia"; $l.referencia; "debito"; $l.debito; "credito"; $l.credito))
		End for each
		$cab:=New object("empresaID"; <>Usuario.empresaID; "sucursalID"; <>Usuario.sucursalID; \
		"fecha"; Form.fecha; "concepto"; Form.concepto; "origen"; "MANUAL")
		$r:=ds.ContabilidadPrincipal.registrar($cab; $lineas)
End case

If ($r=Null)
	return
End if
If ($r.ok)
	ALERT("Documento registrado: "+String($r.numero))
	ACCEPT
Else
	ALERT($r.mensaje)
End if
