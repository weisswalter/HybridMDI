object dmAnwesenheit: TdmAnwesenheit
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object qryTag: TFDQuery
    Left = 40
    Top = 32
  end
  object dstblTag: TDataSource
    DataSet = qryTag
    Left = 128
    Top = 32
  end
  object qryCheck: TFDQuery
    Left = 40
    Top = 96
  end
  object dstblCheck: TDataSource
    DataSet = qryCheck
    Left = 128
    Top = 96
  end
  object qryStempel: TFDQuery
    Left = 40
    Top = 160
  end
  object dstblStempel: TDataSource
    DataSet = qryStempel
    Left = 128
    Top = 160
  end
  object qryAbwesenheit: TFDQuery
    Left = 40
    Top = 224
  end
  object dstblAbwesenheit: TDataSource
    DataSet = qryAbwesenheit
    Left = 128
    Top = 224
  end
  object qryRegime: TFDQuery
    Left = 40
    Top = 288
  end
  object dstblRegime: TDataSource
    DataSet = qryRegime
    Left = 128
    Top = 288
  end
  object qryMonat: TFDQuery
    Left = 40
    Top = 352
  end
  object dstblMonat: TDataSource
    DataSet = qryMonat
    Left = 128
    Top = 352
  end
  object qryFerien: TFDQuery
    Left = 40
    Top = 416
  end
  object dstblFerien: TDataSource
    DataSet = qryFerien
    Left = 128
    Top = 416
  end
  object qryPersonAuswahl: TFDQuery
    Left = 296
    Top = 32
  end
  object dsPersonAuswahl: TDataSource
    DataSet = qryPersonAuswahl
    Left = 384
    Top = 32
  end
  object qryArtAuswahl: TFDQuery
    Left = 296
    Top = 96
  end
  object dsArtAuswahl: TDataSource
    DataSet = qryArtAuswahl
    Left = 384
    Top = 96
  end
  object qryRasterAuswahl: TFDQuery
    Left = 296
    Top = 160
  end
  object dsRasterAuswahl: TDataSource
    DataSet = qryRasterAuswahl
    Left = 384
    Top = 160
  end
  object qryAdresseAuswahl: TFDQuery
    Left = 296
    Top = 224
  end
  object dsAdresseAuswahl: TDataSource
    DataSet = qryAdresseAuswahl
    Left = 384
    Top = 224
  end
end
