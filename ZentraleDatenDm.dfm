object dmZentraleDaten: TdmZentraleDaten
  Height = 4579
  Width = 4883
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=PG'
      'Server=100.98.168.109'
      'Port=5432'
      'Database=TRTHeisenberg'
      'User_Name=wwe123'
      'Password=a4cX7pAp29WRK7XHkGHBzs4DIhjAM14Z')
    LoginPrompt = False
    Left = 124
    Top = 61
  end
  object FDTableabwesenheit: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'abwesenheit'
    Left = 124
    Top = 305
  end
  object FDTableabwesenheitsart: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'abwesenheitsart'
    Left = 124
    Top = 520
  end
  object FDTableadresse: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'adresse'
    Left = 124
    Top = 733
  end
  object FDTableadressentyp: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'adressentyp'
    Left = 124
    Top = 948
  end
  object FDTableadressinfo: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'adressinfo'
    Left = 124
    Top = 1161
  end
  object FDTableanlage: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'anlage'
    Left = 124
    Top = 1375
  end
  object FDTableanlage_abschreibung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'anlage_abschreibung'
    Left = 124
    Top = 1588
  end
  object FDTableanlage_dokument: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'anlage_dokument'
    Left = 124
    Top = 1804
  end
  object FDTableanonymisierung_protokoll: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'anonymisierung_protokoll'
    Left = 124
    Top = 2014
  end
  object FDTableanwesenheit_check: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'anwesenheit_check'
    Left = 124
    Top = 2229
  end
  object FDTableanwesenheit_tag: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'anwesenheit_tag'
    Left = 124
    Top = 2443
  end
  object FDTableartikel: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'artikel'
    Left = 124
    Top = 2656
  end
  object FDTableartikel_artikel: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'artikel_artikel'
    Left = 124
    Top = 2869
  end
  object FDTableartikel_barcode: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'artikel_barcode'
    Left = 124
    Top = 3085
  end
  object FDTableartikel_fach: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'artikel_fach'
    Left = 124
    Top = 3298
  end
  object FDTableartikel_foto: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'artikel_foto'
    Left = 124
    Top = 3513
  end
  object FDTableartikel_preis: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'artikel_preis'
    Left = 764
    Top = 305
  end
  object FDTableartikel_variante: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'artikel_variante'
    Left = 764
    Top = 520
  end
  object FDTableartikel_variante_typ: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'artikel_variante_typ'
    Left = 764
    Top = 733
  end
  object FDTableartikel_variante_wert: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'artikel_variante_wert'
    Left = 764
    Top = 948
  end
  object FDTableartikel_zugang: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'artikel_zugang'
    Left = 764
    Top = 1161
  end
  object FDTableaudit_log: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'audit_log'
    Left = 764
    Top = 1375
  end
  object FDTableausstattung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'ausstattung'
    Left = 764
    Top = 1588
  end
  object FDTablebeleg: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'beleg'
    Left = 764
    Top = 1804
  end
  object FDTablebeleg_position: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'beleg_position'
    Left = 764
    Top = 2014
  end
  object FDTablebenutzer: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'benutzer'
    Left = 764
    Top = 2229
  end
  object FDTablebenutzer_mandant: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'benutzer_mandant'
    Left = 764
    Top = 2443
  end
  object FDTablebetriebs_ausnahme: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'betriebs_ausnahme'
    Left = 764
    Top = 2656
  end
  object FDTablebetriebszeit: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'betriebszeit'
    Left = 764
    Top = 2869
  end
  object FDTablebezirk: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'bezirk'
    Left = 764
    Top = 3085
  end
  object FDTablebuchung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'buchung'
    Left = 764
    Top = 3298
  end
  object FDTablebuchung_dokument: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'buchung_dokument'
    Left = 764
    Top = 3513
  end
  object FDTablebuchung_zeile: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'buchung_zeile'
    Left = 1405
    Top = 305
  end
  object FDTablebudget: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'budget'
    Left = 1405
    Top = 520
  end
  object FDTablecontentweb: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'contentweb'
    Left = 1405
    Top = 733
  end
  object FDTablecontentweb_text: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'contentweb_text'
    Left = 1405
    Top = 948
  end
  object FDTabledatenschutz_kenntnisnahme: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'datenschutz_kenntnisnahme'
    Left = 1405
    Top = 1161
  end
  object FDTabledatenschutz_vorfall: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'datenschutz_vorfall'
    Left = 1405
    Top = 1375
  end
  object FDTabledatenschutzinformation: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'datenschutzinformation'
    Left = 1405
    Top = 1588
  end
  object FDTabledokument: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'dokument'
    Left = 1405
    Top = 1804
  end
  object FDTabledokument_typ: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'dokument_typ'
    Left = 1405
    Top = 2014
  end
  object FDTabeleinheit: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'einheit'
    Left = 1405
    Top = 2229
  end
  object FDTabeleinwilligung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'einwilligung'
    Left = 1405
    Top = 2443
  end
  object FDTabelemail_anhang: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'email_anhang'
    Left = 1405
    Top = 2656
  end
  object FDTabelemail_konto: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'email_konto'
    Left = 1405
    Top = 2869
  end
  object FDTabelemail_nachricht: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'email_nachricht'
    Left = 1405
    Top = 3085
  end
  object FDTabelemail_option: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'email_option'
    Left = 1405
    Top = 3298
  end
  object FDTabelemail_ordner: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'email_ordner'
    Left = 1405
    Top = 3513
  end
  object FDTableemailadresse: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'emailadresse'
    Left = 2048
    Top = 305
  end
  object FDTableemailtyp: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'emailtyp'
    Left = 2048
    Top = 520
  end
  object FDTableerfassungsraster: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'erfassungsraster'
    Left = 2048
    Top = 733
  end
  object FDTablefeedback: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'feedback'
    Left = 2048
    Top = 948
  end
  object FDTablefeiertag: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'feiertag'
    Left = 2048
    Top = 1161
  end
  object FDTableferien_anspruch: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'ferien_anspruch'
    Left = 2048
    Top = 1375
  end
  object FDTablegutsprache_abruf: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'gutsprache_abruf'
    Left = 2048
    Top = 1588
  end
  object FDTableheisenberg_deployment_log: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'heisenberg_deployment_log'
    Left = 2048
    Top = 1804
  end
  object FDTableheisenberg_kunde: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'heisenberg_kunde'
    Left = 2048
    Top = 2014
  end
  object FDTableheisenberg_script: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'heisenberg_script'
    Left = 2048
    Top = 2229
  end
  object FDTableheisenberg_version: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'heisenberg_version'
    Left = 2048
    Top = 2443
  end
  object FDTablekalkulation: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kalkulation'
    Left = 2048
    Top = 2656
  end
  object FDTablekalkulation_dokument: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kalkulation_dokument'
    Left = 2048
    Top = 2869
  end
  object FDTablekalkulation_position: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kalkulation_position'
    Left = 2048
    Top = 3085
  end
  object FDTablekalkulation_risiko: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kalkulation_risiko'
    Left = 2048
    Top = 3298
  end
  object FDTableklient: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'klient'
    Left = 2048
    Top = 3513
  end
  object FDTableklient_semester: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'klient_semester'
    Left = 2686
    Top = 305
  end
  object FDTablekompetenz_typ: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kompetenz_typ'
    Left = 2686
    Top = 520
  end
  object FDTablekonto: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'konto'
    Left = 2686
    Top = 733
  end
  object FDTablekostenart: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kostenart'
    Left = 2686
    Top = 948
  end
  object FDTablekostengutsprache: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kostengutsprache'
    Left = 2686
    Top = 1161
  end
  object FDTablekostenstelle: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kostenstelle'
    Left = 2686
    Top = 1375
  end
  object FDTablekostenstelle_wert: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kostenstelle_wert'
    Left = 2686
    Top = 1588
  end
  object FDTablekostenwert_dokument: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kostenwert_dokument'
    Left = 2686
    Top = 1804
  end
  object FDTablekunde: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kunde'
    Left = 2686
    Top = 2014
  end
  object FDTablekurs: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kurs'
    Left = 2686
    Top = 2229
  end
  object FDTablekurs_anwesenheit: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kurs_anwesenheit'
    Left = 2686
    Top = 2443
  end
  object FDTablekurs_ausstattung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kurs_ausstattung'
    Left = 2686
    Top = 2656
  end
  object FDTablekurs_durchfuehrung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kurs_durchfuehrung'
    Left = 2686
    Top = 2869
  end
  object FDTablekurs_kompetenz: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kurs_kompetenz'
    Left = 2686
    Top = 3085
  end
  object FDTablekurs_kurs: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kurs_kurs'
    Left = 2686
    Top = 3298
  end
  object FDTablekurs_material: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kurs_material'
    Left = 2686
    Top = 3513
  end
  object FDTablekurs_teilnehmer: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kurs_teilnehmer'
    Left = 3329
    Top = 305
  end
  object FDTablekurs_termin: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kurs_termin'
    Left = 3329
    Top = 520
  end
  object FDTablelager: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'lager'
    Left = 3329
    Top = 733
  end
  object FDTableland: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'land'
    Left = 3329
    Top = 948
  end
  object FDTableleadquelle_typ: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'leadquelle_typ'
    Left = 3329
    Top = 1161
  end
  object FDTableleistung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'leistung'
    Left = 3329
    Top = 1375
  end
  object FDTablelohn_abzugsart: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'lohn_abzugsart'
    Left = 3329
    Top = 1588
  end
  object FDTablelohn_dokument: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'lohn_dokument'
    Left = 3329
    Top = 1804
  end
  object FDTablelohn_periode: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'lohn_periode'
    Left = 3329
    Top = 2014
  end
  object FDTablelohn_periode_position: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'lohn_periode_position'
    Left = 3329
    Top = 2229
  end
  object FDTablelohn_zulage: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'lohn_zulage'
    Left = 3329
    Top = 2443
  end
  object FDTablemandant: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'mandant'
    Left = 3329
    Top = 2656
  end
  object FDTablemandant_dokument: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'mandant_dokument'
    Left = 3329
    Top = 2869
  end
  object FDTablemarktpreis: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'marktpreis'
    Left = 3329
    Top = 3085
  end
  object FDTablenavbarweb: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'navbarweb'
    Left = 3329
    Top = 3298
  end
  object FDTablenavbarweb_text: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'navbarweb_text'
    Left = 3329
    Top = 3513
  end
  object FDTablenavigation: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'navigation'
    Left = 3968
    Top = 305
  end
  object FDTableperson: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'person'
    Left = 3968
    Top = 520
  end
  object FDTableperson_adresse: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'person_adresse'
    Left = 3968
    Top = 733
  end
  object FDTableperson_arbeitszeit: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'person_arbeitszeit'
    Left = 3968
    Top = 948
  end
  object FDTableperson_beziehung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'person_beziehung'
    Left = 3968
    Top = 1161
  end
  object FDTableperson_dokument: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'person_dokument'
    Left = 3968
    Top = 1375
  end
  object FDTableperson_email: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'person_email'
    Left = 3968
    Top = 1588
  end
  object FDTableperson_kompetenz: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'person_kompetenz'
    Left = 3968
    Top = 1804
  end
  object FDTableperson_lohn: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'person_lohn'
    Left = 3968
    Top = 2014
  end
  object FDTableperson_mandant: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'person_mandant'
    Left = 3968
    Top = 2229
  end
  object FDTableperson_telefonnummer: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'person_telefonnummer'
    Left = 3968
    Top = 2443
  end
  object FDTableperson_typ: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'person_typ'
    Left = 3968
    Top = 2656
  end
  object FDTableraster_abschnitt: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'raster_abschnitt'
    Left = 3968
    Top = 2869
  end
  object FDTableraum: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'raum'
    Left = 3968
    Top = 3085
  end
  object FDTableraum_ausstattung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'raum_ausstattung'
    Left = 3968
    Top = 3298
  end
  object FDTablerechnungstyp: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'rechnungstyp'
    Left = 3968
    Top = 3513
  end
  object FDTablezeit_stempel: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'zeit_stempel'
    Left = 124
    Top = 3724
  end
  object FDTablezugang_status: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'zugang_status'
    Left = 764
    Top = 3724
  end
  object FDTablezuschlagssatz: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'zuschlagssatz'
    Left = 1405
    Top = 3724
  end
  object FDTableumlage: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'umlage'
    Left = 2048
    Top = 3724
  end
  object FDTablevariante: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'variante'
    Left = 2686
    Top = 3724
  end
  object FDTablevariante_variante: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'variante_variante'
    Left = 3329
    Top = 3724
  end
  object FDTableverarbeitungstaetigkeit: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'verarbeitungstaetigkeit'
    Left = 3968
    Top = 3724
  end
  object FDTablevorgang: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'vorgang'
    Left = 124
    Top = 3938
  end
  object FDTablevorgang_beleg: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'vorgang_beleg'
    Left = 764
    Top = 3938
  end
  object FDTablevorgang_dokument: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'vorgang_dokument'
    Left = 1405
    Top = 3938
  end
  object FDTablevorgang_email: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'vorgang_email'
    Left = 2048
    Top = 3938
  end
  object FDTablewaehrungskurs: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'waehrungskurs'
    Left = 2686
    Top = 3938
  end
  object FDTableweb_bild: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'web_bild'
    Left = 3329
    Top = 3938
  end
  object FDTableweb_farbe: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'web_farbe'
    Left = 3968
    Top = 3938
  end
  object FDTableweb_seite: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'web_seite'
    Left = 124
    Top = 4150
  end
  object FDTableweb_text: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'web_text'
    Left = 764
    Top = 4150
  end
  object FDTablewebinhalt: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'webinhalt'
    Left = 1405
    Top = 4150
  end
  object FDTabletermin_ausstattung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'termin_ausstattung'
    Left = 2048
    Top = 4150
  end
  object FDTablev_adresse_anzeige: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_adresse_anzeige'
    Left = 4610
    Top = 305
  end
  object FDTablev_adressinfo_anzeige: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_adressinfo_anzeige'
    Left = 4610
    Top = 520
  end
  object FDTablev_raum_anzeige: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_raum_anzeige'
    Left = 4610
    Top = 733
  end
  object FDTablev_regal_anzeige: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_regal_anzeige'
    Left = 4610
    Top = 948
  end
  object FDTableregal: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'regal'
    Left = 4201
    Top = 244
  end
  object FDTableregal_fach: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'regal_fach'
    Left = 4201
    Top = 416
  end
  object FDTablerolle_typ: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'rolle_typ'
    Left = 4201
    Top = 588
  end
  object FDTablesemester: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'semester'
    Left = 4201
    Top = 760
  end
  object FDTablesprache: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'sprache'
    Left = 4201
    Top = 931
  end
  object FDTablesteuer_code: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'steuer_code'
    Left = 4201
    Top = 1104
  end
  object FDTabletelefonnummer: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'telefonnummer'
    Left = 4201
    Top = 1275
  end
  object FDTabletelefonnummertyp: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'telefonnummertyp'
    Left = 4201
    Top = 1448
  end
  object FDTablev_kurs_termin_liste: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_kurs_termin_liste'
    Left = 3688
    Top = 930
  end
  object FDTablev_kurs_coach: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_kurs_coach'
    Left = 3688
    Top = 1101
  end
  object FDTablev_person_auswahl: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_person_auswahl'
    Left = 3688
    Top = 1274
  end
  object FDTablev_benutzer_uebersicht: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_benutzer_uebersicht'
    Left = 3688
    Top = 1445
  end
  object FDTablev_navbar_editor: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_navbar_editor'
    Left = 3688
    Top = 1618
  end
  object FDTablev_content_editor: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_content_editor'
    Left = 3688
    Top = 1789
  end
  object FDTablev_anlage_jahr: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_anlage_jahr'
    Left = 3688
    Top = 1961
  end
  object FDTablev_konto_auswahl: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_konto_auswahl'
    Left = 3688
    Top = 2133
  end
  object FDTablev_raum_auswahl_einfach: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_raum_auswahl_einfach'
    Left = 3688
    Top = 2305
  end
  object FDTablev_beleg_person_auswahl: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_beleg_person_auswahl'
    Left = 3688
    Top = 2476
  end
  object FDTablev_rechnungstyp_auswahl: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_rechnungstyp_auswahl'
    Left = 3688
    Top = 2649
  end
  object FDTablev_lehrer_liste: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_lehrer_liste'
    Left = 3688
    Top = 2820
  end
  object FDTablev_person_kompetenz_status: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_person_kompetenz_status'
    Left = 3688
    Top = 2993
  end
  object FDTablev_lehrer_kurs_eignung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_lehrer_kurs_eignung'
    Left = 3688
    Top = 3164
  end
  object FDTablev_lagerort: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_lagerort'
    Left = 3688
    Top = 3301
  end
  object FDTablevorgang_typ: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'vorgang_typ'
    Left = 124
    Top = 4688
  end
  object FDTablevorgang_zustand: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'vorgang_zustand'
    Left = 124
    Top = 4781
  end
  object FDTablevorgang_uebergang: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'vorgang_uebergang'
    Left = 124
    Top = 4875
  end
  object FDTablevorgang_verlauf: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'vorgang_verlauf'
    Left = 124
    Top = 4969
  end
  object FDTablevorgang_vorgang: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'vorgang_vorgang'
    Left = 124
    Top = 5063
  end
  object FDTablenummernkreis: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'nummernkreis'
    Left = 124
    Top = 5156
  end
  object FDTablekategorie: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'kategorie'
    Left = 124
    Top = 5274
  end
  object FDTableartikel_kategorie: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'artikel_kategorie'
    Left = 124
    Top = 5368
  end
  object FDTablesystemeinstellung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'systemeinstellung'
    Left = 124
    Top = 5664
  end
  object FDTablev_person_konto: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_person_konto'
    Left = 124
    Top = 5758
  end
  object FDTablev_person_email_anmeldung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_person_email_anmeldung'
    Left = 124
    Top = 5851
  end
  object FDTablemandant_einstellung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'mandant_einstellung'
    Left = 124
    Top = 5958
  end
  object FDTablev_shop_einstellung: TFDTable
    Connection = FDConnection1
    FetchOptions.AssignedValues = [evMode, evItems]
    FetchOptions.Mode = fmAll
    FetchOptions.Items = [fiBlobs, fiDetails]
    ResourceOptions.AssignedValues = [rvCmdExecMode, rvDirectExecute]
    ResourceOptions.DirectExecute = True
    UpdateOptions.AssignedValues = [uvEDelete, uvEInsert, uvEUpdate]
    UpdateOptions.EnableDelete = False
    UpdateOptions.EnableInsert = False
    UpdateOptions.EnableUpdate = False
    TableName = 'v_shop_einstellung'
    Left = 124
    Top = 6051
  end
end
