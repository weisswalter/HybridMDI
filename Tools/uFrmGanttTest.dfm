object frmGanttTest: TfrmGanttTest
  Left = 0
  Top = 0
  Caption = 'Gantt - Belegungsansicht'
  ClientHeight = 560
  ClientWidth = 1100
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  Visible = True
  OnCreate = FormCreate
  TextHeight = 15
  object pnlOben: TPanel
    Left = 0
    Top = 0
    Width = 1100
    Height = 44
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object lblDatum: TLabel
      Left = 8
      Top = 14
      Width = 36
      Height = 15
      Caption = 'Datum'
    end
    object lblZoom: TLabel
      Left = 320
      Top = 14
      Width = 90
      Height = 15
      Caption = 'Zoom: 60 px/Std'
    end
    object dtpDatum: TDateTimePicker
      Left = 52
      Top = 10
      Width = 130
      Height = 23
      Date = 46000.000000000000000000
      Time = 0.000000000000000000
      TabOrder = 0
      OnChange = dtpDatumChange
    end
    object btnTagZurueck: TButton
      Left = 190
      Top = 9
      Width = 40
      Height = 25
      Caption = '<'
      TabOrder = 5
      OnClick = btnTagZurueckClick
    end
    object btnTagVor: TButton
      Left = 234
      Top = 9
      Width = 40
      Height = 25
      Caption = '>'
      TabOrder = 6
      OnClick = btnTagVorClick
    end
    object trkZoom: TTrackBar
      Left = 416
      Top = 8
      Width = 200
      Height = 30
      Max = 200
      Min = 10
      Position = 60
      TabOrder = 1
      TickStyle = tsNone
      OnChange = trkZoomChange
    end
    object btnBeispiel: TButton
      Left = 636
      Top = 8
      Width = 130
      Height = 28
      Caption = 'Beispiel laden'
      TabOrder = 2
      OnClick = btnBeispielClick
    end
    object btnBedarf: TButton
      Left = 772
      Top = 8
      Width = 150
      Height = 28
      Caption = 'Bedarf 13:00-14:30'
      TabOrder = 3
      OnClick = btnBedarfClick
    end
    object btnLeeren: TButton
      Left = 928
      Top = 8
      Width = 100
      Height = 28
      Caption = 'Leeren'
      TabOrder = 4
      OnClick = btnLeerenClick
    end
  end
  object pnlUnten: TPanel
    Left = 0
    Top = 534
    Width = 1100
    Height = 26
    Align = alBottom
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object lblStatus: TLabel
      Left = 8
      Top = 5
      Width = 3
      Height = 15
    end
  end
end
