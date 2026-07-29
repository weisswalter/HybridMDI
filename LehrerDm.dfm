object dmLehrer: TdmLehrer
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object qryLehrer: TFDQuery
    Left = 40
    Top = 32
  end
  object dstblLehrer: TDataSource
    DataSet = qryLehrer
    Left = 128
    Top = 32
  end
  object tblPerson: TFDTable
    TableName = 'person'
    Left = 40
    Top = 96
  end
  object dstblPerson: TDataSource
    DataSet = tblPerson
    Left = 128
    Top = 96
  end
  object tblPersonBeziehung: TFDTable
    TableName = 'person_beziehung'
    Left = 40
    Top = 160
  end
  object dstblPersonBeziehung: TDataSource
    DataSet = tblPersonBeziehung
    Left = 128
    Top = 160
  end
  object qryKompetenzen: TFDQuery
    Left = 40
    Top = 224
  end
  object dstblKompetenzen: TDataSource
    DataSet = qryKompetenzen
    Left = 128
    Top = 224
  end
  object qryKompetenzAuswahl: TFDQuery
    Left = 296
    Top = 32
  end
  object dsKompetenzAuswahl: TDataSource
    DataSet = qryKompetenzAuswahl
    Left = 384
    Top = 32
  end
  object qryKurse: TFDQuery
    Left = 40
    Top = 288
  end
  object dstblKurse: TDataSource
    DataSet = qryKurse
    Left = 128
    Top = 288
  end
end
