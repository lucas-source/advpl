#INCLUDE"TOTVS.CH"

/*
Autor: Lucas Rocha Vieira
*/

User Function fxImport()

Local cArq       := ''
Local nTipo      := 0
Local aReceb     := {}

    aAdd(aReceb, {5, .T., {|| cArq  := fGetFile()      } } )
    aAdd(aReceb, {1, .T., {|| nTipo := 1, FechaBatch() } } )
    aAdd(aReceb, {2, .T., {|| FechaBatch()             } } )

    FormBatch( "Importação do contas a pagar", {"O objetivo desta rotina é fazer importação de titulos no contas a pagar."}, aReceb )

    If nTipo == 1

        If Empty( cArq ) 
            cArq := fGetFile()
        EndIf

        Processa( {|| fGear( cArq ) }, "Processando..." )

    Endif

Return Nil

/* função */
Static function fGetFile()
Return cGetFile("Arquivo TXT | *.txt","Selecione o arquivo",,"",.T.)

/* função */
Static Function fGear( cArq )

Local cLinha   := ""
Local _cErro   := ""
Local nI       := 0
Local nP       := 0
Local nCont    := 0
Local aDados   := {}
Local aErro    := {}
Local aCarrega := {}
Local lValid   := .T.

Public nOok     := 0

    If !file(cArq)
        MsgAlert("Arquivo " + cArq + "não localizado!", "Atenção")
        Return(.F.)
    EndIf 

    //ABRINDO O ARQUIVO
    FT_FUSE(cArq)
    FT_FGOTOP()
    ProcRegua(FT_FLASTREC()) 

    //Tabelas de validacao
    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))//CODIGO + LOJA

    DbSelectArea("SED")
    SED->(DbSetOrder(1))//CODIGO

    DbSelectArea("SE2")
    SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
    
    While !FT_FEOF() 

        IncProc()

        cLinha := FT_FREADLN()
        aDados := Separa(cLinha, ";")

        If aDados[1] <> "E2_PREFIXO"

            nCont++
            //Funcao de validação
            lValid := fValidando(aDados, aErro)
            
            If lValid 

                aAdd( aCarrega, {   aDados[01] ,;
                                    aDados[02] ,;
                                    aDados[03] ,;
                                    aDados[04] ,;
                                    aDados[05] ,;
                                    aDados[06] ,;
                                    aDados[07] ,;
                                    aDados[08] ,;
                                    aDados[09] ,;
                                    aDados[10] ,;
                                    aDados[11] ,;    
                                    aDados[12] ,;
                                    aDados[13] })

            EndIf 

        EndIf

        FT_FSKIP()

    EndDo 

    //fechando tabelas abertas
    SA2->(DbCloseArea())
    SED->(DbCloseArea())

    //fechando o arquivo
    FT_FUSE()

    If Len( aCarrega ) == nCont  
        
        For nI := 1 To Len( aCarrega )
            //Função para incluir
            fIncluindo( aCarrega[nI] )
        Next nI

    Else

        For nP := 1 to len(aErro)
            _cErro += AllTrim(aErro[nP]) + CRLF 
        Next np

        nOok++
        MsgInfo( _cErro , "Atenção" )

    EndIf

    SE2->(DbCloseArea())

    If nOok == 0 
        MsgInfo("Importação concluída com sucesso!", "Atenção")
    Else 
        Alert("Não foi possível concluir a importação completa!", "Atenção")
    EndIf 

Return 

/* função */
Static function fIncluindo(aCarrega)

Local   aTitutlo    := {}
Private lMsErroAuto := .F.


    aTitutlo := {   { "E2_PREFIXO" ,  aCarrega[01]        , NIL },;
                    { "E2_NUM"     ,  aCarrega[02]        , NIL },;
                    { "E2_TIPO"    ,  aCarrega[03]        , NIL },;
                    { "E2_PARCELA" ,  aCarrega[04]        , NIL },;
                    { "E2_NATUREZ" ,  aCarrega[05]        , NIL },;
                    { "E2_FORNECE" ,  aCarrega[06]        , NIL },;
                    { "E2_CCD"     ,  aCarrega[07]        , NIL },;
                    { "E2_LOJA"    ,  aCarrega[08]        , NIL },;
                    { "E2_HIST"    ,  aCarrega[09]        , NIL },;
                    { "E2_EMISSAO" ,  cTod(aCarrega[10])  , NIL },;
                    { "E2_VENCTO"  ,  cTod(aCarrega[11])  , NIL },;
                    { "E2_VENCREA" ,  cTod(aCarrega[12])  , NIL },;
                    { "E2_VALOR"   ,  Val(aCarrega[13])   , NIL }}
 
    MsExecAuto( { |x,y,z| FINA050(x,y,z)},aTitutlo,,3) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
 
    If lMsErroAuto
        nOok++
        MostraErro()
    Endif

Return

/* função */
Static Function fValidando(aDados, aErro)

Local _lGet := .T.

    //Validando fornecedor
    IF !( SA2->(DbSeek(XFilial("SA2") + AllTrim(aDados[6]))))
        aAdd( aErro , "Fornecedor não localizado Cnpj/Cpf: " + Alltrim( aDados[6] ) ) 
        _lGet := .F.
    EndIf

    //Validando a natureza
    IF !( SED->(DbSeek(XFilial("SED") + AllTrim(aDados[5]) )) )
        aAdd( aErro , "Natureza não localizada: " + Alltrim( aDados[5] ) ) 
        _lGet := .F.
    EndIf

        //Validando o contas a pagar
    IF  SE2->(DbSeek(XFilial("SE2") + aDados[1] + aDados[2] )) 
        aAdd( aErro , "Titulo no contas a pagar já existe!: " + Alltrim( aDados[2] ) ) 
        _lGet := .F.
    EndIf

Return(_lGet)
