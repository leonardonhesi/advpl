#include 'protheus.ch'
//TODO Ver questão de limpar os campos permitindo que varias operações possam ser feitas durante a execução do programa
/*/{Protheus.doc} Metadados
(long_description)
@author bolognesi
@since 24/03/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
class ManBaseDados 

	data aCampoValor
	data lOk
	data cMsgErro
	data nOrd 
	data aInfoKey
	data cOrder
	data cKey

	method newManBaseDados() constructor 
	method getCampoValor()
	method getInfoKey()
	method getKey()
	method getOrd()
	method getOrder()
	method setOrd()
	method addKey()
	method addCpoVlr()
	method getOk()
	method getMsgErro()
	method limpar()
	method updTable()
	method isAuto()
	method allOk()
	

endclass

/*/{Protheus.doc} new
Metodo construtor
@author bolognesi
@since 24/03/2016 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
method newManBaseDados() class ManBaseDados
	::limpar()
return

method getCampoValor() 	class ManBaseDados
return ::aCampoValor 

method getInfoKey() 	class ManBaseDados
return ::aInfoKey

method getOk() 			class ManBaseDados
return ::lOk

method getMsgErro() 	class ManBaseDados
return ::cMsgErro

method getKey()			class ManBaseDados
return ::cKey

method isAuto() 		class ManBaseDados
return  _SetAutoMode() .Or. IsBlind()

method allOk()			class ManBaseDados
	if !::getOk()
		If  !::isAuto()
			MessageBox( "[ERRO] " + ::getMsgErro() , "AVISO", 48)
			//TODO ELSE MANDAR E-MAIL
		EndIf
		::limpar()
	EndIf
return ::getOk()

method limpar() 		class ManBaseDados
	::lOk 			:= .T.
	::cMsgErro 		:= ""
	::aCampoValor 	:= {}
	::nOrd			:= 0 
	::aInfoKey		:= {}
	::cKey			:= ""

return	

method getOrd() class ManBaseDados
return ::nOrd


method getOrder()	class ManBaseDados
return ::cOrder

method setOrd(cTab, nOrd)   class ManBaseDados
	Local nX		:=  0
	Local aDesc 	:= {}
	Local aInfoKey 	:= {}
	Local aX3		:= {}	
	Local lIx		:= .F.
	Local cOrder	:= ""
	Default cTab	:= ""
	Default nOrd	:= 0	

	If !Empty(cTab) .And. nOrd > 0		
		DbSelectArea(cTab)
		If Select(cTab) > 0

			DbSelectarea("SIX")
			SIX->(DbSetOrder(1))
			lIx := SIX->(DbSeek(cTab + cValToChar(nOrd) ,.F. ) )
			If	lIx 
				DbSetOrder(nOrd)
				aDesc := StrTokArr(SIX->(CHAVE), '+') 
				If Len(aDesc) > 0
					For nX := 2 To Len(aDesc)
						aX3 := TamSX3(aDesc[nX])
						Aadd(aInfoKey, {aDesc[nX], aX3[1], aX3[2], aX3[3] }  )
						cOrder += Alltrim(aDesc[nX])
					Next nX
				Endif
			Else
				::lOk 		:= .F.
				::cMsgErro	:= 'ORDEM '  + cValToChar(nOrd) + ' NÂO ENCONTRADA'
			EndIf
		Else
			::lOk 		:= .F.
			::cMsgErro	:= 'ALIAS NÃO EXISTE'
		EndIf
	else
		::lOk 		:= .F.
		::cMsgErro	:= 'ORDEM OU CHAVE NÃO DEFINIDAS CORRETAMENTE'
	endIf

	::nOrd 		:= nOrd
	::aInfoKey 	:= aInfoKey
	::cOrder	:= SIX->(CHAVE)	
return ::allOk()

