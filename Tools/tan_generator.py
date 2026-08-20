"""TAN-Liste fuer den Notfallzugang erzeugen.

Erzeugt 10 Einmal-Passwoerter (TANs) und die zugehoerigen SHA-256-Hashes.

ABLAUF:
  1. Dieses Skript ausfuehren.
  2. Den ausgegebenen Pascal-Block in NotfallFrm.pas eintragen
     (Konstante cTanHashes) und Heisenberg neu uebersetzen.
  3. Die KLARTEXT-TANs ausdrucken oder in einen Passwortmanager legen -
     sie stehen nirgends im Programm und sind nach diesem Lauf nicht
     wiederherstellbar.

WARUM NUR DIE HASHES INS PROGRAMM: Wer die EXE hat, kann sie durchsuchen.
Klartext-TANs waeren damit sofort lesbar; aus einem SHA-256-Hash laesst sich
eine zufaellige 20-stellige TAN dagegen nicht zurueckrechnen.

GRENZE, die man kennen muss: Die Hashes im Programm sagen einem Angreifer,
WIE VIELE TANs es gibt und ob eine geratene richtig waere. Gegen das
Durchprobieren schuetzt allein die Laenge der TAN - deshalb 20 Zeichen aus
einem grossen Zeichenvorrat und nicht sechs Ziffern wie bei einer Bank-TAN.
"""

import hashlib
import secrets
import string

ANZAHL = 10
LAENGE = 20
# Ohne 0/O und 1/l/I - die verwechselt man am Telefon staendig, und genau
# so wird die TAN uebermittelt.
ZEICHEN = "".join(c for c in (string.ascii_uppercase + string.digits)
                  if c not in "O0I1")


def tan_erzeugen() -> str:
    roh = "".join(secrets.choice(ZEICHEN) for _ in range(LAENGE))
    # In Vierergruppen, damit man sie am Telefon durchgeben kann
    return "-".join(roh[i:i + 4] for i in range(0, LAENGE, 4))


def hash_von(tan: str) -> str:
    # Bindestriche und Gross-/Kleinschreibung sollen egal sein - das Programm
    # normalisiert genauso (siehe NotfallFrm.TanNormalisieren).
    normal = tan.replace("-", "").replace(" ", "").upper()
    return hashlib.sha256(normal.encode("ascii")).hexdigest()


def main() -> None:
    tans = [tan_erzeugen() for _ in range(ANZAHL)]

    print("=" * 70)
    print("KLARTEXT-TANs - ausdrucken und sicher aufbewahren.")
    print("Sie stehen NICHT im Programm und sind spaeter nicht wiederherstellbar.")
    print("=" * 70)
    for nr, tan in enumerate(tans, 1):
        print(f"  TAN {nr:2d}:  {tan}")

    print()
    print("=" * 70)
    print("Fuer NotfallFrm.pas - Konstante cTanHashes ersetzen:")
    print("=" * 70)
    print("  cTanHashes: array[1..%d] of string = (" % ANZAHL)
    for nr, tan in enumerate(tans, 1):
        komma = "," if nr < ANZAHL else ""
        print(f"    '{hash_von(tan)}'{komma}")
    print("  );")
    print()
    print("Danach Heisenberg neu uebersetzen. Verbrauchte TANs werden in")
    print("C:\\ProgramData\\Heisenberg\\notfall.dat vermerkt, NICHT in der")
    print("Datenbank - sonst waeren sie nach einem Zuruecksetzen wieder gueltig.")


if __name__ == "__main__":
    main()
