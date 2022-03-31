#include "TOPCONN.CH"
#include "TBICONN.CH"
#include "TOTVS.CH"
#include "FWBROWSE.CH"
#include "FWMVCDEF.CH"
#include "XMLXFUN.CH"
#include "RESTFUL.CH"
#include "PROTHEUS.CH"

/**************************************************************************************************
{Protheus.doc} WSCLIENTE
@description	Endpoint criado para consultar informacoes do cliente
@type   		WSRESTFUL	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		13/02/2022
@database		13/02/2022
@country		Brasil
@language		PT-BR
@obs			13/02/2022 - Controle de documentacao
@param			cgc , String, CNPJ ou CPF do cliente
@return						
*****************************************************************************************************/
WSRESTFUL WSCLIENTE DESCRIPTION "Consumindo o servico REST"  

    WSDATA cgc As String OPTIONAL

    WSMETHOD GET DESCRIPTION "Servico para consumir dados do cliente" WSSYNTAX "WSCLIENTE/{}"

END WSRESTFUL

/**************************************************************************************************
{Protheus.doc} WSARMAZEM
@description	Metodo get recebe o json e realiza os tratamentos 
@type   		WSMETHOD	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		13/02/2022
@database		13/02/2022
@country		Brasil
@language		PT-BR
@obs			13/02/2022 - Controle de documentacao
@param			cgc , String, CNPJ ou CPF do cliente
@return			Json 	
*****************************************************************************************************/
WSMETHOD GET WSRECEIVE cgc  WSSERVICE WSCLIENTE

Local _cCgc       := ""
Local _cCod         := ""
Local _cErro        := ""
Local _cJson        := ""
Local cJSON         := Self:cgc
Private oJson       := JsonObject():New()
Private _cAlias     := GetNextAlias()

    Self:SetContentType("application/json")

    //-----------------------------------------------------------
    //Funcao de validacao
    //-----------------------------------------------------------
    If !(FValidGet(_cCgc, @_cErro, @_cCod, cJSON))
        ::SetResponse(_cErro)
        Return 
    EndIf 
    //-----------------------------------------------------------
    //Funcao para gerar a Query 
    //-----------------------------------------------------------
    If !(GetCliQry(_cCod, @_cErro))
        ::SetResponse(_cErro)
        Return 
    EndIf 
    //-----------------------------------------------------------
    //Funcao para gerar o Json
    //-----------------------------------------------------------
    GetCliJson(@_cJson)
    //-----------------------------------------------------------
    //Retorno do Json
    //-----------------------------------------------------------
    ::SetResponse(_cJson)

Return 

/**************************************************************************************************
{Protheus.doc} GetCliJson
@description	Funcao para gerar o Json
@type   		Funcao	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		11/02/2022
@database		11/02/2022
@country		Brasil
@language		PT-BR
@obs			11/02/2022 - Controle de documentacao
@param			_cJson, String, Mensagem de retorno json
@return						
*****************************************************************************************************/
Static Function GetCliJson(_cJson)

Local _nCont := 0

    _cJson := '{' + CRLF 
    _cJson += '"cliente" : "'+AllTrim((_cAlias)->A1_NOME)+'"    '+','+ CRLF
    _cJson += '"filCompra" : "'+AllTrim((_cAlias)->FILIAL)+'"   '+','+ CRLF

    DbSelectArea(_cAlias)
    (_cAlias)->(DbGoTop())
    While (_cAlias)->(!Eof())
        //-----------------------------------------------------------------------------
        //Conta os chassis cadastrados
        //-----------------------------------------------------------------------------
        _nCont ++ 

        _cJson += ' "chassi'+cValToChar(_nCont)+'" :{  '+ CRLF
        _cJson += ' "chassiVeic" : "'+AllTrim((_cAlias)->VV1_CHASSI)+'", ' + CRLF
        _cJson += ' "horimetro" : "" '
        _cJson += '},'+ CRLF

        (_cAlias)->(DbSkip())
    EndDo 

    //-----------------------------------------------------------------------------
    //Retira a ultima virgula da subchave do json
    //-----------------------------------------------------------------------------
    _cJson := SubStr(_cJson, 1, len(_cJson)-1) 
    _cJson += '}'

    (_cAlias)->(DbCloseArea())

Return 