method addKey(aChave)   class ManBaseDados
	//aChave{"024243" , "01" , "1540804401"}
	//(aInfoKey, {Nome, Tamanho, Decimal, Tipo }  )
	Local nX 		:= 0 
	Local cKey 		:= ""
	Local aIKey		:= ::getInfoKey()
	Local cTipo		:= ""
	Local lOk		:= .T.
	Local cMsg		:= ""
	Default aChave 	:= {}

	If !Empty(aChave) .And. !Empty(aIKey) .And. (Len(aChave) <= Len(aIKey) )

		For nX := 1 To Len(aChave)

			cTipo := ValType(aChave[nX])
			If cTipo  <> 'C'
				If cTipo == 'D'
					aChave[nX] := DtoS(aChave[nX])
				ElseIf cTipo == 'N'
					aChave[nX] := cValToChar(aChave[nX])
				ElseIf cTipo == 'L'
					aChave[nX] := cValToChar(aChave[nX])
				Else
					lOk 	:= .F.
					cMsg 	:= "O TIPO " + cTipo + " NÃO PERMITIDO PARA UTILIZAR EM CHAVE" 
				EndIf

			EndIf
			aChave[nX] := Padr(aChave[nX], aIKey[nX,2] )
			cKey += aChave[nX] 
		Next nX

	else
		lOk 	:= .F.
		cMsg 	:= 'NÃO FOI POSSIVEL FORMATAR A CHAVE PARA BUSCA'

	EndIf

	::lOk 		:= lOk
	::cMsgErro	:= cMsg 
	::cKey 		:= cKey
return ::allOk()


 
method addCpoVlr(cCampo,cValor) class ManBaseDados
	Local cPref 	:= ""
	Local cTpVlr	:= ""
	Local cTpCampo	:= "" 

	If !Empty(cCampo) //.And. !Empty(cValor)
		cTpVlr 		:= ValType(cValor)
		cPref 		:= FWTabPref(cCampo)

		If !Empty(cPref) 
			cTpCampo	:= cValToChar(TamSx3(cCampo)[3])

			If cTpCampo == cTpVlr 

				If cTpVlr == 'C'
					cValor := Padr(cValor, TamSx3(cCampo)[1] )
				EndIf
				AAdd(::aCampoValor, {cPref,cPref+'->'+cCampo,cValor})

			Else
				::lOk 		:= .F.
				::cMsgErro	:= 'TIPO DE DADOS (PARAMTERO X CAMPO) INCOMPATIVEIS'
			EndIf

		Else
			::lOk 		:= .F.
			::cMsgErro	:= 'ALIAS PARA O CAMPO NÂO EXISTE'
		EndIf

	Else
		::lOk 		:= .F.
		::cMsgErro	:= 'FALTA PARAMETROS NA CHAMADA'
	EndIf	
return ::allOk()

method updTable(nRec) class ManBaseDados
	Local lRet 		:= .F.
	Local lSeek		:= .F.
	Local aCampo	:= {}
	Local nX		:=  0
	Local cTab		:= ""
	Local cUnlock	:= ""
	Local cLock		:= ""
	Local cGoto		:= ""
	Local lOk		:= ::getOk() 
	Local cTabAli	:= ""

	Default nRec	:= ""

	If  lOk

		aCampo := ::getCampoValor()

		If Len(aCampo) > 0
			cTab 	:= aCampo[1,1]
			cGoto  	:= aCampo[1,1] + '->(dbgoto( ' + cValtoChar(nRec) + ' ))' 
			DbSelectarea(cTab)

			If Empty(nRec)
				DbSetOrder(::getOrd())
				lSeek := DbSeek(xFilial(cTab) + ::getKey(),.F.)
			Else
				&cGoto
				If !Eof()
					lSeek := .T.
				EndIf
			EndIf

			If lSeek	
				RecLock(cTab, .F.)

				For nX := 1 To Len(aCampo)

					cTabAli := aCampo[nX,2] 
					If ValType(aCampo[nX,3]) == 'C'
						cVlr 	:= " '" + aCampo[nX,3] + "' "
					//TODO Testar quando for campo de data
					Else
						cVlr 	:= cValToChar(aCampo[nX,3])
					endIf
					cUpd 	:= cTabAli + " := " + cVlr  
					&cUpd 
				Next nX
				MsUnLock()

			Else
				::lOk 		:= .F.
				::cMsgErro	:= "BUSCA NÃO ENCONTRADO PELO DBSEEK, VERIFIQUE A CHAVE " + ::getKey() + " PARA A ORDEM" + cValToChar(::getOrder())
			EndIf

		Else
			::lOk 		:= .F.
			::cMsgErro	:= "UPDATE SEM DEFINIR CAMPOS UTILIZE  oObjeto:addCpoVlr(CAMPO,VALOR) ANTES DO UPDATE "

		EndIf

	EndIf

return ::allOk()