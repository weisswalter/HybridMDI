object dmLehrer: TdmLehrer
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object qryLehrer: TFDMemTable
    Left = 40
    Top = 32
  end
  object dstblLehrer: TDataSource
    DataSet = qryLehrer
    Left = 128
    Top = 32
  end
  object tblPerson: TFDMemTable
    Left = 40
    Top = 96
  end
  object dstblPerson: TDataSource
    DataSet = tblPerson
    Left = 128
    Top = 96
  end
  object tblPersonBeziehung: TFDMemTable
    Left = 40
    Top = 160
  end
  object dstblPersonBeziehung: TDataSource
    DataSet = tblPersonBeziehung
    Left = 128
    Top = 160
  end
  object qryKompetenzen: TFDMemTable
    IndexFieldNames = 'person_id;mandant_id'
    MasterSource = dstblLehrer
    MasterFields = 'person_id;mandant_id'
    Left = 40
    Top = 224
  end
  object dstblKompetenzen: TDataSource
    DataSet = qryKompetenzen
    Left = 128
    Top = 224
  end
  object qryKompetenzAuswahl: TFDMemTable
    Left = 296
    Top = 32
  end
  object dsKompetenzAuswahl: TDataSource
    DataSet = qryKompetenzAuswahl
    Left = 384
    Top = 32
  end
  object qryKurse: TFDMemTable
    IndexFieldNames = 'person_id;mandant_id'
    MasterSource = dstblLehrer
    MasterFields = 'person_id;mandant_id'
    Left = 40
    Top = 288
  end
  object dstblKurse: TDataSource
    DataSet = qryKurse
    Left = 128
    Top = 288
  end
end
