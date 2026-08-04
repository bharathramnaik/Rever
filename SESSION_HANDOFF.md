# Rever — Session Handoff (updated after token-router + publish flow session)

Branch: `master` (repo: D:\Projects\Rever). Last pushed commit: `6db6e33`.
Everything below is committed or being committed this session.

## Product direction (user's decisions)

- NO AI tutor / chatbot. Rever delivers static micro-learning only.
- One-shot LLM calls ONLY for: book → overall picture + micro-learning structure (extraction, NotebookLM-style). Interactive calls removed.
- URL/YouTube extraction: commented out (deferred until a reliable LLM API).
- Users publish their own articles/blogs → owner approves (Supabase dashboard) → visible to all.
- Preferences-driven: show up to 10 books; each profile can access/request only 3 books for now (plans/pricing later).

## LLM providers (current chain, in order)

1. `nvidia-nemotron` — nvidia/nemotron-3-ultra-550b-a55b, key `LLM_API_KEY_NVIDIA_NEMOTRON` (thinking on)
2. `nvidia-inkling` — thinkingmachines/inkling, `LLM_API_KEY_NVIDIA_INKLING`
3. `nvidia-riva` — nvidia/riva-translate-4b-instruct-v2, `LLM_API_KEY_NVIDIA_3`
4. `token-router` — moonshotai/kimi-k3-free, `LLM_API_KEY_TOKEN_ROUTER`, base https://api.tokenrouter.com/v1 (NEW — user's key named "Revere")

- kimi-k3-free LIVE-TESTED working via tokenrouter (reasoning comes back in `message.reasoning_content`, not `reasoning` — parser handles both).
- `nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free` on tokenrouter FAILED: insufficient_user_quota (account $0.00) — NOT wired in.
- CI (build-android + build-web) now also pass `--dart-define=LLM_API_KEY_TOKEN_ROUTER=${{ secrets.LLM_API_KEY_TOKEN_ROUTER }}`. **USER MUST ADD GitHub secret `LLM_API_KEY_TOKEN_ROUTER`** (value: sk-tARdDWMR1h9EfY9s60Czh5uHg5Zdovcx6QSSpjzuDvYAG07e) — secret was never put in any file.

## Implemented this session (TO COMMIT — pending push)

1. AI tutor fully cut: `lib/src/features/ai_tutor/` deleted, route `/ai-tutor` + import removed from router.dart, home quick action + "Ask the AI Tutor" card removed, me_screen copy tweaked, `flutter_markdown` dependency removed.
2. `supabase/full_schema.sql` += 012 `submissions` (title/body/status pending|approved|rejected + RLS own/approved-readable, insert/update own) and 013 `book_access` (profile_id/source_id/status requested|granted|denied, PK pair, RLS read-all/insert-own). **USER MUST RUN THIS FILE AGAIN in Supabase SQL editor** (appends 012/013).
3. New data layer:
   - `lib/src/data/models/submission_model.dart` + `submission_repository.dart` + `providers/submission_providers.dart`
   - `lib/src/data/models/book_access_model.dart` + `repositories/book_access_repository.dart` (has `BookAccessGate`: statusFor/activeCount/canRequestMore, cap 3) + `providers/book_access_providers.dart`
   - Dev-mode local caches (SharedPreferences) for both, because demo ids (`dev-bharath`) aren't UUIDs → 22P02. Book requests AUTO-GRANT in dev so the flow is testable.
4. `create_screen.dart` rewritten: "Publish your article" form (title + body) → `submissionRepository.submit` → "Submitted for review"; "My Submissions" list with status chips + Withdraw. Old URL/Note/YouTube tabs + `_processSource` extraction left as a commented "DEFERRED" block.
5. `explore_screen.dart`: Sources preview → **Books** section, capped at 10 (`take(10)`), tappable → `/source/:id`, copy explains the 3-book cap.
6. `source_detail_screen.dart` rewritten: access card (Request access / Requested / Denied / "Access limit reached (3)"), on granted → **Start Micro-learning** button → one-shot `UrlTextFetcher.fetch(url)` → `contentGeneratorProvider.generate` → inline cards + Save to Library (dev local store / prod ideaCardRepository.saveGenerated + graph edges). No LLM key → "AI extraction will be available soon".
7. `home_screen_test.dart`: removed AI Tutor assertion. `flutter analyze` clean (only pre-existing infos), `flutter test` 109 passed + 1 skipped.
8. `.gitignore` += `build/`; `build/web/*` untracked (git rm --cached) — build artifacts no longer committed.

## Still TODO / notes

- `llm_live_smoke_test.dart` unchanged (runs chain incl. token-router if define passed).
- No tests yet for new repos/screens (submissions/book_access/create/source_detail). Add unit tests for BookAccessGate (cap logic) + repo dev paths if time permits.
- Admin approval UX: owner approves via Supabase dashboard (UPDATE submissions SET status='approved', approved_at=now() WHERE id=...). In-app admin UI not built — by design (keep simple).
- Earlier committed baseline `6db6e33` covers: NVIDIA chain, extra_body fix, CI secrets (nemotron/inkling/riva), schema 007–011, live smoke test.
- Constraints: NEVER write API keys into source; don't `dart format` whole repo (reverts ~85 files, old formatter style); CI gates on analyze + tests.
- Profile boot-redirect (once-per-process static in profile_switch_screen.dart) and streak logActivity wiring (content_reel_screen 'finished') were part of the pre-outage batch — verify they're in the commit you make.
