object dmDokumente: TdmDokumente
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  object qryDokumente: TFDMemTable
    Left = 175
    Top = 40
  end
  object dsDokumente: TDataSource
    DataSet = qryDokumente
    Left = 310
    Top = 40
  end
end
