object dmLagerEntnahme: TdmLagerEntnahme
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblBeleg: TFDTable
    OnNewRecord = tblBelegNewRecord
    TableName = 'beleg'
    Left = 40
    Top = 32
  end
  object tblBelegPosition: TFDTable
    OnNewRecord = tblBelegPositionNewRecord
    TableName = 'beleg_position'
    Left = 40
    Top = 96
  end
  object dstblBeleg: TDataSource
    DataSet = tblBeleg
    Left = 128
    Top = 32
  end
  object dstblBelegPosition: TDataSource
    DataSet = tblBelegPosition
    Left = 128
    Top = 96
  end
  object qryPersonAuswahl: TFDQuery
    Left = 40
    Top = 160
  end
  object dsPersonAuswahl: TDataSource
    DataSet = qryPersonAuswahl
    Left = 128
    Top = 160
  end
  object qryRechnungstypAuswahl: TFDQuery
    Left = 40
    Top = 224
  end
  object dsRechnungstypAuswahl: TDataSource
    DataSet = qryRechnungstypAuswahl
    Left = 128
    Top = 224
  end
end
