object dmMail: TdmMail
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  object tblKonto: TFDTable
    OnNewRecord = tblKontoNewRecord
    TableName = 'email_konto'
    Left = 40
    Top = 32
  end
  object dstblKonto: TDataSource
    DataSet = tblKonto
    Left = 128
    Top = 32
  end
  object qryOrdner: TFDQuery
    Left = 40
    Top = 96
  end
  object dstblOrdner: TDataSource
    DataSet = qryOrdner
    Left = 128
    Top = 96
  end
  object qryNachrichten: TFDQuery
    Left = 40
    Top = 160
  end
  object dstblNachrichten: TDataSource
    DataSet = qryNachrichten
    Left = 128
    Top = 160
  end
  object qryAnhaenge: TFDQuery
    Left = 40
    Top = 224
  end
  object dstblAnhaenge: TDataSource
    DataSet = qryAnhaenge
    Left = 128
    Top = 224
  end
  object tblDokument: TFDTable
    TableName = 'dokument'
    Left = 40
    Top = 288
  end
  object dstblDokument: TDataSource
    DataSet = tblDokument
    Left = 128
    Top = 288
  end
  object qryOptProtokoll: TFDQuery
    Left = 296
    Top = 32
  end
  object dsOptProtokoll: TDataSource
    DataSet = qryOptProtokoll
    Left = 384
    Top = 32
  end
  object qryOptSicherheit: TFDQuery
    Left = 296
    Top = 96
  end
  object dsOptSicherheit: TDataSource
    DataSet = qryOptSicherheit
    Left = 384
    Top = 96
  end
  object qryOptAuth: TFDQuery
    Left = 296
    Top = 160
  end
  object dsOptAuth: TDataSource
    DataSet = qryOptAuth
    Left = 384
    Top = 160
  end
  object qryOptFlow: TFDQuery
    Left = 296
    Top = 224
  end
  object dsOptFlow: TDataSource
    DataSet = qryOptFlow
    Left = 384
    Top = 224
  end
end
