object dmVorlage: TdmVorlage
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblStamm: TFDTable
    Left = 40
    Top = 32
  end
  object tblDetail: TFDTable
    Left = 40
    Top = 96
  end
  object dstblStamm: TDataSource
    DataSet = tblStamm
    Left = 128
    Top = 32
  end
  object dstblDetail: TDataSource
    DataSet = tblDetail
    Left = 128
    Top = 96
  end
end
