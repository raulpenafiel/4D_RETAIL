//%attributes = {}
//Ajustes: alterna ENTRADA/SALIDA en la línea seleccionada
If (Form.lineaActual=Null)
	ALERT("Seleccione una línea.")
	return
End if
If (Form.lineaActual.tipo="ENTRADA")
	Form.lineaActual.tipo:="SALIDA"
Else
	Form.lineaActual.tipo:="ENTRADA"
End if
Doc_Recalcular
