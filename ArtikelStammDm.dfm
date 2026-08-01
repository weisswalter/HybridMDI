object dmArtikelStamm: TdmArtikelStamm
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblArtikel: TFDTable
    OnNewRecord = tblArtikelNewRecord
    TableName = 'artikel'
    Left = 40
    Top = 32
  end
  object tblArtikelFach: TFDTable
    OnNewRecord = tblArtikelFachNewRecord
    TableName = 'artikel_fach'
    Left = 40
    Top = 96
  end
  object tblArtikelFoto: TFDTable
    OnNewRecord = tblArtikelFotoNewRecord
    TableName = 'artikel_foto'
    Left = 40
    Top = 160
  end
  object dstblArtikel: TDataSource
    DataSet = tblArtikel
    Left = 128
    Top = 32
  end
  object dstblArtikelFach: TDataSource
    DataSet = tblArtikelFach
    Left = 128
    Top = 96
  end
  object dstblArtikelFoto: TDataSource
    DataSet = tblArtikelFoto
    Left = 128
    Top = 160
  end
  object qryBestandBaum: TFDQuery
    Left = 40
    Top = 224
  end
  object qryStueckliste: TFDQuery
    Left = 40
    Top = 288
  end
  object dstblStueckliste: TDataSource
    DataSet = qryStueckliste
    Left = 128
    Top = 288
  end
  object qryStuecklisteBaum: TFDQuery
    Left = 400
    Top = 400
  end
  object dsStuecklisteBaum: TDataSource
    DataSet = qryStuecklisteBaum
    Left = 488
    Top = 400
  end
  object qryArtikelAuswahl: TFDQuery
    Left = 400
    Top = 464
  end
  object dsArtikelAuswahl: TDataSource
    DataSet = qryArtikelAuswahl
    Left = 488
    Top = 464
  end
  object qryVariantenBaum: TFDQuery
    Left = 400
    Top = 528
  end
  object dsVariantenBaum: TDataSource
    DataSet = qryVariantenBaum
    Left = 488
    Top = 528
  end
end
