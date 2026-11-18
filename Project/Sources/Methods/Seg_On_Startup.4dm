//%attributes = {}

//On Startup (se ejecuta en cada 4D Remote)
C_OBJECT(<>Usuario)
C_TEXT(<>MenuBar)

<>Usuario:=New object

If (Seg_Login())
	<>MenuBar:=Menu_Construir()
	SET MENU BAR(<>MenuBar)
	Modulo_Abrir("PRINCIPAL")
Else 
	If (Is compiled mode)
		QUIT 4D
	End if 
End if 
