object dmKurs: TdmKurs
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblKurs: TFDTable
    OnNewRecord = tblKursNewRecord
    TableName = 'kurs'
    Left = 40
    Top = 32
  end
  object dstblKurs: TDataSource
    DataSet = tblKurs
    Left = 128
    Top = 32
  end
  object qryUnterkurse: TFDQuery
    Left = 40
    Top = 96
  end
  object dstblUnterkurse: TDataSource
    DataSet = qryUnterkurse
    Left = 128
    Top = 96
  end
  object qryKompetenzen: TFDQuery
    Left = 40
    Top = 160
  end
  object dstblKompetenzen: TDataSource
    DataSet = qryKompetenzen
    Left = 128
    Top = 160
  end
  object qryMaterial: TFDQuery
    Left = 40
    Top = 224
  end
  object dstblMaterial: TDataSource
    DataSet = qryMaterial
    Left = 128
    Top = 224
  end
  object qryDurchfuehrungen: TFDQuery
    Left = 40
    Top = 288
  end
  object dstblDurchfuehrungen: TDataSource
    DataSet = qryDurchfuehrungen
    Left = 128
    Top = 288
  end
  object qryTermine: TFDQuery
    Left = 40
    Top = 352
  end
  object dstblTermine: TDataSource
    DataSet = qryTermine
    Left = 128
    Top = 352
  end
  object qryTeilnehmer: TFDQuery
    Left = 40
    Top = 416
  end
  object dstblTeilnehmer: TDataSource
    DataSet = qryTeilnehmer
    Left = 128
    Top = 416
  end
  object qryKursAuswahl: TFDQuery
    Left = 264
    Top = 32
  end
  object dsKursAuswahl: TDataSource
    DataSet = qryKursAuswahl
    Left = 352
    Top = 32
  end
  object qryKompetenzAuswahl: TFDQuery
    Left = 264
    Top = 96
  end
  object dsKompetenzAuswahl: TDataSource
    DataSet = qryKompetenzAuswahl
    Left = 352
    Top = 96
  end
  object qryArtikelAuswahl: TFDQuery
    Left = 264
    Top = 160
  end
  object dsArtikelAuswahl: TDataSource
    DataSet = qryArtikelAuswahl
    Left = 352
    Top = 160
  end
  object qryLehrerAuswahl: TFDQuery
    Left = 264
    Top = 224
  end
  object dsLehrerAuswahl: TDataSource
    DataSet = qryLehrerAuswahl
    Left = 352
    Top = 224
  end
  object qryRaumAuswahl: TFDQuery
    Left = 264
    Top = 288
  end
  object dsRaumAuswahl: TDataSource
    DataSet = qryRaumAuswahl
    Left = 352
    Top = 288
  end
  object qrySemesterAuswahl: TFDQuery
    Left = 264
    Top = 352
  end
  object dsSemesterAuswahl: TDataSource
    DataSet = qrySemesterAuswahl
    Left = 352
    Top = 352
  end
  object qryPersonAuswahl: TFDQuery
    Left = 264
    Top = 416
  end
  object dsPersonAuswahl: TDataSource
    DataSet = qryPersonAuswahl
    Left = 352
    Top = 416
  end
  object qryBelegung: TFDQuery
    Left = 296
    Top = 480
  end
  object dsBelegung: TDataSource
    DataSet = qryBelegung
    Left = 384
    Top = 480
  end
  object qryRaumEignung: TFDQuery
    Left = 296
    Top = 544
  end
  object dsRaumEignung: TDataSource
    DataSet = qryRaumEignung
    Left = 384
    Top = 544
  end
  object qryLehrerEignung: TFDQuery
    Left = 296
    Top = 608
  end
  object dsLehrerEignung: TDataSource
    DataSet = qryLehrerEignung
    Left = 384
    Top = 608
  end
  object qryBaukasten: TFDQuery
    Left = 296
    Top = 672
  end
  object dsBaukasten: TDataSource
    DataSet = qryBaukasten
    Left = 384
    Top = 672
  end
end
