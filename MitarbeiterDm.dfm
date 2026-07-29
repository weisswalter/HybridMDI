object dmMitarbeiter: TdmMitarbeiter
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object qryMitarbeiter: TFDQuery
    Left = 40
    Top = 32
  end
  object dstblMitarbeiterListe: TDataSource
    DataSet = qryMitarbeiter
    Left = 128
    Top = 32
  end
  object tblPerson: TFDTable
    TableName = 'person'
    Left = 40
    Top = 96
  end
  object tblPersonBeziehung: TFDTable
    TableName = 'person_beziehung'
    Left = 40
    Top = 160
  end
  object dstblPerson: TDataSource
    DataSet = tblPerson
    Left = 128
    Top = 96
  end
  object dstblPersonBeziehung: TDataSource
    DataSet = tblPersonBeziehung
    Left = 128
    Top = 160
  end
  object qryRolleAuswahl: TFDQuery
    Left = 40
    Top = 224
  end
  object dsRolleAuswahl: TDataSource
    DataSet = qryRolleAuswahl
    Left = 128
    Top = 224
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
