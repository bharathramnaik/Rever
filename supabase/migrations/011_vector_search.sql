-- Sprint 6: Vector search (flow.txt §4/§6)
-- pgvector embeddings on idea cards + similarity RPC.

ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS embedding VECTOR(1536);

CREATE INDEX IF NOT EXISTS idx_idea_cards_embedding
    ON idea_cards USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

CREATE OR REPLACE FUNCTION search_idea_embeddings(
    query_embedding vector(1536),
    match_count int DEFAULT 10
) RETURNS TABLE (
    id uuid,
    takeaway text,
    body text,
    quality_score real,
    similarity float
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT ic.id, ic.takeaway, ic.body, ic.quality_score,
           1 - (ic.embedding <=> query_embedding) AS similarity
    FROM idea_cards ic
    WHERE ic.embedding IS NOT NULL
    ORDER BY ic.embedding <=> query_embedding
    LIMIT match_count;
END $$;
