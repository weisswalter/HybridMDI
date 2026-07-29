# mail_caller.py
# Python-Zwischenschicht der Mail-Bruecke — nach dem Muster von
# BridgePOC\Python\cs_caller.py.
#
# Delphi ruft auf:
#   import mail_caller
#   _cs_result = mail_caller.fetch_inbox(1)
#
# Diese Datei tut selbst nichts Fachliches. Sie laedt nur die C#-Assembly
# und reicht durch. Die gesamte Mailarbeit (IMAP, MIME-Dekodierung, Schreiben
# nach Postgres) passiert in C# mit MailKit.

import sys
import os

from pythonnet import load
load("coreclr")
import clr

# Pfad zur kompilierten C#-DLL. Die Suche geht mehrere Kandidaten durch,
# damit sowohl der Debug- als auch der Release-Build gefunden wird, ohne
# dass man hier etwas anpassen muss.
_here = os.path.dirname(__file__)
_candidates = [
    os.path.join(_here, '..', 'CSharp', 'MailLib', 'bin', 'Release', 'net8.0'),
    os.path.join(_here, '..', 'CSharp', 'MailLib', 'bin', 'Debug', 'net8.0'),
    os.path.join(_here, '..', 'CSharp', 'MailLib', 'bin', 'Release', 'net8.0-windows'),
    os.path.join(_here, '..', 'CSharp', 'MailLib', 'bin', 'Debug', 'net8.0-windows'),
]

# Es wird die ZULETZT GEBAUTE DLL genommen, nicht die erste gefundene.
#
# Vorher stand Release vor Debug in der Liste. Wer nur Debug baut — der
# Normalfall beim Entwickeln — bekam dann stillschweigend die alte
# Release-DLL untergeschoben, und keine Aenderung wurde wirksam. Genau das
# ist am 28.07.2026 passiert und hat eine gute Stunde gekostet.
_bin = None
_neuestes = None
for _c in _candidates:
    _c = os.path.normpath(_c)
    _dll = os.path.join(_c, 'MailLib.dll')
    if os.path.isfile(_dll):
        _zeit = os.path.getmtime(_dll)
        if _neuestes is None or _zeit > _neuestes:
            _neuestes = _zeit
            _bin = _c

if _bin is None:
    raise FileNotFoundError(
        "MailLib.dll nicht gefunden. Bitte das C#-Projekt bauen:\n"
        "  cd CSharp\\MailLib && dotnet build -c Release\n"
        "Gesucht wurde in:\n  " + "\n  ".join(os.path.normpath(c) for c in _candidates))

if _bin not in sys.path:
    sys.path.append(_bin)

clr.AddReference('MailLib')
from Heisenberg.Mail import MailBridge        # noqa: E402


def fetch_inbox(konto_id: int) -> str:
    """Holt neue Mails des Kontos per IMAP und schreibt sie in die Datenbank.
    Rueckgabe: kurze Statusmeldung fuer die Delphi-Oberflaeche."""
    return MailBridge.FetchInbox(konto_id)


def fetch_folders(konto_id: int) -> str:
    """Gleicht die Ordnerliste des Kontos mit email_ordner ab."""
    return MailBridge.FetchFolders(konto_id)


def send_mail(nachricht_id: int) -> str:
    """Verschickt eine in email_nachricht vorbereitete Mail per SMTP."""
    return MailBridge.SendMail(nachricht_id)


def test_connection(konto_id: int) -> str:
    """Prueft IMAP- und SMTP-Zugang, ohne etwas zu veraendern."""
    return MailBridge.TestConnection(konto_id)
