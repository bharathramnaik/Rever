-- Sprint 1: Idea-level knowledge graph (flow.txt §5)
-- Edges between idea cards: supports / contradicts / prerequisite_of / etc.

CREATE TABLE IF NOT EXISTS idea_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_idea_id UUID REFERENCES idea_cards(id) ON DELETE CASCADE,
    target_idea_id UUID REFERENCES idea_cards(id) ON DELETE CASCADE,
    relationship_type TEXT NOT NULL CHECK (relationship_type IN (
        'supports', 'contradicts', 'prerequisite_of',
        'related_to', 'example_of', 'applies_to'
    )),
    confidence REAL DEFAULT 0.5,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(source_idea_id, target_idea_id, relationship_type)
);

CREATE INDEX IF NOT EXISTS idx_idea_relationships_source ON idea_relationships(source_idea_id);
CREATE INDEX IF NOT EXISTS idx_idea_relationships_target ON idea_relationships(target_idea_id);

ALTER TABLE idea_relationships ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "idea_relationships_read" ON idea_relationships;
CREATE POLICY "idea_relationships_read"
    ON idea_relationships FOR SELECT USING (true);
