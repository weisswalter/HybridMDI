object dmKunde: TdmKunde
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object qryKunden: TFDQuery
    Left = 40
    Top = 32
  end
  object dstblKundenListe: TDataSource
    DataSet = qryKunden
    Left = 128
    Top = 32
  end
  object tblPerson: TFDMemTable
    Left = 40
    Top = 96
  end
  object tblKunde: TFDMemTable
    Left = 40
    Top = 160
  end
  object dstblPerson: TDataSource
    DataSet = tblPerson
    Left = 128
    Top = 96
  end
  object dstblKunde: TDataSource
    DataSet = tblKunde
    Left = 128
    Top = 160
  end
  object qryMitarbeiterAuswahl: TFDQuery
    Left = 40
    Top = 224
  end
  object dsMitarbeiterAuswahl: TDataSource
    DataSet = qryMitarbeiterAuswahl
    Left = 128
    Top = 224
  end
  object qryKontakte: TFDQuery
    Left = 40
    Top = 288
  end
  object dstblKontakte: TDataSource
    DataSet = qryKontakte
    Left = 128
    Top = 288
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
