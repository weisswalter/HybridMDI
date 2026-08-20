object dmMandant: TdmMandant
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  object memMandant: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 112
    Top = 40
  end
  object dsMandant: TDataSource
    Left = 184
    Top = 40
  end
end
