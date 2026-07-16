object frmScanner: TfrmScanner
  Left = 0
  Top = 0
  Caption = 'Scanner  TRTHeisenberg'
  ClientHeight = 560
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  Visible = True
  OnClose = FormClose
  OnShow = FormShow
  TextHeight = 15
  object pgcScanner: TPageControl
    Left = 0
    Top = 0
    Width = 800
    Height = 560
    ActivePage = tabAuswahl
    Align = alClient
    TabOrder = 0
    OnChange = pgcScannerChange
    object tabAuswahl: TTabSheet
      Caption = 'Scannerauswahl'
      object rgTreiberart: TRadioGroup
        Left = 0
        Top = 0
        Width = 792
        Height = 57
        Align = alTop
        Caption = 'Treiberart'
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          'WIA'
          'TWAIN')
        TabOrder = 0
        OnClick = rgTreiberartClick
      end
      object pnlAuswahlTop: TPanel
        Left = 0
        Top = 57
        Width = 792
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object btnAktualisieren: TButton
          Left = 8
          Top = 6
          Width = 120
          Height = 28
          Caption = 'Aktualisieren'
          TabOrder = 0
          OnClick = btnAktualisierenClick
        end
      end
      object lstGeraete: TListBox
        Left = 0
        Top = 98
        Width = 792
        Height = 424
        Align = alClient
        ItemHeight = 15
        TabOrder = 2
      end
    end
    object tabEinstellungen: TTabSheet
      Caption = 'Einstellungen'
      ImageIndex = 1
      object rgScannerfach: TRadioGroup
        Left = 0
        Top = 0
        Width = 792
        Height = 60
        Align = alTop
        Caption = 'Scannerfach'
        TabOrder = 0
      end
      object lblFachHinweis: TLabel
        Left = 0
        Top = 60
        Width = 792
        Height = 15
        Align = alTop
        AutoSize = False
        Caption = ' '
      end
      object btnScanStart: TButton
        Left = 16
        Top = 96
        Width = 180
        Height = 36
        Caption = 'Scan starten'
        TabOrder = 0
        OnClick = btnScanStartClick
      end
    end
  end
end
