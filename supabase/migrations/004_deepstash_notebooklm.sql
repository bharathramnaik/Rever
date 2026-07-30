-- Deepstash + NotebookLM Schema
-- Idea Cards, Stashes, and Source upgrades

-- Upgrade sources for NotebookLM ingestion
ALTER TABLE sources ADD COLUMN IF NOT EXISTS file_path text;
ALTER TABLE sources ADD COLUMN IF NOT EXISTS raw_text text;
ALTER TABLE sources ADD COLUMN IF NOT EXISTS status text DEFAULT 'ready';

-- Deepstash Idea Cards
CREATE TABLE IF NOT EXISTS idea_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    concept_id UUID REFERENCES concepts(id) ON DELETE SET NULL,
    takeaway text NOT NULL,
    body text NOT NULL,
    quote text,
    audio_url text,
    like_count INT DEFAULT 0,
    mind_blown_count INT DEFAULT 0,
    actionable_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Custom Stashes (Collections)
CREATE TABLE IF NOT EXISTS stashes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title text NOT NULL,
    description text,
    is_private boolean DEFAULT false,
    color_hex text DEFAULT '#6C63FF',
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS stash_items (
    stash_id UUID REFERENCES stashes(id) ON DELETE CASCADE,
    idea_card_id UUID REFERENCES idea_cards(id) ON DELETE CASCADE,
    added_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (stash_id, idea_card_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_idea_cards_source ON idea_cards(source_id);
CREATE INDEX IF NOT EXISTS idx_idea_cards_concept ON idea_cards(concept_id);
CREATE INDEX IF NOT EXISTS idx_stashes_profile ON stashes(profile_id);
CREATE INDEX IF NOT EXISTS idx_stash_items_stash ON stash_items(stash_id);

-- RLS
ALTER TABLE idea_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE stashes ENABLE ROW LEVEL SECURITY;
ALTER TABLE stash_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "idea_cards_read" ON idea_cards FOR SELECT USING (true);
CREATE POLICY "stashes_own" ON stashes USING (profile_id IN (
    SELECT id FROM profiles WHERE account_id = auth.uid()
));
CREATE POLICY "stash_items_own" ON stash_items USING (stash_id IN (
    SELECT s.id FROM stashes s WHERE s.profile_id IN (
        SELECT id FROM profiles WHERE account_id = auth.uid()
    )
));
