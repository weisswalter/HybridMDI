object frmDokumente: TfrmDokumente
  Left = 0
  Top = 0
  Caption = 'Dokumentenverwaltung '#226#8364#8221' TRTHeisenberg'
  ClientHeight = 560
  ClientWidth = 820
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  Visible = True
  OnClose = FormClose
  TextHeight = 15
  object pgcDokumente: TPageControl
    Left = 0
    Top = 0
    Width = 820
    Height = 560
    ActivePage = tabDokumente
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 818
    ExplicitHeight = 552
    object tabDokumente: TTabSheet
      Caption = 'Dokumente'
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 812
        Height = 40
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 810
        object lblHinweis: TLabel
          Left = 380
          Top = 10
          Width = 392
          Height = 13
          Caption = 
            #195#8222'nderungen hier '#226#8224#8217' Navigator Post '#226#8224#8217' Blazor-Seite neu laden z' +
            'um Pr'#195#188'fen'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGrayText
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object navDokumente: TJvDBNavigator
          Left = 4
          Top = 6
          Width = 360
          Height = 28
          TabOrder = 0
        end
      end
      object pnlGrid: TPanel
        Left = 0
        Top = 40
        Width = 812
        Height = 220
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        ExplicitWidth = 810
        object grdDokumente: TDBGrid
          Left = 0
          Top = 0
          Width = 812
          Height = 220
          Align = alClient
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
      object pnlMemo: TPanel
        Left = 0
        Top = 260
        Width = 812
        Height = 270
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 2
        ExplicitWidth = 810
        ExplicitHeight = 262
        object lblOcrText: TLabel
          Left = 4
          Top = 4
          Width = 100
          Height = 15
          Caption = 'OCR-Text / Inhalt:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object mmoOcrText: TDBMemo
          Left = 0
          Top = 30
          Width = 812
          Height = 240
          Align = alBottom
          ScrollBars = ssBoth
          TabOrder = 0
          WordWrap = False
          ExplicitTop = 22
          ExplicitWidth = 810
        end
      end
    end
  end
end
