object frmTemplate: TfrmTemplate
  Left = 0
  Top = 0
  Caption = 'frmTemplate'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnDestroy = FormDestroy
  TextHeight = 15
  object ActionList: TActionList
    Images = ilst16
    Left = 312
    Top = 312
    object Action1: TAction
      Caption = 'Action1'
    end
    object actFirst: TAction
      Caption = 'actFirst'
    end
    object actPrior: TAction
      Caption = 'actPrior'
    end
    object actNext: TAction
      Caption = 'actNext'
    end
    object actLast: TAction
      Caption = 'actLast'
    end
    object actNew: TAction
      Caption = 'actNew'
    end
    object actEdit: TAction
      Caption = 'actEdit'
    end
    object actCancel: TAction
      Caption = 'actCancel'
    end
    object actRefresh: TAction
      Caption = 'actRefresh'
    end
  end
  object ilst16: TJvImageList
    Items = <>
    Left = 304
    Top = 224
  end
  object ilst32: TJvImageList
    Items = <>
    Height = 32
    Width = 32
    Left = 304
    Top = 136
  end
end
