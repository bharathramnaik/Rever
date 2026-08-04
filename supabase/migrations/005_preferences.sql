-- Deepstash-style user preferences
-- Stores topic interests, goals, and learning style per profile

CREATE TABLE IF NOT EXISTS preferences (
    profile_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    topics text[] NOT NULL DEFAULT '{}',
    goal text,
    learning_style text,
    daily_goal_ideas int NOT NULL DEFAULT 5,
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_preferences_topics ON preferences USING GIN (topics);

ALTER TABLE preferences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "preferences_own" ON preferences;
CREATE POLICY "preferences_own" ON preferences FOR ALL USING (
    profile_id IN (SELECT id FROM profiles WHERE account_id = auth.uid())
) WITH CHECK (
    profile_id IN (SELECT id FROM profiles WHERE account_id = auth.uid())
);
