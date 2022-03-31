#INCLUDE "TOTVS.CH"

/**************************************************************************************************
{Protheus.doc} RecordM680
@description	Rotina Oportunidades de negocio - RecordM680
@type   		User Function	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		29/03/2022
@database		29/03/2022
@country		Brasil
@language		PT-BR
@obs			29/03/2022 - Controle de documentacao
@param			cFilialCp, cCodigoCp, cCodCli, cLojaCli, cNomeCli, cDddCli , cTelCli, cEmailCli,;
                cNivelEmp, cTemperat, cOpc, cFilGd, cCodGd, cCodMarc, cModVei, cQnt, cOperFab, cDateInt,;
                cDateLimt, cCodVend, cTipoCon, aItensNeg
@return			Logico			
*****************************************************************************************************/
User Function RecordM680(cFilialCp, cCodigoCp, cCodCli, cLojaCli, cNomeCli, cDddCli , cTelCli, cEmailCli,;
                        cNivelEmp, cTemperat, cOpc, cFilGd, cCodGd, cCodMarc, cModVei, cQnt, cOperFab, cDateInt,;
                        cDateLimt, cCodVend, cTipoCon, aItensNeg)

Private lTypeRecd := .T. // Alteracao ou Inclusao 

    //----------------------------------------------------------
    //Funcao para abrir as tabelas
    //----------------------------------------------------------
    OpenTable()

    If AllTrim(cOpc) != '1' // Inclusão
        lTypeRecd := .F.
    EndIf

    //----------------------------------------------------------
    //Funcao para validar os dados passado no JSON
    //----------------------------------------------------------
    If CheckDados(cCodCli, cLojaCli, cCodMarc, cModVei, cCodVend)
        
        //----------------------------------------------------------
        //Funcao para inserir os dados
        //----------------------------------------------------------
        InsertDados(cFilialCp, cCodigoCp, cCodCli, cLojaCli, cNomeCli, cDddCli , cTelCli, cEmailCli,;
                    cNivelEmp, cTemperat, cOpc, cFilGd, cCodGd, cCodMarc, cModVei, cQnt, cOperFab, cDateInt,;
                    cDateLimt, cCodVend, cTipoCon, aItensNeg)
    Else
        CloseTable()
        Return(.F.)
    EndIf 

    //----------------------------------------------------------
    //Funcao para fechar as tabelas 
    //----------------------------------------------------------
    CloseTable()

Return(.T.)

/**************************************************************************************************
{Protheus.doc} InsertDados
@description	Insere dados nas tabelas VDL e VDM 
@type   		User Function	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		29/03/2022
@database		29/03/2022
@country		Brasil
@language		PT-BR
@obs			29/03/2022 - Controle de documentacao
@param			cFilialCp, cCodigoCp, cCodCli, cLojaCli, cNomeCli, cDddCli , cTelCli, cEmailCli,;
                cNivelEmp, cTemperat, cOpc, cFilGd, cCodGd, cCodMarc, cModVei, cQnt, cOperFab, cDateInt,;
                cDateLimt, cCodVend, cTipoCon, aItensNeg
@return			Nil			
*****************************************************************************************************/
Static Function InsertDados(cFilialCp, cCodigoCp, cCodCli, cLojaCli, cNomeCli, cDddCli , cTelCli, cEmailCli,;
                            cNivelEmp, cTemperat, cOpc, cFilGd, cCodGd, cCodMarc, cModVei, cQnt, cOperFab, cDateInt,;
                            cDateLimt, cCodVend, cTipoCon, aItensNeg)

