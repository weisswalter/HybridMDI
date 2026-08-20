object dmWebEditor: TdmWebEditor
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblNavbar: TFDMemTable
    Left = 32
    Top = 24
  end
  object dsNavbar: TDataSource
    Left = 32
    Top = 96
  end
  object tblNavbarTextAlle: TFDMemTable
    Left = 128
    Top = 24
  end
  object tblNavbarText: TFDMemTable
    Left = 224
    Top = 24
  end
  object dsNavbarText: TDataSource
    Left = 224
    Top = 96
  end
  object tblContent: TFDMemTable
    Left = 320
    Top = 24
  end
  object dsContent: TDataSource
    Left = 320
    Top = 96
  end
  object tblContentTextAlle: TFDMemTable
    Left = 416
    Top = 24
  end
  object tblContentText: TFDMemTable
    Left = 496
    Top = 24
  end
  object dsContentText: TDataSource
    Left = 496
    Top = 96
  end
  object tblDokument: TFDMemTable
    Left = 128
    Top = 96
  end
end
