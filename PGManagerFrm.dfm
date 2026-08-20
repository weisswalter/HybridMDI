object frmPGManager: TfrmPGManager
  Left = 0
  Top = 0
  Caption = 'DB-Manager  TRTHeisenberg'
  ClientHeight = 684
  ClientWidth = 860
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
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 860
    Height = 665
    ActivePage = TabSheet3
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'SQL'
      object JvMemo1: TJvMemo
        Left = 0
        Top = 0
        Width = 852
        Height = 185
        Align = alTop
        Lines.Strings = (
          'SELECT * FROM pg_database ORDER BY datname;')
        TabOrder = 0
      end
      object btnSQL: TButton
        Left = 8
        Top = 200
        Width = 150
        Height = 30
        Caption = 'Skript ausf'#252'hren'
        TabOrder = 1
        OnClick = btnSQLClick
      end
      object btnQuery: TButton
        Left = 168
        Top = 200
        Width = 150
        Height = 30
        Caption = 'Abfrage (SELECT)'
        TabOrder = 2
        OnClick = btnQueryClick
      end
      object btnLoadSQL: TButton
        Left = 328
        Top = 200
        Width = 150
        Height = 30
        Caption = 'SQL-Datei laden'#8230
        TabOrder = 3
        OnClick = btnLoadSQLClick
      end
      object DBGrid1: TDBGrid
        Left = 0
        Top = 250
        Width = 852
        Height = 385
        Align = alBottom
        TabOrder = 4
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
      object JvDBNavigator1: TJvDBNavigator
        Left = 512
        Top = 202
        Width = 240
        Height = 25
        TabOrder = 5
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Database'
      ImageIndex = 1
      object grpTablespace: TGroupBox
        Left = 8
        Top = 8
        Width = 836
        Height = 100
        Caption = 'Tablespace anlegen'
        TabOrder = 0
        object lblTsName: TLabel
          Left = 8
          Top = 28
          Width = 35
          Height = 15
          Caption = 'Name:'
        end
        object lblTsPath: TLabel
          Left = 280
          Top = 28
          Width = 27
          Height = 15
          Caption = 'Pfad:'
        end
        object edtTsName: TEdit
          Left = 56
          Top = 24
          Width = 200
          Height = 23
          TabOrder = 0
          Text = 'docmanager_ts'
        end
        object edtTsPath: TEdit
          Left = 320
          Top = 24
          Width = 400
          Height = 23
          TabOrder = 1
          Text = 'C:/Databases/PostgreSQL/DocManager'
        end
        object btnCreateTablespace: TButton
          Left = 8
          Top = 60
          Width = 160
          Height = 28
          Caption = 'Tablespace anlegen'
          TabOrder = 2
          OnClick = btnCreateTablespaceClick
        end
      end
      object grpDatabase: TGroupBox
        Left = 8
        Top = 120
        Width = 836
        Height = 100
        Caption = 'Datenbank anlegen'
        TabOrder = 1
        object lblDbName: TLabel
          Left = 8
          Top = 28
          Width = 35
          Height = 15
          Caption = 'Name:'
        end
        object lblDbTs: TLabel
          Left = 280
          Top = 28
          Width = 116
          Height = 15
          Caption = 'Tablespace (optional):'
        end
        object edtDbName: TEdit
          Left = 56
          Top = 24
          Width = 200
          Height = 23
          TabOrder = 0
          Text = 'docmanager'
        end
        object edtDbTablespace: TEdit
          Left = 408
          Top = 24
          Width = 200
          Height = 23
          TabOrder = 1
          Text = 'docmanager_ts'
        end
        object btnCreateDatabase: TButton
          Left = 8
          Top = 60
          Width = 160
          Height = 28
          Caption = 'Datenbank anlegen'
          TabOrder = 2
          OnClick = btnCreateDatabaseClick
        end
      end
      object MemoLog: TMemo
        Left = 8
        Top = 232
        Width = 836
        Height = 400
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 2
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Verbindungen'
      ImageIndex = 2
      object grpConn: TGroupBox
        Left = 8
        Top = 8
        Width = 836
        Height = 175
        Caption = 'Verbindung'
        TabOrder = 0
        object lblHost: TLabel
          Left = 8
          Top = 28
          Width = 28
          Height = 15
          Caption = 'Host:'
        end
        object lblPort: TLabel
          Left = 212
          Top = 28
          Width = 25
          Height = 15
          Caption = 'Port:'
        end
        object lblUser: TLabel
          Left = 316
          Top = 28
          Width = 49
          Height = 15
          Caption = 'Benutzer:'
        end
        object lblPwd: TLabel
          Left = 504
          Top = 28
          Width = 50
          Height = 15
          Caption = 'Passwort:'
        end
        object lblDatabase: TLabel
          Left = 8
          Top = 84
          Width = 60
          Height = 15
          Caption = 'Datenbank:'
        end
        object lblTablespace: TLabel
          Left = 232
          Top = 84
          Width = 61
          Height = 15
          Caption = 'Tablespace:'
        end
        object lblProfileName: TLabel
          Left = 8
          Top = 140
          Width = 31
          Height = 15
          Caption = 'Profil:'
        end
        object lblConnStatus: TLabel
          Left = 680
          Top = 84
          Width = 50
          Height = 15
          Caption = 'getrennt'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtHost: TEdit
          Left = 8
          Top = 48
          Width = 180
          Height = 23
          TabOrder = 0
          Text = 'localhost'
        end
        object edtPort: TEdit
          Left = 212
          Top = 48
          Width = 80
          Height = 23
          TabOrder = 1
          Text = '5455'
        end
        object edtUser: TEdit
          Left = 316
          Top = 48
          Width = 160
          Height = 23
          TabOrder = 2
          Text = 'postgres'
        end
        object edtPassword: TEdit
          Left = 504
          Top = 48
          Width = 160
          Height = 23
          PasswordChar = '*'
          TabOrder = 3
          Text = #9'a4cX7pAp29WRK7XHkGHBzs4DIhjAM14Z'
        end
        object btnConnect: TButton
          Left = 680
          Top = 44
          Width = 80
          Height = 30
          Caption = 'Verbinden'
          TabOrder = 4
          OnClick = btnConnectClick
        end
        object btnDisconnect: TButton
          Left = 764
          Top = 44
          Width = 64
          Height = 30
          Caption = 'Trennen'
          TabOrder = 5
          OnClick = btnDisconnectClick
        end
        object edtDatabase: TEdit
          Left = 72
          Top = 80
          Width = 150
          Height = 23
          TabOrder = 6
          Text = 'postgres'
        end
        object edtTablespace: TEdit
          Left = 304
          Top = 80
          Width = 160
          Height = 23
          TabOrder = 7
        end
        object btnTestConnection: TButton
          Left = 504
          Top = 108
          Width = 160
          Height = 26
          Caption = 'Verbindung testen'
          TabOrder = 8
          OnClick = btnTestConnectionClick
        end
        object edtProfileName: TEdit
          Left = 56
          Top = 136
          Width = 160
          Height = 23
          TabOrder = 9
          Text = 'localhost-postgres'
        end
        object btnSaveProfile: TButton
          Left = 232
          Top = 134
          Width = 130
          Height = 26
          Caption = 'Profil speichern'
          TabOrder = 10
          OnClick = btnSaveProfileClick
        end
        object btnSaveJSON: TButton
          Left = 376
          Top = 134
          Width = 130
          Height = 26
          Caption = 'JSON speichern'
          TabOrder = 11
          OnClick = btnSaveJSONClick
        end
        object btnLoadJSON: TButton
          Left = 520
          Top = 134
          Width = 130
          Height = 26
          Caption = 'JSON laden'
          TabOrder = 12
          OnClick = btnLoadJSONClick
        end
      end
      object grpDatabases: TGroupBox
        Left = 8
        Top = 192
        Width = 412
        Height = 200
        Caption = 'Datenbanken (Doppelklick = verbinden + Feld)'
        TabOrder = 1
        object DBGrid3: TDBGrid
          Left = 8
          Top = 20
          Width = 396
          Height = 140
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          OnDblClick = DBGrid3DblClick
        end
        object btnLoadDatabases: TButton
          Left = 8
          Top = 168
          Width = 140
          Height = 26
          Caption = 'Datenbanken laden'
          TabOrder = 1
          OnClick = btnLoadDatabasesClick
        end
      end
      object grpTablespaces: TGroupBox
        Left = 432
        Top = 192
        Width = 412
        Height = 200
        Caption = 'Tablespaces (Doppelklick = Feld)'
        TabOrder = 2
        object DBGrid4: TDBGrid
          Left = 8
          Top = 20
          Width = 396
          Height = 140
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          OnDblClick = DBGrid4DblClick
        end
        object btnLoadTablespaces: TButton
          Left = 8
          Top = 168
          Width = 140
          Height = 26
          Caption = 'Tablespaces laden'
          TabOrder = 1
          OnClick = btnLoadTablespacesClick
        end
      end
      object grpProfiles: TGroupBox
        Left = 8
        Top = 400
        Width = 836
        Height = 232
        Caption = 'Gespeicherte Profile (Doppelklick = verwenden)'
        TabOrder = 3
        object DBGrid2: TDBGrid
          Left = 8
          Top = 20
          Width = 820
          Height = 170
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          OnDblClick = DBGrid2DblClick
        end
        object btnUseProfile: TButton
          Left = 8
          Top = 198
          Width = 130
          Height = 26
          Caption = 'Profil verwenden'
          TabOrder = 1
          OnClick = btnUseProfileClick
        end
        object btnDeleteProfile: TButton
          Left = 152
          Top = 198
          Width = 120
          Height = 26
          Caption = 'Profil l'#246'schen'
          TabOrder = 2
          OnClick = btnDeleteProfileClick
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Tabelle'
      ImageIndex = 3
      object pnlTableTop: TPanel
        Left = 0
        Top = 0
        Width = 852
        Height = 110
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblTableName: TLabel
          Left = 8
          Top = 12
          Width = 77
          Height = 15
          Caption = 'Tabellenname:'
        end
        object edtTableName: TEdit
          Left = 8
          Top = 32
          Width = 300
          Height = 23
          TabOrder = 0
          Text = 'dokument'
        end
        object btnOpenTable: TButton
          Left = 320
          Top = 30
          Width = 140
          Height = 28
          Caption = #214'ffnen / Editieren'
          TabOrder = 1
          OnClick = btnOpenTableClick
        end
        object navTable: TJvDBNavigator
          Left = 472
          Top = 31
          Width = 300
          Height = 26
          TabOrder = 2
        end
        object chkConnected: TCheckBox
          Left = 8
          Top = 82
          Width = 100
          Height = 17
          Caption = 'Verbunden'
          Enabled = False
          TabOrder = 3
        end
        object btnLoadTables: TButton
          Left = 168
          Top = 78
          Width = 140
          Height = 26
          Caption = 'Tabellen laden'
          TabOrder = 4
          OnClick = btnLoadTablesClick
        end
      end
      object pnlTablesLeft: TPanel
        Left = 0
        Top = 110
        Width = 240
        Height = 525
        Align = alLeft
        BevelOuter = bvNone
        Caption = ' '
        TabOrder = 1
        object dgTables: TDBGrid
          Left = 0
          Top = 0
          Width = 240
          Height = 525
          Align = alClient
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          OnDblClick = dgTablesDblClick
        end
      end
      object DBGrid5: TDBGrid
        Left = 240
        Top = 110
        Width = 612
        Height = 525
        Align = alClient
        TabOrder = 2
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 665
    Width = 860
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = '  Datenbank: (nicht verbunden)'
  end
  object OpenDialogSQL: TOpenDialog
    Filter = 'SQL-Dateien (*.sql)|*.sql|Alle Dateien (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 704
    Top = 24
  end
end