/**************************************************************************************************
{Protheus.doc} FValidGet
@description	Metodo para validar as inforamacoes passado no get e do cliente
@type   		Function
@author			Lucas Rocha Vieira 
@version   		1.00
@since     		11/02/2022
@database		11/02/2022
@country		Brasil
@language		PT-BR
@obs			11/02/2022 - Controle de documentacao
@param			_cCgc   , String, CNPJ/CPF;
@param			_cErro  , String, Mensagem de erro 
@param			_cCod   , String, Codigo do cliente
@return			Logico
*****************************************************************************************************/
Static Function FValidGet(_cCgc, _cErro, _cCod, cJSON)

Local _cType := ""

    //--------------------------------------------------------------
    // Validacao do texto Json
    //--------------------------------------------------------------
    _cType := oJson:FromJson(cJSON)

    If ValType(_cType) == "C"
        _cErro  := '{ "mensagem": "Falha ao transformar texto em objeto json!"' +','+ CRLF
        _cErro  += ' "cerro" : '+  _cType	        	                            +'}'
        Return(.F.)
    EndIf

    //--------------------------------------------------------------
    // Validacao da propriedade passada
    //--------------------------------------------------------------
    _cCgc := cJSON

    If Empty(_cCgc)
        _cErro  := '{ "mensagem": "O json passado esta em branco" }'
        Return(.F.)
    EndIf 

    //--------------------------------------------------------------
    // Valida a existencia do cadastro do cliente 
    //--------------------------------------------------------------
    _cCod := Posicione( "SA1" , 3 , xFilial("SA1") + AllTrim(_cCgc) , "A1_COD" )

    If Empty(_cCod)
        _cErro  := '{ "mensagem": "Nenhum cliente com esse CPNJ/CPF"' +'}'
        Return(.F.)
    EndIf 

Return(.T.) 

/**************************************************************************************************
{Protheus.doc} GetCliQry
@description	Funcao para gerar a query 
@type   		Function	
@author			Lucas Rocha Vieira 
@version   		1.00
@since     		11/02/2022
@database		11/02/2022
@country		Brasil
@language		PT-BR
@obs			11/02/2022 - Controle de documentacao
@param			_cCod   , String, Codigo do cliente
@param			_cErro  , String, Mensagem de erro
@return			Logico	
*****************************************************************************************************/
Static Function GetCliQry(_cCod, _cErro)

Local _cQry   := ""

    _cQry := " SELECT                                                                        " + CRLF
    _cQry += "      (SELECT TOP 1  M0_FILIAL                                                 " + CRLF
    _cQry += "      FROM "+ RetSQLName("SE1") + " SE1                                        " + CRLF
    _cQry += "      INNER JOIN  SYS_COMPANY  SYS ON "+ RetSqlDel("SYS")                        + CRLF
    _cQry += "      WHERE                                                                    " + CRLF
    _cQry += "      E1_CLIENTE = '"+_cCod+"'                                                 " + CRLF
    _cQry += "      ORDER BY E1_EMISSAO DESC                                                 " + CRLF
    _cQry += "      )                                                                        " + CRLF
    _cQry += " AS [FILIAL] ,                                                                 " + CRLF
    _cQry += " A1_NOME,                                                                      " + CRLF
    _cQry += " VV1_CHASSI                                                                    " + CRLF
    _cQry += " FROM "+ RetSQLName("VV1") + " VV1                                             " + CRLF
    _cQry += " LEFT JOIN "+ RetSqlName("SA1") +" SA1 ON" + RetSqlDel("SA1")                    + CRLF
    _cQry += " AND A1_COD = VV1_PROATU                                                       " + CRLF  
    _cQry += " WHERE                                                                         " + CRLF  
    _cQry += " VV1_PROATU = '"+_cCod+"'                                                      " + CRLF  
    _cQry += " AND A1_LOJA = '0001'                                                          " + CRLF  
    _cQry += " AND VV1.D_E_L_E_T_ = ''                                                       " + CRLF  

    DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry), _cAlias , .T. , .F.)

    If Empty((_cAlias)->VV1_CHASSI)
        _cErro  := '{ "mensagem": "Esse cliente nao possui cadastro de veiculos" }'
        (_cAlias)->(DbCloseArea())
        Return(.F.)
    EndIf 

Return(.T.)
