object dmLager: TdmLager
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 300
  Width = 500
  object FDConnection: TFDConnection
    LoginPrompt = False
    Left = 32
    Top = 32
  end
  object tblMandant: TFDTable
    Connection = FDConnection
    TableName = 'mandant'
    Left = 128
    Top = 32
  end
  object tblLager: TFDTable
    IndexFieldNames = 'mandant_id'
    MasterSource = dstblMandant
    MasterFields = 'mandant_id'
    Connection = FDConnection
    TableName = 'lager'
    Left = 224
    Top = 32
  end
  object tblAdressinfo: TFDTable
    Connection = FDConnection
    TableName = 'adressinfo'
    Left = 400
    Top = 32
  end
  object tblRaum: TFDTable
    Connection = FDConnection
    TableName = 'raum'
    Left = 480
    Top = 32
  end
  object tblAusstattung: TFDTable
    Connection = FDConnection
    TableName = 'ausstattung'
    Left = 560
    Top = 32
  end
  object tblRaumAusstattung: TFDTable
    IndexFieldNames = 'raum_id'
    MasterSource = dstblRaum
    MasterFields = 'raum_id'
    Connection = FDConnection
    TableName = 'raum_ausstattung'
    Left = 640
    Top = 32
  end
  object tblRegal: TFDTable
    Connection = FDConnection
    TableName = 'regal'
    Left = 720
    Top = 32
  end
  object tblRegalFach: TFDTable
    IndexFieldNames = 'regal_id'
    MasterSource = dstblRegal
    MasterFields = 'regal_id'
    Connection = FDConnection
    TableName = 'regal_fach'
    Left = 800
    Top = 32
  end
  object qryAdressen: TFDQuery
    Left = 320
    Top = 32
  end
  object qryAdressinfoLookup: TFDQuery
    Left = 400
    Top = 96
  end
  object qryRaumLookup: TFDQuery
    Left = 480
    Top = 96
  end
  object qryRegalLookup: TFDQuery
    Left = 720
    Top = 96
  end
  object qryEinheitLookup: TFDQuery
    Left = 800
    Top = 96
  end
  object dstblMandant: TDataSource
    DataSet = tblMandant
    Left = 128
    Top = 96
  end
  object dstblLager: TDataSource
    DataSet = tblLager
    Left = 224
    Top = 96
  end
  object dstblAdressinfo: TDataSource
    DataSet = tblAdressinfo
    Left = 400
    Top = 160
  end
  object dstblRaum: TDataSource
    DataSet = tblRaum
    Left = 480
    Top = 160
  end
  object dstblAusstattung: TDataSource
    DataSet = tblAusstattung
    Left = 560
    Top = 96
  end
  object dstblRaumAusstattung: TDataSource
    DataSet = tblRaumAusstattung
    Left = 640
    Top = 96
  end
  object dstblRegal: TDataSource
    DataSet = tblRegal
    Left = 720
    Top = 160
  end
  object dstblRegalFach: TDataSource
    DataSet = tblRegalFach
    Left = 800
    Top = 160
  end
  object dsAdressen: TDataSource
    DataSet = qryAdressen
    Left = 320
    Top = 96
  end
  object dsAdressinfoLookup: TDataSource
    DataSet = qryAdressinfoLookup
    Left = 400
    Top = 224
  end
  object dsRaumLookup: TDataSource
    DataSet = qryRaumLookup
    Left = 480
    Top = 224
  end
  object dsRegalLookup: TDataSource
    DataSet = qryRegalLookup
    Left = 720
    Top = 224
  end
  object dsEinheitLookup: TDataSource
    DataSet = qryEinheitLookup
    Left = 800
    Top = 224
  end
end
