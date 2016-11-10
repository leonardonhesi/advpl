#include 'protheus.ch'

#define NOME_CAMPO				1
#define VALOR_CAMPO				2

class cbcSendEmail 

	data lOk
	data cMsg

	data lErrMail
	data cErrMail

	data oServer
	data oMessage

	data EMCONTA
	data RELSERV
	data EMSENHA
	data NPORTA

	method newcbcSendEmail() constructor 
	method goToEmail()
	method vldParam()
	method addAtach()
	method iniSrvMsg()

	method getFrom()
	method setFrom()
	method getTo()
	method setTo()
	method getcCc()
	method setcCc()
	method getcBcc()
	method setcBcc()
	method getcSubject()
	method setcSubject()
	method getcBody()
	method setcBody()
	method setPriority()
	method setConfReader()
	method setHtmlBody()

	method getErrTxt()
	method isErr()

endclass

//TODO metodo para enviar body html em estilo de lista (TD/TR) (Header/Cols)

method newcbcSendEmail(cMailConta,cMailServer,cMailSenha, nPorta) class cbcSendEmail
	Default cMailConta	:= Nil
	Default cMailServer := Nil
	Default cMailSenha  := Nil
	Default nPorta		:= 587
	::EMCONTA	:=If(cMailConta 				== NIL,GETMV("MV_EMCONTA"),cMailConta)
	::RELSERV	:=Lower(StrTran(If(cMailServer 	== NIL,GETMV("MV_RELSERV"),cMailServer),':587',''))
	::EMSENHA	:=If(cMailSenha 				== NIL,GETMV("MV_EMSENHA"),cMailSenha)
	::NPORTA	:= nPorta		
	::iniSrvMsg()

return (self)

method iniSrvMsg(lReboot) class cbcSendEmail
	Default lReboot :=  .F.	
	If lReboot
		::oMessage:Clear()
		::oServer:SmtpDisconnect()
		FreeObj(::oServer)
		FreeObj(::oMessage)
	EndIf
	If ::vldParam():lOk
		If defServer(Self):lOk
			defMessage(Self)
		EndIf
	EndIf
return (self)

method isErr(nErr) class cbcSendEmail
	Default nErr := -1
	::lErrMail  := .F. 
	::cErrMail	:= "" 

	If nErr < 0
		::lErrMail  := .T. 
		::cErrMail	:= "[ERRO] - Parametro (nErr) com o numero do erro obrigatorio, cbcSendEmail():isErr(nErr)" 
	ElseIf nErr != 0
		::lErrMail  := .T. 
		::cErrMail	:= "[ERRO] - " + ::getErrTxt(nErr) 
	EndIf

	If ::lErrMail
		showConsoleMsg(::cErrMail, Self)
	EndIf

return (self)

method getErrTxt(nErr) class cbcSendEmail	
return (::oServer:GetErrorString(nErr))

method goToEmail() class cbcSendEmail
	::lOk	:= .T.
	::cMsg	:= ""
	If   ::isErr(::oMessage:Send(::oServer)):lErrMail
		::lOk	:= .F.
		::cMsg	:= ::cErrMail
		::oMessage:Clear()
		::oServer:SmtpDisconnect()
	Else
		showConsoleMsg('Enviado com sucesso', Self)
		::iniSrvMsg(.T.)
	EndIf
return (self)

method vldParam() class cbcSendEmail
	::lOk	:= .T.
	::cMsg	:= ""
	If Empty(::EMCONTA)
		::lOk	:= .F.
		::cMsg	:= '[ERRO]- Email do remetente não informado, verifique parametro MV_EMCONTA!'
	Endif
	If 	Empty(::RELSERV)
		::lOk	:= .F.
		::cMsg	:= '[ERRO]- Servidor SMTP não configurado, verifique parametro MV_RELSERV!'
	EndIf
	If 	Empty(::EMSENHA)
		::lOk	:= .F.
		::cMsg	:= '[ERRO]- Senha para conta de e-mail inválida, verifique parametro MV_EMSENHA!'
	EndIf
return (self)

method addAtach(cPath, cArquivo) class cbcSendEmail
	::lOk	:= .T.
	::cMsg	:= ""

	If ::oMessage:AttachFile( cPath + cArquivo ) < 0
		::lOk	:= .F.
		::cMsg	:= "[ERRO] - Arquivo não pode ser anexado "
		::oMessage:Clear()
		::oServer:SmtpDisconnect()
		showConsoleMsg(::cMsg, Self)
	Else
		::oMessage:AddAtthTag( 'Content-Disposition: attachment; filename=' + cArquivo )
	EndIf

return (self)

/*Getters e Setters*/

