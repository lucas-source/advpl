#INCLUDE'PROTHEUS.CH'
#INCLUDE'TOPCONN.CH'
#INCLUDE'TOTVS.CH'
#INCLUDE'RWMAKE.CH'
#INCLUDE'PARMTYPE.CH'

/*/{Protheus.doc} WZFIN007
	Envio de workflow das rotinas de cadastros.
	@type function
	@version 27
	@author Lucas Rocha Vieira
	@since 10/11/2020
	@return True
/*/
User Function WZFIN007(nOpc, cUser, oProcess, cCod, cLoja, oObj)

    Default oProcess := Nil


    If nOpc == 0

        //Tratativa do cadastro de natureza
        If oObj <> NIL
            If alltrim(oObj:cDescription) == "Naturezas"
                cCadastro := ""
            EndIf 
        EndIf 


        Do Case 
            
            //----------------------------------------
            //Workflow de Fornecedor
            //----------------------------------------
            Case AllTrim(cCadastro) == "Fornecedores - INCLUIR"

                oFornec := TWFProcess():New( "000010" , "Fornecedo" )
                fWretFornc(oFornec, cCod, cLoja,, 1) 
                FreeObj(oFornec)

                SA2->(DBCloseArea())

            Case AllTrim(cCadastro) == "Fornecedores - ALTERAR"

                oFornec := TWFProcess():New( "000010" , "Fornecedo" )

                fWretFornc(oFornec, cCod, cLoja,, 1) 
                FreeObj(oFornec)

                If  SA2->A2_MSBLQL == "2" .AND. lOk .OR. ALLTRIM(SA2->A2_MSBLQL) == "" .AND. lOk 

                    DBSelectArea("SA2")
	                SA2->(DBSetOrder(1))
	                If	SA2->(DBSeek(xFilial("SA2")+SA2->(cCod+cLoja)))
                        SA2->(Reclock("SA1"))
                        SA2->A2_MSBLQL  := "1"
                        SA2->A2_APROVAD := ""
                        SA2->(MsUnlock())
                    Else 
                        MsgStop( "Falha ao posicionar no registro de aprova��o! Verifique com a equipe de TI/ERP." , "Aten��o!" )
                    EndIf 

                EndIf      

                SA2->(DBCloseArea())

            //PONTO DE ENTRADA PARA DESBLOQUEAR O REGISTRO SEM ABRIR O FORMUL�RIO
            Case AllTrim(cCadastro) == "Fornecedores - DESBLOQUEAR REGISTRO"
                
                If SA2->A2_MSBLQL == "2"
                    MsgInfo("S� e permitido enviar o workflow se o registro estiver bloqueado!", "Aten��o")  
                    Return(.F.)
                Else 
                    oFornec := TWFProcess():New( "000010" , "Fornecedo" )
                    fWretFornc(oFornec, cCod, cLoja,, 1) 
                    FreeObj(oFornec)
                EndIf 

                If !Empty(AllTrim(SA2->A2_APROVAD))
                    SA2->(Reclock("SA2"))
                    SA2->A2_APROVAD := ""
                    SA2->(MsUnlock())
                EndIf 

                SA2->(DBCloseArea())


            //----------------------------------------
            //Workflow de Natureza
            //----------------------------------------                
            Case alltrim(oObj:cDescription) == "Naturezas"

                oNaturez:= TWFProcess():New( "000011" , "Natureza"  ) 

                If oObj:GetOperation() == 3

                    FWorkNat(oNaturez, cCod,,, 1)
                    FreeObj(oNaturez)

                ElseIf oObj:GetOperation() == 4

                    FWorkNat(oNaturez, cCod,,, 1)
                    FreeObj(oNaturez)

                    If  SED->ED_MSBLQL == "2" .AND. lOk .OR. ALLTRIM(SED->ED_MSBLQL) == "" .AND. lOk

                        DBSelectArea("SED")
	                    SED->(DBSetOrder(1))
	                    If	SED->(DBSeek(xFilial("SED")+SED->(cCod)))
                            SED->(Reclock("SED"))
                            SED->ED_MSBLQL  := "1"
                            SED->ED_XAPROVA := ""
                            SED->(MsUnlock())
                        Else 
                            MsgStop( "Falha ao posicionar no registro de aprova��o! Verifique com a equipe de TI/ERP." , "Aten��o!" )
                        EndIf 

                    EndIf  

                    If !Empty(AllTrim(SED->ED_XAPROVA))
                        SED->(Reclock("SED"))
                        SED->ED_XAPROVA := ""
                        SED->(MsUnlock())
                    EndIf 

                EndIf     

                SED->(DBCloseArea())

        EndCase 
    
    ElseIf nOpc == 2 
        //-------------------------------------------------
        //Retorno do workflow de fornecedor
        //-------------------------------------------------
        fWretFornec(oProcess, cUser)
        oProcess:Free()

    ElseIf nOpc == 3
        //-------------------------------------------------
        //Retorno do workflow de natureza
        //-------------------------------------------------
        fWretNat(oProcess, cUser)
        oProcess:Free()

    EndIf 


