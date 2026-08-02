object dmLohn: TdmLohn
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object qryPerioden: TFDQuery
    Left = 40
    Top = 32
  end
  object dsPerioden: TDataSource
    DataSet = qryPerioden
    Left = 152
    Top = 32
  end
  object qryPositionen: TFDQuery
    Left = 40
    Top = 96
  end
  object dsPositionen: TDataSource
    DataSet = qryPositionen
    Left = 152
    Top = 96
  end
  object tblLohn: TFDTable
    OnNewRecord = tblLohnNewRecord
    TableName = 'person_lohn'
    Left = 40
    Top = 160
  end
  object dsLohn: TDataSource
    DataSet = tblLohn
    Left = 152
    Top = 160
  end
  object tblZulage: TFDTable
    OnNewRecord = tblZulageNewRecord
    TableName = 'lohn_zulage'
    Left = 40
    Top = 224
  end
  object dsZulage: TDataSource
    DataSet = tblZulage
    Left = 152
    Top = 224
  end
  object tblAbzug: TFDTable
    OnNewRecord = tblAbzugNewRecord
    TableName = 'lohn_abzugsart'
    Left = 40
    Top = 288
  end
  object dsAbzug: TDataSource
    DataSet = tblAbzug
    Left = 152
    Top = 288
  end
  object qryPersonen: TFDQuery
    Left = 40
    Top = 352
  end
  object dsPersonen: TDataSource
    DataSet = qryPersonen
    Left = 152
    Top = 352
  end
end
