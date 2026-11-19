//%attributes = {}
//Cta_Mascara(mascara) -> {ok; mensaje; separador; niveles}
//Analiza la máscara del plan de cuentas: un 9 por dígito y un único separador (. o -) entre niveles.
//niveles: colección con la cantidad de dígitos de cada nivel. Ej.: "9.9.99.999" -> [1; 1; 2; 3]
#DECLARE($mascara : Text) : Object
var $res : Object
var $i; $largo : Integer
var $c; $sep : Text

$res:=New object("ok"; False; "mensaje"; ""; "separador"; ""; "niveles"; New collection)
$mascara:=Trim($mascara)
If ($mascara="")
	$res.mensaje:="La máscara de cuentas es obligatoria (ej. 9.9.99.999)."
	return $res
End if

$largo:=0
For ($i; 1; Length($mascara))
	$c:=$mascara[[$i]]
	Case of
		: ($c="9")
			$largo+=1
		: (($c=".") || ($c="-"))
			If ($sep="")
				$sep:=$c
			End if
			If (($c#$sep) || ($largo=0))
				$res.mensaje:="Máscara inválida: use un solo tipo de separador (. o -) y al menos un 9 entre separadores."
				return $res
			End if
			$res.niveles.push($largo)
			$largo:=0
		Else
			$res.mensaje:="Máscara inválida: solo admite el dígito 9 y un separador (. o -)."
			return $res
	End case
End for

If ($largo=0)
	$res.mensaje:="Máscara inválida: no puede terminar con un separador."
	return $res
End if
$res.niveles.push($largo)

If ($sep="")
	$res.mensaje:="La máscara debe tener al menos dos niveles separados por . o - (ej. 9.9.99.999)."
	return $res
End if

$res.separador:=$sep
$res.ok:=True
return $res
