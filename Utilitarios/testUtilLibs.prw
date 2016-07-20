#include 'protheus.ch'
#include 'parmtype.ch'

User Function MetaDados()
	Local oBase
	/******************  Exemplos da CLASSE Metadados **************************/
	//TODOS OS METODOS RETORNAM LOGICO SOBRE SUA EXECU��O
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

	//EXECUTAR A ATUALIZA��O E CONFERIR POSSIVEIS ERROS
	oBase:updTable()

	//AO INFORMAR O PARAMETRO COM O NUMERO DO RECNO, DISPENSA (setOrd() e addKey()) vai direto no registro
	oBase:updTable(nRec)
	//****************************************************************/
Return (Nil)

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
	PARA QUE ISSO N�O ACONTE�A UTILIZE 2 PARAMETRO COMO .F.*/

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