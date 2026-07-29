object dmKlient: TdmKlient
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object qryKlienten: TFDQuery
    Left = 40
    Top = 32
  end
  object dstblKlientenListe: TDataSource
    DataSet = qryKlienten
    Left = 128
    Top = 32
  end
  object tblPerson: TFDTable
    TableName = 'person'
    Left = 40
    Top = 96
  end
  object tblKlient: TFDTable
    TableName = 'klient'
    Left = 40
    Top = 160
  end
  object dstblPerson: TDataSource
    DataSet = tblPerson
    Left = 128
    Top = 96
  end
  object dstblKlient: TDataSource
    DataSet = tblKlient
    Left = 128
    Top = 160
  end
  object qryKundeAuswahl: TFDQuery
    Left = 40
    Top = 224
  end
  object dsKundeAuswahl: TDataSource
    DataSet = qryKundeAuswahl
    Left = 128
    Top = 224
  end
  object qryMitarbeiterAuswahl: TFDQuery
    Left = 40
    Top = 288
  end
  object dsMitarbeiterAuswahl: TDataSource
    DataSet = qryMitarbeiterAuswahl
    Left = 128
    Top = 288
  end
  object qryLeadquelleAuswahl: TFDQuery
    Left = 40
    Top = 352
  end
  object dsLeadquelleAuswahl: TDataSource
    DataSet = qryLeadquelleAuswahl
    Left = 128
    Top = 352
  end
  object qrySemesterAuswahl: TFDQuery
    Left = 40
    Top = 416
  end
  object dsSemesterAuswahl: TDataSource
    DataSet = qrySemesterAuswahl
    Left = 128
    Top = 416
  end
  object qryKlientSemester: TFDQuery
    Left = 40
    Top = 480
  end
  object dstblKlientSemester: TDataSource
    DataSet = qryKlientSemester
    Left = 128
    Top = 480
  end
  object qryEmailUebersicht: TFDQuery
    Left = 224
    Top = 32
  end
  object dstblEmailUebersicht: TDataSource
    DataSet = qryEmailUebersicht
    Left = 312
    Top = 32
  end
  object qryTelefonUebersicht: TFDQuery
    Left = 224
    Top = 96
  end
  object dstblTelefonUebersicht: TDataSource
    DataSet = qryTelefonUebersicht
    Left = 312
    Top = 96
  end
  object qryAdresseUebersicht: TFDQuery
    Left = 224
    Top = 160
  end
  object dstblAdresseUebersicht: TDataSource
    DataSet = qryAdresseUebersicht
    Left = 312
    Top = 160
  end
end
