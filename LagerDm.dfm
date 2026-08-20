object dmLager: TdmLager
  Left = 0
  Top = 0
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  object tblMandant: TFDMemTable
    Left = 128
    Top = 32
  end
  object tblLager: TFDMemTable
    IndexFieldNames = 'mandant_id'
    MasterSource = dstblMandant
    MasterFields = 'mandant_id'
    Left = 224
    Top = 32
  end
  object tblAdressinfo: TFDMemTable
    Left = 400
    Top = 32
  end
  object tblRaum: TFDMemTable
    Left = 480
    Top = 32
  end
  object tblAusstattung: TFDMemTable
    Left = 560
    Top = 32
  end
  object tblRaumAusstattung: TFDMemTable
    IndexFieldNames = 'raum_id'
    MasterSource = dstblRaum
    MasterFields = 'raum_id'
    Left = 640
    Top = 32
  end
  object tblRegal: TFDMemTable
    Left = 720
    Top = 32
  end
  object tblRegalFach: TFDMemTable
    IndexFieldNames = 'regal_id'
    MasterSource = dstblRegal
    MasterFields = 'regal_id'
    Left = 800
    Top = 32
  end
  object memAdressen: TFDMemTable
    Left = 320
    Top = 32
  end
  object memAdressinfoLookup: TFDMemTable
    Left = 400
    Top = 96
  end
  object memRaumLookup: TFDMemTable
    Left = 480
    Top = 96
  end
  object memRegalLookup: TFDMemTable
    Left = 720
    Top = 96
  end
  object memEinheitLookup: TFDMemTable
    Left = 800
    Top = 96
  end
  object dstblMandant: TDataSource
    DataSet = tblMandant
    Left = 128
    Top = 96
  end
  object dstblLager: TDataSource
    DataSet = tblLager
    Left = 224
    Top = 96
  end
  object dstblAdressinfo: TDataSource
    DataSet = tblAdressinfo
    Left = 400
    Top = 160
  end
  object dstblRaum: TDataSource
    DataSet = tblRaum
    Left = 480
    Top = 160
  end
  object dstblAusstattung: TDataSource
    DataSet = tblAusstattung
    Left = 560
    Top = 96
  end
  object dstblRaumAusstattung: TDataSource
    DataSet = tblRaumAusstattung
    Left = 640
    Top = 96
  end
  object dstblRegal: TDataSource
    DataSet = tblRegal
    Left = 720
    Top = 160
  end
  object dstblRegalFach: TDataSource
    DataSet = tblRegalFach
    Left = 800
    Top = 160
  end
  object dsAdressen: TDataSource
    DataSet = memAdressen
    Left = 320
    Top = 96
  end
  object dsAdressinfoLookup: TDataSource
    DataSet = memAdressinfoLookup
    Left = 400
    Top = 224
  end
  object dsRaumLookup: TDataSource
    DataSet = memRaumLookup
    Left = 480
    Top = 224
  end
  object dsRegalLookup: TDataSource
    DataSet = memRegalLookup
    Left = 720
    Top = 224
  end
  object dsEinheitLookup: TDataSource
    DataSet = memEinheitLookup
    Left = 800
    Top = 224
  end
end
