#INCLUDE'PROTHEUS.CH'
#INCLUDE'TOPCONN.CH
#INCLUDE'TOTVS.CH'

/*/{Protheus.doc} WZCDV003
Criar tela de consulta dos tipos de despepsas
@type function
@version 25
@author Lucas Rocha Vieira
@since 23/07/2020
/*/

User Function WZCDV003()

Local nt      := 0
Local lCheck  := .T.
Local lReturn := .F.
Local _lMark  := .T.
Local _aRoti  := {}


    For nt := 1 to 37 // Array criado para listagem de marcação do checkbox
		Aadd(_aRoti, lCheck)
	Next nt

	mvRet  := Alltrim(ReadVar()) // retorno dos itens marcados (PV1TDE) 

	DEFINE DIALOG oDlg TITLE "Tipos de Despesas" FROM 180,180 TO 700,780 PIXEL

	@ 11,06   CHECKBOX oChkBox VAR _aRoti[1]  PROMPT "DIARIAS"                        SIZE 100,210 OF oDlg
	@ 21,06   CHECKBOX oChkBox VAR _aRoti[2]  PROMPT "PASSAGEM AEREA"                 SIZE 100,210 OF oDlg
	@ 31,06   CHECKBOX oChkBox VAR _aRoti[3]  PROMPT "PASSAGEM RODOVIARIA"            SIZE 100,210 OF oDlg
	@ 41,06   CHECKBOX oChkBox VAR _aRoti[4]  PROMPT "HOSPEDAGEM"                     SIZE 100,210 OF oDlg
	@ 51,06   CHECKBOX oChkBox VAR _aRoti[5]  PROMPT "TAXI EM VIAGEM"                 SIZE 100,210 OF oDlg
	@ 61,06   CHECKBOX oChkBox VAR _aRoti[6]  PROMPT "TRANSPORTE URBANO PUBLICO"      SIZE 100,210 OF oDlg
	@ 71,06   CHECKBOX oChkBox VAR _aRoti[7]  PROMPT "REFEICOES EM VIAGEM"            SIZE 100,210 OF oDlg
	@ 81,06   CHECKBOX oChkBox VAR _aRoti[8]  PROMPT "REFEICAO RAPIDA (HORAS EXTRAS)" SIZE 100,210 OF oDlg
	@ 91,06   CHECKBOX oChkBox VAR _aRoti[9]  PROMPT "ALUGUEL DE VEICULO"             SIZE 100,210 OF oDlg
	@ 101,06  CHECKBOX oChkBox VAR _aRoti[10] PROMPT "PEDAGIO"                        SIZE 100,210 OF oDlg
	@ 111,06  CHECKBOX oChkBox VAR _aRoti[11] PROMPT "COMBUSTIVEL"                    SIZE 100,210 OF oDlg
	@ 121,06  CHECKBOX oChkBox VAR _aRoti[12] PROMPT "QUILOMETRAGEM"                  SIZE 100,210 OF oDlg
	@ 131,06  CHECKBOX oChkBox VAR _aRoti[13] PROMPT "ESTACIONAMENTO"                 SIZE 100,210 OF oDlg
	@ 141,06  CHECKBOX oChkBox VAR _aRoti[14] PROMPT "REEMBOLSO DE TELEFONIA MOVEL"   SIZE 100,210 OF oDlg
	@ 151,06  CHECKBOX oChkBox VAR _aRoti[15] PROMPT "CORREIOS"                       SIZE 100,210 OF oDlg
	@ 161,06  CHECKBOX oChkBox VAR _aRoti[16] PROMPT "CARTORIO"                       SIZE 100,210 OF oDlg
	@ 171,06  CHECKBOX oChkBox VAR _aRoti[17] PROMPT "CURSOS"                         SIZE 100,210 OF oDlg
	@ 181,06  CHECKBOX oChkBox VAR _aRoti[18] PROMPT "SERV. MOTOQUEIRO"               SIZE 100,210 OF oDlg
	@ 11,160  CHECKBOX oChkBox VAR _aRoti[19] PROMPT "VERBA DE REPRESENTACAO"         SIZE 100,210 OF oDlg
	@ 21,160  CHECKBOX oChkBox VAR _aRoti[20] PROMPT "FA - ALUGUEL"                   SIZE 100,210 OF oDlg
	@ 31,160  CHECKBOX oChkBox VAR _aRoti[21] PROMPT "FA - CONDOMINIO"                SIZE 100,210 OF oDlg
	@ 41,160  CHECKBOX oChkBox VAR _aRoti[22] PROMPT "INTERNET"                       SIZE 100,210 OF oDlg
	@ 51,160  CHECKBOX oChkBox VAR _aRoti[23] PROMPT "HOMOLOGACAO"                    SIZE 100,210 OF oDlg
	@ 61,160  CHECKBOX oChkBox VAR _aRoti[24] PROMPT "MATERIAL DE USO E CONSUMO"      SIZE 100,210 OF oDlg
	@ 71,160  CHECKBOX oChkBox VAR _aRoti[25] PROMPT "MATERIAL DE ESCRITORIO"         SIZE 100,210 OF oDlg
	@ 81,160  CHECKBOX oChkBox VAR _aRoti[26] PROMPT "MATERIAL DE INFORMATICA"        SIZE 100,210 OF oDlg
	@ 91,160  CHECKBOX oChkBox VAR _aRoti[27] PROMPT "TAXI NA CIDADE DE TRABALHO"     SIZE 100,210 OF oDlg
	@ 101,160 CHECKBOX oChkBox VAR _aRoti[28] PROMPT "FA - DIVERSOS"                  SIZE 100,210 OF oDlg
	@ 111,160 CHECKBOX oChkBox VAR _aRoti[29] PROMPT "FRETES"                         SIZE 100,210 OF oDlg
	@ 121,160 CHECKBOX oChkBox VAR _aRoti[30] PROMPT "CAMPANHAS PROMOCIONAIS- BRINDE" SIZE 100,210 OF oDlg
	@ 131,160 CHECKBOX oChkBox VAR _aRoti[31] PROMPT "DESPESA C/ INTEGRACAO DE ASVEN" SIZE 100,210 OF oDlg
	@ 141,160 CHECKBOX oChkBox VAR _aRoti[32] PROMPT "CONFRATERNIZACOES"              SIZE 100,210 OF oDlg
	@ 151,160 CHECKBOX oChkBox VAR _aRoti[33] PROMPT "VIAGENS P/ AUDIENCIA JURIDICA"  SIZE 100,210 OF oDlg
	@ 161,160 CHECKBOX oChkBox VAR _aRoti[34] PROMPT "VIAGENS,HOSPEDAGEM E REEMBOLSO" SIZE 100,210 OF oDlg
	@ 171,160 CHECKBOX oChkBox VAR _aRoti[35] PROMPT "INFRA, MATERIAL E BUFFET"       SIZE 100,210 OF oDlg
	@ 181,160 CHECKBOX oChkBox VAR _aRoti[36] PROMPT "FORN. CURSOS E PALESTRANTES"    SIZE 100,210 OF oDlg
	@ 191,160 CHECKBOX oChkBox VAR _aRoti[37] PROMPT "BOLSA DE ESTUDOS"               SIZE 100,210 OF oDlg

    @ 211 , 160 Button  oBokC   Prompt "Marcar/Desmarcar"   Size 050 , 014 Of oDlg   Pixel Action fMark(@_lMark,@_aRoti,oDlg)

	DEFINE Sbutton FROM 230,60 TYPE 1 ACTION (lReturn := .T., &MvRet := fValores(_aRoti), oDlg:end()) Enable Of oDlg

    DEFINE Sbutton FROM 230,100 TYPE 2 ACTION (&MvRet := "", oDlg:end()) Enable Of oDlg

	ACTIVATE DIALOG oDlg CENTERED

