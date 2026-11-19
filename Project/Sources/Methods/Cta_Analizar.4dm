//%attributes = {}
//Cta_Analizar(codigo; mascara) -> {ok; mensaje; nivel; grupo; padre}
//Comprueba que el código de cuenta respete la máscara. Un código puede tener menos niveles que la máscara.
//nivel: cantidad de niveles del código.  grupo: número del primer nivel.  padre: código de la cuenta superior ("" en nivel 1).
//Ej. con máscara 9.9.99.999: "1.1.01" -> nivel 3, grupo 1, padre "1.1"
#DECLARE($codigo : Text; $mascara : Text) : Object
var $res; $m : Object
var $seg : Collection
var $i; $j; $car : Integer

$res:=New object("ok"; False; "mensaje"; ""; "nivel"; 0; "grupo"; 0; "padre"; "")
$m:=Cta_Mascara($mascara)
If (Not($m.ok))
	$res.mensaje:=$m.mensaje
	return $res
End if

$codigo:=Trim($codigo)
If ($codigo="")
	$res.mensaje:="El código de la cuenta es obligatorio."
	return $res
End if

$seg:=Split string($codigo; $m.separador)
If ($seg.length>$m.niveles.length)
	$res.mensaje:="El código tiene más niveles que la máscara "+$mascara+"."
	return $res
End if

For ($i; 0; $seg.length-1)
	If (Length($seg[$i])#$m.niveles[$i])
		$res.mensaje:="El nivel "+String($i+1)+" del código debe tener "+String($m.niveles[$i])+" dígito(s) según la máscara "+$mascara+"."
		return $res
	End if
	For ($j; 1; Length($seg[$i]))
		$car:=Character code($seg[$i][[$j]])
		If (($car<48) || ($car>57))
			$res.mensaje:="El código solo admite dígitos y el separador '"+$m.separador+"' (máscara "+$mascara+")."
			return $res
		End if
	End for
End for

$res.nivel:=$seg.length
$res.grupo:=Num($seg[0])
$res.padre:=$seg.slice(0; $seg.length-1).join($m.separador)
$res.ok:=True
return $res
