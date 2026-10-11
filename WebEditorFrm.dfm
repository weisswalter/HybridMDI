inherited frmWebEditor: TfrmWebEditor
  Caption = 'Webinhalte bearbeiten'
  ClientHeight = 700
  ClientWidth = 1100
  StyleElements = [seFont, seClient, seBorder]
  OnCreate = FormCreate
  ExplicitLeft = 3
  ExplicitTop = 3
  ExplicitWidth = 1116
  ExplicitHeight = 739
  TextHeight = 15
  inherited Splitter1: TSplitter
    Height = 700
    ExplicitHeight = 700
  end
  inherited pnlStamm: TPanel
    Height = 700
    StyleElements = [seFont, seClient, seBorder]
    ExplicitHeight = 692
    inherited pnlStammFelder: TPanel
      Height = 700
      StyleElements = [seFont, seClient, seBorder]
      ExplicitHeight = 692
      object lblBezeichnung: TLabel [0]
        Left = 8
        Top = 528
        Width = 68
        Height = 15
        Caption = 'Bezeichnung'
      end
      inherited rbtnbleft: TRibbonButtonBar
        TabOrder = 3
        StyleElements = [seFont, seClient, seBorder]
      end
      object cboSprache: TComboBox
        Left = 0
        Top = 48
        Width = 313
        Height = 23
        Align = alTop
        Style = csDropDownList
        TabOrder = 0
        OnChange = cboSpracheChange
      end
      object dbgrdNavbar: TDBGrid
        Left = 0
        Top = 71
        Width = 313
        Height = 629
        Align = alClient
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
        OnCellClick = dbgrdNavbarCellClick
      end
      object edtBezeichnung: TDBEdit
        Left = 8
        Top = 546
        Width = 297
        Height = 23
        TabOrder = 2
      end
    end
  end
  inherited rbnpnl1: TRibbonPanel
    Width = 782
    Height = 700
    StyleElements = [seFont, seClient, seBorder]
    TopPanel.Width = 782
    TopPanel.StyleElements = [seFont, seClient, seBorder]
    TopPanel.ExplicitWidth = 780
    HeaderButtons = <
      item
        Caption = 'Karten'
      end
      item
        Caption = 'Vorschau'
      end
      item
        Caption = 'HTML'
      end>
    ActivePageIndex = 1
    OnButtonClick = rbnpnl1ButtonClick
    ExplicitWidth = 780
    ExplicitHeight = 692
    object tsKarten: TTabSheet
      Caption = 'Karten'
      object dbgrdKarten: TDBGrid
        Left = 0
        Top = 0
        Width = 782
        Height = 220
        Align = alTop
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
      object pnlKartenEdit: TPanel
        Left = 0
        Top = 220
        Width = 782
        Height = 449
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        ExplicitWidth = 780
        ExplicitHeight = 441
        object lblTitel: TLabel
          Left = 16
          Top = 12
          Width = 23
          Height = 15
          Caption = 'Titel'
        end
        object lblText: TLabel
          Left = 16
          Top = 64
          Width = 21
          Height = 15
          Caption = 'Text'
        end
        object lblGruppe: TLabel
          Left = 440
          Top = 12
          Width = 39
          Height = 15
          Caption = 'Gruppe'
        end
        object lblZielSlug: TLabel
          Left = 440
          Top = 64
          Width = 42
          Height = 15
          Caption = 'ZielSlug'
        end
        object edtTitel: TDBEdit
          Left = 16
          Top = 30
          Width = 400
          Height = 23
          TabOrder = 0
        end
        object memText: TDBMemo
          Left = 16
          Top = 82
          Width = 400
          Height = 150
          ScrollBars = ssVertical
          TabOrder = 1
        end
        object edtGruppe: TDBEdit
          Left = 440
          Top = 30
          Width = 250
          Height = 23
          TabOrder = 2
        end
        object edtZielSlug: TDBEdit
          Left = 440
          Top = 82
          Width = 250
          Height = 23
          TabOrder = 3
        end
        object chkKarteAktiv: TDBCheckBox
          Left = 16
          Top = 246
          Width = 97
          Height = 17
          Caption = 'Aktiv'
          DataField = 'aktiv'
          TabOrder = 4
          ValueChecked = 'True'
          ValueUnchecked = 'False'
        end
        object btnKarteNeu: TButton
          Left = 16
          Top = 280
          Width = 100
          Height = 25
          Caption = 'Neu'
          TabOrder = 5
          OnClick = btnKarteNeuClick
        end
        object btnKarteSpeichern: TButton
          Left = 122
          Top = 280
          Width = 100
          Height = 25
          Caption = 'Speichern'
          TabOrder = 6
          OnClick = btnKarteSpeichernClick
        end
        object btnKarteAbbrechen: TButton
          Left = 228
          Top = 280
          Width = 100
          Height = 25
          Caption = 'Abbrechen'
          TabOrder = 7
          OnClick = btnKarteAbbrechenClick
        end
        object btnKarteLoeschen: TButton
          Left = 334
          Top = 280
          Width = 100
          Height = 25
          Caption = 'L'#246'schen'
          TabOrder = 8
          OnClick = btnKarteLoeschenClick
        end
      end
    end
    object tsVorschau: TTabSheet
      Caption = 'Vorschau'
      ImageIndex = 1
      object pnlVorschauTop: TPanel
        Left = 0
        Top = 0
        Width = 782
        Height = 33
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object btnVorschauAktualisieren: TButton
          Left = 8
          Top = 4
          Width = 140
          Height = 25
          Caption = 'Aktualisieren'
          TabOrder = 0
          OnClick = btnVorschauAktualisierenClick
        end
      end
      object BrowserVorschau: TEdgeBrowser
        Left = 0
        Top = 33
        Width = 782
        Height = 636
        Align = alClient
        TabOrder = 1
        AllowSingleSignOnUsingOSPrimaryAccount = False
        TargetCompatibleBrowserVersion = '137.0.3296.44'
        UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
      end
    end
    object tsHtml: TTabSheet
      Caption = 'HTML'
      ImageIndex = 2
      object pnlHtmlTop: TPanel
        Left = 0
        Top = 0
        Width = 784
        Height = 33
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblHtmlHinweis: TLabel
          Left = 160
          Top = 9
          Width = 3
          Height = 15
        end
        object btnHtmlSpeichern: TButton
          Left = 8
          Top = 4
          Width = 140
          Height = 25
          Caption = 'Speichern'
          TabOrder = 0
          OnClick = btnHtmlSpeichernClick
        end
      end
      object BrowserHtml: TEdgeBrowser
        Left = 0
        Top = 33
        Width = 784
        Height = 639
        Align = alClient
        TabOrder = 1
        AllowSingleSignOnUsingOSPrimaryAccount = False
        TargetCompatibleBrowserVersion = '137.0.3296.44'
        UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
        OnExecuteScript = BrowserHtmlExecuteScript
      end
    end
  end
  inherited ilst16: TJvImageList
    Left = 248
  end
  inherited ilst32: TJvImageList
    Left = 232
    Top = 152
  end
end