Local _cProxDoc     := ""  

    If lTypeRecd
        //----------------------------------------------------------
        // Busca o Proximo numero 
        //----------------------------------------------------------
        fNextNum(@_cProxDoc, cFilialCp)
    Else 
        VDL->(DbSeek(cFilialCp+cCodigoCp))
        _cProxDoc := cCodigoCp
    EndIf 
    //----------------------------------------------------------
    // Tabela Vdl Gravar ou alterar
    //----------------------------------------------------------
    If RecordVDL(cFilialCp, _cProxDoc, cCodCli, cLojaCli, cNomeCli, cDddCli, cTelCli, cEmailCli,cNivelEmp,cTemperat)
        Conout("Gravacao na tabela VDl - COM SUCESSO" + _cProxDoc)
    EndIf 
    //----------------------------------------------------------
    // Tabela VDM Gravar ou alterar
    //----------------------------------------------------------
    If RecordVDM( _cProxDoc, aItensNeg)
        Conout("Gravacao na tabela VDM - COM SUCESSO" + _cProxDoc)
    EndIf 

Return 

/**************************************************************************************************
{Protheus.doc} RecordVDL
@description	Insere ou altera dados na tabela VDL 
@type   		User Function	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		29/03/2022
@database		29/03/2022
@country		Brasil
@language		PT-BR
@obs			29/03/2022 - Controle de documentacao
@param			cFilialCp, _cProxDoc, cCodCli, cLojaCli, cNomeCli, cDddCli, cTelCli, cEmailCli,cNivelEmp,cTemperat
@return			Logico			
*****************************************************************************************************/
Static Function RecordVDL(cFilialCp, _cProxDoc, cCodCli, cLojaCli, cNomeCli, cDddCli, cTelCli, cEmailCli,cNivelEmp,cTemperat) 


    VDL->(RecLock("VDL",lTypeRecd))
        VDL->VDL_FILIAL := cFilialCp
        VDL->VDL_CODOPO := _cProxDoc
        VDL->VDL_CODCLI := cCodCli
        VDL->VDL_LOJCLI := cLojaCli
        VDL->VDL_NOMCLI := AllTrim(SA1->A1_NOME)
        VDL->VDL_DDDCLI := cDddCli
        VDL->VDL_TELCLI := cTelCli
        VDL->VDL_EMACLI := cEmailCli
        VDL->VDL_NIVIMP := cNivelEmp
        VDL->VDL_TMPNEG := cTemperat
    VDL->(MsUnlock())    

Return(.T.)

/**************************************************************************************************
{Protheus.doc} RecordVDM
@description	Insere ou altera dados na tabela VDM
@type   		User Function	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		29/03/2022
@database		29/03/2022
@country		Brasil
@language		PT-BR
@obs			29/03/2022 - Controle de documentacao
@param			_cProxDoc, aItensNeg
@return			Logico			
*****************************************************************************************************/
Static Function RecordVDM( _cProxDoc, aItensNeg)

