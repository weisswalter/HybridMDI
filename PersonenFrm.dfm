object frmPersonen: TfrmPersonen
  Left = 0
  Top = 0
  Caption = 'Personen'
  ClientHeight = 640
  ClientWidth = 1426
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
  object pnlStamm: TPanel
    Left = 0
    Top = 0
    Width = 330
    Height = 640
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object pnlStammButtons: TPanel
      Left = 0
      Top = 0
      Width = 330
      Height = 38
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object btnErsterStamm: TJvNavPanelButtonTop
        Left = 0
        Top = 0
        Width = 40
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Caption = 'Erster'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        OnClick = BtnNavClick
      end
      object btnZurueckStamm: TJvNavPanelButtonTop
        Tag = 1
        Left = 40
        Top = 0
        Width = 48
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Caption = 'Zur'#252'ck'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        OnClick = BtnNavClick
      end
      object btnWeiterStamm: TJvNavPanelButtonTop
        Tag = 2
        Left = 88
        Top = 0
        Width = 50
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Caption = 'Weiter'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        OnClick = BtnNavClick
      end
      object btnLetzterStamm: TJvNavPanelButtonTop
        Tag = 3
        Left = 138
        Top = 0
        Width = 50
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Caption = 'Letzter'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        OnClick = BtnNavClick
      end
      object btnNeuStamm: TJvNavPanelButtonTop
        Tag = 4
        Left = 188
        Top = 0
        Width = 31
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Caption = 'Neu'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        OnClick = BtnNavClick
      end
      object btnAendernStamm: TJvNavPanelButtonTop
        Tag = 5
        Left = 219
        Top = 0
        Width = 50
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Caption = #196'ndern'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        OnClick = BtnNavClick
        ExplicitLeft = 217
      end
      object btnSpeichernStamm: TJvNavPanelButtonTop
        Tag = 6
        Left = 269
        Top = 0
        Width = 64
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Caption = 'Speichern'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        OnClick = BtnNavClick
      end
      object btnAbbrechenStamm: TJvNavPanelButtonTop
        Tag = 7
        Left = 333
        Top = 0
        Width = 61
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Caption = 'Abbrechen'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        OnClick = BtnNavClick
        ExplicitLeft = 377
      end
      object btnNeuLadenStamm: TJvNavPanelButtonTop
        Tag = 8
        Left = 394
        Top = 0
        Width = 61
        Height = 38
        Align = alLeft
        Alignment = taCenter
        Caption = 'Neu laden'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        StyleManager = PaneStyle1
        ParentStyleManager = False
        ImageIndex = 0
        OnClick = BtnNavClick
        ExplicitLeft = 438
      end
      object grdtStamm: TJvGradient
        Left = 455
        Top = 0
        Width = 31
        Height = 38
        Style = grVertical
        StartColor = 16245453
        EndColor = 15966336
        ExplicitLeft = 526
        ExplicitWidth = 8
      end
    end
    object pnlStammFelder: TPanel
      Left = 0
      Top = 38
      Width = 330
      Height = 602
      Align = alClient
      BevelOuter = bvNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 10
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ShowCaption = False
      TabOrder = 1
      object lblNr: TLabel
        Left = 12
        Top = 16
        Width = 9
        Height = 10
        Caption = 'Nr.'
      end
      object txtNr: TDBText
        Left = 130
        Top = 16
        Width = 75
        Height = 15
        DataField = 'person_id'
        DataSource = dmPersonen.dstblPerson
      end
      object lblVorname: TLabel
        Left = 12
        Top = 47
        Width = 28
        Height = 10
        Caption = 'Vorname'
      end
      object lblNachname: TLabel
        Left = 12
        Top = 76
        Width = 43
        Height = 10
        Caption = 'Name / Firma'
      end
      object lblPersonTyp: TLabel
        Left = 12
        Top = 105
        Width = 38
        Height = 10
        Caption = 'Personentyp'
      end
      object lblErstellt: TLabel
        Left = 12
        Top = 134
        Width = 33
        Height = 10
        Caption = 'Erstellt am'
      end
      object txtErstellt: TDBText
        Left = 130
        Top = 134
        Width = 155
        Height = 15
        DataField = 'created_at'
        DataSource = dmPersonen.dstblPerson
      end
      object lblBeschreibung: TLabel
        Left = 12
        Top = 188
        Width = 42
        Height = 10
        Caption = 'Beschreibung'
      end
      object lblPhoto: TLabel
        Left = 12
        Top = 304
        Width = 18
        Height = 10
        Caption = 'Photo'
      end
      object edtVorname: TJvDBMaskEdit
        Left = 130
        Top = 44
        Width = 168
        Height = 18
        DataField = 'vorname'
        DataSource = dmPersonen.dstblPerson
        TabOrder = 0
        EditMask = ''
      end
      object edtNachname: TJvDBMaskEdit
        Left = 130
        Top = 73
        Width = 168
        Height = 18
        DataField = 'nachname_firmenname'
        DataSource = dmPersonen.dstblPerson
        TabOrder = 1
        EditMask = ''
      end
      object cboPersonTyp: TJvDBLookupCombo
        Left = 130
        Top = 102
        Width = 168
        Height = 23
        DataField = 'typ_id'
        DataSource = dmPersonen.dstblPerson
        LookupField = 'typ_id'
        LookupDisplay = 'bezeichnung'
        LookupSource = dmPersonen.dstblPersonTyp
        TabOrder = 2
      end
      object cbxHauptperson: TDBCheckBox
        Left = 130
        Top = 158
        Width = 190
        Height = 17
        Caption = 'Hauptperson (Mandant)'
        DataField = 'ist_hauptperson'
        DataSource = dmPersonen.dstblPersonMandant
        TabOrder = 3
        ValueChecked = 'True'
        ValueUnchecked = 'False'
      end
      object memBeschreibung: TDBMemo
        Left = 12
        Top = 206
        Width = 306
        Height = 90
        DataField = 'beschreibung'
        DataSource = dmPersonen.dstblPerson
        TabOrder = 4
      end
      object imgPhoto: TDBImage
        Left = 19
        Top = 320
        Width = 200
        Height = 200
        DataField = 'photo'
        DataSource = dmPersonen.dstblPerson
        Stretch = True
        TabOrder = 5
      end
      object btnPhotoLaden: TButton
        Left = 12
        Top = 532
        Width = 120
        Height = 25
        Caption = 'Foto laden...'
        TabOrder = 6
        OnClick = btnPhotoLadenClick
      end
    end
  end
  object JvRibbonPanel1: TJvRibbonPanel
    Left = 330
    Top = 0
    Width = 1096
    Height = 640
    Align = alClient
    TabOrder = 1
    ActiveTheme = nptXPBlue
    InactiveTheme = nptXPSilver
    Headers = <
      item
        Caption = 'Adressen'
        Width = 120
        Buttons = <
          item
            ActionTag = 0
            Width = 64
          end
          item
            ActionTag = 1
            Width = 70
          end
          item
            ActionTag = 2
            Width = 66
          end
          item
            ActionTag = 3
            Width = 70
          end
          item
            ActionTag = 4
            Width = 50
          end
          item
            ActionTag = 5
            Width = 66
          end
          item
            ActionTag = 6
            Width = 84
          end
          item
            ActionTag = 7
            Width = 84
          end
          item
            ActionTag = 8
            Width = 84
          end>
        ContentPanel = pnlAdressen
      end
      item
        Caption = 'Emails'
        Width = 110
        Buttons = <
          item
            ActionTag = 0
            Width = 64
          end
          item
            ActionTag = 1
            Width = 70
          end
          item
            ActionTag = 2
            Width = 66
          end
          item
            ActionTag = 3
            Width = 70
          end
          item
            ActionTag = 4
            Width = 50
          end
          item
            ActionTag = 5
            Width = 66
          end
          item
            ActionTag = 6
            Width = 84
          end
          item
            ActionTag = 7
            Width = 84
          end
          item
            ActionTag = 8
            Width = 84
          end>
        ContentPanel = pnlEmails
      end
      item
        Caption = 'Telefon'
        Width = 110
        Buttons = <
          item
            ActionTag = 0
            Width = 64
          end
          item
            ActionTag = 1
            Width = 70
          end
          item
            ActionTag = 2
            Width = 66
          end
          item
            ActionTag = 3
            Width = 70
          end
          item
            ActionTag = 4
            Width = 50
          end
          item
            ActionTag = 5
            Width = 66
          end
          item
            ActionTag = 6
            Width = 84
          end
          item
            ActionTag = 7
            Width = 84
          end
          item
            ActionTag = 8
            Width = 84
          end>
        ContentPanel = pnlTelefon
      end
      item
        Caption = 'Beziehungen'
        Width = 130
        Buttons = <
          item
            ActionTag = 0
            Width = 64
          end
          item
            ActionTag = 1
            Width = 70
          end
          item
            ActionTag = 2
            Width = 66
          end
          item
            ActionTag = 3
            Width = 70
          end
          item
            ActionTag = 4
            Width = 50
          end
          item
            ActionTag = 5
            Width = 66
          end
          item
            ActionTag = 6
            Width = 84
          end
          item
            ActionTag = 7
            Width = 84
          end
          item
            ActionTag = 8
            Width = 84
          end>
        ContentPanel = pnlBeziehungen
      end>
    ActivePageIndex = 0
    OnButtonClick = RibbonButtonClick
  end
  object pnlAdressen: TPanel
    Left = 8
    Top = 700
    Width = 1088
    Height = 567
    BevelOuter = bvNone
    Caption = 'pnlAdressen'
    ShowCaption = False
    TabOrder = 2
    Visible = False
    object pnlFldAdressen: TPanel
      Left = 0
      Top = 0
      Width = 1088
      Height = 84
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
      object lblStrasse: TLabel
        Left = 8
        Top = 4
        Width = 33
        Height = 15
        Caption = 'Stra'#223'e'
      end
      object lblHausNr: TLabel
        Left = 216
        Top = 4
        Width = 16
        Height = 15
        Caption = 'Nr.'
      end
      object lblPlz: TLabel
        Left = 276
        Top = 4
        Width = 20
        Height = 15
        Caption = 'PLZ'
      end
      object lblOrt: TLabel
        Left = 348
        Top = 4
        Width = 17
        Height = 15
        Caption = 'Ort'
      end
      object lblAdressTyp: TLabel
        Left = 512
        Top = 4
        Width = 52
        Height = 15
        Caption = 'Adresstyp'
      end
      object lblBestAdresse: TLabel
        Left = 8
        Top = 54
        Width = 129
        Height = 15
        Caption = 'oder bestehende w'#228'hlen'
      end
      object lblLand: TLabel
        Left = 680
        Top = 4
        Width = 26
        Height = 15
        Caption = 'Land'
      end
      object lblBezirk: TLabel
        Left = 840
        Top = 4
        Width = 31
        Height = 15
        Caption = 'Bezirk'
      end
      object edtStrasse: TJvDBMaskEdit
        Left = 8
        Top = 22
        Width = 200
        Height = 23
        DataField = 'strasse'
        DataSource = dmPersonen.dstblAdresse
        TabOrder = 0
        EditMask = ''
      end
      object edtHausNr: TJvDBMaskEdit
        Left = 216
        Top = 22
        Width = 52
        Height = 23
        DataField = 'hausnummer'
        DataSource = dmPersonen.dstblAdresse
        TabOrder = 1
        EditMask = ''
      end
      object edtPlz: TJvDBMaskEdit
        Left = 276
        Top = 22
        Width = 64
        Height = 23
        DataField = 'plz'
        DataSource = dmPersonen.dstblAdresse
        TabOrder = 2
        EditMask = ''
      end
      object edtOrt: TJvDBMaskEdit
        Left = 348
        Top = 22
        Width = 156
        Height = 23
        DataField = 'ort'
        DataSource = dmPersonen.dstblAdresse
        TabOrder = 3
        EditMask = ''
      end
      object cboAdressTyp: TJvDBLookupCombo
        Left = 512
        Top = 22
        Width = 150
        Height = 23
        DataField = 'adressentyp_id'
        DataSource = dmPersonen.dstblPersonAdresse
        LookupField = 'adressentyp_id'
        LookupDisplay = 'bezeichnung'
        LookupSource = dmPersonen.dstblAdressentyp
        TabOrder = 4
      end
      object cboBestAdresse: TJvDBLookupCombo
        Left = 160
        Top = 51
        Width = 502
        Height = 23
        DataField = 'adresse_id'
        DataSource = dmPersonen.dstblPersonAdresse
        LookupField = 'adresse_id'
        LookupDisplay = 'anzeige'
        LookupSource = dmPersonen.dsAdressen
        TabOrder = 5
      end
      object cboLand: TJvDBLookupCombo
        Left = 680
        Top = 22
        Width = 150
        Height = 23
        DataField = 'land_id'
        DataSource = dmPersonen.dstblAdresse
        LookupField = 'land_id'
        LookupDisplay = 'land_name'
        LookupSource = dmPersonen.dstblLand
        TabOrder = 6
      end
      object cboBezirk: TJvDBLookupCombo
        Left = 840
        Top = 22
        Width = 150
        Height = 23
        DataField = 'bezirk_id'
        DataSource = dmPersonen.dstblAdresse
        LookupField = 'bezirk_id'
        LookupDisplay = 'bezirk_name'
        LookupSource = dmPersonen.dstblBezirk
        TabOrder = 7
      end
    end
    object grdAdressen: TDBGrid
      Left = 0
      Top = 122
      Width = 1088
      Height = 483
      Align = alClient
      DataSource = dmPersonen.dstblPersonAdresse
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlEmails: TPanel
    Left = 8
    Top = 1300
    Width = 1088
    Height = 567
    BevelOuter = bvNone
    Caption = 'pnlEmails'
    ShowCaption = False
    TabOrder = 3
    Visible = False
    object pnlFldEmails: TPanel
      Left = 0
      Top = 0
      Width = 1088
      Height = 52
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
      object lblEmail: TLabel
        Left = 8
        Top = 4
        Width = 80
        Height = 15
        Caption = 'E-Mail-Adresse'
      end
      object lblEmailTyp: TLabel
        Left = 324
        Top = 4
        Width = 46
        Height = 15
        Caption = 'Emailtyp'
      end
      object cboEmailAdr: TDBComboBox
        Left = 8
        Top = 22
        Width = 300
        Height = 23
        DataField = 'email_adresse'
        DataSource = dmPersonen.dstblEmailadresse
        TabOrder = 0
      end
      object cboEmailTyp: TJvDBLookupCombo
        Left = 324
        Top = 22
        Width = 160
        Height = 23
        DataField = 'emailtyp_id'
        DataSource = dmPersonen.dstblPersonEmail
        LookupField = 'emailtyp_id'
        LookupDisplay = 'bezeichnung'
        LookupSource = dmPersonen.dstblEmailtyp
        TabOrder = 1
      end
    end
    object grdEmails: TDBGrid
      Left = 0
      Top = 90
      Width = 1088
      Height = 515
      Align = alClient
      DataSource = dmPersonen.dstblPersonEmail
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlTelefon: TPanel
    Left = 8
    Top = 1900
    Width = 1088
    Height = 567
    BevelOuter = bvNone
    Caption = 'pnlTelefon'
    ShowCaption = False
    TabOrder = 4
    Visible = False
    object pnlFldTelefon: TPanel
      Left = 0
      Top = 0
      Width = 1088
      Height = 52
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
      object lblNummer: TLabel
        Left = 8
        Top = 4
        Width = 48
        Height = 15
        Caption = 'Nummer'
      end
      object lblTelefonTyp: TLabel
        Left = 224
        Top = 4
        Width = 56
        Height = 15
        Caption = 'Telefontyp'
      end
      object cboTelefonNr: TDBComboBox
        Left = 8
        Top = 22
        Width = 200
        Height = 23
        DataField = 'nummer'
        DataSource = dmPersonen.dstblTelefonnummer
        TabOrder = 0
      end
      object cboTelefonTyp: TJvDBLookupCombo
        Left = 224
        Top = 22
        Width = 160
        Height = 23
        DataField = 'telefonnummertyp_id'
        DataSource = dmPersonen.dstblPersonTelefonnummer
        LookupField = 'telefonnummertyp_id'
        LookupDisplay = 'bezeichnung'
        LookupSource = dmPersonen.dstblTelefonnummertyp
        TabOrder = 1
      end
    end
    object grdTelefon: TDBGrid
      Left = 0
      Top = 90
      Width = 1088
      Height = 515
      Align = alClient
      DataSource = dmPersonen.dstblPersonTelefonnummer
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlBeziehungen: TPanel
    Left = 8
    Top = 2500
    Width = 1088
    Height = 567
    BevelOuter = bvNone
    Caption = 'pnlBeziehungen'
    ShowCaption = False
    TabOrder = 5
    Visible = False
    object pnlFldBeziehungen: TPanel
      Left = 0
      Top = 0
      Width = 1088
      Height = 52
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 1
      object lblRolle: TLabel
        Left = 8
        Top = 4
        Width = 26
        Height = 15
        Caption = 'Rolle'
      end
      object lblZielPerson: TLabel
        Left = 244
        Top = 4
        Width = 55
        Height = 15
        Caption = 'Zielperson'
      end
      object cboRolle: TJvDBLookupCombo
        Left = 8
        Top = 22
        Width = 220
        Height = 23
        DataField = 'rolle_id'
        DataSource = dmPersonen.dstblPersonBeziehung
        LookupField = 'rolle_id'
        LookupDisplay = 'rollen_bezeichnung'
        LookupSource = dmPersonen.dstblRolleTyp
        TabOrder = 0
      end
      object cboZielPerson: TJvDBLookupCombo
        Left = 244
        Top = 22
        Width = 300
        Height = 23
        DataField = 'ziel_person_id'
        DataSource = dmPersonen.dstblPersonBeziehung
        LookupField = 'person_id'
        LookupDisplay = 'anzeige'
        LookupSource = dmPersonen.dsPersonen
        TabOrder = 1
      end
      object cbxMitarbeiter: TDBCheckBox
        Left = 564
        Top = 24
        Width = 100
        Height = 17
        Caption = 'Mitarbeiter'
        DataField = 'ist_mitarbeiter'
        DataSource = dmPersonen.dstblPersonBeziehung
        TabOrder = 2
        ValueChecked = 'True'
        ValueUnchecked = 'False'
      end
      object cbxKunde: TDBCheckBox
        Left = 672
        Top = 24
        Width = 80
        Height = 17
        Caption = 'Kunde'
        DataField = 'ist_kunde'
        DataSource = dmPersonen.dstblPersonBeziehung
        TabOrder = 3
        ValueChecked = 'True'
        ValueUnchecked = 'False'
      end
      object cbxKontakt: TDBCheckBox
        Left = 760
        Top = 24
        Width = 90
        Height = 17
        Caption = 'Kontakt'
        DataField = 'ist_kontakt'
        DataSource = dmPersonen.dstblPersonBeziehung
        TabOrder = 4
        ValueChecked = 'True'
        ValueUnchecked = 'False'
      end
      object cbxLehrer: TDBCheckBox
        Left = 856
        Top = 24
        Width = 80
        Height = 17
        Caption = 'Lehrer'
        DataField = 'ist_lehrer'
        DataSource = dmPersonen.dstblPersonBeziehung
        TabOrder = 5
        ValueChecked = 'True'
        ValueUnchecked = 'False'
      end
      object cbxKlient: TDBCheckBox
        Left = 944
        Top = 24
        Width = 80
        Height = 17
        Caption = 'Klient'
        DataField = 'ist_klient'
        DataSource = dmPersonen.dstblPersonBeziehung
        TabOrder = 6
        ValueChecked = 'True'
        ValueUnchecked = 'False'
      end
    end
    object grdBeziehungen: TDBGrid
      Left = 0
      Top = 90
      Width = 1088
      Height = 515
      Align = alClient
      DataSource = dmPersonen.dstblPersonBeziehung
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object PaneStyle1: TJvNavPaneStyleManager
    Theme = nptXPBlue
    Left = 48
    Top = 592
  end
  object dlgPhoto: TOpenPictureDialog
    Filter = 
      'Bilder (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp|Alle ' +
      'Dateien (*.*)|*.*'
    Left = 208
    Top = 592
  end
end
