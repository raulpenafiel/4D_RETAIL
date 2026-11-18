Class extends Entity

//Regla de la nota de modelo: según TipoOrigen (CLIENTE / PROVEEDOR / AJUSTE) se llena SOLO una
//de las llaves ClientesID, ProveedoresID, InventarioAjustesID; las otras quedan en 0.
Function validar() : Text
	var $llaves : Integer
	var $ok : Boolean

	If (Not(["ENTRADA"; "SALIDA"].includes(This.Tipo)))
		return "Tipo de movimiento inválido (ENTRADA/SALIDA)."
	End if
	If (This.Cantidad<=0)
		return "La cantidad del movimiento debe ser mayor que cero."
	End if
	$llaves:=Num(Num(This.ClientesID)#0)+Num(Num(This.ProveedoresID)#0)+Num(Num(This.InventarioAjustesID)#0)
	Case of
		: (This.TipoOrigen="CLIENTE")
			$ok:=(Num(This.ClientesID)#0)
		: (This.TipoOrigen="PROVEEDOR")
			$ok:=(Num(This.ProveedoresID)#0)
		: (This.TipoOrigen="AJUSTE")
			$ok:=(Num(This.InventarioAjustesID)#0)
	End case
	If ((Not($ok)) || ($llaves#1))
		return "Movimiento inválido: según TipoOrigen debe llenarse solo una de ClientesID, ProveedoresID o InventarioAjustesID."
	End if
	return Val_MismaEmpresa(This; ["inventario"; "sucursal"; "cliente"; "proveedor"; "ajuste"; "facturaCliente"; "facturaProveedor"])