Local nY            := 0 
Local _cFilGrd      := ""
Local _cCodiGrd     := ""
Local _cCodMarcGrd  := ""
Local _cModVeiGrd   := ""
Local _cQntGrd      := ""
Local _cOperGrd     := ""
Local _cDateIntGrd  := ""
Local _cDateLmtGrd  := ""
Local _cCodVendGrd  := ""
Local _cTipoGrd     := ""
Local _nCodItens    := 0
Local nArray        := 0

    For nY := 1 To Len(aItensNeg)

        nArray++

        _cFilGrd     := IIF(aItensNeg[nY][1] == "cFilGd"   , aItensNeg[nArray][2], _cFilGrd     )
        _cCodiGrd    := IIF(aItensNeg[nY][1] == "cCodGd"   , aItensNeg[nArray][2], _cCodiGrd    )
        _cCodMarcGrd := IIF(aItensNeg[nY][1] == "cCodMarc" , aItensNeg[nArray][2], _cCodMarcGrd )
        _cModVeiGrd  := IIF(aItensNeg[nY][1] == "cModVei"  , aItensNeg[nArray][2], _cModVeiGrd  )
        _cQntGrd     := IIF(aItensNeg[nY][1] == "cQnt"     , aItensNeg[nArray][2], _cQntGrd     )
        _cOperGrd    := IIF(aItensNeg[nY][1] == "cOperFab" , aItensNeg[nArray][2], _cOperGrd    )
        _cDateIntGrd := IIF(aItensNeg[nY][1] == "cDateInt" , aItensNeg[nArray][2], _cDateIntGrd )
        _cDateLmtGrd := IIF(aItensNeg[nY][1] == "cDateLimt", aItensNeg[nArray][2], _cDateLmtGrd )
        _cCodVendGrd := IIF(aItensNeg[nY][1] == "cCodVend" , aItensNeg[nArray][2], _cCodVendGrd )
        _cTipoGrd    := IIF(aItensNeg[nY][1] == "cTipoCon" , aItensNeg[nArray][2], _cTipoGrd    )

        If  !Empty(_cFilGrd)  .AND. !Empty(_cCodiGrd)    .AND. !Empty(_cCodMarcGrd) .AND. !Empty(_cModVeiGrd)  .AND. !Empty(_cQntGrd) .AND.;
            !Empty(_cOperGrd) .AND. !Empty(_cDateIntGrd) .AND. !Empty(_cDateLmtGrd) .AND. !Empty(_cCodVendGrd) .AND. !Empty(_cTipoGrd)

                _nCodItens ++

                If !lTypeRecd
                    VDM->(DbSeek(_cFilGrd + _cProxDoc + Strzero(_nCodItens, 6, 0)))
                EndIf 
                
                VDM->(RecLock("VDM",lTypeRecd))
                    VDM->VDM_FILIAL := _cFilGrd
                    VDM->VDM_CODOPO := _cProxDoc
                    VDM->VDM_CODINT := Strzero(_nCodItens, 6, 0)
                    VDM->VDM_CODMAR := AllTrim(_cCodMarcGrd)
                    VDM->VDM_MODVEI := _cModVeiGrd
                    VDM->VDM_QTDINT := Val(_cQntGrd)
                    VDM->VDM_OPCFAB := _cOperGrd
                    VDM->VDM_DATINT := Date(_cDateIntGrd)
                    VDM->VDM_DATLIM := Date(_cDateLmtGrd)
                    VDM->VDM_CODVEN := _cCodVendGrd
                    VDM->VDM_TIPCON := _cTipoGrd
                VDM->(MsUnlock())    

                fZeroVar(@_cFilGrd, @_cCodiGrd,  @_cCodMarcGrd, @_cModVeiGrd , @_cQntGrd, @_cOperGrd, @_cDateIntGrd, @_cDateLmtGrd, @_cCodVendGrd, @_cTipoGrd)

        EndIf 

    Next 

Return(.T.)

/**************************************************************************************************
{Protheus.doc} fNextNum
@description	Busca o Proximo codigo da tabela VDL
@type   		User Function	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		29/03/2022
@database		29/03/2022
@country		Brasil
@language		PT-BR
@obs			29/03/2022 - Controle de documentacao
@param			_cProxDoc, aItensNeg
@return			Logico			
*****************************************************************************************************/
Static Function fNextNum(_cProxDoc, cFilialCp)

    _cProxDoc := GetSXENum("VDM","VDM_CODINT")

    While VDM->(dbSeek(cFilialCp+_cProxDoc))
        ConfirmSX8()
        _cProxDoc := GetSXENum("VDM","VDM_CODINT")
    EndDo

Return 

/**************************************************************************************************
{Protheus.doc} CheckDados
@description	Validacoes nos dados
@type   		User Function	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		29/03/2022
@database		29/03/2022
@country		Brasil
@language		PT-BR
@obs			29/03/2022 - Controle de documentacao
@param			cCodCli, cLojaCli, cCodMarc, cModVei, cCodVend
@return			Logico			
*****************************************************************************************************/
Static Function CheckDados(cCodCli, cLojaCli, cCodMarc, cModVei, cCodVend )

    //----------------------------------------------------------
    // Valida dados do cliente
    //----------------------------------------------------------
    If !(SA1->(DbSeek(xFilial("SA1") + cCodCli + cLojaCli)))
        Return(.F.)
    EndIf 

    //----------------------------------------------------------
    // Valida dados do Modelos de veiculos 
    //----------------------------------------------------------
    If !(VV2->(DbSeek(xFilial("VV2") + cCodMarc + cModVei)))
        Return(.F.)
    EndIf 

    //----------------------------------------------------------
    // Valida dados de tecnicos
    //----------------------------------------------------------
    If !(VAI->(DbSeek(xFilial("VAI") + cCodVend)))
        Return(.F.)
    EndIf 

