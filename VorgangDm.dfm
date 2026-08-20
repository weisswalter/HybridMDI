object dmVorgang: TdmVorgang
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
    object memTyp: TFDMemTable
      FetchOptions.AssignedValues = [evMode]
      FetchOptions.Mode = fmAll
      ResourceOptions.AssignedValues = [rvSilentMode]
      ResourceOptions.SilentMode = True
      UpdateOptions.AssignedValues = [uvCheckRequired]
      UpdateOptions.CheckRequired = False
      Left = 40
      Top = 24
    end
    object memZustand: TFDMemTable
      FetchOptions.AssignedValues = [evMode]
      FetchOptions.Mode = fmAll
      ResourceOptions.AssignedValues = [rvSilentMode]
      ResourceOptions.SilentMode = True
      UpdateOptions.AssignedValues = [uvCheckRequired]
      UpdateOptions.CheckRequired = False
      Left = 40
      Top = 80
    end
    object memUebergang: TFDMemTable
      FetchOptions.AssignedValues = [evMode]
      FetchOptions.Mode = fmAll
      ResourceOptions.AssignedValues = [rvSilentMode]
      ResourceOptions.SilentMode = True
      UpdateOptions.AssignedValues = [uvCheckRequired]
      UpdateOptions.CheckRequired = False
      Left = 40
      Top = 136
    end
    object memVorgangVorgang: TFDMemTable
      FetchOptions.AssignedValues = [evMode]
      FetchOptions.Mode = fmAll
      ResourceOptions.AssignedValues = [rvSilentMode]
      ResourceOptions.SilentMode = True
      UpdateOptions.AssignedValues = [uvCheckRequired]
      UpdateOptions.CheckRequired = False
      Left = 40
      Top = 192
    end
    object tblVorgang: TFDMemTable
      FetchOptions.AssignedValues = [evMode]
      FetchOptions.Mode = fmAll
      ResourceOptions.AssignedValues = [rvSilentMode]
      ResourceOptions.SilentMode = True
      UpdateOptions.AssignedValues = [uvCheckRequired]
      UpdateOptions.CheckRequired = False
      Left = 240
      Top = 24
      object tblVorgangvorgang_id: TIntegerField
        FieldName = 'vorgang_id'
      end
      object tblVorgangmandant_id: TIntegerField
        FieldName = 'mandant_id'
      end
      object tblVorgangvorgang_nr: TWideStringField
        FieldName = 'vorgang_nr'
        Size = 50
      end
      object tblVorgangbezeichnung: TWideStringField
        FieldName = 'bezeichnung'
        Size = 200
      end
      object tblVorgangbeschreibung: TWideMemoField
        FieldName = 'beschreibung'
      end
      object tblVorgangperson_id: TIntegerField
        FieldName = 'person_id'
      end
      object tblVorgangeroeffnet_am: TDateField
        FieldName = 'eroeffnet_am'
      end
      object tblVorganggeschlossen_am: TDateField
        FieldName = 'geschlossen_am'
      end
      object tblVorgangcreated_at: TSQLTimeStampField
        FieldName = 'created_at'
      end
      object tblVorgangdurchfuehrung_id: TIntegerField
        FieldName = 'durchfuehrung_id'
      end
      object tblVorgangverwendungszweck_id: TIntegerField
        FieldName = 'verwendungszweck_id'
      end
      object tblVorgangtyp_id: TIntegerField
        FieldName = 'typ_id'
      end
      object tblVorgangzustand_id: TIntegerField
        FieldName = 'zustand_id'
      end
      object tblVorgangbearbeiter_id: TIntegerField
        FieldName = 'bearbeiter_id'
      end
      object tblVorgangfaellig_am: TDateField
        FieldName = 'faellig_am'
      end
      object tblVorgangtyp_bezeichnung: TWideStringField
        FieldKind = fkLookup
        FieldName = 'typ_bezeichnung'
        LookupDataSet = memTyp
        LookupKeyFields = 'typ_id'
        LookupResultField = 'bezeichnung'
        KeyFields = 'typ_id'
        Size = 100
        Lookup = True
      end
      object tblVorgangzustand_bezeichnung: TWideStringField
        FieldKind = fkLookup
        FieldName = 'zustand_bezeichnung'
        LookupDataSet = memZustand
        LookupKeyFields = 'zustand_id'
        LookupResultField = 'bezeichnung'
        KeyFields = 'zustand_id'
        Size = 100
        Lookup = True
      end
    end
    object dstblVorgang: TDataSource
      DataSet = tblVorgang
      Left = 360
      Top = 24
    end
    object tblVerlauf: TFDMemTable
      FetchOptions.AssignedValues = [evMode]
      FetchOptions.Mode = fmAll
      ResourceOptions.AssignedValues = [rvSilentMode]
      ResourceOptions.SilentMode = True
      UpdateOptions.AssignedValues = [uvCheckRequired]
      UpdateOptions.CheckRequired = False
      Left = 240
      Top = 200
      object tblVerlaufverlauf_id: TIntegerField
        FieldName = 'verlauf_id'
      end
      object tblVerlaufvorgang_id: TIntegerField
        FieldName = 'vorgang_id'
      end
      object tblVerlaufvon_zustand_id: TIntegerField
        FieldName = 'von_zustand_id'
      end
      object tblVerlaufnach_zustand_id: TIntegerField
        FieldName = 'nach_zustand_id'
      end
      object tblVerlaufbenutzer_id: TIntegerField
        FieldName = 'benutzer_id'
      end
      object tblVerlaufzeitpunkt: TSQLTimeStampField
        FieldName = 'zeitpunkt'
      end
      object tblVerlaufbemerkung: TWideMemoField
        FieldName = 'bemerkung'
      end
      object tblVerlaufvon_bezeichnung: TWideStringField
        FieldKind = fkLookup
        FieldName = 'von_bezeichnung'
        LookupDataSet = memZustand
        LookupKeyFields = 'zustand_id'
        LookupResultField = 'bezeichnung'
        KeyFields = 'von_zustand_id'
        Size = 100
        Lookup = True
      end
      object tblVerlaufnach_bezeichnung: TWideStringField
        FieldKind = fkLookup
        FieldName = 'nach_bezeichnung'
        LookupDataSet = memZustand
        LookupKeyFields = 'zustand_id'
        LookupResultField = 'bezeichnung'
        KeyFields = 'nach_zustand_id'
        Size = 100
        Lookup = True
      end
    end
    object dstblVerlauf: TDataSource
      DataSet = tblVerlauf
      Left = 360
      Top = 200
    end
    object tblVerknuepft: TFDMemTable
      FetchOptions.AssignedValues = [evMode]
      FetchOptions.Mode = fmAll
      ResourceOptions.AssignedValues = [rvSilentMode]
      ResourceOptions.SilentMode = True
      UpdateOptions.AssignedValues = [uvCheckRequired]
      UpdateOptions.CheckRequired = False
      Left = 240
      Top = 320
    end
    object dstblVerknuepft: TDataSource
      DataSet = tblVerknuepft
      Left = 360
      Top = 320
    end
end
