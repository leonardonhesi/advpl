#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'

//TODO Implementar Relacionamentos Joins

/*/{Protheus.doc} SqlUtil
@author bolognesi
@since 08/08/2016
@version 1.0
@example
oSql := SqlUtil():newSqlUtil()
@description Classe para abstrair, facilittar e centralizar todas as utilidades relacionadas ao SQL
disponibilizando um objeto para interagir com o banco de dados.
/*/
class SqlUtil 

	Data lOk
	Data cMsgErro

	Data cWhere
	Data cFromStr
	Data cFromTab
	//TODO Data aJoinTab
	Data aCampos
	Data cCmpOrdem
	Data qryForSend
	Data oRes
	Data nRegCount

	method newSqlUtil() constructor 
	method QrySelect()
	method addCampos()
	method addFromTab()
	method addWhere()
	method addOrder()
	// TODO method addJoin()
	method clearWhere()
	method closeWhere()
	method zeroAll()
	method resToObj()
	method trataTipo()

endclass

/*/{Protheus.doc} newSqlUtil
Metodo construtor
@author bolognesi
@since 08/08/2016 
@version 1.0
@description Construtor da classe
/*/
method newSqlUtil() class SqlUtil
	::clearWhere()
	::lOk := .T.
	return(self)

	/*/{Protheus.doc} zeroAll()
	@author bolognesi
	@since 08/08/2016 
	@version 1.0
	@description Limpa todas as propriedades
	/*/
method zeroAll() class SqlUtil
	::clearWhere()
	::aCampos 	:= {}
	::cCmpOrdem	:= ""
	::cFromTab 	:= ""
	::cFromStr 	:= ""
	::lOk		:= .T.
	::cMsgErro	:= ""
	return(self) 

	/*/{Protheus.doc} addCampos()
	@author bolognesi
	@since 08/08/2016 
	@version 1.0
	@description Campos relacionados a tabela FROM, que ser�o retornados na busca
	para adicionar campos de join utilize outro metodo
	/*/
method addCampos(aCmps) class SqlUtil
	Local nX := 0
	Local cPref
	Default aCmps := {}

	::aCampos := {}
	::lOk := .T.

	If Empty(::cFromTab)
		::lOk := .F.
		::cMsgErro := "[ERRO] - Antes de definir os campos selecione um tabela para from"
	Else
		For nX := 1 To Len(aCmps)
			cPref 	:= FWTabPref(aCmps[nX])
			If Empty(cPref) 
				::lOk := .F.
				::cMsgErro := "[ERRO] - Campo " + aCmps[nX] + " n�o existe em nenhuma tabela"
				break
			Else
				If cPref # ::cFromTab
					::lOk := .F.
					::cMsgErro := "[ERRO] - Campo " + aCmps[nX] + " mas n�o pertence as tabelas informadas "
				Else
					If Substr(aCmps[nX],1,3) # ::cFromTab
						AAdd(::aCampos, cPref + '.' + aCmps[nX] )
					Else
						AAdd(::aCampos, aCmps[nX] )
					EndIf
				EndIf 
			EndIf
		Next nX
	EndIf
return(self)

/*/{Protheus.doc} addFromTab()
@author bolognesi
@since 08/08/2016 
@version 1.0
@description Adicionar tabela que ser� utilizada como principal da consulta
/*/
method addFromTab(cTable) class SqlUtil
	Default cTable := ""
	::lOk := .T.
	::zeroAll()
	//Verificar caso venha SSS010
	if Len(cTable) >= 6
		cTable := Substr(cTable,1,3)
	EndIf
	if !FWAliasInDic(cTable)
		::lOk := .F.
		::cMsgErro := "[ERRO] - Tabela " + cTable + " n�o existe no dicionario de dados"
	Else
		::cFromTab :=  cTable
		::cFromStr :=  RETSQLNAME(cTable)  + ' ' + cTable
	EndIf
return(self)

/*/{Protheus.doc} addOrder
@author bolognesi
@since 10/08/2016 
@version 1.0
@description Utilizado para adicionar uma ordem a query (Order By)
/*/
method addOrder(aOrdem, cTipo) class SqlUtil
	Local nX		:= 0
	Local nY		:= 0
	Local lTemOk	:= .F.
	Local cPref		:= ""
	Default cTipo 	:= ' ASC '
	Default aOrdem	:= {}
	::cCmpOrdem 	:= ""
	::lOk 			:= .T.

	If Empty(::cFromTab)
		::lOk := .F.
		::cMsgErro := "[ERRO] - Antes de definir a ordem selecione um tabela para from"
		ElseIf Empty(aOrdem)
		::lOk := .F.
		::cMsgErro := "[ERRO] - Informe os campos para ordenar pelo parametro"
	Else
		For nX := 1 To Len(aOrdem)
			lTemOk := .F.
			For nY := 1 To Len(::aCampos)
				if (aOrdem[nX] $ ::aCampos[nY]) .Or. (::aCampos[nY] $ '*') 
					lTemOk := .T.
				EndIf 
			next nY
			If !lTemOk
				::lOk := .F.
				::cMsgErro := "[ERRO] - Campo utilizado para ordenar n�o incluido addCampos"
				Break
			EndIf
		Next nX
		If ::lOk
			::cCmpOrdem 	:= ' ORDER BY '
			For nX := 1 To Len(aOrdem)
				cPref 	:= FWTabPref(aOrdem[nX])
				If Substr(aOrdem[nX],1,3) # ::cFromTab
					::cCmpOrdem += ' ' +   cPref + '.' + aOrdem[nX] + ' '
				Else
					::cCmpOrdem += ' ' +  aOrdem[nX] + ' ' 
				EndIf
				If nX < Len(aOrdem)
					::cCmpOrdem += ','
				Else
					::cCmpOrdem += ' ' + cTipo 
				EndIf
			Next nX
		Else
		EndIf
	EndIf

