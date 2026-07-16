object dmMandant: TdmMandant
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 150
  Width = 215
  object FDConnection: TFDConnection
    LoginPrompt = False
    Left = 40
    Top = 40
  end
  object qryMandant: TFDQuery
    Left = 112
    Top = 40
  end
  object dsMandant: TDataSource
    Left = 184
    Top = 40
  end
end
