object dmPython: TdmPython
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 150
  Width = 215
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 80
    Top = 48
  end
end
