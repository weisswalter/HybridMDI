object frmMail: TfrmMail
  Left = 0
  Top = 0
  Caption = 'E-Mail'
  ClientHeight = 700
  ClientWidth = 1200
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1200
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object lblKonto: TLabel
      Left = 8
      Top = 13
      Width = 33
      Height = 15
      Caption = 'Konto'
    end
    object cboKonto: TDBLookupComboBox
      Left = 50
      Top = 8
      Width = 260
      Height = 23
      KeyField = 'konto_id'
      ListField = 'bezeichnung'
      ListSource = dmMail.dstblKonto
      TabOrder = 0
      OnCloseUp = cboKontoCloseUp
    end
    object btnAbrufen: TJvNavPanelButtonTop
      Left = 330
      Top = 0
      Width = 90
      Height = 40
      Action = actAbrufen
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
    end
    object btnNeuLaden: TJvNavPanelButtonTop
      Left = 420
      Top = 0
      Width = 90
      Height = 40
      Action = actNeuLaden
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
    end
    object btnGelesen: TJvNavPanelButtonTop
      Left = 510
      Top = 0
      Width = 110
      Height = 40
      Action = actGelesen
      Alignment = taCenter
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleManager = PaneStyle1
      ParentStyleManager = False
    end
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 40
    Width = 700
    Height = 660
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object splLeft: TSplitter
      Left = 0
      Top = 180
      Width = 700
      Height = 5
      Cursor = crVSplit
      Align = alTop
    end
    object dbgrdOrdner: TDBGrid
      Left = 0
      Top = 0
      Width = 700
      Height = 180
      Align = alTop
      DataSource = dmMail.dstblOrdner
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdOrdnerCellClick
    end
    object dbgrdNachrichten: TDBGrid
      Left = 0
      Top = 185
      Width = 700
      Height = 475
      Align = alClient
      DataSource = dmMail.dstblNachrichten
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdNachrichtenCellClick
    end
  end
  object Splitter1: TSplitter
    Left = 700
    Top = 40
    Width = 5
    Height = 660
  end
  object JvRibbonPanel1: TRibbonPanel
    Left = 705
    Top = 40
    Width = 495
    Height = 660
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 2
    ActiveTheme = nptXPBlue
    InactiveTheme = nptXPSilver
    ActivePageIndex = 0
    HeaderButtons = <
      item
        Caption = 'Nachricht'
        Width = 120
      end
      item
        Caption = 'Anh'#228'nge'
        Width = 110
      end
      item
        Caption = 'Konto'
        Width = 100
      end
      item
        Caption = 'Erweitert'
        Width = 110
      end>
    object tsNachricht: TTabSheet
      Caption = 'Nachricht'
      object barNachricht: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 495
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actErsterR
          end
          item
            Action = actZurueckR
            Width = 75
          end
          item
            Action = actWeiterR
            Width = 70
          end
          item
            Action = actLetzterR
            Width = 75
          end>
      end
      object pnlNachricht: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlNachricht'
        ShowCaption = False
        TabOrder = 3
        object pnlKopf: TPanel
          Left = 0
          Top = 0
          Width = 480
          Height = 160
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblVon: TLabel
            Left = 8
            Top = 10
            Width = 21
            Height = 15
            Caption = 'Von'
          end
          object lblAn: TLabel
            Left = 8
            Top = 46
            Width = 15
            Height = 15
            Caption = 'An'
          end
          object lblBetreff: TLabel
            Left = 8
            Top = 82
            Width = 39
            Height = 15
            Caption = 'Betreff'
          end
          object lblDatum: TLabel
            Left = 8
            Top = 118
            Width = 34
            Height = 15
            Caption = 'Datum'
          end
          object edtVon: TDBEdit
            Left = 90
            Top = 6
            Width = 380
            Height = 23
            DataField = 'von_adresse'
            DataSource = dmMail.dstblNachrichten
            ReadOnly = True
            TabOrder = 0
          end
          object edtAn: TDBEdit
            Left = 90
            Top = 42
            Width = 380
            Height = 23
            DataField = 'an_adressen'
            DataSource = dmMail.dstblNachrichten
            ReadOnly = True
            TabOrder = 1
          end
          object edtBetreff: TDBEdit
            Left = 90
            Top = 78
            Width = 380
            Height = 23
            DataField = 'betreff'
            DataSource = dmMail.dstblNachrichten
            ReadOnly = True
            TabOrder = 2
          end
          object edtDatum: TDBEdit
            Left = 90
            Top = 114
            Width = 200
            Height = 23
            DataField = 'gesendet_am'
            DataSource = dmMail.dstblNachrichten
            ReadOnly = True
            TabOrder = 3
          end
        end
        object memBody: TDBMemo
          Left = 0
          Top = 160
          Width = 480
          Height = 400
          Align = alClient
          DataField = 'body_text'
          DataSource = dmMail.dstblNachrichten
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 1
        end
      end
    end
    object tsAnhaenge: TTabSheet
      Caption = 'Anh'#228'nge'
      object barAnhaenge: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 495
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actErsterR
          end
          item
            Action = actZurueckR
            Width = 75
          end
          item
            Action = actWeiterR
            Width = 70
          end
          item
            Action = actLetzterR
            Width = 75
          end>
      end
      object pnlAnhaenge: TPanel
        Align = alClient
        BevelOuter = bvNone
        Caption = 'pnlAnhaenge'
        ShowCaption = False
        TabOrder = 4
        object pnlAnhangInfo: TPanel
          Left = 0
          Top = 0
          Width = 480
          Height = 30
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblAnhangHinweis: TLabel
            Left = 8
            Top = 8
            Width = 260
            Height = 15
            Caption = 'Doppelklick '#246'ffnet den Anhang'
          end
        end
        object dbgrdAnhaenge: TDBGrid
          Left = 0
          Top = 30
          Width = 480
          Height = 530
          Align = alClient
          DataSource = dmMail.dstblAnhaenge
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          OnDblClick = dbgrdAnhaengeDblClick
        end
      end
    end
    object tsKonto: TTabSheet
      Caption = 'Konto'
      object barKonto: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 495
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actErsterR
          end
          item
            Action = actZurueckR
            Width = 75
          end
          item
            Action = actWeiterR
            Width = 70
          end
          item
            Action = actLetzterR
            Width = 75
          end>
      end
      object pnlKonto: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 9
        object lblKBez: TLabel
          Left = 8
          Top = 48
          Width = 66
          Height = 15
          Caption = 'Bezeichnung'
        end
        object lblKEmail: TLabel
          Left = 250
          Top = 48
          Width = 76
          Height = 15
          Caption = 'E-Mail-Adresse'
        end
        object lblKAnzeige: TLabel
          Left = 8
          Top = 96
          Width = 72
          Height = 15
          Caption = 'Anzeigename'
        end
        object lblKMaxAbruf: TLabel
          Left = 330
          Top = 96
          Width = 190
          Height = 15
          Caption = 'Max. Nachrichten je Ordner (0 = alle)'
        end
        object lblKImapHost: TLabel
          Left = 8
          Top = 152
          Width = 60
          Height = 15
          Caption = 'IMAP-Server'
        end
        object lblKImapPort: TLabel
          Left = 300
          Top = 152
          Width = 22
          Height = 15
          Caption = 'Port'
        end
        object lblKSmtpHost: TLabel
          Left = 8
          Top = 200
          Width = 62
          Height = 15
          Caption = 'SMTP-Server'
        end
        object lblKSmtpPort: TLabel
          Left = 300
          Top = 200
          Width = 22
          Height = 15
          Caption = 'Port'
        end
        object lblKBenutzer: TLabel
          Left = 8
          Top = 248
          Width = 60
          Height = 15
          Caption = 'Benutzername'
        end
        object lblKSmtpBenutzer: TLabel
          Left = 8
          Top = 296
          Width = 230
          Height = 15
          Caption = 'SMTP-Benutzername (leer = wie oben)'
        end
        object lblKPasswort: TLabel
          Left = 8
          Top = 352
          Width = 48
          Height = 15
          Caption = 'Passwort'
        end
        object lblKSchluessel: TLabel
          Left = 250
          Top = 352
          Width = 100
          Height = 15
          Caption = 'Master-Schl'#252'ssel'
        end
        object lblKSmtpPasswort: TLabel
          Left = 8
          Top = 402
          Width = 220
          Height = 15
          Caption = 'SMTP-Passwort (leer = wie oben)'
        end
        object lblKSmtpStatus: TLabel
          Left = 8
          Top = 492
          Width = 3
          Height = 15
        end
        object lblKPasswortStatus: TLabel
          Left = 8
          Top = 474
          Width = 3
          Height = 15
        end
        object lblKHinweis: TLabel
          Left = 8
          Top = 512
          Width = 540
          Height = 46
          AutoSize = False
          Caption =
            'Das Passwort wird in der Datenbank verschl'#252'sselt abgelegt (pgcryp' +
            'to). Der Master-Schl'#252'ssel wird NICHT gespeichert '#8212' er gilt nur f'#252 +
            'r diese Sitzung und muss nach jedem Programmstart erneut eingegeb' +
            'en werden, sobald ein Passwort gesetzt oder gelesen wird.'
          WordWrap = True
        end
        object pnlKontoButtons: TPanel
          Left = 0
          Top = 0
          Width = 560
          Height = 36
          Align = alTop
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object btnKNeu: TButton
            Left = 0
            Top = 3
            Width = 90
            Height = 30
            Caption = 'Neu'
            TabOrder = 0
            OnClick = btnKNeuClick
          end
          object btnKAendern: TButton
            Left = 96
            Top = 3
            Width = 90
            Height = 30
            Caption = #196'ndern'
            TabOrder = 1
            OnClick = btnKAendernClick
          end
          object btnKSpeichern: TButton
            Left = 192
            Top = 3
            Width = 90
            Height = 30
            Caption = 'Speichern'
            TabOrder = 2
            OnClick = btnKSpeichernClick
          end
          object btnKAbbrechen: TButton
            Left = 288
            Top = 3
            Width = 90
            Height = 30
            Caption = 'Abbrechen'
            TabOrder = 3
            OnClick = btnKAbbrechenClick
          end
          object btnKTesten: TButton
            Left = 400
            Top = 3
            Width = 150
            Height = 30
            Caption = 'Verbindung testen'
            TabOrder = 4
            OnClick = btnKTestenClick
          end
        end
        object edtKBez: TDBEdit
          Left = 8
          Top = 66
          Width = 230
          Height = 23
          DataField = 'bezeichnung'
          DataSource = dmMail.dstblKonto
          TabOrder = 1
        end
        object edtKEmail: TDBEdit
          Left = 250
          Top = 66
          Width = 300
          Height = 23
          DataField = 'email_adresse'
          DataSource = dmMail.dstblKonto
          TabOrder = 2
        end
        object edtKAnzeige: TDBEdit
          Left = 8
          Top = 114
          Width = 300
          Height = 23
          DataField = 'anzeige_name'
          DataSource = dmMail.dstblKonto
          TabOrder = 3
        end
        object edtKMaxAbruf: TDBEdit
          Left = 330
          Top = 114
          Width = 80
          Height = 23
          DataField = 'max_abruf'
          DataSource = dmMail.dstblKonto
          TabOrder = 20
        end
        object edtKImapHost: TDBEdit
          Left = 8
          Top = 170
          Width = 280
          Height = 23
          DataField = 'imap_host'
          DataSource = dmMail.dstblKonto
          TabOrder = 4
        end
        object edtKImapPort: TDBEdit
          Left = 300
          Top = 170
          Width = 70
          Height = 23
          DataField = 'imap_port'
          DataSource = dmMail.dstblKonto
          TabOrder = 5
        end
        object cbxKImapSsl: TDBCheckBox
          Left = 386
          Top = 172
          Width = 90
          Height = 17
          Caption = 'SSL'
          DataField = 'imap_ssl'
          DataSource = dmMail.dstblKonto
          TabOrder = 6
          ValueChecked = 'True'
          ValueUnchecked = 'False'
        end
        object edtKSmtpHost: TDBEdit
          Left = 8
          Top = 218
          Width = 280
          Height = 23
          DataField = 'smtp_host'
          DataSource = dmMail.dstblKonto
          TabOrder = 7
        end
        object edtKSmtpPort: TDBEdit
          Left = 300
          Top = 218
          Width = 70
          Height = 23
          DataField = 'smtp_port'
          DataSource = dmMail.dstblKonto
          TabOrder = 8
        end
        object cbxKSmtpTls: TDBCheckBox
          Left = 386
          Top = 220
          Width = 110
          Height = 17
          Caption = 'STARTTLS'
          DataField = 'smtp_starttls'
          DataSource = dmMail.dstblKonto
          TabOrder = 9
          ValueChecked = 'True'
          ValueUnchecked = 'False'
        end
        object edtKBenutzer: TDBEdit
          Left = 8
          Top = 266
          Width = 300
          Height = 23
          DataField = 'benutzername'
          DataSource = dmMail.dstblKonto
          TabOrder = 10
        end
        object cbxKStandard: TDBCheckBox
          Left = 330
          Top = 268
          Width = 120
          Height = 17
          Caption = 'Standardkonto'
          DataField = 'ist_standard'
          DataSource = dmMail.dstblKonto
          TabOrder = 11
          ValueChecked = 'True'
          ValueUnchecked = 'False'
        end
        object cbxKAktiv: TDBCheckBox
          Left = 460
          Top = 268
          Width = 90
          Height = 17
          Caption = 'Aktiv'
          DataField = 'aktiv'
          DataSource = dmMail.dstblKonto
          TabOrder = 12
          ValueChecked = 'True'
          ValueUnchecked = 'False'
        end
        object edtKSmtpBenutzer: TDBEdit
          Left = 8
          Top = 314
          Width = 300
          Height = 23
          DataField = 'smtp_benutzername'
          DataSource = dmMail.dstblKonto
          TabOrder = 13
        end
        object edtKPasswort: TEdit
          Left = 8
          Top = 370
          Width = 230
          Height = 23
          PasswordChar = '*'
          TabOrder = 14
        end
        object edtKSchluessel: TEdit
          Left = 250
          Top = 370
          Width = 180
          Height = 23
          PasswordChar = '*'
          TabOrder = 15
        end
        object btnKPasswortSetzen: TButton
          Left = 440
          Top = 368
          Width = 110
          Height = 28
          Caption = 'Passwort setzen'
          TabOrder = 16
          OnClick = btnKPasswortSetzenClick
        end
        object edtKSmtpPasswort: TEdit
          Left = 8
          Top = 420
          Width = 230
          Height = 23
          PasswordChar = '*'
          TabOrder = 17
        end
        object btnKSmtpPasswortSetzen: TButton
          Left = 250
          Top = 418
          Width = 180
          Height = 28
          Caption = 'SMTP-Passwort setzen'
          TabOrder = 18
          OnClick = btnKSmtpPasswortSetzenClick
        end
        object cbxKKlartext: TCheckBox
          Left = 8
          Top = 456
          Width = 300
          Height = 17
          Caption = 'Klartext ablegen (nur zum Ausprobieren)'
          TabOrder = 19
          OnClick = cbxKKlartextClick
        end
      end
    end
    object tsErweitert: TTabSheet
      Caption = 'Erweitert'
      object barErweitert: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 495
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <
          item
            Action = actErsterR
          end
          item
            Action = actZurueckR
            Width = 75
          end
          item
            Action = actWeiterR
            Width = 70
          end
          item
            Action = actLetzterR
            Width = 75
          end>
      end
      object pnlErweitert: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 7
        object lblEProt: TLabel
          Left = 8
          Top = 8
          Width = 200
          Height = 15
          Caption = 'Protokoll'
        end
        object cboEProt: TDBLookupComboBox
          Left = 8
          Top = 26
          Width = 320
          Height = 23
          DataField = 'protokoll'
          DataSource = dmMail.dstblKonto
          KeyField = 'wert'
          ListField = 'anzeige'
          ListSource = dmMail.dsOptProtokoll
          TabOrder = 0
        end
        object lblEFlow: TLabel
          Left = 340
          Top = 8
          Width = 200
          Height = 15
          Caption = 'OAuth-Anmeldeweg'
        end
        object cboEFlow: TDBLookupComboBox
          Left = 340
          Top = 26
          Width = 210
          Height = 23
          DataField = 'oauth_flow'
          DataSource = dmMail.dstblKonto
          KeyField = 'wert'
          ListField = 'anzeige'
          ListSource = dmMail.dsOptFlow
          TabOrder = 1
        end
        object lblEImapSich: TLabel
          Left = 8
          Top = 60
          Width = 200
          Height = 15
          Caption = 'IMAP: Transportsicherheit'
        end
        object cboEImapSich: TDBLookupComboBox
          Left = 8
          Top = 78
          Width = 320
          Height = 23
          DataField = 'imap_sicherheit'
          DataSource = dmMail.dstblKonto
          KeyField = 'wert'
          ListField = 'anzeige'
          ListSource = dmMail.dsOptSicherheit
          TabOrder = 2
        end
        object lblEImapAuth: TLabel
          Left = 340
          Top = 60
          Width = 200
          Height = 15
          Caption = 'IMAP: Anmeldeverfahren'
        end
        object cboEImapAuth: TDBLookupComboBox
          Left = 340
          Top = 78
          Width = 210
          Height = 23
          DataField = 'imap_auth'
          DataSource = dmMail.dstblKonto
          KeyField = 'wert'
          ListField = 'anzeige'
          ListSource = dmMail.dsOptAuth
          TabOrder = 3
        end
        object lblESmtpSich: TLabel
          Left = 8
          Top = 112
          Width = 200
          Height = 15
          Caption = 'SMTP: Transportsicherheit'
        end
        object cboESmtpSich: TDBLookupComboBox
          Left = 8
          Top = 130
          Width = 320
          Height = 23
          DataField = 'smtp_sicherheit'
          DataSource = dmMail.dstblKonto
          KeyField = 'wert'
          ListField = 'anzeige'
          ListSource = dmMail.dsOptSicherheit
          TabOrder = 4
        end
        object lblESmtpAuth: TLabel
          Left = 340
          Top = 112
          Width = 200
          Height = 15
          Caption = 'SMTP: Anmeldeverfahren'
        end
        object cboESmtpAuth: TDBLookupComboBox
          Left = 340
          Top = 130
          Width = 210
          Height = 23
          DataField = 'smtp_auth'
          DataSource = dmMail.dstblKonto
          KeyField = 'wert'
          ListField = 'anzeige'
          ListSource = dmMail.dsOptAuth
          TabOrder = 5
        end
        object lblEPopHost: TLabel
          Left = 8
          Top = 164
          Width = 200
          Height = 15
          Caption = 'POP3-Server'
        end
        object edtEPopHost: TDBEdit
          Left = 8
          Top = 182
          Width = 200
          Height = 23
          DataField = 'pop3_host'
          DataSource = dmMail.dstblKonto
          TabOrder = 6
        end
        object lblEPopPort: TLabel
          Left = 216
          Top = 164
          Width = 40
          Height = 15
          Caption = 'Port'
        end
        object edtEPopPort: TDBEdit
          Left = 216
          Top = 182
          Width = 60
          Height = 23
          DataField = 'pop3_port'
          DataSource = dmMail.dstblKonto
          TabOrder = 7
        end
        object lblEPopSich: TLabel
          Left = 286
          Top = 164
          Width = 200
          Height = 15
          Caption = 'POP3-Sicherheit'
        end
        object cboEPopSich: TDBLookupComboBox
          Left = 286
          Top = 182
          Width = 180
          Height = 23
          DataField = 'pop3_sicherheit'
          DataSource = dmMail.dstblKonto
          KeyField = 'wert'
          ListField = 'anzeige'
          ListSource = dmMail.dsOptSicherheit
          TabOrder = 8
        end
        object cbxEPopDel: TDBCheckBox
          Left = 476
          Top = 184
          Width = 150
          Height = 17
          Caption = 'nach Abruf loeschen'
          DataField = 'pop3_loeschen'
          DataSource = dmMail.dstblKonto
          TabOrder = 9
          ValueChecked = 'True'
          ValueUnchecked = 'False'
        end
        object lblETimeout: TLabel
          Left = 8
          Top = 216
          Width = 80
          Height = 15
          Caption = 'Zeitlimit (s)'
        end
        object edtETimeout: TDBEdit
          Left = 8
          Top = 234
          Width = 60
          Height = 23
          DataField = 'timeout_sekunden'
          DataSource = dmMail.dstblKonto
          TabOrder = 10
        end
        object cbxEZert: TDBCheckBox
          Left = 80
          Top = 236
          Width = 140
          Height = 17
          Caption = 'Zertifikat pruefen'
          DataField = 'zertifikat_pruefen'
          DataSource = dmMail.dstblKonto
          TabOrder = 11
          ValueChecked = 'True'
          ValueUnchecked = 'False'
        end
        object cbxEKopf: TDBCheckBox
          Left = 226
          Top = 236
          Width = 150
          Height = 17
          Caption = 'nur Kopfdaten holen'
          DataField = 'nur_kopfdaten'
          DataSource = dmMail.dstblKonto
          TabOrder = 12
          ValueChecked = 'True'
          ValueUnchecked = 'False'
        end
        object lblEAbDat: TLabel
          Left = 380
          Top = 216
          Width = 200
          Height = 15
          Caption = 'Abruf ab Datum'
        end
        object edtEAbDat: TDBEdit
          Left = 380
          Top = 234
          Width = 110
          Height = 23
          DataField = 'abruf_ab_datum'
          DataSource = dmMail.dstblKonto
          TabOrder = 13
        end
        object lblEMaxAnh: TLabel
          Left = 8
          Top = 264
          Width = 200
          Height = 15
          Caption = 'max. Anhang (KB, 0=alle)'
        end
        object edtEMaxAnh: TDBEdit
          Left = 8
          Top = 282
          Width = 110
          Height = 23
          DataField = 'max_anhang_kb'
          DataSource = dmMail.dstblKonto
          TabOrder = 14
        end
        object lblEFilter: TLabel
          Left = 130
          Top = 264
          Width = 200
          Height = 15
          Caption = 'Ordnerfilter (Komma, leer = alle)'
        end
        object edtEFilter: TDBEdit
          Left = 130
          Top = 282
          Width = 420
          Height = 23
          DataField = 'ordner_filter'
          DataSource = dmMail.dstblKonto
          TabOrder = 15
        end
        object lblETenant: TLabel
          Left = 8
          Top = 316
          Width = 200
          Height = 15
          Caption = 'OAuth Tenant'
        end
        object edtETenant: TDBEdit
          Left = 8
          Top = 334
          Width = 260
          Height = 23
          DataField = 'oauth_tenant'
          DataSource = dmMail.dstblKonto
          TabOrder = 16
        end
        object lblEClient: TLabel
          Left = 280
          Top = 316
          Width = 200
          Height = 15
          Caption = 'OAuth Client-ID'
        end
        object edtEClient: TDBEdit
          Left = 280
          Top = 334
          Width = 270
          Height = 23
          DataField = 'oauth_client_id'
          DataSource = dmMail.dstblKonto
          TabOrder = 17
        end
        object lblEAuthUrl: TLabel
          Left = 8
          Top = 368
          Width = 200
          Height = 15
          Caption = 'OAuth Authority'
        end
        object edtEAuthUrl: TDBEdit
          Left = 8
          Top = 386
          Width = 260
          Height = 23
          DataField = 'oauth_authority'
          DataSource = dmMail.dstblKonto
          TabOrder = 18
        end
        object lblEGraph: TLabel
          Left = 280
          Top = 368
          Width = 200
          Height = 15
          Caption = 'Graph-Basis-URL'
        end
        object edtEGraph: TDBEdit
          Left = 280
          Top = 386
          Width = 270
          Height = 23
          DataField = 'graph_basis_url'
          DataSource = dmMail.dstblKonto
          TabOrder = 19
        end
        object lblEScopes: TLabel
          Left = 8
          Top = 420
          Width = 200
          Height = 15
          Caption = 'OAuth Scopes'
        end
        object edtEScopes: TDBEdit
          Left = 8
          Top = 438
          Width = 542
          Height = 23
          DataField = 'oauth_scopes'
          DataSource = dmMail.dstblKonto
          TabOrder = 20
        end
      end
    end
  end
  object PaneStyle1: TJvNavPaneStyleManager
    Theme = nptXPBlue
    Left = 900
    Top = 620
  end
  object ActionListEdit: TActionList
    Left = 960
    Top = 620
    object actAbrufen: TAction
      Caption = 'Abrufen'
      OnExecute = actAbrufenExecute
    end
    object actNeuLaden: TAction
      Caption = 'Neu laden'
      OnExecute = actNeuLadenExecute
    end
    object actGelesen: TAction
      Caption = 'Gelesen/Ungelesen'
      OnExecute = actGelesenExecute
    end
  end
  object ActionListRechts: TActionList
    Left = 1020
    Top = 620
    object actErsterR: TAction
      Caption = 'Erster'
      OnExecute = ActionRechtsExecute
    end
    object actZurueckR: TAction
      Tag = 1
      Caption = 'Zur'#252'ck'
      OnExecute = ActionRechtsExecute
    end
    object actWeiterR: TAction
      Tag = 2
      Caption = 'Weiter'
      OnExecute = ActionRechtsExecute
    end
    object actLetzterR: TAction
      Tag = 3
      Caption = 'Letzter'
      OnExecute = ActionRechtsExecute
    end
  end
end
