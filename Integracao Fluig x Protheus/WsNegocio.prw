#include "TOPCONN.CH"
#include "TBICONN.CH"
#include "TOTVS.CH"
#include "FWBROWSE.CH"
#include "FWMVCDEF.CH"
#include "XMLXFUN.CH"
#include "RESTFUL.CH"
#include "PROTHEUS.CH"

/**************************************************************************************************
{Protheus.doc} WSNEGOCIO
@description	Endpoint criado com a integracao do fluig com o protheus rotina Oportunidade de negocio
@type   		WSRESTFUL	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		29/03/2022
@database		29/03/2022
@country		Brasil
@language		PT-BR
@obs			29/03/2022 - Controle de documentacao
@param			
@return						
*****************************************************************************************************/
WSRESTFUL WSNEGOCIO DESCRIPTION "Consumindo o servico REST/ para a rotina Oportunidade de negócio - VEICM680"  

    // Capa
    WSDATA cFilialCp    As String // Filial Capa VDL
    WSDATA cCodigoCp    As String // Codigo Capa VDL
    WSDATA cCodCli      As String // Codigo Cliente
    WSDATA cLojaCli     As String // Loja Cliente
    WSDATA cNomeCli     As String // Nome Cliente
    WSDATA cDddCli      As String // DDD Cliente
    WSDATA cTelCli      As String // Telefone Cliente
    WSDATA cEmailCli    As String // Email Cliente
    WSDATA cNivelEmp    AS String // Nivel Empresa
    WSDATA cTemperat    AS String // Temperatura 
    WSDATA cOpc         AS String // Tipo de movimentacao 1=incluir 2=alterar
    // Itens 
    WSDATA cFilGd       AS String // Filial Grid VDM
    WSDATA cCodGd       AS String // Codigo Grid VDM
    WSDATA cCodMarc     AS String // Codigo marcar 
    WSDATA cModVei      AS String // Modelo veiculo
    WSDATA cQnt         AS String // Quantidade
    WSDATA cOperFab     AS String // Operacionais
    WSDATA cDateInt     AS String // Data interesse
    WSDATA cDateLimt    AS String // Data Limite 
    WSDATA cCodVend     AS String // Codigo Vendedor
    WSDATA cTipoCon     AS String // Tipo 

    WSMETHOD POST DESCRIPTION "Servico para movimentar a rotina de Oportunidades/Interesses - VEICM680" WSSYNTAX "WSNEGOCIO/{}"

END WSRESTFUL

/**************************************************************************************************
{Protheus.doc} WSNEGOCIO
@description	Metodo Post
@type   		WSMETHOD	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		29/03/2022
@database		29/03/2022
@country		Brasil
@language		PT-BR
@obs			29/03/2022 - Controle de documentacao
@param			
@return			Logico 			
*****************************************************************************************************/
WSMETHOD POST WSRECEIVE cFilialCp, cCodigoCp, cCodCli, cLojaCli, cNomeCli, cDddCli , cTelCli , cEmailCli,;
                        cNivelEmp, cTemperat, cOpc, cFilGd, cCodGd, cCodMarc, cModVei, cQnt, cOperFab   ,;
                        cDateInt, cDateLimt, cCodVend, cTipoCon WSSERVICE WSNEGOCIO

Local cFilialCp     := ""
Local cCodigoCp     := ""
Local cCodCli       := ""
Local cLojaCli      := ""
Local cNomeCli      := ""
Local cDddCli       := ""
Local cTelCli       := ""
Local cEmailCli     := ""
Local cNivelEmp     := ""
Local cTemperat     := ""
Local cOpc          := ""
Local cFilGd        := ""
Local cCodGd        := ""
Local cCodMarc      := ""
Local cModVei       := ""
Local cQnt          := ""
Local cOperFab      := ""
Local cDateInt      := ""
Local cDateLimt     := ""
Local cCodVend      := ""
Local cTipoCon      := ""
Local aItensNeg     := {}
Local _cErro        := ""
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
    U_DeserializeJS(oJson, @cFilialCp, @cCodigoCp, @cCodCli, @cLojaCli, @cNomeCli, @cDddCli , @cTelCli, @cEmailCli,;
                    @cNivelEmp, @cTemperat, @cOpc, @cFilGd, @cCodGd, @cCodMarc, @cModVei, @cQnt, @cOperFab, @cDateInt,;
                    @cDateLimt, @cCodVend, @cTipoCon, @aItensNeg )

    //-------------------------------------------------------------------
    // Chamando o metodo para a validacao
    //-------------------------------------------------------------------
    If !(U_RecordM680(cFilialCp, cCodigoCp, cCodCli, cLojaCli, cNomeCli, cDddCli , cTelCli, cEmailCli,;
                    cNivelEmp, cTemperat, cOpc, cFilGd, cCodGd, cCodMarc, cModVei, cQnt, cOperFab, cDateInt,;
                    cDateLimt, cCodVend, cTipoCon, aItensNeg))
        Return(.F.)
    EndIf

