object dmAnlagen: TdmAnlagen
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblAnlage: TFDTable
    AfterScroll = tblAnlageAfterScroll
    OnNewRecord = tblAnlageNewRecord
    TableName = 'anlage'
    Left = 40
    Top = 32
  end
  object dsAnlage: TDataSource
    DataSet = tblAnlage
    Left = 152
    Top = 32
  end
  object qryPlan: TFDQuery
    Left = 40
    Top = 96
  end
  object dsPlan: TDataSource
    DataSet = qryPlan
    Left = 152
    Top = 96
  end
  object qryKonto: TFDQuery
    Left = 40
    Top = 160
  end
  object dsKonto: TDataSource
    DataSet = qryKonto
    Left = 152
    Top = 160
  end
  object qryRaum: TFDQuery
    Left = 40
    Top = 224
  end
  object dsRaum: TDataSource
    DataSet = qryRaum
    Left = 152
    Top = 224
  end
end
