object dmKursAnwesenheit: TdmKursAnwesenheit
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object qryTermine: TFDMemTable
    Left = 40
    Top = 32
  end
  object dsTermine: TDataSource
    DataSet = qryTermine
    Left = 152
    Top = 32
  end
  object tblAnwesenheit: TFDMemTable
    IndexFieldNames = 'termin_id'
    MasterSource = dsTermine
    MasterFields = 'termin_id'
    Left = 40
    Top = 96
  end
  object dsAnwesenheit: TDataSource
    DataSet = tblAnwesenheit
    Left = 152
    Top = 96
  end
  object qryCoach: TFDMemTable
    Left = 40
    Top = 160
  end
  object dsCoach: TDataSource
    DataSet = qryCoach
    Left = 152
    Top = 160
  end
end