Return()

/*/{Protheus.doc} FWorkNat
	Envio de workflow de cliente.
	@type function
	@version 27
	@author Lucas Rocha Vieira
	@since 10/11/2020
	@return True
/*/
Static Function FWorkNat(oProcess, cCod,cLoja, cUser, nGrupo)

	Local oHtml 	:= Nil
	Local cLogoCli	:= Lower( AllTrim( GetMV( "SC_WFLOCLI" ,, "http://www.parconstrucao.com.br/img/logo.png" ) ) )
    Local cTitle	:= "Cadastro de Natureza"
    Local chttp     := GetNewPar("WZ_WFLINK", "http://187.94.63.120:8091/wf")//"http://187.94.63.120:8087/wf"
    Local cHtmlWF   := ""
    Local cIDLink   := ""
    Default cUser   := RetCodUsr()

    DBSelectArea("SED")
	SED->(DBSetOrder(1))
	If	SED->(DBSeek(xFilial("SED")+ cCod ))

        //-------------------------------------------------
        //Criacao de uma nova tarefa e abertura do HTML
        //-------------------------------------------------
        oProcess:NewTask( "Cadastro de Natureza" , "\WORKFLOW\WF_NAT.htm" )       
        oProcess:bReturn  := "U_WZFIN007(3,'"+cUser+"')"
        oHtml 	          := oProcess:oHtml
		cMailID	          := oProcess:Start()    
        oProcess:UserSiga := cUser 

        //-------------------------------------------------
        //Montagem do HTML          
        //-------------------------------------------------
        oHtml:ValByName( "WFAction"		, "WFHTTPRET.APL"	       )
        oHtml:ValByName( "codigo"	    , cCod	    	           )
        oHtml:ValByName( "loja"	        , cLoja 		           )
		oHtml:ValByName( "aprov_nivel"	, ""                       )
        oHtml:ValByName( "aprov_nome"	, ""                	   )
		oHtml:ValByName( "aprov_cod"	, ""    			       )
        oHtml:ValByName( "aprov_status"	, "1"			           )
		oHtml:ValByName( "empresa"		, AllTrim(FWFilialName())  )
		oHtml:ValByName( "cod"		    , Alltrim(SED->ED_CODIGO)  )
		oHtml:ValByName( "descri"		, Alltrim(SED->ED_DESCRIC) )
		oHtml:ValByName( "tipo"		    , Alltrim(SED->ED_TIPO)    )
		oHtml:ValByName( "fcaixa"		, Alltrim(SED->ED_COND)    )
		oHtml:ValByName( "cnaturez"		, Alltrim(SED->ED_XFLUXO)  )
		oHtml:ValByName( "cIRRF"		, Alltrim(SED->ED_CALCIRF) )
        oHtml:ValByName( "cISS"		    , Alltrim(SED->ED_CALCISS) )
        oHtml:ValByName( "cINSS"		, Alltrim(SED->ED_CALCINS) )
        oHtml:ValByName( "cPIS"		    , Alltrim(SED->ED_CALCCSL) )
        oHtml:ValByName( "cCOFINS"		, Alltrim(SED->ED_CALCCOF) )
        oHtml:ValByName( "cCSLL"	    , Alltrim(SED->ED_CALCPIS) )
        oHtml:ValByName( "cDCofins"		, Alltrim(SED->ED_DEDPIS)  )
        oHtml:ValByName( "pis"		    , Alltrim(SED->ED_DEDCOF)  )
        oHtml:ValByName( "confins"		, Alltrim(SED->ED_APURPIS) )
        oHtml:ValByName( "CPRB"		    , Alltrim(SED->ED_APURCOF) )
        oHtml:ValByName( "redpis"		, Alltrim(SED->ED_CPRB)    )
        oHtml:ValByName( "cta"		    , Alltrim(SED->ED_REDPIS)  )

        oProcess:ClientName( cUserName )
        oProcess:cTo       := "d@d.com"

        Sleep(1000)

        //-----------------------------------
        //E-mails dos Aprovadores
        // Grupo (1) Fiscal
        // Grupo (2) Contabil
        //-----------------------------------
        If nGrupo == 1
            cMailDest := GetMV( "MV_FISCAPV" ,, "gustavoxavier@wizsolucoes.com.br")
        ElseIf nGrupo == 2
            cMailDest := GetMV( "MV_CTBAPRV" ,, "gustavoxavier@wizsolucoes.com.br")
        EndIf

        __chttp := chttp  + '/nat/emp' + Alltrim(cEmpAnt) + '/' + Alltrim(oProcess:UserSiga) + '/' + Alltrim( cMailId ) + '.htm'

        //-------------------------------------------------
        //Chamada da fun��o de envio do Workflow
        //-------------------------------------------------
        FwMail(cTitle, cMailDest, __chttp, 0,, ) 

        //--------------------------------------------------
        //Pega o formul�rio do htm de cadastro de cliente
        //--------------------------------------------------
        cIDLink := oProcess:Start("\web\nat\emp" + cEmpAnt + '\' + oProcess:UserSiga )				

		cArqHtml := cIDLink + ".htm"

        //-------------------------------------------------
		//Joga o conteudo do HTML na variavel cHtmlWF		
        //-------------------------------------------------	             	 
		cHtmlWF := WFLoadFile("\web\nat\emp" + cEmpAnt + '\' + oProcess:UserSiga+"\" + cArqHtml)

        //-------------------------------------------------
		//Altera a clausula mailto do HTML origina.			
        //-------------------------------------------------	             	 
		cMailTo		:= "mailto:"
		cHtmlWF		:= StrTran( cHtmlWF , cMailTo , "WFHTTPRET.APL" )

        //--------------------------------------------------------
		//Altera o endereco do logo da empresa do HTML original.
        //--------------------------------------------------------			     
		cMailTo		:= "img_logo"
		cHtmlWF		:= StrTran(cHtmlWF,cMailTo,'<img src="'+cLogoCli+'"')

        //-------------------------------------------------
		//Grava no messenger o html do WF.					
        //-------------------------------------------------		             	 
		WfSaveFile("\web\nat\emp" + cEmpAnt + '\' + oProcess:UserSiga+"\" + cMailId + ".htm", cHtmlWF) 

        //-------------------------------------------------
		//Cria rastreabilidade do WF.						
        //-------------------------------------------------		             	 
		RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,"100100",'Processo da Aprova��o ['+AllTrim(cCod)+'] iniciado!' )
        
    Else
		MsgStop( "Falha ao posicionar no registro de aprova��o! Verifique com a equipe de TI/ERP." , "Aten��o!" )

    EndIf 

Return()

/*/{Protheus.doc} fWretFornc
	Envio de workflow de fornecedor.
	@type function
	@version 27
	@author Lucas Rocha Vieira
	@since 10/11/2020
	@return True
/*/
Static Function fWretFornc(oProcess, cCod, cLoja, cUser, nGrupo)

	Local oHtml 	:= Nil
	Local cLogoCli	:= Lower( AllTrim( GetMV( "SC_WFLOCLI" ,, "http://www.parconstrucao.com.br/img/logo.png" ) ) )
    Local cTitle	:= "Cadastro de Fornecedor"
    Local chttp     := GetNewPar("WZ_WFLINK", "http://187.94.63.120:8091/wf")
    Local cHtmlWF   := ""
    Local cIDLink   := ""
    Default cUser   := RetCodUsr()

    DBSelectArea("SA2")
	SA2->(DBSetOrder(1))//A2_FILIAL+A2_COD+A2_LOJA
	If	SA2->(DBSeek(xFilial("SA2")+SA2->(A2_COD+A2_LOJA)))

        //-------------------------------------------------
        //Criacao de uma nova tarefa e abertura do HTML
        //-------------------------------------------------
        oProcess:NewTask( "Cadastro de Fornecedores" , "\WORKFLOW\WF_FORNEC.htm" )       
        oProcess:bReturn  := "U_WZFIN007(2,'"+cUser+"')"
        oHtml 	          := oProcess:oHtml
		cMailID	          := oProcess:Start() 
        oProcess:UserSiga := cUser 

        //-------------------------------------------------
        //Montagem do HTML           
        //-------------------------------------------------
        oHtml:ValByName( "WFAction"		, "WFHTTPRET.APL"	       )
        oHtml:ValByName( "codigo"	    , cCod	    	           )
        oHtml:ValByName( "loja"	        , cLoja 		           )
		oHtml:ValByName( "aprov_nivel"	, ""                       )
        oHtml:ValByName( "aprov_nome"	, ""    	               )
		oHtml:ValByName( "aprov_cod"	, ""    			       )
		oHtml:ValByName( "empresa"		, AllTrim(FWFilialName())  )
        oHtml:ValByName( "nome"		    , AllTrim(SA2->A2_NOME)    )
        oHtml:ValByName( "fanta"		, AllTrim(SA2->A2_NREDUZ)  )
        oHtml:ValByName( "Tipo"		    , AllTrim((SA2->A2_TIPO))  )
        oHtml:ValByName( "CNPJ/CPF"		, AllTrim(SA2->A2_CGC)     )
        oHtml:ValByName( "Endereco"	    , AllTrim(SA2->A2_END)     )
        oHtml:ValByName( "Comple"	    , AllTrim(SA2->A2_COMPLEM) )
        oHtml:ValByName( "Bairro"	    , AllTrim(SA2->A2_BAIRRO)  )
        oHtml:ValByName( "Municipio"    , AllTrim(SA2->A2_MUN)     )
        oHtml:ValByName( "UF"		    , AllTrim(SA2->A2_EST)     )
        oHtml:ValByName( "CEP"		    , AllTrim(SA2->A2_CEP)     )
        oHtml:ValByName( "codban"	    , AllTrim(SA2->A2_BANCO)   )
        oHtml:ValByName( "agenc"	    , AllTrim(SA2->A2_AGENCIA) )
        oHtml:ValByName( "Tpcponta"	    , AllTrim(SA2->A2_TIPCTA)  )
        oHtml:ValByName( "conta"	    , AllTrim(SA2->A2_NUMCON)  )
        oHtml:ValByName( "naturez"	    , AllTrim(SA2->A2_NATUREZ) )
        oHtml:ValByName( "tipo3"	    , AllTrim(SA2->A2_TPESSOA) )
        oHtml:ValByName( "SIAF"		    , AllTrim(SA2->A2_CODSIAF) )
        oHtml:ValByName( "bcb"		    , AllTrim(SA2->A2_CODPAIS) )
        oHtml:ValByName( "ISS"		    , AllTrim(SA2->A2_RECISS)  )
        oHtml:ValByName( "INSS"		    , AllTrim(SA2->A2_RECINSS) )
        oHtml:ValByName( "PIS"		    , AllTrim(SA2->A2_RECPIS)  )
        oHtml:ValByName( "COFINS"	    , AllTrim(SA2->A2_RECCOFI) )
        oHtml:ValByName( "IRRF"		    , AllTrim(SA2->A2_CALCIRF) )
        oHtml:ValByName( "CPRB"		    , AllTrim(SA2->A2_CPRB)    )


        oProcess:ClientName( cUserName )
        oProcess:cTo       := "d@d.com"

        Sleep(1000)

        //-----------------------------------
        //E-mails dos Aprovadores
        // Grupo (1) Fiscal
        // Grupo (2) Contabil
        // Grupo (3) Financeiro
        //-----------------------------------
        If nGrupo == 1
            cMailDest := GetMV( "MV_FISCAPV" ,, "gustavoxavier@wizsolucoes.com.br")
        ElseIf nGrupo == 2
            cMailDest := GetMV( "MV_CTBAPRV" ,, "gustavoxavier@wizsolucoes.com.br")
        Elseif nGrupo == 3 
            cMailDest := GetMV( "MV_FINCPRV" ,, "gustavoxavier@wizsolucoes.com.br")
        EndIf
        
        __chttp := chttp  + '/fornec/emp' + Alltrim(cEmpAnt) + '/' + Alltrim(oProcess:UserSiga) + '/' + Alltrim( cMailId ) + '.htm'
        
        //-------------------------------------------------
        //Chamada da fun��o de envio do Workflow
        //-------------------------------------------------
        FwMail(cTitle, cMailDest, __chttp, 0,, ) 

        //--------------------------------------------------
        //Pega o formul�rio do htm de cadastro de cliente
        //--------------------------------------------------
        cIDLink := oProcess:Start("\web\fornec\emp" + cEmpAnt + '\' + oProcess:UserSiga )				

		cArqHtml := cIDLink + ".htm"

        //-------------------------------------------------
		//Joga o conteudo do HTML na variavel cHtmlWF		
        //-------------------------------------------------	             	 
		cHtmlWF := WFLoadFile("\web\fornec\emp" + cEmpAnt + '\' + oProcess:UserSiga+"\" + cArqHtml)

        //-------------------------------------------------
		//Altera a clausula mailto do HTML origina.			
        //-------------------------------------------------	             	 
		cMailTo		:= "mailto:"
		cHtmlWF		:= StrTran( cHtmlWF , cMailTo , "WFHTTPRET.APL" )

        //--------------------------------------------------------
		//Altera o endereco do logo da empresa do HTML original.
        //--------------------------------------------------------			     
		cMailTo		:= "img_logo"
		cHtmlWF		:= StrTran(cHtmlWF,cMailTo,'<img src="'+cLogoCli+'"')

        //-------------------------------------------------
		//Grava no messenger o html do WF.					
        //-------------------------------------------------		             	 
		WfSaveFile("\web\fornec\emp" + cEmpAnt + '\' + oProcess:UserSiga+"\" + cMailId + ".htm", cHtmlWF) 

        //-------------------------------------------------
		//Cria rastreabilidade do WF.						
        //-------------------------------------------------		             	 
		RastreiaWF(oProcess:fProcessID+'.'+oProcess:fTaskID,oProcess:fProcCode,"100100",'Processo da Aprova��o ['+AllTrim(cCod)+'] iniciado!' )
        

    Else
	    MsgStop( "Falha ao posicionar no registro de aprova��o! Verifique com a equipe de TI/ERP." , "Aten��o!" )
    EndIf 

Return()

/*/{Protheus.doc} fWretNat
	Retorno do workflow de natureza.
	@type function
	@version 27
	@author Lucas Rocha Vieira
	@since 10/11/2020
	@return True
/*/
Static Function fWretNat(oProcess, cUser)


    Local lAprovou		:= Upper( AllTrim( oProcess:oHtml:RetByName( "RBAPROVA" ) ) ) == "SIM"
    Local cTitle	    := "Cadastro de Natureza"
    Local cMailDest     := AllTrim( UsrRetMail(cUser))
    Local cCodCliet 	:= oProcess:oHtml:RetByName( "codigo") 
    Local cCodLoja  	:= oProcess:oHtml:RetByName( "loja") 
    Local cMotivo		:= oProcess:oHtml:RetByName( "lbmotivo" )
    Local cRepre        := oProcess:oHtml:RetByName( "aprov_cod" )

    //---------------------------------------------------------------                                         
    //Posiciona no titulo e Verifica se o gestor aprovou o workflow
    //---------------------------------------------------------------
    DbSelectArea("SED")
    SED->(DbSetOrder(1))
    SED->(DbSeek(xFilial("SED") + Alltrim(cCodCliet) ))
    If lAprovou

        //-------------------------------------
        //Fila para aprova��o, 2 aprovadores
        //-------------------------------------
        If Empty(AllTrim(ED_XAPROVA))

            SED->(Reclock("SED"))
            SED->ED_XAPROVA := "01"
            SED->(MsUnlock())

            FWorkNat(oProcess, cCodCliet, cCodLoja, cUser, 2)
        
        ElseIf AllTrim(ED_XAPROVA) == "01"

            //Todos aprovaram o workflow
            SED->(Reclock("SED"))
            SED->ED_MSBLQL  := "2"
            SED->ED_XAPROVA := ""
            SED->(MsUnlock())
    
            FwMail(cTitle,cMailDest,, 5,,)

        EndIf

    Else
        
        If !Empty(AllTrim(ED_XAPROVA))
            SED->(Reclock("SED"))
            SED->ED_XAPROVA := ""
            SED->(MsUnlock())
        EndIf 

        //Reprovou o workflow
        FwMail(cTitle,cMailDest,, 6, cMotivo,cRepre)

	EndIf

    SED->(DBCloseArea())

Return()

/*/{Protheus.doc} fWretFornec
	Retorno do workflow de fornecedor.
	@type function
	@version 27
	@author Lucas Rocha Vieira
	@since 10/11/2020
	@return True
/*/
Static Function fWretFornec(oProcess, cUser)


    Local lAprovou		:= Upper( AllTrim( oProcess:oHtml:RetByName( "RBAPROVA" ) ) ) == "SIM"
    Local cTitle	    := "Cadastro de Fornecedor"
    Local cMailDest     := AllTrim( UsrRetMail(cUser))
    Local cCodCliet 	:= oProcess:oHtml:RetByName( "codigo") 
    Local cCodLoja  	:= oProcess:oHtml:RetByName( "loja") 
    Local cMotivo		:= oProcess:oHtml:RetByName( "lbmotivo" )
    Local cRepre        := oProcess:oHtml:RetByName( "aprov_cod" )

    //---------------------------------------------------------------                                         
    //Posiciona no titulo e Verifica se o gestor aprovou o workflow
    //---------------------------------------------------------------
    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))
    SA2->(DbSeek(xFilial("SA2") + cCodCliet + cCodLoja))

    If lAprovou

        //----------------------------
        //Fila para aprova��o 3 aprovadores
        //----------------------------
        If Empty(AllTrim(A2_APROVAD))

            SA2->(Reclock("SA2"))
            SA2->A2_APROVAD := "01"
            SA2->(MsUnlock())

            fWretFornc(oProcess, cCodCliet, cCodLoja, cUser, 2)
        
        ElseIf AllTrim(A2_APROVAD) == "01"
        
            SA2->(Reclock("SA2"))
            SA2->A2_APROVAD := "02"
            SA2->(MsUnlock())
    
            fWretFornc(oProcess, cCodCliet, cCodLoja, cUser, 3)

        ElseIf AllTrim(A2_APROVAD) == "02"

            //Todos aprovaram o workflow
            SA2->(Reclock("SA2"))
            SA2->A2_MSBLQL  := "2"
            SA2->A2_APROVAD := ""
            SA2->(MsUnlock())
    
            FwMail(cTitle,cMailDest,, 2,,)

        EndIf

    Else
        //Limpar o campo de aprovacao
        If !Empty(AllTrim(A2_APROVAD))
            SA2->(Reclock("SA2"))
            SA2->A2_APROVAD := ""
            SA2->(MsUnlock())
        EndIf 

        //Reprovou o workflow
        FwMail(cTitle,cMailDest,, 3, cMotivo,cRepre)

	EndIf

    SA2->(DBCloseArea())

Return() 

/*/{Protheus.doc} FwMail
	Envio do workflow.
	@type function
	@version 27
	@author Lucas Rocha Vieira
	@since 10/11/2020
	@return True
/*/
Static Function FwMail(cTitle,cMailDest,cEndWF, nalternat, cMotivo, cRepre)

	Local cHtml		:= ""
	Local _cEmlCp	:= AllTrim( GETMV( 'WZ_CTBECPY' ,, '' ) )
    Public lOk		:= .F.

    //-------------------------------------------------
    // Envio do workflow para o aprovador
    //-------------------------------------------------
    If nalternat == 0
	    cHtml  := ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	    cHtml  += ' <head> '
	    cHtml  += ' 	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	    cHtml  += ' 	<title>Aprovacao de cadastro</title>
	    cHtml  += ' </head>
	    cHtml  += ' <body>
	    cHtml  += ' <center>
	    cHtml  += ' <table width="850" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" >
	    cHtml  += ' 	<tr>
	    cHtml  += ' 		<td width="850"><img src="http://187.94.63.120:8091/wf/modelo_wf_wiz.jpg" width="850" height="62" /></td>
	    cHtml  += ' 	</tr>
	    cHtml  += ' 	<tr>
	    cHtml  += ' 		<td style="font-family:Verdana;font-size:18px;color:#50555a;"><br>Solicita��o de desbloqueio do cadastro</td>'
	    cHtml  += ' 	</tr>
	    cHtml  += ' 	<tr>
	    cHtml  += ' 		<td style="font-family:Verdana;font-size:18px;color:#50555a;">Empresa: '+ Capital(ALLTRIM(FWFILIALNAME())) +'<br><br></td>
	    cHtml  += ' 	</tr>
	    cHtml  += ' 	<tr>
	    cHtml  += ' 		<td bgColor="#00aa9b" style="font-family:Verdana;font-size:14px;color:#FFFFFF;" align="center"><b><a href="'+ cEndWF +'"><font color="#FFFFFF">Clique Aqui</font></a></b> para avaliar!</td>
	    cHtml  += ' 	</tr>
	    cHtml  += ' </table>
	    cHtml  += ' </center>
	    cHtml  += ' </body>
	    cHtml  += ' </html> 

	    lOk := U_WZSNDEML( ,,,, cMailDest , cTitle , cHtml ,, .F. ,,, _cEmlCp , )

	    If !lOk .And. __cInternet == NIL
	    	MsgInfo( "Erro ao enviar E-mail ao Aprovador." , "WorkFlow" )
        Else
            MsgInfo( "Altera��o realizada." + CRLF+ "Registro bloqueado, aguardando aprova��o do gestor!" , "WorkFlow" )
	    EndIf
    
    //-------------------------------------------------
    // Envio do workflow para o usu�rio
    //-------------------------------------------------
    Else 
        cHtml  := ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	    cHtml  += ' <head> '
	    cHtml  += ' 	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	    cHtml  += ' 	<title>Aprovacao Calend�rio Cont�bil</title>
	    cHtml  += ' </head>
	    cHtml  += ' <body>
	    cHtml  += ' <center>
	    cHtml  += ' <table width="850" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" >
	    cHtml  += ' 	<tr>
	    cHtml  += ' 		<td width="850"><img src="http://187.94.63.120:8091/wf/modelo_wf_wiz.jpg" width="850" height="62" /></td>
	    cHtml  += ' 	</tr>
        //-------------------------------------------------
        //Aprovou o workflow de cliente     (1)
        //Aprovou o workflow de forncedor   (2)
        //Reprovou o workflow de fornecedor (3)
        //Reprovou o workflow de cliente    (4)
        //Aprovou o workflow de natureza    (5)
        //Reprovou o workflow de natureza   (6)
        //------------------------------------------------- 
        If nalternat == 1 
	        cHtml  += ' 	<tr>
	        cHtml  += ' 		<td style="font-family:Verdana;font-size:18px;color:#50555a;"><br>Cliente Desbloqueado! c�digo: '+AllTrim(SA1->A1_COD)+'</td>'
	        cHtml  += ' 	</tr>
        ElseIf nalternat == 2
	        cHtml  += ' 	<tr>
	        cHtml  += ' 		<td style="font-family:Verdana;font-size:18px;color:#50555a;"><br>Fornecedor Desbloqueado! c�digo: '+AllTrim(SA2->A2_COD)+'</td>'
	        cHtml  += ' 	</tr>   

        ElseIf  nalternat == 3
            cHtml  += ' 	<tr>
	        cHtml  += ' 		<td style="font-family:Verdana;font-size:18px;color:#50555a;"><br>O seu cadastro de fornecedor n�o foi aprovado! C�digo:' + AllTrim(SA2->A2_COD) +'</td>'
	        cHtml  += ' 	</tr>
            
            cHtml  += ' 	<tr>
	        cHtml  += ' 		<td style="font-family:Verdana;font-size:18px;color:#50555a;"><br>Motivo: '+cMotivo+'</td>'
	        cHtml  += ' 	</tr>
        ElseIf nalternat == 4
        	cHtml  += ' 	<tr>
	        cHtml  += ' 		<td style="font-family:Verdana;font-size:18px;color:#50555a;"><br>O seu cadastro de cliente n�o foi aprovado! C�digo:' + AllTrim(SA1->A1_COD) +'</td>'
	        cHtml  += ' 	</tr>
            
            cHtml  += ' 	<tr>
	        cHtml  += ' 		<td style="font-family:Verdana;font-size:18px;color:#50555a;"><br>Motivo: '+cMotivo+'</td>'
	        cHtml  += ' 	</tr>

        ElseIf nalternat == 5
        	cHtml  += ' 	<tr>
	        cHtml  += ' 		<td style="font-family:Verdana;font-size:18px;color:#50555a;"><br>Natureza Desbloqueada! C�digo: '+AllTrim(SED->ED_CODIGO)+'</td>'
	        cHtml  += ' 	</tr>
        
        ElseIf nalternat == 6
            cHtml  += ' 	<tr>
	        cHtml  += ' 		<td style="font-family:Verdana;font-size:18px;color:#50555a;"><br>O seu cadastro de natureza n�o foi aprovado! C�digo:' + AllTrim(SED->ED_CODIGO) +'</td>'
	        cHtml  += ' 	</tr>
            
            cHtml  += ' 	<tr>
	        cHtml  += ' 		<td style="font-family:Verdana;font-size:18px;color:#50555a;"><br>Motivo: '+cMotivo+'</td>'
	        cHtml  += ' 	</tr>
        EndIf

	    cHtml  += ' 	<tr> 
	    cHtml  += ' 		<td style="font-family:Verdana;font-size:18px;color:#50555a;">Empresa: '+ Capital(AllTrim(FwFilialName())) +'<br><br></td>
	    cHtml  += ' 	</tr> 
	    cHtml  += ' </table>
	    cHtml  += ' </center>
	    cHtml  += ' </body>
	    cHtml  += ' </html>

        U_WZSNDEML( ,,,, cMailDest , cTitle , cHtml ,, .F. ,,, _cEmlCp , )

    EndIf 
    
Return()
