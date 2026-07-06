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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
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
      object mnuSep2: TMenuItem
        Caption = '-'
      end
      object mnuDokumente: TMenuItem
        Caption = 'Dokumente (DB-Test)'
        OnClick = mnuDokumenteClick
      end
    end
  end
end
