//%attributes = {}
//On Load de los *_DETALLE de documentos.
//En modo "ver" desactiva todos los botones (b...) salvo Cerrar y bloquea entradas (i...) y listas (lb...).
ARRAY TEXT($objetos; 0)
var $i : Integer
var $n : Text

If (Form.modo="ver")
	FORM GET OBJECTS($objetos)
	For ($i; 1; Size of array($objetos))
		$n:=$objetos{$i}
		Case of
			: ($n="bCerrar")
				//siempre activo
			: ($n="b@")
				OBJECT SET ENABLED(*; $n; False)
			: (($n="i@") || ($n="lb@"))
				OBJECT SET ENTERABLE(*; $n; False)
		End case
	End for
End if
