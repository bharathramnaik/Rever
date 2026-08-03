# Rever — CTO / Lead-Dev Context (Session Memory)

> Purpose: Prevents re-reading the codebase. Read once, trust this, update as you change things.

## Project
Flutter 3 (Material 3, Riverpod, GoRouter) + Supabase + FastAPI AI layer. Personal microlearning OS. Dev-mode bypasses auth (`DEV_MODE=true` default) with hardcoded profiles (dev-bharath/adult, dev-arjun/child 8, dev-nikhil/teen 15).

## Verified State (8/3/2026 — read from source, not docs)

### Fully Working & Wired
- **Auth**: Supabase. `lib/src/core/providers/auth_provider.dart` — `authStateProvider`, `currentUserProvider`, `isAuthenticatedProvider`. Dev auto-sign-in in `lib/main.dart`.
- **Profiles**: `profile_provider.dart` — `activeProfileIdProvider` (Notifier), `activeProfileProvider` (FutureProvider), `profilesProvider` (real Supabase when !isDev, else demo 3).
- **Router** (`lib/src/app/router.dart`): ShellRoute tabs (home/learn/create/library/me) + standalone routes (`/topic/:slug`, `/concept/:id`, `/sources`, `/source/:id`, `/ai-tutor?conceptId=`, `/review`, `/content-reel`, `/onboarding`, `/interests`, `/preferences`, `/profiles`, `/auth`). AppShell uses `NavigationBar`.
- **Explore/Library**: `ExternalContentService` — real Open Library + Wikipedia REST. Providers: `trendingContentProvider`, `searchBooksProvider`, `contentDetailProvider`, `contentStashesProvider`. `generateStashes()` deterministic sentence-splitting (no LLM).
- **Create (Spaces)**: `create_screen.dart` — 3 tabs → `_processSource` (2s fake delay line 112 then `fetchDetail`+`generateStashes`) → review sheet → `ideaCardRepositoryProvider.saveCards()` → real Supabase `idea_cards`.
- **Idea persistence**: `idea_card_repository.dart` — `saveCards`, `fetchFeed`, `reactToCard` (rpc `increment_card_reaction`), `addToStash`, `fetchByStash`. REAL.
- **Streaks**: `streak_providers.dart` — `streakProvider(profileId)`, `logStreakActivity(ref, profileId)`; called from `content_reel_screen.dart`. REAL (docs stale).
- **Quotes**: fallback chain Supabase → Quotable.io → ZenQuotes. Tap-and-hold expand.
- **Spaced repetition**: `core/learning/spaced_repetition.dart` (SM-2), `mastery_calculator.dart`.
- **Concept screen**: 5-level depth (Glance→Apply), quiz, flashcards, related concepts.

### Confirmed Broken / Placeholder (priority order)
1. **AI Tutor (Phase 3 roadmap)** — TOP GAP:
   - `ai/main.py`: FastAPI scaffold ONLY — `/ai/chat`, `/ai/generate/card`, `/ai/generate/quiz`, `/ai/generate/visual`, `/ai/embed` all "Not implemented yet".
   - `ai_tutor_screen.dart`: `_sendMessage` → `Future.delayed(1s)` → `_generatePlaceholderResponse` (hardcoded). 12 `TutorMode` chips. UI polished; backend not connected.
   - `AiMessageModel` exists but unused by tutor screen.
2. **Me screen**: "Notifications coming soon!" snackbar.
3. **Email OTP auth**: dialog exists, OTP not implemented.
4. **Drift/SQLite offline**: not wired (Phase 2).
5. **Python edge functions**: not deployed.

## Architecture Rules (enforced)
Riverpod only; GoRouter only; Dio for external HTTP; Supabase SDK for DB; Material 3 `ReverTheme`; `profile_id` scoping; RLS; `isDev` bypass for demo.

## Implementation Decision (AI Tutor, 8/3/2026)
- **Backend** (`ai/main.py` rewrite): Pydantic models; `/ai/chat` accepts `{message, mode, conversation_history}`; OpenAI Chat Completions when `OPENAI_API_KEY` set; deterministic per-mode fallback (quizMe/simplify/example/explain etc.) when no key — keyless dev works, gets better with key. Grounding sources in response. `/ai/generate/card`, `/ai/generate/quiz`, `/ai/generate/visual`, `/ai/embed` implemented (LLM-or-fallback).
- **Flutter**: `core/services/ai_api_service.dart` (Dio, 30s timeout, base URL `AppEnvironment.aiBaseUrl` default `http://localhost:8000`). `AiTutorScreen` calls backend; on failure falls back to placeholder text — never blocks.
- **NOT** hardcoded localhost for prod: `--dart-define=AI_BASE_URL=https://...`.

## Test/Verify Commands
- `flutter analyze` / `flutter test`
- `cd ai && pip install -r requirements.txt && uvicorn main:app --reload`
- `flutter run -d chrome`

## Git
Conventional commits, push `origin master`, CI runs test+analyze+build.