return(self)

/*/{Protheus.doc} closeWhere
@author bolognesi
@since 08/08/2016 
@version 1.0
@description Utilizado para finalizar Where adicionando a clausula de n�o deletado
os inners devem ter campo DELET igual ao delete da tabela principal do from
/*/
method closeWhere() class SqlUtil
	if !Empty(::cFromTab)
		::cWhere  += " AND   " + ::cFromTab  +  ".D_E_L_E_T_	<>	'*' "
	EndIf
return(self)


/*/{Protheus.doc} clearWhere
@author bolognesi
@since 08/08/2016 
@version 1.0
@description Utilizado para limpar o conteudo da propriedade cWhere
/*/
method clearWhere() class SqlUtil
	::cWhere := "  WHERE  "
return (self)


/*/{Protheus.doc} addWhere
@author bolognesi
@since 08/08/2016 
@version 1.0
@param lLimpa boolean Parametro utilizado para limpar conteudo anterior que possa existir na variavel
@description Adicionar conteudo ao where que ser� utilizado, o conceito inicial � de concatenar a conteudo existente
utiliza-se o parametro lLimpa para iniciar um where zerado, lembrando que qualquer metodo que utilize a propriedade cWhere
deve limpar o seu conteudo.
/*/
method addWhere(cQry,cLogico, lLimpa) class SqlUtil
	Default lLimpa 	:= .F.
	Default cLogico := " AND "

	if lLimpa
		::clearWhere()
	Else
		if !Empty(cQry)
			If	::cWhere == "  WHERE  "
				::cWhere += cQry
			Else
				::cWhere += ' ' +  cLogico + ' ' + cQry 
			EndIf
		EndIf
	EndIf

return(self)

/*/{Protheus.doc} QrySelect()
@author bolognesi
@since 08/08/2016 
@version 1.0
@description Permite realizar um select e retonar os dados do banco
/*/
method QrySelect() class SqlUtil
	Local cNomTab 	:= "SQL_"+StrTran(Time(),':','')
	Local cQuery	:= ""
	Local nX 		:= 0
	Local aDados	:= {}
	Local selAre	:= ""
	Local cQryJson	:= ""
	
	If Select( "QrySel") > 0
		QrySel->(dbcloseArea())
		FErase( "QrySel" + GetDbExtension())
	EndIf
	cQuery 	:= " SELECT  "
	//CAMPOS
	For nX := 1 To Len(::aCampos)
		cQuery += " " + ::aCampos[nX]
		If nX < Len(::aCampos)
			cQuery += ",  "
		EndIf
	Next nX
	//FROM
	cQuery 	+= " FROM " + ::cFromStr
	//WHERE
	::closeWhere()
	cQuery  += ::cWhere
	//ORDER BY
	if  ' ORDER BY ' $ ::cCmpOrdem 	 
		cQuery += ::cCmpOrdem
	EndIf
	cQuery := ChangeQuery(cQuery)
	::qryForSend := cQuery

	TCQUERY cQuery NEW ALIAS "QrySel"		

	DbSelectArea("QrySel")
	QrySel->(DbGotop())
	lRet := !QrySel->(Eof())

	if !lRet
		::lOk := .F.
		::cMsgErro := "[AVISO] - Consulta n�o retornou dados, utilize propriedade qryForSend, para visualizar a query enviado ao banco "
	Else
		::nRegCount := 0
		nT := Len(DbStruct())
		cQryJson += '{"QRY": [' 
		While !QrySel->(Eof())
			cQryJson +='{'
			For nI := 1 To nT
				cCmp := field(nI)
				cQryJson += '"' + cCmp + '" : ' + '"' +  ::trataTipo(&cCmp) + '"'	
				If nI != nT
					cQryJson += ','
				EndIf
			Next nI
			::nRegCount ++
			QrySel->(DbSkip())
			If !QrySel->(Eof())
				cQryJson += '},'
			Else
				cQryJson += '}'
			Endif
		EndDo
		cQryJson += ']}'
		::resToObj(cQryJson)
	EndIf
	If Select( "QrySel") > 0
		QrySel->(dbcloseArea())
		FErase( "QrySel" + GetDbExtension())
	End If	

	::zeroAll()
return(self)

/*/{Protheus.doc} resToObj()
@author bolognesi
@since 08/08/2016 
@version 1.0
@description O retorno do SQL, transformado em Objeto
/*/
method resToObj(cJsStr) class SqlUtil
	Local oRet := Nil
	Default cJsStr := ""
	If !Empty(cJsStr)
		FWJsonDeserialize(cJsStr, @oRet)
		::oRes := oRet:QRY
	EndIf
return(self)

/*/{Protheus.doc} trataTipo
@author bolognesi
@since 08/08/2016 
@version 1.0
@description Trata o tipos de dados retornados pelo SQL
/*/
method trataTipo(dado) class SqlUtil
	Local cRet := ""
	Local tipo := ""
	Default dado := ""

	tipo := ValType(dado)
	//TODO Obter tipos dos dados pelo X3???
	If tipo $ 'C'
		cRet := Alltrim(dado)
	Else 
	EndIf
return cRet
