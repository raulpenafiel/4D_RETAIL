Case of
	: (Form event code=On Load)
		Form.cabecera:=<>Usuario.empresaNombre+"   |   Dominio: "+<>Usuario.dominio+"   |   "+<>Usuario.nombres+" ("+<>Usuario.rol+")"
		var $m : Object
		For each ($m; Seg_Modulos())
			OBJECT SET ENABLED(*; "b"+$m.codigo; Seg_Permiso($m.codigo; "ver"))
		End for each
End case