method setHtmlBody(cFile, aCmps, aLoop) class cbcSendEmail
	Local oHtml		:= Nil
	Local nH		:= 0
	Local nL		:= 0
	Local nI		:= 0
	Local cCampo	:= ""
	Local xValor	:= Nil
	Local bErro 
	Default cFile	:= '\espelhoPedido\html\Espelho_pedido.htm'
	Default aCmps	:= {}
	Default aLoop	:= {}
	::lOk	:= .T.
	::cMsg	:= ""
	
	If Empty(aCmps) .And. Empty(aLoop) 
		::lOk	:= .F.
		::cMsg	:= "[ERRO] - Parametros (aCmps ou aLoop) um dos dois precisa existir cbcSendEmail():setHtmlBody(), "
	Else
		bErro	:= ErrorBlock({|oErr| HandleEr(oErr)})
		BEGIN SEQUENCE		
			oHtml :=  TWFHtml():new(cFile)
					
			//HEADER
			If !Empty(aCmps)
				For nH := 1 to Len(aCmps)	
						oHtml:Valbyname(aCmps[nH][NOME_CAMPO],aCmps[nH][VALOR_CAMPO])
				Next
			EndIF
			//LINHAS
			If !Empty(aLoop)
				For nL := 1 to Len(aLoop)	
					For nI :=  1 To Len(aLoop[nL])
						_cCampo := aLoop[nL][nI][NOME_CAMPO]
						_xValor := aLoop[nL][nI][VALOR_CAMPO]
						If oHtml:Retbyname(_cCampo) != Nil
							aadd(oHtml:Valbyname(_cCampo) , _xValor )
						EndIf 							
					Next 
				Next
			EndIF
			::oMessage:cBody := oHtml:HtmlCode()
			FreeObj(oHtml)
			RECOVER
		END SEQUENCE
		ErrorBlock(bErro)   
	EndIF
return (self)

method setConfReader(lConf) class cbcSendEmail
	Default lConf := .F.
	::oMessage:SetConfirmRead(lConf)
return (self)

method setPriority(nPri) class cbcSendEmail
	Default nPri := 0
	If nPri < 1 .Or.  nPri > 5
		::oMessage:nXPriority := 3
	Else
		::oMessage:nXPriority := nPri
	EndIF 
return (self)

method getFrom() class cbcSendEmail
return (::oMessage:cFrom)
method setFrom(cFrm) class cbcSendEmail
	::oMessage:cFrom := cFrm
return (self)

method getTo() class cbcSendEmail
return (::oMessage:cTo)
method setTo(cParTo) class cbcSendEmail
	::oMessage:cTo := cParTo
return (self)

method getcCc() class cbcSendEmail
return (::oMessage:cCc)
method setcCc(cParCc) class cbcSendEmail
	::oMessage:cCc := cParCc
return (self)

method getcBcc() class cbcSendEmail
return (::oMessage:cBcc)
method setcBcc(cParBcc) class cbcSendEmail
	::oMessage:cBcc := cParBcc
return (self)

method getcSubject() class cbcSendEmail
return (::oMessage:cSubject)
method setcSubject(cParSub) class cbcSendEmail
	::oMessage:cSubject := cParSub
return (self)

method getcBody() class cbcSendEmail
return (::oMessage:cBody)	
method setcBody(cParBody) class cbcSendEmail
	::oMessage:cBody := cParBody
return (self)


/* FUNÇÕES ESTATICAS */

static Function defMessage(oSelf)
	oSelf:oMessage := TMailMessage():New()
	oSelf:oMessage:Clear()
	oSelf:oMessage:cFrom  		:= 'relatorios@cobrecom.com.br'
	oSelf:oMessage:cTo			:= ""
	oSelf:oMessage:cCc    		:= ""
	oSelf:oMessage:cBcc			:= ""
	oSelf:oMessage:cSubject 	:= "[IFC-COBRECOM] - Envio de Email
	oSelf:oMessage:cBody        := "Segue o e-mail"       
return (oSelf)

static Function defServer(oSelf) 

	oSelf:lOk	:= .T.
	oSelf:cMsg	:= ""

	oSelf:oServer 	:= TMailManager():New()
	oSelf:oServer:Init( "", oSelf:RELSERV, "", "", 0, oSelf:NPORTA )

	//Definir o timeout
	If  oSelf:isErr(oSelf:oServer:SetSmtpTimeOut(60)):lErrMail   
		oSelf:lOk	:= .F.
		oSelf:cMsg	:= '[ERRO]- ' + oSelf:cErrMail
	EndIf

	//Conectar com o servidor
	If  oSelf:isErr(oSelf:oServer:SmtpConnect()):lErrMail
		oSelf:lOk	:= .F.
		oSelf:cMsg	:= '[ERRO]-' + oSelf:cErrMail
	EndIf

	//Autenticar no servidor
	If   oSelf:isErr(oSelf:oServer:SmtpAuth(oSelf:EMCONTA,oSelf:EMSENHA)):lErrMail
		oSelf:lOk	:= .F.
		oSelf:cMsg	:= '[ERRO]-' + oSelf:cErrMail
		oSelf:oServer:SmtpDisconnect()
	EndIF

return (oSelf)

static function showConsoleMsg(cMsg, oSelf)
	ConOut("[Classe SendEmail - "+ DtoC(Date())+" - "+Time()+" ]  - " +;	
	" Assunto: " 		+ IIF(oSelf:oMessage == Nil,"",oSelf:getcSubject())+;
	" Enviado para:" 	+ IIF(oSelf:oMessage == Nil,"",oSelf:getTo())+;   
	" Ocorrência: "    + cMsg )
return


Static function HandleEr(oErr)
	ConsoleLog('[' + oErr:Description + ']' + oErr:ERRORSTACK)
	u_autoAlert('[' + oErr:Description + ']' + oErr:ERRORSTACK,,'Box',,48)
	BREAK
return

static function ConsoleLog(cMsg)
	ConOut("[Classe SendEmail - Html Body - "+DtoC(Date())+" - "+Time()+" ] "+ cMsg) 
return