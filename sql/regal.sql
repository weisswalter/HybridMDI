-- ============================================================================
-- Heisenberg: regal (Regal steht in einem Raum), lager.regal_id als FK
-- PostgreSQL DDL
-- ============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS regal (
    regal_id     serial PRIMARY KEY,
    raum_id      integer NOT NULL REFERENCES raum(raum_id),
    bezeichnung  varchar(100),
    beschreibung text
);
CREATE INDEX IF NOT EXISTS ix_regal_raum ON regal (raum_id);

ALTER TABLE lager
    ADD CONSTRAINT lager_regal_id_fkey
    FOREIGN KEY (regal_id) REFERENCES regal(regal_id);

COMMIT;
