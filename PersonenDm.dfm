object dmPersonen: TdmPersonen
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  object dsPersonen: TDataSource
    Left = 176
    Top = 32
  end
  object dsAdressen: TDataSource
    Left = 176
    Top = 96
  end
  object dsEmails: TDataSource
    Left = 152
    Top = 168
  end
  object tblPerson: TFDMemTable
    AfterPost = tblPersonAfterPost
    IndexFieldNames = 'person_id'
    MasterSource = dstblPersonMandant
    MasterFields = 'person_id'
    Left = 416
    Top = 88
  end
  object tblAdresse: TFDMemTable
    AfterPost = tblAdresseAfterPost
    IndexFieldNames = 'adresse_id'
    MasterSource = dstblPersonAdresse
    MasterFields = 'adresse_id'
    Left = 496
    Top = 88
  end
  object tblEmailadresse: TFDMemTable
    AfterPost = tblEmailadresseAfterPost
    IndexFieldNames = 'email_id'
    MasterSource = dstblPersonEmail
    MasterFields = 'email_id'
    Left = 408
    Top = 200
  end
  object tblPersonAdresse: TFDMemTable
    IndexFieldNames = 'mandant_id;person_id'
    MasterSource = dstblPersonMandant
    MasterFields = 'mandant_id;person_id'
    Left = 488
    Top = 200
  end
  object tblPersonEmail: TFDMemTable
    IndexFieldNames = 'mandant_id;person_id'
    MasterSource = dstblPersonMandant
    MasterFields = 'mandant_id;person_id'
    Left = 568
    Top = 88
  end
  object tblPersonMandant: TFDMemTable
    IndexFieldNames = 'mandant_id'
    MasterSource = dstblMandant
    MasterFields = 'mandant_id'
    Left = 568
    Top = 200
  end
  object tblPersonTyp: TFDMemTable
    Left = 648
    Top = 88
  end
  object tblAdressentyp: TFDMemTable
    IndexFieldNames = 'mandant_id'
    MasterSource = dstblMandant
    MasterFields = 'mandant_id'
    Left = 648
    Top = 200
  end
  object tblEmailtyp: TFDMemTable
    IndexFieldNames = 'mandant_id'
    MasterSource = dstblMandant
    MasterFields = 'mandant_id'
    Left = 728
    Top = 88
  end
  object tblTelefonnummertyp: TFDMemTable
    IndexFieldNames = 'mandant_id'
    MasterSource = dstblMandant
    MasterFields = 'mandant_id'
    Left = 728
    Top = 200
  end
  object tblTelefonnummer: TFDMemTable
    AfterPost = tblTelefonnummerAfterPost
    IndexFieldNames = 'telefonnummer_id'
    MasterSource = dstblPersonTelefonnummer
    MasterFields = 'telefonnummer_id'
    Left = 808
    Top = 88
  end
  object tblPersonTelefonnummer: TFDMemTable
    IndexFieldNames = 'mandant_id;person_id'
    MasterSource = dstblPersonMandant
    MasterFields = 'mandant_id;person_id'
    Left = 808
    Top = 200
  end
  object tblRolleTyp: TFDMemTable
    IndexFieldNames = 'mandant_id'
    MasterSource = dstblMandant
    MasterFields = 'mandant_id'
    Left = 888
    Top = 88
  end
  object tblPersonBeziehung: TFDMemTable
    IndexFieldNames = 'mandant_id;quell_person_id'
    MasterSource = dstblPersonMandant
    MasterFields = 'mandant_id;person_id'
    Left = 888
    Top = 200
  end
  object tblMandant: TFDMemTable
    Left = 968
    Top = 88
  end
  object tblLand: TFDMemTable
    IndexFieldNames = 'land_id'
    Left = 1048
    Top = 88
  end
  object tblBezirk: TFDMemTable
    IndexFieldNames = 'land_id'
    MasterSource = dstblAdresse
    MasterFields = 'land_id'
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
