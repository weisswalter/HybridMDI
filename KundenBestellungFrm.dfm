inherited frmKundenBestellung: TfrmKundenBestellung
  Caption = 'Kunde bestellt bei Hauptperson'
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  inherited pnlStamm: TPanel
    inherited pnlStammFelder: TPanel
      object lblKunde: TLabel
        Left = 16
        Top = 12
        Width = 33
        Height = 15
        Caption = 'Kunde'
      end
      object lblBelegNr: TLabel
        Left = 16
        Top = 64
        Width = 55
        Height = 15
        Caption = 'Beleg-Nr.'
      end
      object lblBelegDatum: TLabel
        Left = 232
        Top = 64
        Width = 34
        Height = 15
        Caption = 'Datum'
      end
      object lblRechnungstyp: TLabel
        Left = 16
        Top = 116
        Width = 73
        Height = 15
        Caption = 'Rechnungstyp'
      end
      object lblStatus: TLabel
        Left = 232
        Top = 116
        Width = 33
        Height = 15
        Caption = 'Status'
      end
      object lblBemerkung: TLabel
        Left = 16
        Top = 168
        Width = 72
        Height = 15
        Caption = 'Bemerkung'
      end
      object cboKunde: TDBLookupComboBox
        Left = 16
        Top = 30
        Width = 350
        Height = 23
        DataField = 'person_id'
        DataSource = dmKundenBestellung.dstblBeleg
        KeyField = 'person_id'
        ListField = 'nachname_firmenname'
        ListSource = dmKundenBestellung.dsPersonAuswahl
        TabOrder = 0
      end
      object edtBelegNr: TDBEdit
        Left = 16
        Top = 82
        Width = 200
        Height = 23
        DataField = 'beleg_nr'
        DataSource = dmKundenBestellung.dstblBeleg
        TabOrder = 1
      end
      object edtBelegDatum: TDBEdit
        Left = 232
        Top = 82
        Width = 134
        Height = 23
        DataField = 'beleg_datum'
        DataSource = dmKundenBestellung.dstblBeleg
        TabOrder = 2
      end
      object cboRechnungstyp: TDBLookupComboBox
        Left = 16
        Top = 134
        Width = 200
        Height = 23
        DataField = 'rechnungstyp_id'
        DataSource = dmKundenBestellung.dstblBeleg
        KeyField = 'rechnungstyp_id'
        ListField = 'bezeichnung'
        ListSource = dmKundenBestellung.dsRechnungstypAuswahl
        TabOrder = 3
      end
      object cboStatus: TDBComboBox
        Left = 232
        Top = 134
        Width = 134
        Height = 23
        DataField = 'status'
        DataSource = dmKundenBestellung.dstblBeleg
        Style = csDropDownList
        ItemHeight = 15
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
        DataSource = dmKundenBestellung.dstblBeleg
        ScrollBars = ssVertical
        TabOrder = 5
      end
    end
  end
  inherited JvRibbonPanel1: TJvRibbonPanel
    Headers = <
      item
        Caption = 'Positionen'
        Width = 110
        Actions = ActionListRechts
        Buttons = <
          item
            Action = actErsterR
          end
          item
            Action = actZurueckR
          end
          item
            Action = actWeiterR
          end
          item
            Action = actLetzterR
          end
          item
            Action = actNeuR
          end
          item
            Action = actAendernR
          end
          item
            Action = actSpeichernR
          end
          item
            Action = actAbbrechenR
          end
          item
            Action = actNeuLadenR
          end>
        ContentPanel = pnlPositionen
      end>
    ActivePageIndex = 0
  end
  object pnlPositionen: TPanel
    Left = 8
    Top = 624
    Width = 400
    Height = 400
    BevelOuter = bvNone
    Caption = 'pnlPositionen'
    ShowCaption = False
    TabOrder = 2
    Visible = False
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
      object btnHinzufuegen: TButton
        Left = 152
        Top = 112
        Width = 200
        Height = 25
        Caption = 'Position hinzuf'#252'gen'
        TabOrder = 4
        OnClick = btnHinzufuegenClick
      end
    end
    object dbgrdPositionen: TDBGrid
      Left = 0
      Top = 0
      Width = 400
      Height = 250
      Align = alClient
      DataSource = dmKundenBestellung.dstblBelegPosition
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
end
