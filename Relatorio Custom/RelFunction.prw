#INCLUDE'TOTVS.CH'
#INCLUDE'PROTHEUS.CH'

/*/{Protheus.doc} WZWZRCDV001
Relatório de tipos de despesas do colaborador
@type function
@version 25
@author Lucas Rocha Vieira
@since 23/07/2020
/*/
User Function WZRCDV001()
//---------------------------------------------------------
//Consulta específica aonde o retorno é um array(PV1TDE) 
//---------------------------------------------------------
    fRelatCdv(aSize({},37))
Return
Static Function fRelatCdv(aReto)
Local _cColab   := Space( TamSX3('PV0_CODIGO')[01]  )
Local cTipox    := ""
Local _cAba     := "PV1"
Local _cTabela  := "Relatório Cdv"
Local _cNomArq  := "WZRCDV001"+ RetCodUsr() + StrTran( Time() , ":" , "" ) +".xls"
Local _cPath    := "C:\temp"
Local _nI       := 0
Local _Nc       := 0
Local nVinc     := 0
Local _aParam   := {}
Local _aParRet  := {}
Local _aCabec   := {}
Local _aDados   := {} 
Local _oExcel   := Nil
Local _oMsExcel := Nil
	If ApOleClient( "MSExcel" )
		AADD( _aParam  , { 1 , " Colaborador"       , _cColab        , "" , "", "PV0"     , "", 050, .T. })
		AADD( _aParam  , { 1 , " Tipo de Despesas"  , cTipox         , "" , "", "PV1TDE"  , "", 050, .T. }) //consulta específica
		AADD( _aParam  , { 2 , " Status"            , nVinc          , {"3=encerrado", "1=em aberto"}, 090 , ".T.", .T.})
        AADD(_aParam   , { 1 , " Data Inicial"      , Ctod(Space(8)) ,""  ,"" ,"" ,"" , 50, .F. })
        AADD(_aParam   , { 1 , " Data Final"        , Ctod(Space(8)) ,""  ,"" ,"" ,"" , 50, .F. })
		For _Nc := 1 To Len( _aParam )
			AADD( _aParRet , _aParam[_Nc][03] )
		Next _Nc
		If Parambox( _aParam , 'Extração em Planilha' , @_aParRet ,,, .F. ,,,,, .F. , .F. )
	        FWMsgRun( , {|| _aCabec := fHeader()             },, "Processando... ") //montagem do cabeçalho           
            FWMsgRun( , {|| _aDados := fBody(_aCabec)        },, "Processando... ") //informações do relatório
            _oExcel  := FWMSExcel():New()
        
            _oExcel:AddworkSheet( _cAba )
        
            _oExcel:AddTable( _cAba , _cTabela )
            For _nI := 1 To Len( _aCabec )
                _oExcel:AddColumn( _cAba , _cTabela , _aCabec[_nI][02] , _aCabec[_nI][05] , 1 , .F. )
            Next _nI
            For _nI := 1 To Len( _aDados )
                _oExcel:AddRow( _cAba , _cTabela , _aDados[_nI] )
            Next _nI
            If !Empty( _oExcel:aWorkSheet )
                _oExcel:Activate()
                _oExcel:GetXMLFile( _cNomArq )
        
                FWMsgRun( , {|| CpyS2T( "\SYSTEM\"+ _cNomArq , _cPath ) } ,, "Aguarde! Copiando arquivo..." )
            
                _oMsExcel := MsExcel():New()
                _oMsExcel:WorkBooks:Open( _cPath + _cNomArq ) // Abre a planilha
                _oMsExcel:SetVisible(.T.)
                _oMsExcel:Destroy()
            EndIf
		Else
			MsgStop( "Execução cancelada pelo usuário!" , "Atenção!" )
		EndIf
	Else
		MsgStop( "Microsoft Excel não instalado no computador local!" , "Atenção!" )
	EndIf
Return
/*/{Protheus.doc} fHeader
Montagem do cabeçalho do relatório
@type function
@version 25
@author Lucas Rocha Vieira
@since 23/07/2020
@return Array, 16 campos.
/*/
Static Function fHeader() 
Local _aRet := {}
    AADD( _aRet , { "PV6_CODIGO"        , "CODIGO_REEMB/PRESTC" , "C" , "" , 2 } )  
    AADD( _aRet , { "PV6_DATA"          , "DATA_REEMB/PRESTC"   , "C" , "" , 2 } )                                      
    AADD( _aRet , { "PV6_TIPO"          , "TIPO_REEMB/PRESTC"   , "C" , "" , 1 } )                                         
    AADD( _aRet , { "PV6_STATUS"        , "STATUS_REEMB/PRESTC" , "C" , "" , 1 } )
    AADD( _aRet , { "PV6_CODCOL"        , "COD_COLABORADO"      , "C" , "" , 2 } )
    AADD( _aRet , { "E2_NUM"            , "NUM_TITULO"          , "C" , "" , 1 } )
    AADD( _aRet , { "E2_VALOR"          , "VALOR_TITULO"        , "N" , PesqPict( "SE2" , "E2_VALOR" ) , 3 } )
    AADD( _aRet , { "E2_BAIXA"          , "BAIXA"               , "N" , PesqPict( "SE2" , "E2_BAIXA" ) , 3 } )
    AADD( _aRet , { "PV7.PV7_CODIGO"    , "CODIGO_ITENS"        , "C" , "" , 1 } )
    AADD( _aRet , { "PV7.PV7_ITEM"      , "ITEM_ITENS"          , "N" , "" , 1 } )
    AADD( _aRet , { "PV7.PV7_DATA"      , "DATA_RECEBER"        , "C" , "" , 2 } )
    AADD( _aRet , { "PV7.PV7_TIPDES"    , "CODIGO_DIPESAS"      , "C" , "" , 1 } )
    AADD( _aRet , { "PV7.PV7_VALOR "    , "VALOR_DEPESAS"       , "N" , PesqPict( "PV7" , "PV7_VALOR"  ) , 3 } )
    AADD( _aRet , { "PV7.PV7_VALAPR"    , "VALOR_APROVADO"      , "N" , PesqPict( "PV7" , "PV7_VALAPR" ) , 3 } )
    AADD( _aRet , { "PV7.PV7_OBS"       , "OBSERVACAO"          , "C" , "" , 2 } )
    AADD( _aRet , { "PV1.PV1_DESCRI"    , "DESCRICAO"           , "C" , "" , 2 } )
Return(_aRet)
/*/{Protheus.doc} fBody
Montagem do cabeçalho do relatório
@type function
@version 25
@author Lucas Rocha Vieira
@since 23/07/2020
@return Array, informações do relatório.
/*/
Static Function fBody(_aCabec)
Local _cAlias := GetNextAlias()
Local _cQry   := ""
Local cPeg    := ""
Local nO      := 0
local _aRet   := {} 
	_cQry:= " SELECT"
	_cQry+= " PV6_CODIGO	    AS DAD001 ,"
	_cQry+= " PV6_DATA 	        AS DAD002 ,"
	_cQry+= " PV6_TIPO 	        AS DAD003 ,"
	_cQry+= " PV6_STATUS 	    AS DAD004 ,"
	_cQry+= " PV6_CODCOL 	    AS DAD005 ,"
	_cQry+= " E2_NUM            AS DAD006 ,"
	_cQry+= " E2_VALOR   	    AS DAD007 ,"
	_cQry+= " E2_BAIXA   	    AS DAD008 ,"
	_cQry+= " PV7.PV7_CODIGO	AS DAD009 ,"
	_cQry+= " PV7.PV7_ITEM	    AS DAD010 ,"
	_cQry+= " PV7.PV7_DATA	    AS DAD011 ,"
	_cQry+= " PV7.PV7_TIPDES	AS DAD012 ,"
	_cQry+= " PV7.PV7_VALOR     AS DAD013 ,"
	_cQry+= " PV7.PV7_VALAPR    AS DAD014 ,"
	_cQry+= " PV7.PV7_OBS		AS DAD015 ,"
	_cQry+= " PV1.PV1_DESCRI    AS DAD016  "
	_cQry+= " FROM "+ RetSqlName("PV6") +" PV6 "
    _cQry+= " LEFT	JOIN "+ RetSqlName("SE2") +" SE2 ON" + RetSqlDel("SE2") +" AND SE2.E2_FILIAL  = '" + xFilial('SE2') + "' AND SE2.E2_XCDVPRE = PV6.PV6_CODIGO
    If Len( MV_PAR02) == 37 //Todos os intens de despesas estão selecionados
	    _cQry+= "   INNER JOIN "+ RetSqlName("PV7") +" PV7 ON "+ RetSqlDel("PV7") +" AND PV7.PV7_FILIAL = '" + xFilial('PV7') + "' AND PV7.PV7_CODIGO = PV6.PV6_CODIGO "
        _cQry+= "   AND	PV7.PV7_TIPDES	BETWEEN '' AND 'ZZZ'"
    Else 
        For nO := 1 To Len(MV_PAR02)
            cPeg += " " + MV_PAR02[nO] + " ," //Coloquei os espaços e vírgulas para realização da consulta (PV7_TIPDES)
        Next nO
        cPeg := SubStr(cPeg, 1, len(cPeg)-1) //Retiro a última vírgula da variável
        _cQry+= "   INNER JOIN "+ RetSqlName("PV7") +" PV7 ON "+ RetSqlDel("PV7") +" AND PV7.PV7_FILIAL = '" + xFilial('PV7') + "' AND PV7.PV7_CODIGO = PV6.PV6_CODIGO "
        _cQry+= "   AND	PV7.PV7_TIPDES IN ( "+( StrTran(cPeg, " ", "'")  )+" ) " //realizo o tratamento da varivável para a consulta
    EndIf 
    _cQry+= " LEFT  JOIN "+ RetSqlName("PV1") +" PV1 ON" + RetSqlDel("PV1") +" AND PV1.PV1_FILIAL = '" + xFilial('PV1') + "' AND PV1.PV1_CODIGO = PV7.PV7_TIPDES "
	_cQry+= "	WHERE " 
    _cQry+= "   PV6.PV6_FILIAL = '"+ xFilial('PV7') +"' " 
	_cQry+= "	AND		PV6.PV6_CODCOL  = '"+ MV_PAR01 +"' "
	_cQry+= "	AND		PV6.PV6_STATUS	= '"+ MV_PAR03 +"' "
    If !Empty(MV_PAR05)
        _cQry+= "   AND  PV6_DATENC BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' "
    EndIf
	_cQry+= "	AND		"+ RetSqlDel("PV7") 
	_cQry+= "	ORDER	BY PV6.PV6_CODIGO"
    DBUseArea( .T. , "TOPCONN" , TcGenQry(,,_cQry), _cAlias , .T. , .F.)
    DBSelectArea(_cAlias)
    (_cAlias)->(DbGoTop())
        While (_cAlias)->(!Eof() )
            AADD( _aRet,{   fTipox( (_cAlias)->DAD001 , _aCabec , 01 )   ,;
                            fTipox( (_cAlias)->DAD002 , _aCabec , 02 )   ,;
                            fTipox( (_cAlias)->DAD003 , _aCabec , 03 )   ,;
                            fTipox( (_cAlias)->DAD004 , _aCabec , 04 )   ,;
                            fTipox( (_cAlias)->DAD005 , _aCabec , 05 )   ,;
                            fTipox( (_cAlias)->DAD006 , _aCabec , 06 )   ,;
                            fTipox( (_cAlias)->DAD007 , _aCabec , 07 )   ,;
                            fTipox( (_cAlias)->DAD008 , _aCabec , 08 )   ,;
                            fTipox( (_cAlias)->DAD009 , _aCabec , 09 )   ,;
                            fTipox( (_cAlias)->DAD010 , _aCabec , 10 )   ,;
                            fTipox( (_cAlias)->DAD011 , _aCabec , 11 )   ,;
                            fTipox( (_cAlias)->DAD012 , _aCabec , 12 )   ,;
                            fTipox( (_cAlias)->DAD013 , _aCabec , 13 )   ,;
                            fTipox( (_cAlias)->DAD014 , _aCabec , 14 )   ,;
                            fTipox( (_cAlias)->DAD015 , _aCabec , 15 )   ,;
                            fTipox( (_cAlias)->DAD016 , _aCabec , 16 )   })
            (_cAlias)->( DBSkip() )
        EndDo
    (_cAlias)->(DbCloseArea())
Return( _aRet )
/*/{Protheus.doc} fTipox
Verificação do tipo de dado
@type function
@version 25
@author Lucas Rocha Vieira
@since 23/07/2020
@return _xRet, tipipagem do dado.
/*/
Static Function fTipox(_xValor , _aCabec , _nPos )
Local _xRet := Nil
    Do Case
        Case _aCabec[_nPos][03] == "C" ; _xRet := AllTrim( _xValor )//caracter
        Case _aCabec[_nPos][03] == "D" ; _xRet := DTOC( STOD( _xValor ) )//data
        Case _aCabec[_nPos][03] == "N" ; _xRet := Transform(   _xValor , _aCabec[_nPos][04] )//numero
        Case _aCabec[_nPos][03] == "B" ; _xRet := U_WZRetBox(  _xValor , _aCabec[_nPos][01] )//box
    EndCase
return(_xRet)
