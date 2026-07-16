object dmDokumente: TdmDokumente
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=PG'
      'Database=TRTHeisenberg'
      'User_Name=postgres'
      'Password=postgres'
      'Server=localhost')
    LoginPrompt = False
    Left = 40
    Top = 40
  end
  object qryDokumente: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      ' SELECT dokument_id, typ_id, titel, ocr_text,  '
      '           mime_type, quelle, dateigroesse_kb, sprache,  '
      '           scan_datum, created_at  '
      '    FROM dokument  '
      '    ORDER BY dokument_id')
    Left = 175
    Top = 40
    object qryDokumentedokument_id: TIntegerField
      FieldName = 'dokument_id'
      Origin = 'dokument_id'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object qryDokumentetyp_id: TIntegerField
      FieldName = 'typ_id'
      Origin = 'typ_id'
    end
    object qryDokumentetitel: TWideStringField
      FieldName = 'titel'
      Origin = 'titel'
      Size = 300
    end
    object qryDokumenteocr_text: TWideMemoField
      FieldName = 'ocr_text'
      Origin = 'ocr_text'
      BlobType = ftWideMemo
    end
    object qryDokumentemime_type: TWideStringField
      FieldName = 'mime_type'
      Origin = 'mime_type'
      Size = 100
    end
    object qryDokumentequelle: TWideStringField
      FieldName = 'quelle'
      Origin = 'quelle'
      Size = 50
    end
    object qryDokumentedateigroesse_kb: TIntegerField
      FieldName = 'dateigroesse_kb'
      Origin = 'dateigroesse_kb'
    end
    object qryDokumentesprache: TWideStringField
      FieldName = 'sprache'
      Origin = 'sprache'
      Size = 5
    end
    object qryDokumentescan_datum: TSQLTimeStampField
      FieldName = 'scan_datum'
      Origin = 'scan_datum'
      ProviderFlags = [pfInUpdate]
    end
    object qryDokumentecreated_at: TSQLTimeStampField
      FieldName = 'created_at'
      Origin = 'created_at'
      ProviderFlags = [pfInUpdate]
    end
  end
  object dsDokumente: TDataSource
    DataSet = qryDokumente
    Left = 310
    Top = 40
  end
end
