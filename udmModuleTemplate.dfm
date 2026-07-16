object dmModuleTemplate: TdmModuleTemplate
  Height = 480
  Width = 640
  object JvThread1: TJvThread
    Exclusive = False
    MaxCount = 0
    RunOnCreate = True
    FreeOnTerminate = False
    AfterCreateDialogForm = JvThread1AfterCreateDialogForm
    OnExecute = JvThread1Execute
    Left = 352
    Top = 296
  end
end