Return(.T.)

/**************************************************************************************************
{Protheus.doc} DeserializeJS
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
User function DeserializeJS(jsonObj, cFilialCp, cCodigoCp, cCodCli, cLojaCli, cNomeCli, cDddCli , cTelCli , cEmailCli,;
                            cNivelEmp, cTemperat, cOpc, cFilGd, cCodGd, cCodMarc, cModVei, cQnt, cOperFab ,cDateInt,;
                            cDateLimt, cCodVend, cTipoCon, aItensNeg )
Local i, j
Local names
Local lenJson
Local item
Local _nJson
Local aJson := {}

    lenJson := len(jsonObj)
 
    If lenJson > 0

        For i := 1 to lenJson
            U_DeserializeJS(jsonObj[i])
        Next

    Else

        names := jsonObj:Getnames()

        For i := 1 to len(names)
            item := jsonObj[names[i]]

            If ValType(item) == "C"

                Aadd(aJson,{names[i], cvaltochar(jsonObj[names[i]])})
                cFilialCp   := IIF(AllTrim(names[i]) == "cFilialCp"  , AllTrim(jsonObj[names[i]]),  cFilialCp   )
                cCodigoCp   := IIF(AllTrim(names[i]) == "cCodigoCp"  , AllTrim(jsonObj[names[i]]),  cCodigoCp   )
                cCodCli     := IIF(AllTrim(names[i]) == "cCodCli"    , AllTrim(jsonObj[names[i]]),  cCodCli     )
                cLojaCli    := IIF(AllTrim(names[i]) == "cLojaCli"   , AllTrim(jsonObj[names[i]]),  cLojaCli    )
                cNomeCli    := IIF(AllTrim(names[i]) == "cNomeCli"   , AllTrim(jsonObj[names[i]]),  cNomeCli    )
                cDddCli     := IIF(AllTrim(names[i]) == "cDddCli"    , AllTrim(jsonObj[names[i]]),  cDddCli     )
                cTelCli     := IIF(AllTrim(names[i]) == "cTelCli"    , AllTrim(jsonObj[names[i]]),  cTelCli     )
                cEmailCli   := IIF(AllTrim(names[i]) == "cEmailCli"  , AllTrim(jsonObj[names[i]]),  cEmailCli   )
                cNivelEmp   := IIF(AllTrim(names[i]) == "cNivelEmp"  , AllTrim(jsonObj[names[i]]),  cNivelEmp   )            
                cTemperat   := IIF(AllTrim(names[i]) == "cTemperat"  , AllTrim(jsonObj[names[i]]),  cTemperat   )   
                cOpc        := IIF(AllTrim(names[i]) == "cOpc"       , AllTrim(jsonObj[names[i]]),  cOpc        )   
            
            ElseIf  ValType(item) == "J"
                _nJson++
                ret := oJson:GetJsonObject(names[i])
                QbraJson(ret, @aItensNeg, _nJson)

            Else

                If ValType(item) == "A"

                    For j := 1 to len(item)
                        U_DeserializeJS(item[j])
                    Next j

                Endif

            Endif

        Next i

    Endif

Return(.T.)

Static Function QbraJson(jsonObj, aItensNeg, _nJson)

Local i, j
Local names
Local lenJson
Local item
 
    lenJson := len(jsonObj)
    
    If lenJson > 0

        For i := 1 to lenJson
        QbraJson(jsonObj[i])
        Next

    Else

        names := jsonObj:GetNames()

        For i := 1 to len(names)

            item := jsonObj[names[i]]

            If ValType(item) == "C" .or.  ValType(item) == "N"

                Aadd(aItensNeg,{names[i], cvaltochar(jsonObj[names[i]]), _nJson})

            Else

                If ValType(item) == "A"

                    For j := 1 to len(item)

                        conout("Indice " + cValtochar(j))

                        If ValType(item[j]) == "J"
                            QbraJson(item[j])
                        Else
                         conout(cvaltochar(item[j]))
                        Endif

                    Next j

                Endif

            Endif

        Next i

    Endif

Return 
