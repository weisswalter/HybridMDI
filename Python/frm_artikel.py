# frm_artikel.py
# Python-GUI für Artikel.

import os
from delphivcl import *

class FrmArtikel(Form):

    def __init__(self, owner):
        self.ListBox1 = None
        self.lblTitel = None
        self.btnSchliessen = None
        self.LoadProps(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'frm_artikel.pydfm'))
        self.btnSchliessen.OnClick = self._on_schliessen

    def load_data(self, data):
        self.ListBox1.Items.Clear()
        for row in data:
            self.ListBox1.Items.Add(f"{row['nr']}  {row['bezeichnung']}  EUR {row['preis']:.2f}")

    def _on_schliessen(self, sender):
        self.Close()
