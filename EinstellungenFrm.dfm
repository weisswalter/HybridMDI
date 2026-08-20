object frmEinstellungen: TfrmEinstellungen
  Left = 0
  Top = 0
  Caption = 'Einstellungen'
  ClientHeight = 650
  ClientWidth = 1000
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
  object JvRibbonPanel1: TRibbonPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 650
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    ActiveTheme = nptXPBlue
    InactiveTheme = nptXPSilver
    HeaderButtons = <
      item
        Caption = 'Personentyp'
        Width = 115
      end
      item
        Caption = 'Rollentyp'
        Width = 100
      end
      item
        Caption = 'Adressentyp'
        Width = 115
      end
      item
        Caption = 'Emailtyp'
        Width = 95
      end
      item
        Caption = 'Telefonnummertyp'
        Width = 160
      end
      item
        Caption = 'Rechnungstyp'
        Width = 125
      end
      item
        Caption = 'Lead-Quelle'
        Width = 115
      end
      item
        Caption = 'Kompetenztyp'
        Width = 130
      end
      item
        Caption = 'Artikelkategorie'
        Width = 155
      end
      item
        Caption = 'Website'
        Width = 100
      end>
    object tsPersonentyp: TTabSheet
      Caption = 'Personentyp'
      object barPersonentyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end
          item
            Action = actLoeschen
            Width = 90
          end>
      end
      object pnlPersonentyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlPersonentyp'
        ShowCaption = False
        TabOrder = 1
        object dbgrdPersonentyp: TDBGrid
          Left = 0
          Top = 0
          Width = 400
          Height = 300
          Align = alClient
          DataSource = dmEinstellungen.dstblPersonentyp
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsRollentyp: TTabSheet
      Caption = 'Rollentyp'
      object barRollentyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end
          item
            Action = actLoeschen
            Width = 90
          end>
      end
      object pnlRollentyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlRollentyp'
        ShowCaption = False
        TabOrder = 2
        object dbgrdRollentyp: TDBGrid
          Left = 0
          Top = 0
          Width = 400
          Height = 300
          Align = alClient
          DataSource = dmEinstellungen.dstblRollentyp
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsAdressentyp: TTabSheet
      Caption = 'Adressentyp'
      object barAdressentyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end
          item
            Action = actLoeschen
            Width = 90
          end>
      end
      object pnlAdressentyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlAdressentyp'
        ShowCaption = False
        TabOrder = 3
        object dbgrdAdressentyp: TDBGrid
          Left = 0
          Top = 0
          Width = 400
          Height = 300
          Align = alClient
          DataSource = dmEinstellungen.dstblAdressentyp
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsEmailtyp: TTabSheet
      Caption = 'Emailtyp'
      object barEmailtyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end
          item
            Action = actLoeschen
            Width = 90
          end>
      end
      object pnlEmailtyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlEmailtyp'
        ShowCaption = False
        TabOrder = 4
        object dbgrdEmailtyp: TDBGrid
          Left = 0
          Top = 0
          Width = 400
          Height = 300
          Align = alClient
          DataSource = dmEinstellungen.dstblEmailtyp
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsTelefonnummertyp: TTabSheet
      Caption = 'Telefonnummertyp'
      object barTelefonnummertyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end
          item
            Action = actLoeschen
            Width = 90
          end>
      end
      object pnlTelefonnummertyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlTelefonnummertyp'
        ShowCaption = False
        TabOrder = 5
        object dbgrdTelefonnummertyp: TDBGrid
          Left = 0
          Top = 0
          Width = 400
          Height = 300
          Align = alClient
          DataSource = dmEinstellungen.dstblTelefonnummertyp
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsRechnungstyp: TTabSheet
      Caption = 'Rechnungstyp'
      object barRechnungstyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end
          item
            Action = actLoeschen
            Width = 90
          end>
      end
      object pnlRechnungstyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlRechnungstyp'
        ShowCaption = False
        TabOrder = 6
        object dbgrdRechnungstyp: TDBGrid
          Left = 0
          Top = 0
          Width = 400
          Height = 300
          Align = alClient
          DataSource = dmEinstellungen.dstblRechnungstyp
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsLeadquellentyp: TTabSheet
      Caption = 'Lead-Quelle'
      object barLeadquellentyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end
          item
            Action = actLoeschen
            Width = 90
          end>
      end
      object pnlLeadquellentyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlLeadquellentyp'
        ShowCaption = False
        TabOrder = 7
        object dbgrdLeadquellentyp: TDBGrid
          Left = 0
          Top = 0
          Width = 400
          Height = 300
          Align = alClient
          DataSource = dmEinstellungen.dstblLeadquellentyp
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsKompetenztyp: TTabSheet
      Caption = 'Kompetenztyp'
      object barKompetenztyp: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end
          item
            Action = actLoeschen
            Width = 90
          end>
      end
      object pnlKompetenztyp: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlKompetenztyp'
        ShowCaption = False
        TabOrder = 8
        object pnlKompetenzHinweis: TPanel
          Left = 0
          Top = 0
          Width = 1000
          Height = 46
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblKompetenzHinweis: TLabel
            Left = 4
            Top = 2
            Width = 990
            Height = 42
            AutoSize = False
            Caption =
              'G'#252'ltigkeit in Monaten: leer = l'#228'uft nie ab. Viele Nachweise (z. B' +
              '. Nothelfer, Staplerausweis) verfallen - dann hier die Dauer eint' +
              'ragen, damit abgelaufene Kompetenzen auffallen.'
            WordWrap = True
          end
        end
        object dbgrdKompetenztyp: TDBGrid
          Left = 0
          Top = 46
          Width = 400
          Height = 300
          Align = alClient
          DataSource = dmEinstellungen.dstblKompetenztyp
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object tsKategorie: TTabSheet
      Caption = 'Artikelkategorie'
      object barKategorie: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actNeu
          end
          item
            Action = actSpeichern
            Width = 90
          end
          item
            Action = actAbbrechen
            Width = 90
          end
          item
            Action = actLoeschen
            Width = 90
          end>
      end
      object pnlKategorie: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 9
        object pnlKategorieHinweis: TPanel
          Left = 0
          Top = 0
          Width = 1000
          Height = 46
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblKategorieHinweis: TLabel
            Left = 4
            Top = 2
            Width = 990
            Height = 42
            AutoSize = False
            Caption = 
              'Ein Artikel kann in mehreren Kategorien liegen; die Zuordnung ge' +
              'schieht im Artikelstamm links. Wird eine Kategorie nicht mehr ge' +
              'braucht, den Haken bei aktiv wegnehmen statt zu loeschen - dann ' +
              'bleiben bestehende Zuordnungen lesbar.'
            WordWrap = True
          end
        end
        object dbgrdKategorie: TDBGrid
          Left = 0
          Top = 46
          Width = 400
          Height = 300
          Align = alClient
          DataSource = dmEinstellungen.dstblKategorie
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          Columns = <
            item
              Expanded = False
              FieldName = 'bezeichnung'
              Title.Caption = 'Bezeichnung'
              Width = 200
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'beschreibung'
              Title.Caption = 'Beschreibung'
              Width = 320
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'sortierung'
              Title.Caption = 'Reihenfolge'
              Width = 80
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'aktiv'
              Title.Caption = 'Aktiv'
              Width = 50
              Visible = True
            end>
        end
      end
    end
    object tsWebsite: TTabSheet
      Caption = 'Website'
      object barWebsite: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 1000
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actSpeichern
            Width = 90
          end>
      end
      object pnlWebsite: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 10
        object lblWebsiteHinweis: TLabel
          Left = 8
          Top = 4
          Width = 900
          Height = 44
          AutoSize = False
          Caption = 
            'Diese Angaben gelten f'#252'r die Website dieses Mandanten. Sie stehe' +
            'n in der Datenbank, nicht in einer Datei auf dem Server - eine '  +
            #196'nderung wirkt beim n'#228'chsten Seitenaufruf, ohne Neustart.'
          WordWrap = True
        end
        object chkShopAktiv: TCheckBox
          Left = 8
          Top = 56
          Width = 400
          Height = 17
          Caption = 'Shop auf der Website anzeigen'
          TabOrder = 0
        end
        object lblWaehrung: TLabel
          Left = 8
          Top = 88
          Width = 200
          Height = 15
          Caption = 'W'#228'hrung (z. B. EUR)'
        end
        object edtWaehrung: TEdit
          Left = 220
          Top = 85
          Width = 80
          Height = 23
          TabOrder = 1
        end
        object lblMwst: TLabel
          Left = 8
          Top = 120
          Width = 200
          Height = 15
          Caption = 'Mehrwertsteuer in Prozent'
        end
        object edtMwst: TEdit
          Left = 220
          Top = 117
          Width = 80
          Height = 23
          TabOrder = 2
        end
        object lblVersand: TLabel
          Left = 8
          Top = 152
          Width = 200
          Height = 15
          Caption = 'Versandkosten'
        end
        object edtVersand: TEdit
          Left = 220
          Top = 149
          Width = 80
          Height = 23
          TabOrder = 3
        end
        object lblVersandFrei: TLabel
          Left = 8
          Top = 184
          Width = 200
          Height = 15
          Caption = 'Versandfrei ab Warenwert'
        end
        object edtVersandFrei: TEdit
          Left = 220
          Top = 181
          Width = 80
          Height = 23
          TabOrder = 4
        end
      end
    end
  end
  object PaneStyle1: TJvNavPaneStyleManager
    Theme = nptXPBlue
    Left = 720
    Top = 552
  end
  object ActionListEdit: TActionList
    Left = 800
    Top = 552
    object actNeu: TAction
      Caption = 'Neu'
      OnExecute = btnNeuClick
    end
    object actSpeichern: TAction
      Caption = 'Speichern'
      OnExecute = btnSpeichernClick
    end
    object actAbbrechen: TAction
      Caption = 'Abbrechen'
      OnExecute = btnAbbrechenClick
    end
    object actLoeschen: TAction
      Caption = 'L'#246'schen'
      OnExecute = btnLoeschenClick
    end
  end
end
