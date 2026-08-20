object dmKalkulation: TdmKalkulation
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblKalkulation: TFDMemTable
    AfterScroll = tblKalkulationAfterScroll
    Left = 40
    Top = 24
  end
  object dsKalkulation: TDataSource
    DataSet = tblKalkulation
    Left = 160
    Top = 24
  end
  object tblPosition: TFDMemTable
    OnNewRecord = tblPositionNewRecord
    Left = 40
    Top = 80
  end
  object dsPosition: TDataSource
    DataSet = tblPosition
    Left = 160
    Top = 80
  end
  object qryBlatt: TFDQuery
    Left = 40
    Top = 136
  end
  object dsBlatt: TDataSource
    DataSet = qryBlatt
    Left = 160
    Top = 136
  end
  object tblZuschlag: TFDMemTable
    OnNewRecord = tblZuschlagNewRecord
    Left = 40
    Top = 192
  end
  object dsZuschlag: TDataSource
    DataSet = tblZuschlag
    Left = 160
    Top = 192
  end
  object tblKostenart: TFDMemTable
    OnNewRecord = tblKostenartNewRecord
    Left = 40
    Top = 248
  end
  object dsKostenart: TDataSource
    DataSet = tblKostenart
    Left = 160
    Top = 248
  end
  object tblKostenstelle: TFDMemTable
    OnNewRecord = tblKostenstelleNewRecord
    Left = 40
    Top = 304
  end
  object dsKostenstelle: TDataSource
    DataSet = tblKostenstelle
    Left = 160
    Top = 304
  end
  object tblKonto: TFDMemTable
    OnNewRecord = tblKontoNewRecord
    Left = 40
    Top = 360
  end
  object dsKonto: TDataSource
    DataSet = tblKonto
    Left = 160
    Top = 360
  end
  object qryKontoLookup: TFDQuery
    Left = 40
    Top = 416
  end
  object dsKontoLookup: TDataSource
    DataSet = qryKontoLookup
    Left = 160
    Top = 416
  end
  object qryArtikel: TFDQuery
    Left = 40
    Top = 472
  end
  object dsArtikel: TDataSource
    DataSet = qryArtikel
    Left = 160
    Top = 472
  end
end
