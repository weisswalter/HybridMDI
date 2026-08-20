inherited frmLieferantenBestellung: TfrmLieferantenBestellung
  Caption = 'Hauptperson bestellt bei Lieferant'
  StyleElements = [seFont, seClient, seBorder]
  OnCreate = FormCreate
  ExplicitLeft = 2
  ExplicitTop = 2
  TextHeight = 15
  inherited pnlStamm: TPanel
    StyleElements = [seFont, seClient, seBorder]
    inherited pnlStammFelder: TPanel
      StyleElements = [seFont, seClient, seBorder]
      object lblLieferant: TLabel [0]
        Left = 16
        Top = 12
        Width = 46
        Height = 15
        Caption = 'Lieferant'
      end
      object lblBelegNr: TLabel [1]
        Left = 16
        Top = 64
        Width = 50
        Height = 15
        Caption = 'Beleg-Nr.'
      end
      object lblBelegDatum: TLabel [2]
        Left = 232
        Top = 64
        Width = 36
        Height = 15
        Caption = 'Datum'
      end
      object lblRechnungstyp: TLabel [3]
        Left = 16
        Top = 116
        Width = 76
        Height = 15
        Caption = 'Rechnungstyp'
      end
      object lblStatus: TLabel [4]
        Left = 232
        Top = 116
        Width = 32
        Height = 15
        Caption = 'Status'
      end
      object lblBemerkung: TLabel [5]
        Left = 16
        Top = 168
        Width = 61
        Height = 15
        Caption = 'Bemerkung'
      end
      inherited rbtnbleft: TRibbonButtonBar
        TabOrder = 6
        StyleElements = [seFont, seClient, seBorder]
      end
      object cboLieferant: TDBLookupComboBox
        Left = 16
        Top = 30
        Width = 350
        Height = 23
        DataField = 'person_id'
        DataSource = dmLieferantenBestellung.dstblBeleg
        KeyField = 'person_id'
        ListField = 'nachname_firmenname'
        ListSource = dmLieferantenBestellung.dsPersonAuswahl
        TabOrder = 0
      end
      object edtBelegNr: TDBEdit
        Left = 16
        Top = 82
        Width = 200
        Height = 23
        DataField = 'beleg_nr'
        DataSource = dmLieferantenBestellung.dstblBeleg
        TabOrder = 1
      end
      object edtBelegDatum: TDBEdit
        Left = 232
        Top = 82
        Width = 134
        Height = 23
        DataField = 'beleg_datum'
        DataSource = dmLieferantenBestellung.dstblBeleg
        TabOrder = 2
      end
      object cboRechnungstyp: TDBLookupComboBox
        Left = 16
        Top = 134
        Width = 200
        Height = 23
        DataField = 'rechnungstyp_id'
        DataSource = dmLieferantenBestellung.dstblBeleg
        KeyField = 'rechnungstyp_id'
        ListField = 'bezeichnung'
        ListSource = dmLieferantenBestellung.dsRechnungstypAuswahl
        TabOrder = 3
      end
      object cboStatus: TDBComboBox
        Left = 232
        Top = 134
        Width = 134
        Height = 23
        Style = csDropDownList
        DataField = 'status'
        DataSource = dmLieferantenBestellung.dstblBeleg
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
        DataSource = dmLieferantenBestellung.dstblBeleg
        ScrollBars = ssVertical
        TabOrder = 5
      end
    end
  end
  inherited rbnpnl1: TRibbonPanel
    StyleElements = [seFont, seClient, seBorder]
    TopPanel.StyleElements = [seFont, seClient, seBorder]
    HeaderButtons = <
      item
        Caption = 'Positionen'
      end
      item
        Caption = 'Druck'
      end>
    object tsPositionen: TTabSheet
      Caption = 'Positionen'
      object pnlPositionAdd: TPanel
        Left = 0
        Top = 419
        Width = 730
        Height = 150
        Align = alBottom
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        object lblAuswahl: TLabel
          Left = 152
          Top = 8
          Width = 84
          Height = 15
          Caption = 'Artikel/Leistung'
        end
        object lblMenge: TLabel
          Left = 152
          Top = 62
          Width = 37
          Height = 15
          Caption = 'Menge'
        end
        object lblEinzelpreis: TLabel
          Left = 260
          Top = 62
          Width = 55
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
        Width = 730
        Height = 419
        Align = alClient
        DataSource = dmLieferantenBestellung.dstblBelegPosition
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object tsDruck: TTabSheet
      Caption = 'Druck'
      object btnVisieren: TJvNavPanelButtonTop
        Left = 16
        Top = 16
        Width = 150
        Alignment = taCenter
        Caption = 'Visieren'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        OnClick = btnVisierenClick
      end
      object btnPdf: TJvNavPanelButtonTop
        Left = 180
        Top = 16
        Width = 150
        Alignment = taCenter
        Caption = 'PDF erzeugen'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        OnClick = btnPdfClick
      end
      object memDruckLog: TMemo
        Left = 0
        Top = 96
        Width = 730
        Height = 200
        Align = alBottom
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Consolas'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
  end
end
