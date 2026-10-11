object dmAnlagen: TdmAnlagen
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblAnlage: TFDMemTable
    OnNewRecord = tblAnlageNewRecord
    Left = 40
    Top = 32
  end
  object dsAnlage: TDataSource
    DataSet = tblAnlage
    Left = 152
    Top = 32
  end
  object qryPlan: TFDMemTable
    IndexFieldNames = 'anlage_id;jahr'
    MasterSource = dsAnlage
    MasterFields = 'anlage_id'
    Left = 40
    Top = 96
  end
  object dsPlan: TDataSource
    DataSet = qryPlan
    Left = 152
    Top = 96
  end
  object qryKonto: TFDMemTable
    Left = 40
    Top = 160
  end
  object dsKonto: TDataSource
    DataSet = qryKonto
    Left = 152
    Top = 160
  end
  object qryRaum: TFDMemTable
    Left = 40
    Top = 224
  end
  object dsRaum: TDataSource
    DataSet = qryRaum
    Left = 152
    Top = 224
  end
  object qryArtikel: TFDMemTable
    Left = 40
    Top = 288
  end
  object dsArtikel: TDataSource
    DataSet = qryArtikel
    Left = 152
    Top = 288
  end
  object tblAnlageFoto: TFDMemTable
    IndexFieldNames = 'anlage_id'
    MasterSource = dsAnlage
    MasterFields = 'anlage_id'
    Left = 40
    Top = 352
  end
  object dstblAnlageFoto: TDataSource
    DataSet = tblAnlageFoto
    Left = 152
    Top = 352
  end
end
