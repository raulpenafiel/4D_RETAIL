Class extends DataClass

//Registra un movimiento de inventario y actualiza InventarioFicha.Stock
//(y el costo promedio en las entradas de proveedor).
//Se llama DENTRO de la transacción del documento de origen: si falla, el que llama cancela.
//$m: {empresaID; sucursalID; inventarioID; fecha; tipo (ENTRADA/SALIDA); cantidad; costoUnit (opcional: costo actual);
//     tipoOrigen (CLIENTE/PROVEEDOR/AJUSTE); clientesID | proveedoresID | inventarioAjustesID;
//     clientesFacturaID; proveedoresFacturaID; anulacion (True en los movimientos de reverso)}
Function registrar($m : Object) : Object
	var $res; $r : Object
	var $p : cs.InventarioFichaEntity
	var $mov : cs.InventarioMovimientosEntity
	var $msg : Text
	var $cant : Real

	$res:=New object("ok"; False; "mensaje"; ""; "costoUnit"; 0)
	$cant:=Num($m.cantidad)
	$p:=ds.InventarioFicha.get(Num($m.inventarioID))
	If ($p=Null)
		$res.mensaje:="Producto inexistente."
		return $res
	End if
	If (Not(Tx_Bloquear($p)))
		$res.mensaje:="El producto "+$p.Nombre+" está en uso. Reintente."
		return $res
	End if

	$mov:=ds.InventarioMovimientos.new()
	$mov.EmpresaID:=String($m.empresaID)
	$mov.SucursalesID:=Num($m.sucursalID)
	$mov.InventarioID:=$p.InventarioID
	$mov.Fecha:=Date($m.fecha)
	If ($mov.Fecha=!00-00-00!)
		$mov.Fecha:=Current date
	End if
	$mov.Tipo:=String($m.tipo)
	$mov.Cantidad:=$cant
	$mov.TipoOrigen:=String($m.tipoOrigen)
	$mov.ClientesID:=Num($m.clientesID)
	$mov.ProveedoresID:=Num($m.proveedoresID)
	$mov.InventarioAjustesID:=Num($m.inventarioAjustesID)
	$mov.ClientesFacturaID:=Num($m.clientesFacturaID)
	$mov.ProveedoresFacturaID:=Num($m.proveedoresFacturaID)
	$mov.Anulacion:=Bool($m.anulacion)
	If ($m.costoUnit=Null)
		$mov.CostoUnit:=$p.Costo
	Else
		$mov.CostoUnit:=Num($m.costoUnit)
	End if

	$msg:=$mov.validar()
	If ($msg#"")
		$p.unlock()
		$res.mensaje:=$msg
		return $res
	End if

	If ($mov.Tipo="SALIDA")
		If ($p.Stock<$cant)
			$p.unlock()
			$res.mensaje:="Stock insuficiente: "+$p.Nombre+" (disponible "+String($p.Stock)+")."
			return $res
		End if
		$p.Stock:=$p.Stock-$cant
	Else
		If (($mov.TipoOrigen="PROVEEDOR") && (Not($mov.Anulacion)))
			//costo promedio ponderado
			If ($p.Stock>0)
				$p.Costo:=Round((($p.Stock*$p.Costo)+($cant*$mov.CostoUnit))/($p.Stock+$cant); 4)
			Else
				$p.Costo:=$mov.CostoUnit
			End if
		End if
		$p.Stock:=$p.Stock+$cant
	End if

	$r:=$p.save()
	If ($r.success)
		$r:=$mov.save()
	End if
	$p.unlock()
	If (Not($r.success))
		$res.mensaje:="No se pudo grabar el movimiento de "+$p.Nombre+"."
		return $res
	End if
	$res.ok:=True
	$res.costoUnit:=$mov.CostoUnit
	$res.id:=$mov.InventarioMovimientosID
	return $res
