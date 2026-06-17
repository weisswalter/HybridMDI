object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'HybridMDI'
  ClientHeight = 600
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object MainMenu1: TMainMenu
    Left = 32
    Top = 32
    object mnuModule: TMenuItem
      Caption = 'Module'
      object mnuKunden: TMenuItem
        Caption = 'Kunden (Delphi)'
        OnClick = mnuKundenClick
      end
      object mnuArtikel: TMenuItem
        Caption = 'Artikel (Delphi)'
        OnClick = mnuArtikelClick
      end
      object mnuSep1: TMenuItem
        Caption = '-'
      end
      object mnuPyKunden: TMenuItem
        Caption = 'Kunden (Python)'
        OnClick = mnuPyKundenClick
      end
      object mnuPyArtikel: TMenuItem
        Caption = 'Artikel (Python)'
        OnClick = mnuPyArtikelClick
      end
    end
  end
end
