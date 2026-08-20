-- ============================================================================
-- Anwendungsrolle für Heisenberg — Stand 03.08.2026
--
-- WARUM NICHT `postgres` VERWENDEN: Der Superuser umgeht jede Rechteprüfung.
-- Solange die Anwendung als Superuser verbunden ist, greift kein einziger
-- GRANT, und ein Fehler in einem Formular kann alles anrichten — auch das,
-- was das Programm nie tun sollte. Diese Rolle darf genau das, was
-- Heisenberg im Alltag braucht: Daten lesen und schreiben.
--
-- WAS SIE NICHT DARF, mit Absicht:
--   - kein Superuser, kein CREATEDB, kein CREATEROLE
--   - keine Tabellen anlegen oder ändern (DDL bleibt beim Administrator)
--   - audit_log nicht ändern oder löschen (die Trigger blocken das ohnehin;
--     das REVOKE macht die Absicht auch ohne Trigger sichtbar)
--
-- Das Passwort ist hier NICHT enthalten — es wird beim Anlegen übergeben,
-- damit diese Datei bedenkenlos im Repository liegen kann.
-- ============================================================================

-- Rolle anlegen, falls sie noch fehlt. Das Passwort kommt von aussen:
--   psql -v passwort="'...'" -f rolle_anwendung.sql
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'wwe123') THEN
        CREATE ROLE wwe123 WITH LOGIN;
    END IF;
END $$;

\if :{?passwort}
    ALTER ROLE wwe123 WITH PASSWORD :passwort;
\endif

-- Ausdrücklich KEINE erhöhten Rechte
ALTER ROLE wwe123 WITH NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;

GRANT CONNECT ON DATABASE "TRTHeisenberg" TO wwe123;
GRANT USAGE ON SCHEMA public TO wwe123;

-- Tagesgeschäft: lesen und schreiben
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO wwe123;
-- serial-Spalten brauchen die Sequenz
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO wwe123;
-- Die Rechenlogik liegt in Funktionen (fn_lohn_berechnen, fn_kalkulation_*,
-- fn_benutzer_anmelden ...) - ohne EXECUTE stünde die halbe Anwendung still
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO wwe123;

-- Damit künftige Tabellen nicht jedes Mal von Hand nachgezogen werden müssen
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO wwe123;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO wwe123;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT EXECUTE ON FUNCTIONS TO wwe123;

-- Das Protokoll darf geschrieben, aber nie verändert werden. Die Trigger aus
-- sql/audit_log.sql verhindern das bereits für jeden - hier steht es
-- zusätzlich als Recht, damit die Absicht auch dann erhalten bleibt, wenn
-- jemand die Trigger einmal anfasst.
REVOKE UPDATE, DELETE ON audit_log FROM wwe123;

-- Kontrolle
SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin
  FROM pg_roles WHERE rolname = 'wwe123';
