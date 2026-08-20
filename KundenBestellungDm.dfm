object dmKundenBestellung: TdmKundenBestellung
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblBeleg: TFDMemTable
    OnNewRecord = tblBelegNewRecord
    Left = 40
    Top = 32
  end
  object tblBelegPosition: TFDMemTable
    OnNewRecord = tblBelegPositionNewRecord
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
  object qryPersonAuswahl: TFDMemTable
    Left = 40
    Top = 160
  end
  object dsPersonAuswahl: TDataSource
    DataSet = qryPersonAuswahl
    Left = 128
    Top = 160
  end
  object qryRechnungstypAuswahl: TFDMemTable
    Left = 40
    Top = 224
  end
  object dsRechnungstypAuswahl: TDataSource
    DataSet = qryRechnungstypAuswahl
    Left = 128
    Top = 224
  end
end
