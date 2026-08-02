object dmKalkulation: TdmKalkulation
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblKalkulation: TFDTable
    AfterScroll = tblKalkulationAfterScroll
    TableName = 'kalkulation'
    Left = 40
    Top = 24
  end
  object dsKalkulation: TDataSource
    DataSet = tblKalkulation
    Left = 160
    Top = 24
  end
  object tblPosition: TFDTable
    OnNewRecord = tblPositionNewRecord
    TableName = 'kalkulation_position'
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
  object tblZuschlag: TFDTable
    OnNewRecord = tblZuschlagNewRecord
    TableName = 'zuschlagssatz'
    Left = 40
    Top = 192
  end
  object dsZuschlag: TDataSource
    DataSet = tblZuschlag
    Left = 160
    Top = 192
  end
  object tblKostenart: TFDTable
    OnNewRecord = tblKostenartNewRecord
    TableName = 'kostenart'
    Left = 40
    Top = 248
  end
  object dsKostenart: TDataSource
    DataSet = tblKostenart
    Left = 160
    Top = 248
  end
  object tblKostenstelle: TFDTable
    OnNewRecord = tblKostenstelleNewRecord
    TableName = 'kostenstelle'
    Left = 40
    Top = 304
  end
  object dsKostenstelle: TDataSource
    DataSet = tblKostenstelle
    Left = 160
    Top = 304
  end
  object tblKonto: TFDTable
    OnNewRecord = tblKontoNewRecord
    TableName = 'konto'
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
