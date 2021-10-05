#INCLUDE 'TOTVS.CH'

/**************************************************************************************************
{Protheus.doc} MedMaisArmazem
@description	Classe para gravar dados enviado do fluig na tabela de armazem(SCP)
@type   		Class	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		22/09/2021
@database		22/09/2021
@country		Brasil
@language		PT-BR
@obs			22/09/2021 - Controle de documentacao
@param			
@return						
*****************************************************************************************************/
Class MedMaisArmazem 

    Method New() CONSTRUCTOR

    Method Storage()    
    Method Validation() 

EndClass 

/**************************************************************************************************
{Protheus.doc} MedMaisArmazem
@description	Construtor da classe
@type   		Method	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		22/09/2021
@database		22/09/2021
@country		Brasil
@language		PT-BR
@obs			22/09/2021 - Controle de documentacao
@param			
@return						
*****************************************************************************************************/
Method New() class MedMaisArmazem
Return()

/**************************************************************************************************
{Protheus.doc} MedMaisArmazem
@description	Gravar dados na tabela SCP
@type   		Method	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		22/09/2021
@database		22/09/2021
@country		Brasil
@language		PT-BR
@obs			22/09/2021 - Controle de documentacao
@param			
@return						
*****************************************************************************************************/
Method Storage(cEmp, cFil, cIdProd, cQnt, cObs, cOk, cErro, cAlias, cArmazem, cSolicit) Class MedMaisArmazem 

Local lRet          := .T.
Local nSaveSx8      := 0
Local nOpcx         := 0
Local cNumero       := ''
Local aCab          := {}
Local aItens        := {}
//CRIEI TESTE
Local cCodSist      := (cAlias)->ZZA_CODIGO

Private lMsErroAuto := .F.
Private lMsErroHelp := .T.

    RpcClearEnv()
    RpcSetType( 3 )
    // Abrindo a empresa 
    lRet := RpcSetEnv( cEmp, cFil )


    If ( !lRet ) 
        ConOut( 'Problemas na Inicialização do Ambiente' )
    Else
        
        nOpcx       := 3
        nSaveSx8    := GetSx8Len()
        cNumero     := GetSx8Num( 'SCP', 'CP_NUM' )
    
        DbSelectArea( 'SCP' )
        SCP->( DbSetOrder( 1 ) ) // CP_FILIAL + CP_NUM + CP_ITEM + DTOS(CP_EMISSAO)

        dbSelectArea( 'SB1' )
        SB1->( dbSetOrder( 1 ) )

        If nOpcx == 3
            While SCP->( DbSeek( xFilial( 'SCP' ) + cNumero ) )
                   ConfirmSx8()
                   cNumero := GetSx8Num('SCP', 'CP_NUM')
            EndDo
        EndIf

        //-------------------------------------------------------------------
        // Alimenta os campos da tabela com os valores das variaveis
        //-------------------------------------------------------------------        
        Aadd( aCab, { "CP_NUM"      , cNumero                                 ,  Nil }) // Num. armazem
        Aadd( aCab, { "CP_EMISSAO"  , dDataBase                               ,  Nil }) // Data de criacao
        Aadd( aCab, { "CP_SOLICIT"  ,  UsrRetName(cCodSist)                   ,  Nil }) // Nome Solicitante
                                                                                                        
        Aadd( aItens, {} )
        Aadd( aItens[ Len( aItens ) ],{ "CP_ITEM"    ,  '01'                   , Nil } ) // Num Item
        Aadd( aItens[ Len( aItens ) ],{ "CP_PRODUTO" ,  cIdProd                , Nil } ) // Num Produto
        Aadd( aItens[ Len( aItens ) ],{ "CP_QUANT"   ,  4                      , Nil } ) // Num Quantidade
        Aadd( aItens[ Len( aItens ) ],{"CP_OBS"      ,  cObs                   , Nil } ) // Observacao
        Aadd( aItens[ Len( aItens ) ],{"CP_USER"     ,  cCodSist               , Nil } ) // Cod usuario
        Aadd( aItens[ Len( aItens ) ],{"CP_LOCAL"    ,  cArmazem               , Nil } ) // Cod usuario
        Aadd( aItens[ Len( aItens ) ],{"CP_ZSOLIC"   ,  cSolicit               , Nil } ) // Cod usuario


        MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aCab, aItens , nOpcx )
    
        If lMsErroAuto
            If !__lSX8
                RollBackSx8()
            EndIf
    
            cErro := '{ "mensagem": "Erro ao executaro o processo!"'           +','+ CRLF
            cErro := '	"cidproduto" :  '+ AllTRim(cIdProd)                    +','+ CRLF
	        cErro += ' "cquantidade" :  '+      cQnt     	                   +','+ CRLF
            cErro += ' "cobs" :         '+ AllTRim(cObs)		               +','+ CRLF
	        cErro += ' "cuser" :        '+ UsrRetName(cCodSist)		           +','+ CRLF
	        cErro += ' "cfilial" :      '+ AllTRim(cFil)		               +'}' // Tratar empresa

           lRet := .F.
           Return(.T.)
    
        Else

           While ( GetSx8Len() > nSaveSx8 )
               ConfirmSx8()
           End

            cOk := '{ "mensagem": "Processo executado com sucesso!"}'
        EndIf
    
    EndIf

