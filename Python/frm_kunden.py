# frm_kunden.py
# Python-GUI für Kunden — gebaut mit delphivcl.
# Nur UI-Logik, keine Geschäftslogik.

import os
from delphivcl import *

class FrmKunden(Form):

    def __init__(self, owner):
        self.ListBox1 = None
        self.lblTitel = None
        self.btnSchliessen = None
        self.LoadProps(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'frm_kunden.pydfm'))
        self.btnSchliessen.OnClick = self._on_schliessen

    def load_data(self, data):
        self.ListBox1.Items.Clear()
        for row in data:
            self.ListBox1.Items.Add(f"{row['nr']}  {row['name']}  ({row['ort']})")

    def _on_schliessen(self, sender):
        self.Close()
