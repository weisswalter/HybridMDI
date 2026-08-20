object frmBenutzer: TfrmBenutzer
  Left = 0
  Top = 0
  Caption = 'Benutzerverwaltung'
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
    Height = 74
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object chkAnmeldepflicht: TCheckBox
      Left = 8
      Top = 50
      Width = 320
      Height = 17
      Caption = 'Anmeldung beim Start verlangen'
      TabOrder = 9
      OnClick = chkAnmeldepflichtClick
    end
    object lblAngemeldet: TLabel
      Left = 8
      Top = 28
      Width = 300
      Height = 15
      AutoSize = False
      Caption = ' '
    end
    object btnNeuLaden: TJvNavPanelButtonTop
      Left = 340
      Top = 2
      Width = 90
      Height = 69
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
    object btnSperren: TJvNavPanelButtonTop
      Left = 434
      Top = 2
      Width = 90
      Height = 69
      Action = actSperren
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
    object btnEntsperren: TJvNavPanelButtonTop
      Left = 528
      Top = 2
      Width = 100
      Height = 69
      Action = actEntsperren
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
    Top = 74
    Width = 640
    Height = 626
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object dbgrdBenutzer: TDBGrid
      Left = 0
      Top = 0
      Width = 640
      Height = 626
      Align = alClient
      DataSource = dmBenutzer.dsBenutzer
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit, dgTitleClick]
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnCellClick = dbgrdBenutzerCellClick
    end
  end
  object Splitter1: TSplitter
    Left = 640
    Top = 74
    Width = 5
    Height = 626
  end
  object JvRibbonPanel1: TRibbonPanel
    Left = 645
    Top = 74
    Width = 555
    Height = 626
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 2
    object tsZugang: TTabSheet
      Caption = 'Zugang'
      object barZugang: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 555
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <>
      end
      object pnlZugang: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object lblNeuName: TLabel
          Left = 8
          Top = 12
          Width = 78
          Height = 15
          Caption = 'Anmeldename'
        end
        object lblNeuPasswort: TLabel
          Left = 280
          Top = 12
          Width = 50
          Height = 15
          Caption = 'Passwort'
        end
        object lblNeuPerson: TLabel
          Left = 8
          Top = 64
          Width = 100
          Height = 15
          Caption = 'Person (optional)'
        end
        object lblNeuMandant: TLabel
          Left = 8
          Top = 116
          Width = 46
          Height = 15
          Caption = 'Mandant'
        end
        object lblNeuRolle: TLabel
          Left = 280
          Top = 116
          Width = 27
          Height = 15
          Caption = 'Rolle'
        end
        object lblReset: TLabel
          Left = 8
          Top = 232
          Width = 250
          Height = 15
          Caption = 'Passwort des gew'#228'hlten Benutzers zur'#252'cksetzen'
        end
        object lblZugangHinweis: TLabel
          Left = 8
          Top = 300
          Width = 539
          Height = 60
          AutoSize = False
          WordWrap = True
        end
        object edtNeuName: TEdit
          Left = 8
          Top = 32
          Width = 260
          Height = 23
          TabOrder = 0
        end
        object edtNeuPasswort: TEdit
          Left = 280
          Top = 32
          Width = 260
          Height = 23
          PasswordChar = '*'
          TabOrder = 1
        end
        object cboNeuPerson: TDBLookupComboBox
          Left = 8
          Top = 84
          Width = 532
          Height = 23
          KeyField = 'person_id'
          ListField = 'name'
          ListSource = dmBenutzer.dsPersonAuswahl
          TabOrder = 2
        end
        object cboNeuMandant: TDBLookupComboBox
          Left = 8
          Top = 136
          Width = 260
          Height = 23
          KeyField = 'mandant_id'
          ListField = 'mandanten_name'
          ListSource = dmBenutzer.dsMandantAuswahl
          TabOrder = 3
        end
        object cboNeuRolle: TComboBox
          Left = 280
          Top = 136
          Width = 160
          Height = 23
          Style = csDropDownList
          TabOrder = 4
        end
        object btnAnlegen: TButton
          Left = 8
          Top = 176
          Width = 150
          Height = 30
          Caption = 'Benutzer anlegen'
          TabOrder = 5
          OnClick = btnAnlegenClick
        end
        object edtResetPasswort: TEdit
          Left = 8
          Top = 252
          Width = 260
          Height = 23
          PasswordChar = '*'
          TabOrder = 6
        end
        object btnReset: TButton
          Left = 280
          Top = 251
          Width = 160
          Height = 26
          Caption = 'Passwort zur'#252'cksetzen'
          TabOrder = 7
          OnClick = btnResetClick
        end
      end
    end
    object tsMandanten: TTabSheet
      Caption = 'Mandanten'
      object barMandanten: TRibbonButtonBar
        Left = 0
        Top = 0
        Width = 555
        Height = 38
        Align = alTop
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 0
        Buttons = <>
      end
      object pnlAnmeldeAdressen: TPanel
    Left = 0
    Top = 430
    Width = 380
    Height = 170
    Align = alBottom
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 8
    object lblAnmeldeAdressen: TLabel
      Left = 8
      Top = 4
      Width = 360
      Height = 30
      AutoSize = False
      Caption = 
        'Diese Adressen gelten als Anmeldung f'#252'r die Person des gew'#228'hlten' +
        ' Kontos - statt des Anmeldenamens.'
      WordWrap = True
    end
    object clbAnmeldeAdressen: TCheckListBox
      Left = 8
      Top = 38
      Width = 364
      Height = 124
      ItemHeight = 17
      TabOrder = 0
      OnClickCheck = clbAnmeldeAdressenClickCheck
    end
  end
  object pnlMandanten: TPanel
        Align = alClient
        BevelOuter = bvNone
        ShowCaption = False
        TabOrder = 1
        object pnlZuordnungAdd: TPanel
          Left = 0
          Top = 400
          Width = 555
          Height = 156
          Align = alBottom
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object lblZuMandant: TLabel
            Left = 8
            Top = 8
            Width = 46
            Height = 15
            Caption = 'Mandant'
          end
          object lblZuRolle: TLabel
            Left = 280
            Top = 8
            Width = 27
            Height = 15
            Caption = 'Rolle'
          end
          object lblMandantenHinweis: TLabel
            Left = 8
            Top = 90
            Width = 539
            Height = 60
            AutoSize = False
            WordWrap = True
          end
          object cboZuMandant: TDBLookupComboBox
            Left = 8
            Top = 28
            Width = 260
            Height = 23
            KeyField = 'mandant_id'
            ListField = 'mandanten_name'
            ListSource = dmBenutzer.dsMandantAuswahl
            TabOrder = 0
          end
          object cboZuRolle: TComboBox
            Left = 280
            Top = 28
            Width = 160
            Height = 23
            Style = csDropDownList
            TabOrder = 1
          end
          object btnZuordnen: TButton
            Left = 8
            Top = 56
            Width = 150
            Height = 28
            Caption = 'Mandant zuordnen'
            TabOrder = 2
            OnClick = btnZuordnenClick
          end
          object btnEntfernen: TButton
            Left = 168
            Top = 56
            Width = 150
            Height = 28
            Caption = 'Zuordnung entfernen'
            TabOrder = 3
            OnClick = btnEntfernenClick
          end
        end
        object dbgrdZuordnung: TDBGrid
          Left = 0
          Top = 0
          Width = 555
          Height = 400
          Align = alClient
          DataSource = dmBenutzer.dsBenutzerMandant
          Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgCancelOnExit]
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
  end
  object PaneStyle1: TJvNavPaneStyleManager
    Theme = nptStandard
    Colors.ButtonColorFrom = 16247513
    Colors.ButtonColorTo = 16050326
    Colors.ButtonSelectedColorFrom = 12189695
    Colors.ButtonSelectedColorTo = 4633855
    Colors.ButtonHotColorFrom = 15660791
    Colors.ButtonHotColorTo = 12313087
    Colors.FrameColor = 6045981
    Colors.HeaderColorFrom = 16245453
    Colors.HeaderColorTo = 15966336
    Left = 960
    Top = 120
  end
  object ActionListEdit: TActionList
    Left = 960
    Top = 180
    object actNeuLaden: TAction
      Caption = 'Neu laden'
      OnExecute = actNeuLadenExecute
    end
    object actSperren: TAction
      Caption = 'Sperren'
      Hint = 'Konto deaktivieren - eine Anmeldung ist dann nicht mehr m'#246'glich'
      OnExecute = actSperrenExecute
    end
    object actEntsperren: TAction
      Caption = 'Entsperren'
      Hint = 'Konto wieder aktivieren und Fehlversuche zur'#252'cksetzen'
      OnExecute = actEntsperrenExecute
    end
  end
end
