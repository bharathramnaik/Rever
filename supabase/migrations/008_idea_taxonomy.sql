-- Sprint 2: Richer Idea model + Taxonomy (flow.txt §1)
-- idea_cards gains quality/difficulty/language/status; new taxonomy tables.

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

CREATE POLICY IF NOT EXISTS "skills_read" ON skills FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "domains_read" ON domains FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "industries_read" ON industries FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "idea_skills_read" ON idea_skills FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "idea_domains_read" ON idea_domains FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "idea_industries_read" ON idea_industries FOR SELECT USING (true);
