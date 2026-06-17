# modul_artikel.py
# Geschäftslogik für Artikel — Python-Seite.

from frm_artikel import FrmArtikel
from delphivcl import Application

class ModulArtikel:

    def load(self):
        return [
            {'nr': 'A-001', 'bezeichnung': 'Schraube M6',    'preis': 0.15},
            {'nr': 'A-002', 'bezeichnung': 'Mutter M6',      'preis': 0.08},
            {'nr': 'A-003', 'bezeichnung': 'Unterlegscheibe','preis': 0.05},
        ]

    def show(self):
        data = self.load()
        frm = FrmArtikel(Application)
        frm.load_data(data)
        frm.Show()
