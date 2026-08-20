object dmModuleTemplate: TdmModuleTemplate
  Left = 0
  Top = 0
  object JvThread1: TJvThread
    Exclusive = False
    MaxCount = 0
    RunOnCreate = True
    FreeOnTerminate = False
    AfterCreateDialogForm = JvThread1AfterCreateDialogForm
    OnExecute = JvThread1Execute
    Left = 550
    Top = 463
  end
end
