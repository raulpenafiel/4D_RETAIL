//%attributes = {}
//Quita la línea seleccionada del documento
If (Form.lineaActual#Null)
	Form.lineas.remove(Form.lineas.indexOf(Form.lineaActual))
	Doc_Recalcular
End if
