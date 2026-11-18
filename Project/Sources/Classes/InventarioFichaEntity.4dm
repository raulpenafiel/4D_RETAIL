Class extends Entity

Function validar() : Text
	If (This.Codigo="")
		return "El código es obligatorio."
	End if
	If (This.Nombre="")
		return "El nombre es obligatorio."
	End if
	If ((This.Precio<0) || (This.Costo<0) || (This.PorcentajeIVA<0) || (This.StockMinimo<0))
		return "Precio, costo, IVA y stock mínimo no pueden ser negativos."
	End if
	If (Val_Existe(This; "Codigo"))
		return "Ya existe un producto con ese código."
	End if
	If ((This.CodigoBarras#"") && (Val_Existe(This; "CodigoBarras")))
		return "Ya existe un producto con ese código de barras."
	End if
	return ""
