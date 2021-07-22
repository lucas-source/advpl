#INCLUDE'TOTVS.CH'

/**************************************************************************************************
{Protheus.doc} BizgFat
@description	Fluxo completo do pedido de compra no modulo Faturamento
@type   		Class	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		05/04/2021
@database		05/04/2021
@country		Brasil
@language		PT-BR
@obs			05/04/2021 - Controle de documentacao
*****************************************************************************************************/
Class BizgFat

    Data _cImg1   As String
    Data _cImg2   As String
    Data cSetaRht As String
    Data cSetaDwn As String
    Data cPc      As String
    Data cDoc     As String
    Data cliv     As String
    Data cSe1     As String
    Data cMov     As String

    Method New() CONSTRUCTOR

    Method Struct()
    Method validation()
    Method Box()

EndClass 

/**************************************************************************************************
{Protheus.doc} BizgFat::New
@description	Construtor da classe
@type   		Method	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		05/04/2021
@database		05/04/2021
@country		Brasil
@language		PT-BR
@obs			05/04/2021 - Controle de documentacao
*****************************************************************************************************/
Method New() class BizgFat

    SELF:_cImg1    := "C:\Temp\h.jpg"  //Img. Azul
    SELF:_cImg2    := "C:\Temp\c.jpg"  //Img. Verde
    SELF:cSetaRht  := "C:\Temp\g.jpg"  //Img. Seta para direita
    SELF:cSetaDwn  := "C:\Temp\i.jpg"  //Img. Seta para baixo
    SELF:cPc       := SELF:_cImg1      //Pedido de compra
    SELF:cDoc      := SELF:_cImg1      //Documento de saida
    SELF:cliv      := SELF:_cImg1      //Livros fiscais 
    SELF:cSe1      := SELF:_cImg1      //Contas a pagar
    SELF:cMov      := SELF:_cImg1      //Movimento bancário

Return(Self)

/**************************************************************************************************
{Protheus.doc}  BizgFat::Struct
@description	Parambox do pedido de compra
@type   		Method	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		05/04/2021
@database		05/04/2021
@country		Brasil
@language		PT-BR
@obs			05/04/2021 - Controle de documentacao
*****************************************************************************************************/
Method Struct() Class BizgFat 

Local _aParam  := {}
Local _cPedido := Space(TamSX3('C5_NUM')[01])


    AADD(_aParam, {1, " Pedido de venda", _cPedido, "", "", "SC5", "", 050, .T.})

    If ParamBox(_aParam, "Informe os parâmetros")

        DBSelectArea("SC5")  //PEDIDO DE COMPRA
	    SC5->( DBSetOrder(1) ) //SC5_FILIAL+C5_NUM
	    If	SC5->( DBSeek( xFilial('SC5') + MV_PAR01 ) )
            SC5->( DbCloseArea() )
            FWMsgRun( , {|| self:validation()  },, "Processando... ")
        Else 
            MsgStop("Nao localizado o pedido de venda", "Atenção")
        EndIf 

	Else
		MsgStop( "Execução cancelada pelo usuário!" , "Atenção!" )
	EndIf

Return 