Return(lReturn)

/*/{Protheus.doc} fMark
Marcar é desmarcar os tipos de despesas
@type function
@version 25
@author Lucas Rocha Vieira
@since 23/07/2020
/*/

Static Function fMark(_lMark,_aRoti,oDlg)

Local np := 0

    If _lMark == .T. 
        _lMark := .F.
    Else 
        _lMark := .T.
    EndIf

    If _lMark == .F. //DESMARCAR CHECKBOX
        For np := 1 to Len(_aRoti)
		    _aRoti[np] := .F.
	    Next np
    Else 
        For np := 1 to Len(_aRoti) 
	        _aRoti[np] := .T. //MARCAR CHECKBOX
	    Next np
    EndIf 

    oDlg:Refresh()

Return


/*/{Protheus.doc} fValores
Retorno os números de códigos de cada tipo de despesas
@type function
@version 25
@author Lucas Rocha Vieira
@since 23/07/2020
@return aReto, array com opções selecionadas.
/*/

Static Function fValores(_aRoti)

Local nx       := 0
Local aReto    := {}
Local aTipdesp := {}

	Aadd(aTipdesp, {_aRoti[1]  , StrZero(1,3) } )
	Aadd(aTipdesp, {_aRoti[2]  , StrZero(2,3) } )
	Aadd(aTipdesp, {_aRoti[3]  , StrZero(4,3) } )
	Aadd(aTipdesp, {_aRoti[4]  , StrZero(6,3) } )
	Aadd(aTipdesp, {_aRoti[5]  , StrZero(8,3) } )
	Aadd(aTipdesp, {_aRoti[6]  , StrZero(10,3)} )
	Aadd(aTipdesp, {_aRoti[7]  , StrZero(11,3)} )
	Aadd(aTipdesp, {_aRoti[8]  , StrZero(13,3)} )
	Aadd(aTipdesp, {_aRoti[9]  , StrZero(14,3)} )
	Aadd(aTipdesp, {_aRoti[10] , StrZero(16,3)} )
	Aadd(aTipdesp, {_aRoti[11] , StrZero(18,3)} )
	Aadd(aTipdesp, {_aRoti[12] , StrZero(19,3)} )
	Aadd(aTipdesp, {_aRoti[13] , StrZero(21,3)} )
	Aadd(aTipdesp, {_aRoti[14] , StrZero(22,3)} )
	Aadd(aTipdesp, {_aRoti[15] , StrZero(23,3)} )
	Aadd(aTipdesp, {_aRoti[16] , StrZero(24,3)} )
	Aadd(aTipdesp, {_aRoti[17] , StrZero(25,3)} )
	Aadd(aTipdesp, {_aRoti[18] , StrZero(26,3)} )
	Aadd(aTipdesp, {_aRoti[19] , StrZero(29,3)} )
	Aadd(aTipdesp, {_aRoti[20] , StrZero(30,3)} )
	Aadd(aTipdesp, {_aRoti[21] , StrZero(31,3)} )
	Aadd(aTipdesp, {_aRoti[22] , StrZero(32,3)} )
	Aadd(aTipdesp, {_aRoti[23] , StrZero(34,3)} )
	Aadd(aTipdesp, {_aRoti[24] , StrZero(35,3)} )
	Aadd(aTipdesp, {_aRoti[25] , StrZero(36,3)} )
	Aadd(aTipdesp, {_aRoti[26] , StrZero(37,3)} )
	Aadd(aTipdesp, {_aRoti[27] , StrZero(38,3)} )
	Aadd(aTipdesp, {_aRoti[28] , StrZero(39,3)} )
	Aadd(aTipdesp, {_aRoti[29] , StrZero(41,3)} )
	Aadd(aTipdesp, {_aRoti[30] , StrZero(42,3)} )
	Aadd(aTipdesp, {_aRoti[31] , StrZero(44,3)} )
	Aadd(aTipdesp, {_aRoti[32] , StrZero(45,3)} )
	Aadd(aTipdesp, {_aRoti[33] , StrZero(46,3)} )
	Aadd(aTipdesp, {_aRoti[34] , StrZero(47,3)} )
	Aadd(aTipdesp, {_aRoti[35] , StrZero(48,3)} )
	Aadd(aTipdesp, {_aRoti[36] , StrZero(49,3)} )
	Aadd(aTipdesp, {_aRoti[37] , StrZero(50,3)} )

	For nx := 1 to len(aTipdesp)
		If !aTipdesp[nx][1]  == .F. //Verifico quais itens estão marcados
			Aadd(aReto , aTipdesp[nx][2])
		EndIf
	Next nx

Return(aReto)
