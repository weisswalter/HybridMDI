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
  object qryAdressen: TFDQuery
    Left = 320
    Top = 32
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
  object dsAdressen: TDataSource
    DataSet = qryAdressen
    Left = 320
    Top = 96
  end
end
