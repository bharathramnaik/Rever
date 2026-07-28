-- Rever Initial Schema
-- Run this in Supabase SQL editor

-- Enable pgvector
CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA extensions;

-- ==================== IDENTITY ====================

CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    avatar_url TEXT,
    profile_type TEXT CHECK (profile_type IN ('adult', 'child', 'teen')) DEFAULT 'adult',
    age_range TEXT,
    daily_goal_minutes INT DEFAULT 10,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE parental_controls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
    daily_limit_minutes INT DEFAULT 30,
    ai_enabled BOOLEAN DEFAULT true,
    content_restrictions JSONB DEFAULT '[]'::jsonb,
    parent_pin_hash TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ==================== KNOWLEDGE ====================

CREATE TABLE topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    icon TEXT,
    color TEXT,
    parent_topic_id UUID REFERENCES topics(id),
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE concepts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    summary TEXT,
    difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')) DEFAULT 'beginner',
    estimated_minutes INT,
    embedding VECTOR(1536),
    quality_score FLOAT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE concept_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
    target_concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
    relationship_type TEXT CHECK (relationship_type IN (
        'prerequisite_of', 'related_to', 'example_of',
        'part_of', 'extends', 'applies_to', 'similar_to'
    )),
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(source_concept_id, target_concept_id, relationship_type)
);

CREATE TABLE concept_topics (
    concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
    topic_id UUID REFERENCES topics(id) ON DELETE CASCADE,
    PRIMARY KEY (concept_id, topic_id)
);

CREATE TABLE sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    url TEXT,
    source_type TEXT,
    license TEXT,
    provenance JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE source_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id UUID REFERENCES sources(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    embedding VECTOR(1536),
    chunk_index INT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ==================== LEARNING ====================

CREATE TABLE learning_objects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
    object_type TEXT CHECK (object_type IN (
        'card', 'article', 'diagram', 'flowchart',
        'timeline', 'quiz', 'flashcard', 'story',
        'animation', 'audio', 'exercise', 'project'
    )) NOT NULL,
    title TEXT NOT NULL,
    content JSONB NOT NULL DEFAULT '{}'::jsonb,
    difficulty TEXT DEFAULT 'beginner',
    age_min INT DEFAULT 0,
    age_max INT DEFAULT 99,
    estimated_duration INT,
    embedding VECTOR(1536),
    quality_score FLOAT DEFAULT 0,
    source_id UUID REFERENCES sources(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE learning_paths (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    topic_id UUID REFERENCES topics(id),
    difficulty TEXT DEFAULT 'beginner',
    estimated_total_minutes INT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE learning_path_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    path_id UUID REFERENCES learning_paths(id) ON DELETE CASCADE,
    learning_object_id UUID REFERENCES learning_objects(id) ON DELETE CASCADE,
    step_order INT NOT NULL,
    required BOOLEAN DEFAULT true,
    UNIQUE(path_id, step_order)
);

-- ==================== ACTIVITY ====================

CREATE TABLE learning_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ DEFAULT now(),
    ended_at TIMESTAMPTZ,
    duration_seconds INT DEFAULT 0,
    objects_viewed INT DEFAULT 0,
    quizzes_taken INT DEFAULT 0,
    ai_queries INT DEFAULT 0
);

CREATE TABLE object_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    learning_object_id UUID REFERENCES learning_objects(id) ON DELETE CASCADE,
    interaction_type TEXT,
    completed BOOLEAN DEFAULT false,
    time_spent_seconds INT DEFAULT 0,
    score FLOAT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE mastery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    concept_id UUID REFERENCES concepts(id) ON DELETE CASCADE,
    mastery_level FLOAT DEFAULT 0,
    times_practiced INT DEFAULT 0,
    last_practiced_at TIMESTAMPTZ,
    next_review_at TIMESTAMPTZ,
    ease_factor FLOAT DEFAULT 2.5,
    repetition_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(profile_id, concept_id)
);

-- ==================== LIBRARY ====================

CREATE TABLE saved_objects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    learning_object_id UUID REFERENCES learning_objects(id) ON DELETE CASCADE,
    notes TEXT,
    saved_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(profile_id, learning_object_id)
);

CREATE TABLE notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    learning_object_id UUID REFERENCES learning_objects(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- ==================== AI ====================

CREATE TABLE ai_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    context JSONB DEFAULT '{}'::jsonb,
    started_at TIMESTAMPTZ DEFAULT now(),
    ended_at TIMESTAMPTZ
);

CREATE TABLE ai_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES ai_sessions(id) ON DELETE CASCADE,
    role TEXT CHECK (role IN ('user', 'assistant')) NOT NULL,
    content TEXT NOT NULL,
    grounding_sources JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ==================== GAMIFICATION ====================

CREATE TABLE streaks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    last_activity_date DATE,
    total_learning_days INT DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    achievement_type TEXT NOT NULL,
    unlocked_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(profile_id, achievement_type)
);

CREATE TABLE xp_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    amount INT NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ==================== INDEXES ====================

CREATE INDEX idx_profiles_account ON profiles(account_id);
CREATE INDEX idx_concept_embedding ON concepts USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX idx_source_embedding ON source_chunks USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX idx_learning_objects_concept ON learning_objects(concept_id);
CREATE INDEX idx_learning_objects_type ON learning_objects(object_type);
CREATE INDEX idx_mastery_profile ON mastery(profile_id, concept_id);
CREATE INDEX idx_mastery_review ON mastery(next_review_at) WHERE next_review_at IS NOT NULL;
CREATE INDEX idx_sessions_profile ON learning_sessions(profile_id, started_at);
CREATE INDEX idx_sessions_started ON learning_sessions(started_at);
CREATE INDEX idx_saved_objects_profile ON saved_objects(profile_id);
CREATE INDEX idx_topics_slug ON topics(slug);
CREATE INDEX idx_concepts_slug ON concepts(slug);

-- ==================== ROW LEVEL SECURITY ====================

ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE object_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE mastery ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE streaks ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE parental_controls ENABLE ROW LEVEL SECURITY;

-- Account access
CREATE POLICY "account_access" ON accounts
    USING (id = auth.uid());

-- Profile access (own profiles)
CREATE POLICY "profile_access" ON profiles
    USING (account_id = auth.uid());

-- Learning data access (profile-scoped)
CREATE POLICY "session_access" ON learning_sessions
    USING (profile_id IN (
        SELECT id FROM profiles WHERE account_id = auth.uid()
    ));

CREATE POLICY "mastery_access" ON mastery
    USING (profile_id IN (
        SELECT id FROM profiles WHERE account_id = auth.uid()
    ));

CREATE POLICY "saved_objects_access" ON saved_objects
    USING (profile_id IN (
        SELECT id FROM profiles WHERE account_id = auth.uid()
    ));

CREATE POLICY "ai_sessions_access" ON ai_sessions
    USING (profile_id IN (
        SELECT id FROM profiles WHERE account_id = auth.uid()
    ));

-- Public knowledge tables (read-only for all authenticated users)
CREATE POLICY "topics_read" ON topics FOR SELECT USING (true);
CREATE POLICY "concepts_read" ON concepts FOR SELECT USING (true);
CREATE POLICY "learning_objects_read" ON learning_objects FOR SELECT USING (true);
CREATE POLICY "sources_read" ON sources FOR SELECT USING (true);
