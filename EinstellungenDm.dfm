object dmEinstellungen: TdmEinstellungen
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblPersonentyp: TFDMemTable
    Left = 40
    Top = 32
  end
  object tblRollentyp: TFDMemTable
    Left = 40
    Top = 96
  end
  object tblAdressentyp: TFDMemTable
    Left = 40
    Top = 160
  end
  object tblEmailtyp: TFDMemTable
    Left = 40
    Top = 224
  end
  object tblTelefonnummertyp: TFDMemTable
    Left = 40
    Top = 288
  end
  object tblRechnungstyp: TFDMemTable
    Left = 40
    Top = 352
  end
  object tblLeadquellentyp: TFDMemTable
    Left = 40
    Top = 416
  end
  object dstblPersonentyp: TDataSource
    DataSet = tblPersonentyp
    Left = 128
    Top = 32
  end
  object dstblRollentyp: TDataSource
    DataSet = tblRollentyp
    Left = 128
    Top = 96
  end
  object dstblAdressentyp: TDataSource
    DataSet = tblAdressentyp
    Left = 128
    Top = 160
  end
  object dstblEmailtyp: TDataSource
    DataSet = tblEmailtyp
    Left = 128
    Top = 224
  end
  object dstblTelefonnummertyp: TDataSource
    DataSet = tblTelefonnummertyp
    Left = 128
    Top = 288
  end
  object dstblRechnungstyp: TDataSource
    DataSet = tblRechnungstyp
    Left = 128
    Top = 352
  end
  object dstblLeadquellentyp: TDataSource
    DataSet = tblLeadquellentyp
    Left = 128
    Top = 416
  end
  object tblKompetenztyp: TFDMemTable
    Left = 40
    Top = 472
  end
  object dstblKompetenztyp: TDataSource
    DataSet = tblKompetenztyp
    Left = 128
    Top = 472
  end
  object tblKategorie: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired]
    UpdateOptions.CheckRequired = False
    Left = 400
    Top = 300
  end
  object dstblKategorie: TDataSource
    DataSet = tblKategorie
    Left = 496
    Top = 300
  end
  object memWebEinstellung: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired]
    UpdateOptions.CheckRequired = False
    Left = 400
    Top = 400
  end
  object tblWebFarbe: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired]
    UpdateOptions.CheckRequired = False
    Left = 400
    Top = 468
  end
  object dstblWebFarbe: TDataSource
    DataSet = tblWebFarbe
    Left = 496
    Top = 468
  end
end