Return(.T.)

/**************************************************************************************************
{Protheus.doc} OpenTable
@description	Abertura das tabelas
@type   		User Function	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		29/03/2022
@database		29/03/2022
@country		Brasil
@language		PT-BR
@obs			29/03/2022 - Controle de documentacao
@param			cCodCli, cLojaCli, cCodMarc, cModVei, cCodVend
@return			Logico			
*****************************************************************************************************/
Static Function OpenTable()

    // Cliente
    DbSelectArea("SA1")
    SA1->(DbSetOrder(1)) // A1_FILIAL, A1_COD, A1_LOJA

    // Modelos de Veículos
    DbSelectArea("VV2")
    VV2->(DbSetOrder(1)) // VV2_FILIAL, VV2_CODMAR, VV2_MODVEI, VV2_SEGMOD

    // Tecnicos
    DbSelectArea("VAI")
    VAI->(DbSetOrder(1)) // VAI_FILIAL, VAI_CODTEC

    // Oportunidades de Negócios
    DbSelectArea("VDL")
    VDL->(DbSetOrder(1))// VDL_FILIAL, VDL_CODOPO

    // Interesses Oport. de Negocios
    DbSelectArea("VDM")
    VDM->(DbSetOrder(1))// VDM_FILIAL, VDM_CODOPO, VDM_CODINT

Return 

/**************************************************************************************************
{Protheus.doc} fZeroVar
@description	Zerar as variaveis 
@type   		User Function	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		29/03/2022
@database		29/03/2022
@country		Brasil
@language		PT-BR
@obs			29/03/2022 - Controle de documentacao
@param			_cFilGrd, _cCodiGrd, _cCodMarcGrd, _cModVeiGrd, _cQntGrd, _cOperGrd, _cDateIntGrd, _cDateLmtGrd, _cCodVendGrd, _cTipoGrd)
@return			Logico			
*****************************************************************************************************/
Static Function fZeroVar(_cFilGrd, _cCodiGrd, _cCodMarcGrd, _cModVeiGrd, _cQntGrd, _cOperGrd, _cDateIntGrd, _cDateLmtGrd, _cCodVendGrd, _cTipoGrd)

    _cFilGrd     := ""
    _cCodiGrd    := ""
    _cCodMarcGrd := ""
    _cModVeiGrd  := ""
    _cQntGrd     := ""
    _cOperGrd    := ""
    _cDateIntGrd := ""
    _cDateLmtGrd := ""
    _cCodVendGrd := ""
    _cTipoGrd    := ""

Return 

/**************************************************************************************************
{Protheus.doc} CloseTable
@description	Fecha os Alias abertos
@type   		User Function	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		29/03/2022
@database		29/03/2022
@country		Brasil
@language		PT-BR
@obs			29/03/2022 - Controle de documentacao
@param			_cFilGrd, _cCodiGrd, _cCodMarcGrd, _cModVeiGrd, _cQntGrd, _cOperGrd, _cDateIntGrd, _cDateLmtGrd, _cCodVendGrd, _cTipoGrd)
@return			Logico			
*****************************************************************************************************/
Static Function CloseTable()

    SA1->(DbCloseArea())
    VV2->(DbCloseArea())
    VA1->(DbCloseArea())
    VDL->(DbCloseArea())
    VDM->(DbCloseArea())

Return 
