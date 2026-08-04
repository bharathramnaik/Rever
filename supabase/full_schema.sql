-- ============================================================
-- Rever â€” Sprint 1-6 migrations (007-011) consolidated
-- Paste this ENTIRE file once into: Dashboard > SQL Editor > New query > Run
-- Safe to run multiple times (all statements are idempotent).
-- Migrations 001-006 are already applied to the remote DB â€” do NOT re-run them.
-- ============================================================

-- 007: Idea knowledge graph (Sprint 1)
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
CREATE POLICY "idea_relationships_read" ON idea_relationships FOR SELECT USING (true);

-- 008: Richer taxonomy (Sprint 2)
ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS difficulty TEXT
    CHECK (difficulty IN ('beginner', 'intermediate', 'advanced'));
ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS quality_score REAL DEFAULT 0;
ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS language TEXT DEFAULT 'en';
ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS status TEXT
    CHECK (status IN ('draft', 'review', 'published', 'archived')) DEFAULT 'published';

CREATE TABLE IF NOT EXISTS skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS domains (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS industries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS idea_skills (
    idea_id UUID REFERENCES idea_cards(id) ON DELETE CASCADE,
    skill_id UUID REFERENCES skills(id) ON DELETE CASCADE,
    PRIMARY KEY (idea_id, skill_id)
);

CREATE TABLE IF NOT EXISTS idea_domains (
    idea_id UUID REFERENCES idea_cards(id) ON DELETE CASCADE,
    domain_id UUID REFERENCES domains(id) ON DELETE CASCADE,
    PRIMARY KEY (idea_id, domain_id)
);

CREATE TABLE IF NOT EXISTS idea_industries (
    idea_id UUID REFERENCES idea_cards(id) ON DELETE CASCADE,
    industry_id UUID REFERENCES industries(id) ON DELETE CASCADE,
    PRIMARY KEY (idea_id, industry_id)
);

CREATE INDEX IF NOT EXISTS idx_idea_cards_status ON idea_cards(status);
CREATE INDEX IF NOT EXISTS idx_idea_cards_quality ON idea_cards(quality_score);
CREATE INDEX IF NOT EXISTS idx_idea_skills_idea ON idea_skills(idea_id);
CREATE INDEX IF NOT EXISTS idx_idea_domains_idea ON idea_domains(idea_id);
CREATE INDEX IF NOT EXISTS idx_idea_industries_idea ON idea_industries(idea_id);

ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE industries ENABLE ROW LEVEL SECURITY;
ALTER TABLE idea_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE idea_domains ENABLE ROW LEVEL SECURITY;
ALTER TABLE idea_industries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "skills_read" ON skills;
CREATE POLICY "skills_read" ON skills FOR SELECT USING (true);
DROP POLICY IF EXISTS "domains_read" ON domains;
CREATE POLICY "domains_read" ON domains FOR SELECT USING (true);
DROP POLICY IF EXISTS "industries_read" ON industries;
CREATE POLICY "industries_read" ON industries FOR SELECT USING (true);
DROP POLICY IF EXISTS "idea_skills_read" ON idea_skills;
CREATE POLICY "idea_skills_read" ON idea_skills FOR SELECT USING (true);
DROP POLICY IF EXISTS "idea_domains_read" ON idea_domains;
CREATE POLICY "idea_domains_read" ON idea_domains FOR SELECT USING (true);
DROP POLICY IF EXISTS "idea_industries_read" ON idea_industries;
CREATE POLICY "idea_industries_read" ON idea_industries FOR SELECT USING (true);

-- 009: Signal tracking (Sprint 3)
CREATE TABLE IF NOT EXISTS signals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    idea_card_id UUID REFERENCES idea_cards(id) ON DELETE CASCADE,
    signal_type TEXT NOT NULL CHECK (signal_type IN (
        'opened', 'finished', 'liked', 'mind_blown', 'actionable',
        'saved', 'shared', 'skipped', 'returned', 'dwelled', 'searched'
    )),
    payload JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_signals_profile ON signals(profile_id, created_at);
CREATE INDEX IF NOT EXISTS idx_signals_type ON signals(signal_type, created_at);
CREATE INDEX IF NOT EXISTS idx_signals_idea ON signals(idea_card_id);

ALTER TABLE signals ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "signals_own" ON signals;
CREATE POLICY "signals_own" ON signals USING (profile_id IN (
    SELECT id FROM profiles WHERE account_id = auth.uid()
));

-- 010: Multi-asset pipeline (Sprint 5)
ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS takeaways text[] DEFAULT '{}';
ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS examples text[] DEFAULT '{}';
ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS questions text[] DEFAULT '{}';
ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS flashcards jsonb DEFAULT '[]'::jsonb;

-- 011: Vector search (Sprint 6)
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


-- 012: User-published content (Sprint 7): publish own articles/blogs,
-- owner approves (via dashboard, service role bypasses RLS); approved
-- posts are visible to every profile.
CREATE TABLE IF NOT EXISTS submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMPTZ DEFAULT now(),
    approved_at TIMESTAMPTZ
);

ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "submissions_read" ON submissions;
CREATE POLICY "submissions_read" ON submissions FOR SELECT
    USING (profile_id IN (SELECT id FROM profiles WHERE account_id = auth.uid())
           OR status = 'approved');
DROP POLICY IF EXISTS "submissions_insert" ON submissions;
CREATE POLICY "submissions_insert" ON submissions FOR INSERT
    WITH CHECK (profile_id IN (SELECT id FROM profiles WHERE account_id = auth.uid()));
DROP POLICY IF EXISTS "submissions_update_own" ON submissions;
CREATE POLICY "submissions_update_own" ON submissions FOR UPDATE
    USING (profile_id IN (SELECT id FROM profiles WHERE account_id = auth.uid()));

-- 013: Book access cap (Sprint 7): profiles request access to books
-- (sources); the owner grants via dashboard. Enforced at 3 per profile.
CREATE TABLE IF NOT EXISTS book_access (
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    source_id UUID NOT NULL REFERENCES sources(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'requested'
        CHECK (status IN ('requested', 'granted', 'denied')),
    created_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (profile_id, source_id)
);

ALTER TABLE book_access ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "book_access_read" ON book_access;
CREATE POLICY "book_access_read" ON book_access FOR SELECT USING (true);
DROP POLICY IF EXISTS "book_access_insert" ON book_access;
CREATE POLICY "book_access_insert" ON book_access FOR INSERT
    WITH CHECK (profile_id IN (SELECT id FROM profiles WHERE account_id = auth.uid()));
