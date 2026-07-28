# Database Schema (PostgreSQL + Supabase)

## Bounded Domains

### IDENTITY

```sql
-- Accounts (owns billing/settings)
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Profiles (owns learning)
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    avatar_url TEXT,
    profile_type TEXT CHECK (profile_type IN ('adult', 'child', 'teen')),
    age_range TEXT, -- '5-7', '8-10', '11-13', '14-17', '18+'
    daily_goal_minutes INT DEFAULT 10,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE profile_interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    topic_id UUID REFERENCES topics(id),
    level TEXT DEFAULT 'beginner'
);

CREATE TABLE parental_controls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
    daily_limit_minutes INT DEFAULT 30,
    ai_enabled BOOLEAN DEFAULT true,
    content_restrictions JSONB DEFAULT '[]',
    parent_pin_hash TEXT
);
```

### KNOWLEDGE

```sql
CREATE TABLE topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    icon TEXT,
    color TEXT,
    parent_topic_id UUID REFERENCES topics(id),
    sort_order INT DEFAULT 0
);

CREATE TABLE concepts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    summary TEXT,
    difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    estimated_minutes INT,
    embedding VECTOR(1536),
    quality_score FLOAT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE concept_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_concept_id UUID REFERENCES concepts(id),
    target_concept_id UUID REFERENCES concepts(id),
    relationship_type TEXT CHECK (relationship_type IN (
        'prerequisite_of', 'related_to', 'example_of',
        'part_of', 'extends', 'applies_to', 'similar_to'
    )),
    UNIQUE(source_concept_id, target_concept_id, relationship_type)
);

CREATE TABLE sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    url TEXT,
    source_type TEXT,
    license TEXT,
    provenance JSONB
);

CREATE TABLE source_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id UUID REFERENCES sources(id),
    content TEXT NOT NULL,
    embedding VECTOR(1536),
    chunk_index INT
);
```

### LEARNING

```sql
CREATE TABLE learning_objects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    concept_id UUID REFERENCES concepts(id),
    object_type TEXT CHECK (object_type IN (
        'card', 'article', 'diagram', 'flowchart',
        'timeline', 'quiz', 'flashcard', 'story',
        'animation', 'audio', 'exercise', 'project'
    )),
    title TEXT NOT NULL,
    content JSONB NOT NULL,
    difficulty TEXT,
    age_min INT,
    age_max INT,
    estimated_duration INT, -- seconds
    embedding VECTOR(1536),
    quality_score FLOAT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE learning_paths (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    topic_id UUID REFERENCES topics(id),
    difficulty TEXT,
    estimated_total_minutes INT
);

CREATE TABLE learning_path_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    path_id UUID REFERENCES learning_paths(id) ON DELETE CASCADE,
    learning_object_id UUID REFERENCES learning_objects(id),
    step_order INT NOT NULL,
    required BOOLEAN DEFAULT true
);
```

### ACTIVITY

```sql
CREATE TABLE learning_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ DEFAULT now(),
    ended_at TIMESTAMPTZ,
    duration_seconds INT,
    objects_viewed INT DEFAULT 0,
    quizzes_taken INT DEFAULT 0,
    ai_queries INT DEFAULT 0
);

CREATE TABLE object_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    learning_object_id UUID REFERENCES learning_objects(id),
    interaction_type TEXT,
    completed BOOLEAN DEFAULT false,
    time_spent_seconds INT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE mastery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    concept_id UUID REFERENCES concepts(id),
    mastery_level FLOAT DEFAULT 0, -- 0.0 to 1.0
    times_practiced INT DEFAULT 0,
    last_practiced_at TIMESTAMPTZ,
    next_review_at TIMESTAMPTZ,
    UNIQUE(profile_id, concept_id)
);
```

### LIBRARY & AI

```sql
CREATE TABLE saved_objects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    learning_object_id UUID REFERENCES learning_objects(id),
    notes TEXT,
    saved_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(profile_id, learning_object_id)
);

CREATE TABLE ai_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    context JSONB,
    started_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE ai_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES ai_sessions(id) ON DELETE CASCADE,
    role TEXT CHECK (role IN ('user', 'assistant')),
    content TEXT NOT NULL,
    grounding_sources JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);
```

### GAMIFICATION

```sql
CREATE TABLE streaks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    last_activity_date DATE,
    total_learning_days INT DEFAULT 0
);

CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    achievement_type TEXT NOT NULL,
    unlocked_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(profile_id, achievement_type)
);
```

## Indexes

```sql
CREATE INDEX idx_profiles_account ON profiles(account_id);
CREATE INDEX idx_concept_embedding ON concepts USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX idx_source_embedding ON source_chunks USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX idx_learning_objects_concept ON learning_objects(concept_id);
CREATE INDEX idx_mastery_profile ON mastery(profile_id, concept_id);
CREATE INDEX idx_mastery_review ON mastery(next_review_at) WHERE next_review_at IS NOT NULL;
CREATE INDEX idx_sessions_profile ON learning_sessions(profile_id, started_at);
```
