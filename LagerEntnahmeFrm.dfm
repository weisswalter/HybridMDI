inherited frmLagerEntnahme: TfrmLagerEntnahme
  Caption = 'Lehrer reserviert/entnimmt aus Lager'
  StyleElements = [seFont, seClient, seBorder]
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  inherited pnlStamm: TPanel
    StyleElements = [seFont, seClient, seBorder]
    inherited pnlStammButtons: TPanel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited pnlStammFelder: TPanel
      StyleElements = [seFont, seClient, seBorder]
      object lblLehrer: TLabel
        Left = 16
        Top = 12
        Width = 33
        Height = 15
        Caption = 'Lehrer'
      end
      object lblBelegNr: TLabel
        Left = 16
        Top = 64
        Width = 50
        Height = 15
        Caption = 'Beleg-Nr.'
      end
      object lblBelegDatum: TLabel
        Left = 232
        Top = 64
        Width = 36
        Height = 15
        Caption = 'Datum'
      end
      object lblRechnungstyp: TLabel
        Left = 16
        Top = 116
        Width = 76
        Height = 15
        Caption = 'Rechnungstyp'
      end
      object lblStatus: TLabel
        Left = 232
        Top = 116
        Width = 32
        Height = 15
        Caption = 'Status'
      end
      object lblBemerkung: TLabel
        Left = 16
        Top = 168
        Width = 61
        Height = 15
        Caption = 'Bemerkung'
      end
      object cboLehrer: TDBLookupComboBox
        Left = 16
        Top = 30
        Width = 350
        Height = 23
        DataField = 'person_id'
        DataSource = dmLagerEntnahme.dstblBeleg
        KeyField = 'person_id'
        ListField = 'nachname_firmenname'
        ListSource = dmLagerEntnahme.dsPersonAuswahl
        TabOrder = 0
      end
      object edtBelegNr: TDBEdit
        Left = 16
        Top = 82
        Width = 200
        Height = 23
        DataField = 'beleg_nr'
        DataSource = dmLagerEntnahme.dstblBeleg
        TabOrder = 1
      end
      object edtBelegDatum: TDBEdit
        Left = 232
        Top = 82
        Width = 134
        Height = 23
        DataField = 'beleg_datum'
        DataSource = dmLagerEntnahme.dstblBeleg
        TabOrder = 2
      end
      object cboRechnungstyp: TDBLookupComboBox
        Left = 16
        Top = 134
        Width = 200
        Height = 23
        DataField = 'rechnungstyp_id'
        DataSource = dmLagerEntnahme.dstblBeleg
        KeyField = 'rechnungstyp_id'
        ListField = 'bezeichnung'
        ListSource = dmLagerEntnahme.dsRechnungstypAuswahl
        TabOrder = 3
      end
      object cboStatus: TDBComboBox
        Left = 232
        Top = 134
        Width = 134
        Height = 23
        Style = csDropDownList
        DataField = 'status'
        DataSource = dmLagerEntnahme.dstblBeleg
        Items.Strings = (
          'offen'
          'teilweise'
          'abgeschlossen'
          'storniert')
        TabOrder = 4
      end
      object memBemerkung: TDBMemo
        Left = 16
        Top = 186
        Width = 350
        Height = 150
        DataField = 'bemerkung'
        DataSource = dmLagerEntnahme.dstblBeleg
        ScrollBars = ssVertical
        TabOrder = 5
      end
    end
  end
  inherited rbnpnl1: TRibbonPanel
    StyleElements = [seFont, seClient, seBorder]
    TopPanel.StyleElements = [seFont, seClient, seBorder]
    object pnlPositionen: TPanel
      Left = 0
      Top = 31
      Width = 400
      Height = 569
      Align = alClient
      BevelOuter = bvNone
      Caption = 'pnlPositionen'
      ShowCaption = False
      TabOrder = 2
      ExplicitLeft = 88
      ExplicitTop = 232
      ExplicitWidth = 185
      ExplicitHeight = 41
      object pnlPositionAdd: TPanel
        Left = 0
        Top = 250
        Width = 400
        Height = 150
        Align = alBottom
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        object lblAuswahl: TLabel
          Left = 152
          Top = 8
          Width = 70
          Height = 15
          Caption = 'Artikel/Leistung'
        end
        object lblMenge: TLabel
          Left = 152
          Top = 62
          Width = 39
          Height = 15
          Caption = 'Menge'
        end
        object lblEinzelpreis: TLabel
          Left = 260
          Top = 62
          Width = 61
          Height = 15
          Caption = 'Einzelpreis'
        end
        object rgArt: TRadioGroup
          Left = 8
          Top = 8
          Width = 129
          Height = 84
          Caption = 'Art'
          ItemIndex = 0
          Items.Strings = (
            'Artikel'
            'Leistung')
          TabOrder = 0
          OnClick = rgArtClick
        end
        object cboAuswahl: TComboBox
          Left = 152
          Top = 26
          Width = 232
          Height = 23
          Style = csDropDown
          TabOrder = 1
        end
        object edtMenge: TEdit
          Left = 152
          Top = 80
          Width = 90
          Height = 23
          TabOrder = 2
        end
        object edtEinzelpreis: TEdit
          Left = 260
          Top = 80
          Width = 90
          Height = 23
          TabOrder = 3
        end
        object cbxRueckgabe: TCheckBox
          Left = 8
          Top = 118
          Width = 140
          Height = 17
          Caption = 'R'#252'ckgabe erwartet'
          TabOrder = 4
        end
        object btnHinzufuegen: TButton
          Left = 152
          Top = 112
          Width = 130
          Height = 25
          Caption = 'Position hinzuf'#252'gen'
          TabOrder = 5
          OnClick = btnHinzufuegenClick
        end
        object btnRueckgabeVerbuchen: TButton
          Left = 288
          Top = 112
          Width = 104
          Height = 25
          Caption = 'R'#252'ckgabe verbuchen'
          TabOrder = 6
          OnClick = btnRueckgabeVerbuchenClick
        end
      end
      object dbgrdPositionen: TDBGrid
        Left = 0
        Top = 0
        Width = 400
        Height = 250
        Align = alClient
        DataSource = dmLagerEntnahme.dstblBelegPosition
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end

  end
end
