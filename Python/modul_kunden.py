# modul_kunden.py
# Geschäftslogik für Kunden — Python-Seite.
# FrmKunden kennt nur diese Klasse, nicht Delphi direkt.

from frm_kunden import FrmKunden
from delphivcl import Application

class ModulKunden:

    def load(self):
        # Platzhalter: später DB-Abfrage, REST-Call o.ä.
        return [
            {'nr': '10001', 'name': 'Müller GmbH', 'ort': 'München'},
            {'nr': '10002', 'name': 'Meier AG',    'ort': 'Zürich'},
            {'nr': '10003', 'name': 'Schulz KG',   'ort': 'Berlin'},
        ]

    def show(self):
        data = self.load()
        frm = FrmKunden(Application)
        frm.load_data(data)
        frm.Show()
