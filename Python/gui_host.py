from delphivcl import *

def StartHiddenHost():
    class HiddenHost(Form):
        def __init__(self, owner):
            self.Visible = False              # Nicht sichtbar
            self.Enabled = False              # Keine Interaktion
            self.Width = 0
            self.Height = 0

    Application.Initialize()
    f = HiddenHost(Application)
    f.Show()
    f.Hide()  # explizit verstecken
