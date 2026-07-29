object dmEinstellungen: TdmEinstellungen
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblPersonentyp: TFDTable
    TableName = 'person_typ'
    Left = 40
    Top = 32
  end
  object tblRollentyp: TFDTable
    TableName = 'rolle_typ'
    Left = 40
    Top = 96
  end
  object tblAdressentyp: TFDTable
    TableName = 'adressentyp'
    Left = 40
    Top = 160
  end
  object tblEmailtyp: TFDTable
    TableName = 'emailtyp'
    Left = 40
    Top = 224
  end
  object tblTelefonnummertyp: TFDTable
    TableName = 'telefonnummertyp'
    Left = 40
    Top = 288
  end
  object tblRechnungstyp: TFDTable
    TableName = 'rechnungstyp'
    Left = 40
    Top = 352
  end
  object tblLeadquellentyp: TFDTable
    TableName = 'leadquelle_typ'
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
end
