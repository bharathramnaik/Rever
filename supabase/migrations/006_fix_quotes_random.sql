-- Resolution for: "column quotes.random does not exist" (PG 42703)
-- lib/src/data/providers/quote_provider.dart selects & orders by a `random`
-- column (postgREST `order=random`), but the column was never created.
-- Adding it (with a pseudo-random default) makes the ordering valid without
-- requiring a backend change. Existing rows are back-filled so ordering
-- stabilises across requests.

ALTER TABLE quotes
  ADD COLUMN IF NOT EXISTS random REAL;

-- Back-fill any rows created before the column existed. `random()` is the
-- Postgres function; evaluated per row here.
UPDATE quotes
  SET random = random()
  WHERE random IS NULL;

-- Keep the column populated for future inserts (seeded rows specify
-- explicit columns, so this default only applies to ad-hoc inserts).
ALTER TABLE quotes
  ALTER COLUMN random SET DEFAULT random();
