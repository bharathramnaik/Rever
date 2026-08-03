# Rever Roadmap (Deepstash 2.0)

Source: `flow.txt` architecture audit (Deepstash 2.0) + verified gap analysis of the
current codebase. Executed sprint-by-sprint per the autonomous-agent protocol
(prompt.txt): 6-step cycle (Reproduce → Instrument → Inspect → Isolate → Fix →
Verify), full test suite + analyze + E2E gate, then commit & push.

## Current state baseline (verified by grep/schema inspection)

| flow.txt item | Status |
|---|---|
| 1. Atomic content model (Source → Idea → Taxonomy) | Partial — `sources`, `concepts`, `idea_cards`, `topics` exist; idea cards lack difficulty/quality_score/status; no skills/domains/industries taxonomy |
| 2. Library population (OpenLibrary + AI) | Partial — OpenLibrary search (title/author/isbn/cover), `content_generator` Book→Prompt→Card; no chunking/fact-check/dedup/quality scoring |
| 3. Recommendation scoring | Partial — preference-based personalization only |
| 4. Vector search | Missing — keyword search only |
| 5. Knowledge graph | Starter at concept level (`concept_relationships` + visual map); missing idea-level edges + AI generation |
| 6. Search stack | Partial — unified keyword search (concepts/topics/sources); no autocomplete/tag |
| 7. AI pipeline multi-asset | Partial — one IdeaCard per source; no takeaways/examples/questions/flashcards/tags/embedding |
| 8. Copyright | Guidance — original distillation + attribution; no word-count-only reliance |
| 9. User layer | Partial — profiles/preferences/streaks/saved_objects/achievements; missing collections-first UX, following, signal tracking |
| 10. Five-layer architecture | Vision |

## Sprints

- [x] Sprint 0 — ROADMAP.md baseline
- [x] Sprint 1 — Idea-level knowledge graph: `idea_relationships` (supports /
      contradicts / prerequisite_of / related_to), AI edge generation via LLM
      chain, related-ideas UI, tests
- [x] Sprint 2 — Richer Idea model + taxonomy: difficulty / quality_score /
      language / status on idea_cards; skills / domains / industries tables
      (`008_idea_taxonomy.sql`)
- [x] Sprint 3 — Implicit signal tracking: `signals` table (opened, finished,
      liked, saved, shared, skipped, dwelled) + recording in reel/library
      (`009_signals.sql`)
- [x] Sprint 4 — Recommendation scoring: `RecommendationService` weighted
      engine (CF proxy + personalization + trending + freshness + diversity)
      + "Top ideas for you" rail in Library Discover
- [x] Sprint 5 — AI multi-asset pipeline: takeaways / examples / questions /
      flashcards / tags per source (`010_idea_assets.sql`) + DuplicateDetector
      + structural quality gate wired into create flow
- [x] Sprint 6 — Vector search: `embedding` column + `search_idea_embeddings`
      RPC (`011_vector_search.sql`) + NVIDIA NIM embedding client + rerank +
      keyword fallback in Library search
- [ ] Sprint 7 — E2E verification gate (tests + analyze + CDP boot), commit & push

## Standing conventions

- LLM keys via `--dart-define` only; NVIDIA NIM chain (kimi → nemotron → nvidia-3);
  zero key literals in source.
- Dev mode bypasses auth (demo profiles); profile-scoped writes are `isDev`-guarded.
- Content is original distillation with source attribution (flow.txt §8).