Return(.T.)  


/**************************************************************************************************
{Protheus.doc} MedMaisArmazem
@description	Validacao dos dados enviados via json
@type   		Method	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		22/09/2021
@database		22/09/2021
@country		Brasil
@language		PT-BR
@obs			22/09/2021 - Controle de documentacao
@param			
@return						
*****************************************************************************************************/
Method Validation(cUsr, cCcusto, cFil, cProd, cErro, cAlias) Class MedMaisArmazem 

Local _cQry     := ""

    _cQry := " SELECT                                       "
    _cQry += " ZZA_NOME,                                    "
	_cQry += " ZZA_CUSTO,                                   "
    _cQry += " ZZA_CODIGO,                                  "
    _cQry += " ZZA_NMUSR                                    "
    _cQry += " FROM "+ RetSqlName("ZZA") +" ZZA             "
    _cQry += " WHERE                                        " 
    _cQry += " ZZA_FILIAL = '"+ AllTrim(cFil) +"'           " // TRATAR A FILIAL 
    _cQry += " AND   ZZA_NOME LIKE  '%"+AllTrim(cUsr)+"%'   " // TRATAR O NOME 
    _cQry += " AND   ZZA_CUSTO =  '"+AllTrim(cCcusto)+"'    " 
    _cQry += " AND   ZZA_STATUS = '1'                       "
    _cQry += " AND ZZA.D_E_L_E_T_ = ''                      "

    DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry), cAlias , .T. , .F.)


    If Empty((cAlias)->ZZA_CODIGO)
        cErro := '{ "mensagem": "O cadastro nao foi localizado na ZZA"'	    +','+ CRLF
        cErro += '	"cidproduto" :  '+ cCcusto                              +','+ CRLF
	    cErro += ' "cuser" :        '+  cUsr		                        +'}'
        ConOut(PadC("Erro ao encontrar o usuario na tablea ZZA", 80))
        ConOut("Error: "+ cErro) 

        Return(.T.)
    EndIf 

    //-------------------------------------------------------------------
    // TABELA: SB1
    // INDICE(1)-> B1_FILIAL + B1_COD
    //-------------------------------------------------------------------
    DbSelectArea( 'SB1' )
    SB1->(DbSetOrder(1))

    If !( SB1->(DBSeek( xFilial('SB1') + AllTrim(cProd))) )

        cErro := '{ "mensagem": "Codigo do produto nao localizado"'	    +','+ CRLF
	    cErro += ' "cidProduto" : '+ cProd          		            +'}'
        ConOut(PadC("Erro ao encontrar o produto", 80))
        ConOut("Error: "+ cErro)  
        Return(.T.)
    EndIf

    SB1->( DbCloseArea())

Return(.T.)
