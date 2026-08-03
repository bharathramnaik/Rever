-- Sprint 3: Implicit signal tracking (flow.txt §3/§9)
-- Every user action on an idea becomes a signal for recommendations/retention.

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
CREATE POLICY IF NOT EXISTS "signals_own" ON signals USING (profile_id IN (
    SELECT id FROM profiles WHERE account_id = auth.uid()
));
