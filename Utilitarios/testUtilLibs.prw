#include 'protheus.ch'
#include 'parmtype.ch'

User Function MetaDados()
	Local oBase
	/******************  Exemplos da CLASSE Metadados **************************/
	//TODOS OS METODOS RETORNAM LOGICO SOBRE SUA EXECUÇÃO
	//PORTANTO DEVEM SER TESTATODS COM IF

	//****** PODE-SE INICIAR UMA TABELA
	//INICIAR A CLASSE
	oBase := ManBaseDados():newManBaseDados()
	//DEFINIR TABELA E ORDEM (TODA VEZ QUE ALTERA LIMPA OS CAMPOS)
	oBase:setOrd("SC6",1)

	//****** E NO DECORRER DO PROGRAMA ATUALIZA-LA QUANDO NECESSARIO
	//DEFINIR CHAVE DE BUSCA (TODA VEZ QUE ALTERA LIMPA OS CAMPOS)
	oBase:addKey({"024243" , "01" , "1540804401"})

	//DEFINIR OS CAMPOS E OS NOVOS VALORES
	oBase:addCpoVlr('C6_ZZNRRES','001234')
	oBase:addCpoVlr('C6_SEMANA','ROTAUTO')	

	//EXECUTAR A ATUALIZAÇÂO E CONFERIR POSSIVEIS ERROS
	oBase:updTable()

	//AO INFORMAR O PARAMETRO COM O NUMERO DO RECNO, DISPENSA (setOrd() e addKey()) vai direto no registro
	oBase:updTable(nRec)
	//****************************************************************/
Return (Nil)

/********************************************************************************************/
User Function SigaArea()
	Local oArea
	DbSelectArea('SC6')
	DbSelectArea('SC5')	
	DbSelectArea('SE2')
	DbSelectArea('SE1')

	/*EXEMPLOS DA CLASSE SigaArea*/
	/*************************/
	oArea := SigaArea():newSigaArea()
	/*SALVAR AS AREAS DE TRABALHOS DEFINIDAS NO ARRAY DE PARAMETRO*/
	oArea:saveArea( {'SC6', 'SC5', 'SE2'} )	

	/*EM CASO DE UMA NOVA CHAMADA ELE LIMPA O ARRAY DAS AREAS ANTERIORES
	PARA QUE ISSO NÂO ACONTEÇA UTILIZE 2 PARAMETRO COMO .F.*/

	//DESTA FORMA IRA APAGAR AS AREAS SC6 SC5 SE2, FICANDO APENAS COM SE1
	oArea:saveArea( {'SE1'} ) 

	//NESTE  ALEM DAS TRES AREAS (SC6, SC5, SE2) ACRESCENTA MAIS SE1
	oArea:saveArea( {'SC6', 'SC5', 'SE2'} )	
	oArea:saveArea( {'SE1'}, .F. ) 

	/*RESTAURA AS AREAS DE TRABALHO AO SEU ESTADO INICIAL*/
	oArea:backArea()
	/*RESTAURA UMA AREA ESPECIFICA PREVIAMENTE SALVA*/
	oArea:backArea({'SC5'})

Return(Nil)
/********************************************************************************************/

User Function SqlUtil()
Local oSql 	:= SqlUtil():newSqlUtil()
Local nX	:= 0
	
	/*EXEMPLO 01 Passando a query completa como parametro*/
	if oSql:QryToDb( "SELECT * FROM SZ3010" ):lOk
	MessageBox("Query enviada: " + oSql:qryForSend , "Aviso",48)
		MessageBox("Consulta Retornou: " + cValToChar(oSql:nRegCount) , "Aviso",48)
		For nX := 1 To oSql:nRegCount
			MessageBox(oSql:oRes[nX]:Z3_DESC , "Aviso",48)	
		Next nX
	Else
		MessageBox(oSql:cMsgErro)
	EndIf
	
	/*EXEMPLO 02*/
	 /*Definir a tabela*/
	 oSql:addFromTab('SZS')
	 /*Os campos da tabela*/
	 oSql:addCampos({'ZS_CODIGO','ZS_NOME'})
	 /*As condições podem ser escritas numa mesma string, bem como adicionadas uma a uma*/
	 oSql:addWhere("ZS_ATIVO = 'S'")
	 /*Por default o segundo paramtero é AND, não precisa informar caso seja OR informar*/
	 oSql:addWhere("ZS_CODIGO <> '' ",'AND')
	 /*Definir a ordem recebe array com a ordem desejada e o segundo parametro recebe o tipo da
	 ordem ASC ou DESC*/
	 oSql:addOrder({'ZS_CODIGO'},'DESC')
	 /*Executar o select*/
	 if oSql:QrySelect():lOk	
		/*Mostra a query que foi enviada*/
		MessageBox("Query enviada: " + oSql:qryForSend , "Aviso",48)
		/*Mostra quantos registros retornaram*/
		MessageBox("Consulta Retornou: " + cValToChar(oSql:nRegCount) , "Aviso",48)
		
		/*Percorrer os registro*/
		For nX := 1 To oSql:nRegCount
			/*O Retorno sempre gera um objeto "oSql:oRes" onde cada registro fica em uma posição
			e o conteudo é acessado pelo mesmo nome dos campos, abaixo estamos exibindo o campo nome
			de todos os retornos da busca*/
			MessageBox(oSql:oRes[nX]:ZS_NOME , "Aviso",48)	
		Next nX
	Else
		/*Caso exista algum erro exibir a mensagem de erro*/
		MessageBox(oSql:cMsgErro, "Aviso",48)
	EndIf
	
	/*EXEMPLO 03 Todos os metodos retornam o self desta forma podemos encadiar os metodos conforme exemplo
	abaixo, repare que as condições where estão definidas em uma unica chamada ao addWhere */
	if oSql:addFromTab('SZS'):addCampos({'ZS_CODIGO','ZS_NOME'}):addWhere("ZS_ATIVO = 'S' AND ZS_CODIGO <> ''"):QrySelect():lOk
		
		MessageBox("Query enviada: " + oSql:qryForSend , "Aviso",48)
		MessageBox("Consulta Retornou: " + cValToChar(oSql:nRegCount) , "Aviso",48)
		For nX := 1 To oSql:nRegCount
			MessageBox(oSql:oRes[nX]:ZS_NOME , "Aviso",48)	
		Next nX
	Else
		MessageBox(oSql:cMsgErro, "Aviso",48)
	EndIf
	
Return (Nil)