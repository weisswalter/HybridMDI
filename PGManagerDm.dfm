object dmPGManager: TdmPGManager
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=PG'
      'Database=postgres'
      'User_Name=postgres')
    LoginPrompt = False
    Left = 48
    Top = 48
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    Left = 160
    Top = 48
  end
  object FDTable1: TFDTable
    Connection = FDConnection1
    Left = 272
    Top = 48
  end
  object DataSource1: TDataSource
    DataSet = FDTable1
    Left = 384
    Top = 48
  end
  object FDMemTable_Profiles: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 48
    Top = 120
  end
  object FDMemTable_DB: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 160
    Top = 120
  end
  object FDMemTable_TS: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 272
    Top = 120
  end
  object DataSource2: TDataSource
    Left = 384
    Top = 120
  end
  object DataSource3: TDataSource
    Left = 496
    Top = 48
  end
  object DataSource4: TDataSource
    Left = 496
    Top = 120
  end
  object fdScript: TFDScript
    SQLScripts = <>
    Connection = FDConnection1
    Params = <>
    Macros = <>
    Left = 48
    Top = 192
  end
  object dsQuery: TDataSource
    DataSet = FDQuery1
    Left = 160
    Top = 192
  end
  object FDMemTable_Tables: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 272
    Top = 192
  end
  object DataSource5: TDataSource
    DataSet = FDMemTable_Tables
    Left = 384
    Top = 192
  end
end
