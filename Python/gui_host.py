# gui_host.py
# Unsichtbares Anker-Fenster für delphivcl.
# delphivcl braucht genau eine Form als "Application.MainForm" — sonst beendet
# sich der Python-Application-Loop beim Schliessen des ersten echten Fensters.
# Lösung: Diese Form ist immer da, aber nie sichtbar.

from delphivcl import *

_host = None

def start_hidden_host():
    global _host
    if _host is not None:
        return

    class _HiddenHost(Form):
        def __init__(self, owner):
            self.Visible = False
            self.Width = 0
            self.Height = 0

    Application.Initialize()
    _host = _HiddenHost(Application)
    _host.Show()
    _host.Hide()
