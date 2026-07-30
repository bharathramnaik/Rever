# Rever — Agent Guide

## Project Structure
```
Rever/
├── docs/           # Product & technical documentation (00-20)
├── backlog/        # Epics with stories, bug tracking (EPIC-001 onwards)
├── decisions/      # Architecture Decision Records (ADR-001 onwards)
├── lib/            # Flutter application
│   └── src/
│       ├── app/                  # App shell, router, providers
│       ├── core/                 # Theme, network, shared providers
│       │   ├── config/           # Environment (isDev flag), Firebase options
│       │   ├── providers/        # Auth, profile, app icon providers
│       │   ├── services/         # Firebase, app icon service
│       │   └── learning/         # SM-2 spaced repetition, mastery calculator
│       ├── features/             # Feature modules
│       │   ├── auth/             # OAuth, email dialog, login screen
│       │   ├── home/             # Greeting, quote card (tap-and-hold), quick actions
│       │   ├── explore/          # Topic grid, search, topic → concept flow
│       │   ├── library/          # 3 tabs: Discover, Saved, Concepts
│       │   │   └── screens/
│       │   │       ├── library_screen.dart       # TabBar with Discover/Saved/Concepts
│       │   │       └── content_reel_screen.dart   # Vertical reel (Deepstash-style)
│       │   ├── spaces/           # Create (NotebookLM ingestion studio), learning spaces
│       │   ├── concept/          # 5-level depth (Glance→Apply), quiz, flashcards, related concepts
│       │   ├── review/           # Spaced repetition review feed
│       │   ├── ai_tutor/         # 12 tutor modes — scaffold (needs API key)
│       │   ├── profile/          # Profile switch, me screen, settings
│       │   ├── sources/          # Source catalog + detail
│       │   └── onboarding/       # Onboarding slides, interest selection
│       ├── data/
│       │   ├── models/           # IdeaCard, Stash, StashItem, StashCard, ExploreContent,
│       │   │                     # Quote, Concept, Topic, Profile, Mastery, etc.
│       │   ├── providers/        # Riverpod providers (quote, concept, topic, search, etc.)
│       │   ├── repositories/     # Supabase repositories (concept, topic, idea_card, etc.)
│       │   └── services/         # ExternalContentService (Open Library, Wikipedia, stash gen)
│       └── shared/               # Shared widgets and utilities
├── supabase/                     # Database migrations (001-004), seed data, RLS
├── ai/                           # Python AI layer (FastAPI — future)
├── admin/                        # Next.js admin panel (future)
├── test/
│   ├── widget/                   # Widget tests for screens
│   ├── integration/              # Critical user flow integration tests
│   └── helpers/                  # Shared test data and provider overrides
└── assets/                       # Fonts, images, animations
```

## Architecture Rules
- **State**: Riverpod only (FutureProvider, NotifierProvider, family providers)
- **Navigation**: GoRouter only — ShellRoute for bottom tabs, standalone routes for full-screen
- **HTTP**: Dio for external APIs (Open Library, Wikipedia, quotes), Supabase SDK for DB
- **Local DB**: Drift/SQLite (offline sync — Phase 2)
- **Theme**: Material 3 via `ReverTheme` from `core/theme/`
- **API calls**: Supabase SDK for auth + data, Dio for external services
- **Profile scope**: All user data includes `profile_id` filter; RLS enforces isolation
- **Demo mode**: `isDev` flag in `environment.dart` — bypasses Supabase auth, uses hardcoded demo profiles (Bharath, Arjun, Nikhil)
- **External content**: Open Library API (books), Wikipedia REST API (articles), Quotable.io + ZenQuotes (quotes fallback)

## Routes

