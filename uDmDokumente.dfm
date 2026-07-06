object dmDokumente: TdmDokumente
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 250
  Width = 500
  PixelsPerInch = 120
  object FDConnection: TFDConnection
    LoginPrompt = False
    Left = 40
    Top = 40
  end
  object qryDokumente: TFDQuery
    Left = 175
    Top = 40
  end
  object dsDokumente: TDataSource
    Left = 310
    Top = 40
  end
end
