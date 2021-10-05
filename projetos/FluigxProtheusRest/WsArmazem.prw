#include "TOPCONN.CH"
#include "TBICONN.CH"
#include "TOTVS.CH"
#include "FWBROWSE.CH"
#include "FWMVCDEF.CH"
#include "XMLXFUN.CH"
#include "RESTFUL.CH"
#include "PROTHEUS.CH"

/**************************************************************************************************
{Protheus.doc} WSARMAZEM
@description	Endpoint criado para consumir o servico Json e tratar os dados 
@type   		WSRESTFUL	
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
WSRESTFUL WSARMAZEM DESCRIPTION "Consumindo o servico REST/ Servico ao armazem"  

    WSDATA cidProduto   As String  
    WSDATA cquantidade  As String 
    WSDATA cobs         As String 
    WSDATA cuser        As String 
    WSDATA ccusto       As String 
    WSDATA cempresa     As String 
    WSDATA cfilial      As String 
    WSDATA carmazem     As String 
    WSDATA csolicitacao AS String

    WSMETHOD POST DESCRIPTION "Servico para consumir dados do fluig e armazena-los ao armazem" WSSYNTAX "WSARMAZEM/{}"


END WSRESTFUL

/**************************************************************************************************
{Protheus.doc} WSARMAZEM
@description	Metodo get recebe o json e realiza os tratamentos 
@type   		WSMETHOD	
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
WSMETHOD POST WSRECEIVE cidProduto, cquantidade, cobs, cuser, ccusto, cempresa, cfilial, carmazem, csolicitacao  WSSERVICE WSARMAZEM

Local _cIdProd      := ""
Local _cQuanProd    := ""
Local _cObs         := ""
Local _cUser        := ""
Local _cCusto       := ""
Local _cEmp         := ""
Local _cArmazem     := ""
Local _cSolicit     := ""
Local _cErro        := ""
Local _cOk          := ""
Local _cFil         := ""
Local oGvrScp       := MedMaisArmazem():New()
Local _cAlias       := GetNextAlias()
Local cJSON         := Self:GetContent()
Private oJson       := JsonObject():New()


    Self:SetContentType("application/json")

    ret := oJson:FromJson(cJSON)
    
    If ValType(ret) == "C"
        _cErro  := '{ "mensagem": "Falha ao transformar texto em objeto json!"' +','+ CRLF
        _cErro  += ' "cerro" : '+  ret	        	                            +'}'
        conout("Falha ao transformar texto em objeto json. Erro: " + ret)
        oGvrScp:Mistake(_cErro)
        return
    EndIf

    //-------------------------------------------------------------------
    // Funcao para desserializar o json 
    //-------------------------------------------------------------------
    U_BreakingJson(oJson, @_cIdProd, @_cQuanProd, @_cObs, @_cUser, @_cCusto, @_cEmp, @_cArmazem, @_cFil, @_cSolicit)

    //-------------------------------------------------------------------
    // Chamando o metodo para a validacao
    //-------------------------------------------------------------------
    oGvrScp:Validation(_cUser, _cCusto, _cFil, _cIdProd, @_cErro, @_cAlias)

    If !Empty(_cErro)
        Return(.F.)
    Else 
        //-------------------------------------------------------------------
        // Chamando o metodo para gravar na tabela
        //-------------------------------------------------------------------
        oGvrScp:Storage(_cEmp, _cFil, _cIdProd, _cQuanProd, _cObs, @_cOk, @_cErro, @_cAlias, _cArmazem, _cSolicit) // Tratar empresa é filial

        If !Empty(_cErro)
            Return(.F.)
        Else 
            Return(.T.)
        EndIf 

    EndIf 

Return(.T.)

/**************************************************************************************************
{Protheus.doc} BreakingJson
@description	Funcao para desserializar o json  
@type   		Funcao	
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
User function BreakingJson(jsonObj, _cIdProd, _cQuanProd, _cObs, _cUser, _cCusto, _cEmp, _cArmazem, _cFil, _cSolicit)
Local i, j
Local names
Local lenJson
Local item
Local aJson := {}

    lenJson := len(jsonObj)
 
    If lenJson > 0

        For i := 1 to lenJson
            U_BreakingJson(jsonObj[i])
        Next

    Else

        names := jsonObj:Getnames()

        For i := 1 to len(names)
            item := jsonObj[names[i]]

            If ValType(item) == "C"
                Aadd(aJson,{names[i], cvaltochar(jsonObj[names[i]])})
                _cIdProd      := IIF(AllTrim(Lower(names[i])) == "cidproduto"       , AllTrim(jsonObj[names[i]]), _cIdProd    )
                _cQuanProd    := IIF(AllTrim(Lower(names[i])) == "cquantidade"      , AllTrim(jsonObj[names[i]]), _cQuanProd  )
                _cObs         := IIF(AllTrim(Lower(names[i])) == "cobs"             , AllTrim(jsonObj[names[i]]), _cObs       )
                _cUser        := IIF(AllTrim(Lower(names[i])) == "cuser"            , AllTrim(jsonObj[names[i]]), _cUser      )
                _cCusto       := IIF(AllTrim(Lower(names[i])) == "ccusto"           , AllTrim(jsonObj[names[i]]), _cCusto     )
                _cEmp         := IIF(AllTrim(Lower(names[i])) == "cempresa"         , AllTrim(jsonObj[names[i]]), _cEmp       )
                _cFil         := IIF(AllTrim(Lower(names[i])) == "cfilial"          , AllTrim(jsonObj[names[i]]), _cFil       )
                _cArmazem     := IIF(AllTrim(Lower(names[i])) == "carmazem"         , AllTrim(jsonObj[names[i]]), _cArmazem   )
                _cSolicit     := IIF(AllTrim(Lower(names[i])) == "csolicitacao"     , AllTrim(jsonObj[names[i]]), _cSolicit   )            

            Else

                If ValType(item) == "A"

                    For j := 1 to len(item)
                        U_BreakingJson(item[j])
                    Next j

                Endif

            Endif

        Next i

    Endif

Return(.T.)