| Path | Screen | In Shell? |
|------|--------|-----------|
| `/profiles` | ProfileSwitchScreen | No |
| `/auth` | LoginScreen (OAuth + email) | No |
| `/onboarding` | OnboardingScreen | No |
| `/home` | HomeScreen (greeting + quote card + quick actions) | Yes |
| `/learn` | ExploreScreen (topics + search) | Yes |
| `/library` | LibraryScreen (Discover + Saved + Concepts) | Yes |
| `/create` | CreateScreen (NotebookLM ingestion studio) | Yes |
| `/me` | MeScreen (settings, streak, achievements) | Yes |
| `/topic/:slug` | TopicScreen (concepts in topic) | No |
| `/concept/:id` | ConceptScreen (5-level depth system) | No |
| `/content-reel` | ContentReelScreen (vertical stash cards) | No |
| `/ai-tutor` | AiTutorScreen (12 modes) | No |
| `/review` | ReviewScreen (SM-2 spaced repetition) | No |
| `/sources` | Source catalog | No |
| `/source/:id` | Source detail | No |

## Current State (July 2026)

### What Works
- **Dev mode bypass**: No Supabase auth needed — tap a demo profile to enter
- **Library → Discover**: Trending books (Open Library) + articles (Wikipedia), search by keyword
- **Content Reel**: Vertical swipeable Deepstash-style idea cards with reactions (Like/Mind Blown/Useful), stash bookmark, progress bar, daily streak overlay
- **Create (NotebookLM Studio)**: 3-tab ingestion (URL, Note, YouTube) → animated processing → auto-extracts idea cards → review sheet
- **Quotes**: Home screen card with tap-and-hold expand; fallback chain (Supabase → Quotable.io → ZenQuotes)
- **Multi-profile**: 3 demo profiles (Adult/Teen/Child), profile switching
- **Explore**: Topic grid from Supabase, search, topic → concept drill-down
- **Concept depth**: 5 levels (Glance → Understand → Explore → Master → Apply) with quizzes, flashcards, related concepts graph
- **Spaced repetition**: SM-2 algorithm, mastery calculator
- **AI Tutor**: 12 modes scaffold (explain, simplify, quiz, analogy, etc.)
- **CI/CD**: GitHub Actions — test, analyze, build web + APK

### What's Pending
- **LLM integration**: AI Tutor needs OpenAI API key (chat + RAG)
- **Source ingestion to DB**: CreateScreen generates cards client-side; not persisted to Supabase yet
- **Streak persistence**: Display works but doesn't sync to Supabase
- **Full-text search**: Search UI built; needs Supabase `tsvector` index
- **Edge functions**: Python `ai/` backend not deployed
- **Drift offline sync**: Schema exists, not wired
- **Email auth OTP**: Dialog exists, OTP verification not implemented

## Commands
- `flutter analyze` — Run linter (must pass before commit)
- `flutter test` — Run all tests
- `flutter run -d chrome` — Run on Chrome (serve with `python -m http.server 3000` from `build/web` for static build)
- `flutter build web` — Production web build
- `flutter build apk --debug` — Android debug APK

## External APIs Used (No Keys Required)
- **Open Library**: `https://openlibrary.org/search.json?q=...` and `https://openlibrary.org/works/{id}.json`
- **Wikipedia**: `https://en.wikipedia.org/api/rest_v1/page/random/summary` and `/page/summary/{title}`
- **Quotable.io**: `https://api.quotable.io/quotes/random`
- **ZenQuotes**: `https://zenquotes.io/api/random`

## Testing Conventions
- **Model tests**: Pure unit tests — test `fromJson()` parsing and edge cases
- **Provider tests**: Use `ProviderContainer` with `overrideWith` to inject test data
- **Widget tests**: Wrap in `ProviderScope` with overrides, use `MaterialApp` wrapper for screens needing theme/routing
- **Integration tests**: Override all data providers with test data, test full navigation flows

## Git Workflow
1. Run `flutter analyze` + `flutter test` before committing
2. Commit with conventional commit message (`feat:`, `fix:`, `refactor:`, `docs:`)
3. Push to `origin master` — CI runs automatically
