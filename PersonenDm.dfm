object dmPersonen: TdmPersonen
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  object FDConnection: TFDConnection
    LoginPrompt = False
    Left = 32
    Top = 32
  end
  object qryPersonen: TFDQuery
    Left = 104
    Top = 32
  end
  object dsPersonen: TDataSource
    Left = 176
    Top = 32
  end
  object qryAdressen: TFDQuery
    Left = 104
    Top = 96
  end
  object dsAdressen: TDataSource
    Left = 176
    Top = 96
  end
  object qryEmails: TFDQuery
    Left = 104
    Top = 160
  end
  object dsEmails: TDataSource
    Left = 176
    Top = 160
  end
  object tblPerson: TFDTable
    AfterPost = tblPersonAfterPost
    IndexFieldNames = 'person_id'
    MasterSource = dstblPersonMandant
    MasterFields = 'person_id'
    Connection = FDConnection
    TableName = 'person'
    Left = 416
    Top = 88
  end
  object tblAdresse: TFDTable
    AfterPost = tblAdresseAfterPost
    IndexFieldNames = 'adresse_id'
    MasterSource = dstblPersonAdresse
    MasterFields = 'adresse_id'
    Connection = FDConnection
    TableName = 'adresse'
    Left = 496
    Top = 88
  end
  object tblEmailadresse: TFDTable
    AfterPost = tblEmailadresseAfterPost
    IndexFieldNames = 'email_id'
    MasterSource = dstblPersonEmail
    MasterFields = 'email_id'
    Connection = FDConnection
    TableName = 'emailadresse'
    Left = 408
    Top = 200
  end
  object tblPersonAdresse: TFDTable
    IndexFieldNames = 'mandant_id;person_id'
    MasterSource = dstblPersonMandant
    MasterFields = 'mandant_id;person_id'
    Connection = FDConnection
    TableName = 'person_adresse'
    Left = 488
    Top = 200
  end
  object tblPersonEmail: TFDTable
    IndexFieldNames = 'mandant_id;person_id'
    MasterSource = dstblPersonMandant
    MasterFields = 'mandant_id;person_id'
    Connection = FDConnection
    TableName = 'person_email'
    Left = 568
    Top = 88
  end
  object tblPersonMandant: TFDTable
    IndexFieldNames = 'mandant_id'
    MasterSource = dstblMandant
    MasterFields = 'mandant_id'
    Connection = FDConnection
    TableName = 'person_mandant'
    Left = 568
    Top = 200
  end
  object tblPersonTyp: TFDTable
    Connection = FDConnection
    TableName = 'person_typ'
    Left = 648
    Top = 88
  end
  object tblAdressentyp: TFDTable
    IndexFieldNames = 'mandant_id'
    MasterSource = dstblMandant
    MasterFields = 'mandant_id'
    Connection = FDConnection
    TableName = 'adressentyp'
    Left = 648
    Top = 200
  end
  object tblEmailtyp: TFDTable
    IndexFieldNames = 'mandant_id'
    MasterSource = dstblMandant
    MasterFields = 'mandant_id'
    Connection = FDConnection
    TableName = 'emailtyp'
    Left = 728
    Top = 88
  end
  object tblTelefonnummertyp: TFDTable
    IndexFieldNames = 'mandant_id'
    MasterSource = dstblMandant
    MasterFields = 'mandant_id'
    Connection = FDConnection
    TableName = 'telefonnummertyp'
    Left = 728
    Top = 200
  end
  object tblTelefonnummer: TFDTable
    AfterPost = tblTelefonnummerAfterPost
    IndexFieldNames = 'telefonnummer_id'
    MasterSource = dstblPersonTelefonnummer
    MasterFields = 'telefonnummer_id'
    Connection = FDConnection
    TableName = 'telefonnummer'
    Left = 808
    Top = 88
  end
  object tblPersonTelefonnummer: TFDTable
    IndexFieldNames = 'mandant_id;person_id'
    MasterSource = dstblPersonMandant
    MasterFields = 'mandant_id;person_id'
    Connection = FDConnection
    TableName = 'person_telefonnummer'
    Left = 808
    Top = 200
  end
  object tblRolleTyp: TFDTable
    IndexFieldNames = 'mandant_id'
    MasterSource = dstblMandant
    MasterFields = 'mandant_id'
    Connection = FDConnection
    TableName = 'rolle_typ'
    Left = 888
    Top = 88
  end
  object tblPersonBeziehung: TFDTable
    IndexFieldNames = 'mandant_id;quell_person_id'
    MasterSource = dstblPersonMandant
    MasterFields = 'mandant_id;person_id'
    Connection = FDConnection
    TableName = 'person_beziehung'
    Left = 888
    Top = 200
  end
  object tblMandant: TFDTable
    Connection = FDConnection
    TableName = 'mandant'
    Left = 968
    Top = 88
  end
  object tblLand: TFDTable
    IndexFieldNames = 'land_id'
    Connection = FDConnection
    TableName = 'land'
    Left = 1048
    Top = 88
  end
  object tblBezirk: TFDTable
    IndexFieldNames = 'land_id'
    MasterSource = dstblAdresse
    MasterFields = 'land_id'
    Connection = FDConnection
    TableName = 'bezirk'
    Left = 1048
    Top = 200
  end
  object dstblPerson: TDataSource
    DataSet = tblPerson
    Left = 416
    Top = 152
  end
  object dstblAdresse: TDataSource
    DataSet = tblAdresse
    Left = 496
    Top = 152
  end
  object dstblEmailadresse: TDataSource
    DataSet = tblEmailadresse
    Left = 408
    Top = 264
  end
  object dstblPersonAdresse: TDataSource
    DataSet = tblPersonAdresse
    Left = 488
    Top = 264
  end
  object dstblPersonEmail: TDataSource
    DataSet = tblPersonEmail
    Left = 568
    Top = 152
  end
  object dstblPersonMandant: TDataSource
    DataSet = tblPersonMandant
    Left = 568
    Top = 264
  end
  object dstblPersonTyp: TDataSource
    DataSet = tblPersonTyp
    Left = 648
    Top = 152
  end
  object dstblAdressentyp: TDataSource
    DataSet = tblAdressentyp
    Left = 648
    Top = 264
  end
  object dstblEmailtyp: TDataSource
    DataSet = tblEmailtyp
    Left = 728
    Top = 152
  end
  object dstblTelefonnummertyp: TDataSource
    DataSet = tblTelefonnummertyp
    Left = 728
    Top = 264
  end
  object dstblTelefonnummer: TDataSource
    DataSet = tblTelefonnummer
    Left = 808
    Top = 152
  end
  object dstblPersonTelefonnummer: TDataSource
    DataSet = tblPersonTelefonnummer
    Left = 808
    Top = 264
  end
  object dstblRolleTyp: TDataSource
    DataSet = tblRolleTyp
    Left = 888
    Top = 152
  end
  object dstblPersonBeziehung: TDataSource
    DataSet = tblPersonBeziehung
    Left = 888
    Top = 264
  end
  object dstblMandant: TDataSource
    DataSet = tblMandant
    Left = 968
    Top = 152
  end
  object dstblLand: TDataSource
    DataSet = tblLand
    Left = 1048
    Top = 152
  end
  object dstblBezirk: TDataSource
    DataSet = tblBezirk
    Left = 1048
    Top = 264
  end
end
