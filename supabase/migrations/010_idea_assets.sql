-- Sprint 5: AI multi-asset pipeline (flow.txt §7)
-- One source becomes many knowledge assets: takeaways, examples, questions,
-- flashcards stored on the idea card.

ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS takeaways text[] DEFAULT '{}';
ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS examples text[] DEFAULT '{}';
ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS questions text[] DEFAULT '{}';
ALTER TABLE idea_cards ADD COLUMN IF NOT EXISTS flashcards jsonb DEFAULT '[]'::jsonb;
