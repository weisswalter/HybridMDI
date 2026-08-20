object dmBenutzer: TdmBenutzer
  Left = 0
  Top = 0
  object qryBenutzer: TFDMemTable
    Left = 40
    Top = 32
  end
  object dsBenutzer: TDataSource
    DataSet = qryBenutzer
    Left = 160
    Top = 32
  end
  object tblBenutzerMandant: TFDMemTable
    Left = 40
    Top = 96
  end
  object dsBenutzerMandant: TDataSource
    DataSet = tblBenutzerMandant
    Left = 160
    Top = 96
  end
  object qryPersonAuswahl: TFDMemTable
    Left = 40
    Top = 160
  end
  object dsPersonAuswahl: TDataSource
    DataSet = qryPersonAuswahl
    Left = 160
    Top = 160
  end
  object qryMandantAuswahl: TFDMemTable
    Left = 40
    Top = 224
  end
  object dsMandantAuswahl: TDataSource
    DataSet = qryMandantAuswahl
    Left = 160
    Top = 224
  end
  object memPersonEmail: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired]
    UpdateOptions.CheckRequired = False
    Left = 400
    Top = 360
  end
end