/**************************************************************************************************
{Protheus.doc} BizgFat::validation
@description	Validacao de todo o fluxo do pedido dentro das rotinas
@type   		Method	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		05/04/2021
@database		05/04/2021
@country		Brasil
@language		PT-BR
@obs			05/04/2021 - Controle de documentacao
*****************************************************************************************************/
Method validation() class BizgFat

    DBSelectArea("SC6")    //ITENS DO P.COMPRA
	SC6->( DBSetOrder(1) ) // C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO
	If SC6->( DBSeek( xFilial("SC6") + MV_PAR01 ) )
        SELF:cPc := SELF:_cImg2
    EndIf 
    
    If !Empty(SC6->(C6_NOTA)) 

        DbSelectArea("SF2")  //DOCUMENTO DE SAIDA
        SF2->( DbSetOrder(1) ) // F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL
        If SF2->(DbSeek(xFilial("SF2")+ SC6->(C6_NOTA) + SC6->(C6_SERIE) + SC6->(C6_CLI) + SC6->(C6_LOJA) )	)
            SELF:cDoc := SELF:_cImg2
        EndIf

        DbSelectArea("SE1") //CONTAS A RECEBER
        SE1->( DbSetOrder(1) )// E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
        If SE1->( DBSeek( xFilial("SE1") + SF2->(F2_SERIE) + SF2->(F2_DOC) ) )
            SELF:cSe1 := SELF:_cImg2

            DbSelectArea("SE5") //MOVIMENTO BANCARIA 
            SE5->( DbSetOrder(7) )//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
			If SE5->(DbSeek( xFilial("SE5") + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ) )
                SELF:cMov := SELF:_cImg2
            EndIf 

        EndIf

        DBSelectArea("SF3")  //LIVROS FISCAIS
        SF3->( DbSetOrder(6) ) //F3_FILIAL + F3_NFISCAL + F3_SERIE
        If SF3->(DbSeek( xFilial("SF3") + SF2->(F2_DOC + F2_SERIE) ))
            SELF:cliv := SELF:_cImg2
        EndIf 

        SF2->( DbCLoseArea() )
        SE5->( DbCLoseArea() )
        SE1->( DbCLoseArea() )
        SF3->( DbCLoseArea() )

    EndIf

    SC6->( DbCloseArea() )

    Self:Box()

Return 

/**************************************************************************************************
{Protheus.doc} BizgFat::Box
@description	Plota o fluxo do pedido de compra
@type   		Method	
@author			Lucas Rocha Vieira
@version   		1.00
@since     		05/04/2021
@database		05/04/2021
@country		Brasil
@language		PT-BR
@obs			05/04/2021 - Controle de documentacao
*****************************************************************************************************/
Method Box() class BizgFat

    Local oBitmap   := Nil
    Local oDlg      := Nil 
    Local oBokC     := Nil

    DEFINE DIALOG oDlg TITLE "Modulo faturamento" FROM 100,110 TO 600,900 PIXEL

    //SE5 
    @ 010, 050 BITMAP oBitmap SIZE 100, 120 OF oDlg NOBORDER FILENAME Self:cPc PIXEL
    @ 065, 050 SAY "Pedido de compra" SIZE 200,011 OF oDlg PIXEL COLOR CLR_BLACK
    //SETA R
    @ 015, 113 BITMAP oBitmap SIZE 090, 050 OF oDlg NOBORDER FILENAME Self:cSetaRht PIXEL
    //SF2
    @ 010, 150 BITMAP oBitmap SIZE 100, 120 OF oDlg NOBORDER FILENAME Self:cDoc PIXEL
    @ 065, 157 SAY "Notas fis. entrada" SIZE 200,011 OF oDlg PIXEL COLOR CLR_BLACK
    //SETA R
    @ 015, 213 BITMAP oBitmap SIZE 090, 050 OF oDlg NOBORDER FILENAME Self:cSetaRht PIXEL
    //SF3
    @ 010, 250 BITMAP oBitmap SIZE 100, 120 OF oDlg NOBORDER FILENAME Self:cliv PIXEL
    @ 065, 260 SAY "Livros fiscais" SIZE 200,011 OF oDlg PIXEL COLOR CLR_BLACK
    //SETA D
    @ 90, 163 BITMAP oBitmap SIZE 090, 050 OF oDlg NOBORDER FILENAME Self:cSetaDwn PIXEL
    //SE1
    @ 130, 150 BITMAP oBitmap SIZE 100, 120 OF oDlg NOBORDER FILENAME Self:cSe1 PIXEL
    @ 185, 159 SAY "Contas a receber" SIZE 200,011 OF oDlg PIXEL COLOR CLR_BLACK
    //SETA R
    @ 135, 213 BITMAP oBitmap SIZE 090, 050 OF oDlg NOBORDER FILENAME Self:cSetaRht PIXEL
    //SE5
    @ 130, 250 BITMAP oBitmap SIZE 100, 120 OF oDlg NOBORDER FILENAME Self:cMov PIXEL
    @ 185, 251 SAY "Movimentos bancários" SIZE 200,011 OF oDlg PIXEL COLOR CLR_BLACK
    //BOTAO DE FINALIZAR
    @ 230, 160 Button oBokC Prompt "Fechar" Size 030 , 014 Of oDlg Pixel Action oDlg:End()

    ACTIVATE DIALOG oDlg CENTERED

Return
