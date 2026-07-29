object dmModuleTemplate: TdmModuleTemplate
  Height = 600
  Width = 800
  object JvThread1: TJvThread
    Exclusive = False
    MaxCount = 0
    RunOnCreate = True
    FreeOnTerminate = False
    AfterCreateDialogForm = JvThread1AfterCreateDialogForm
    OnExecute = JvThread1Execute
    Left = 440
    Top = 370
  end
end
