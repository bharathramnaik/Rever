# Rever — Personal Learning OS

AI-powered microlearning for adults and kids. Break down complex topics into bite-sized, visual learning experiences with spaced repetition to ensure retention.

Now evolving into a **Deepstash + NotebookLM hybrid**: ingest sources (URL, notes, YouTube), auto-extract bite-sized idea cards, browse in a vertical reel with interactive reactions, and query a source-grounded AI tutor.

## Current Status

**Phase 1 (Foundation) — ~90% complete** — 49 tests passing

### ✅ Implemented

| Area | Features |
|------|----------|
| **Onboarding** | Removed static slides — app starts directly at profile selection |
| **Auth** | Google OAuth, email/password dialog, dev-mode auto sign-in (`dev@rever.app`) |
| **Profiles** | Multi-profile switching (Netflix-style grid), demo profiles (Bharath, Arjun, Nikhil) |
| **Explore** | Topic grid from Supabase, topic → concept navigation |
| **Concept** | Detail screen with 5-level depth system (Glance → Apply), MCQ quiz, flashcards, related concepts graph |
| **Library → Discover** | Browse trending books (Open Library API), random Wikipedia articles, search books by keyword |
| **Content Reel** | Vertical swipeable slides (Deepstash-style) with: source badge, digestible idea breakdown, reaction buttons (Like/Mind Blown/Useful with elastic animations), stash bookmark, daily streak overlay |
| **Source Ingestion** | NotebookLM-style studio: paste URL, raw note, or YouTube link → auto-extracts idea cards with processing animation |
| **Review** | Spaced repetition review screen (SM-2 algorithm) |
| **Sources** | Source catalog, source detail screen |
| **AI Tutor** | 12 tutor modes (scaffold — requires API key for LLM integration) |
| **Quotes** | Home screen quote card with tap-and-hold expand, fallback chain (Supabase → Quotable.io → ZenQuotes) |
| **Achievements** | Dynamic app icons (morning/evening auto-switch) |
| **Navigation** | GoRouter, bottom nav (Home/Learn/Create/Library/Me), PopScope back handling |
| **CI/CD** | GitHub Actions — analyze, test, build web + APK, decode Google service files from secrets |

### ❌ Pending

| Feature | Reason |
|---------|--------|
| Email/password auth | Google OAuth primary; email sign-up dialog exists but OTP not wired |
| Daily goal setting | Goal selector exists but not wired to onboarding |
| Full-text search | UI scaffold built; needs Supabase full-text index |
| Daily journey feed | Personalized 5-item daily feed not implemented |
| Reading streak persistence | Streak display exists; persistence to Supabase pending |
| Drift offline | SQLite schema exists; offline sync not wired |
| AI Tutor (LLM) | Requires OpenAI API key — chat UI and 12 modes ready |
| Edge functions | API client configured; edge functions not deployed |

### 🚀 Future Phases

| Phase | Focus | Est. |
|-------|-------|------|
| 2 | Learning Depth: mastery dashboard, learning paths | Next |
| 3 | AI Tutor: GPT integration, RAG pipeline | Blocked (needs API key) |
| 4 | Visual Engine: interactive diagrams, animations | |
| 5 | Knowledge Graph: concept map, mastery heatmap | |
| 6 | Kids Mode: gamification, parent dashboard | |

## Tech Stack

| Layer | Tech |
|-------|------|
| **Frontend** | Flutter 3.x, Riverpod, GoRouter |
| **Backend** | Supabase (PostgreSQL, Auth, Storage, pgvector) |
| **External APIs** | Open Library (books), Wikipedia REST (articles), Quotable.io / ZenQuotes (quotes fallback) |
| **State** | Riverpod (state management, DI) |
| **Local DB** | Drift/SQLite |
| **CI/CD** | GitHub Actions → GitHub Pages (web), APK (Android) |

## Project Structure

```
rever/
├── lib/
│   └── src/
│       ├── app/              # App shell, router, theme provider
│       ├── core/             # Config, network, shared providers
│       ├── features/         # Feature modules
│       │   ├── auth/         # Login, OAuth, email dialog
│       │   ├── home/         # Greeting, quote card, quick actions
│       │   ├── explore/      # Topic grid, search, topic detail
│       │   ├── library/      # Discover (external content), saved, concepts
│       │   │   └── screens/
│       │   │       ├── library_screen.dart       # 3 tabs: Discover/Saved/Concepts
│       │   │       └── content_reel_screen.dart   # Deepstash-style vertical reel
│       │   ├── spaces/       # Create (NotebookLM ingestion studio), learning spaces
│       │   ├── concept/      # 5-level depth, quiz, flashcards, related concepts
│       │   ├── review/       # Spaced repetition (SM-2)
│       │   ├── ai_tutor/     # 12 tutor modes (scaffold)
│       │   ├── profile/      # Profile switch, me screen, settings
│       │   └── sources/      # Source catalog, source detail
│       ├── data/
│       │   ├── models/       # All data models (IdeaCard, Stash, Quote, ExploreContent, etc.)
│       │   ├── providers/    # Riverpod providers
│       │   ├── repositories/ # Supabase data access
│       │   └── services/     # ExternalContentService (Open Library, Wikipedia, stash generation)
│       └── learning_engine/  # Spaced repetition, mastery calculator
├── supabase/                 # DB migrations (001-004), seed data, RLS
│   └── migrations/
│       ├── 001_initial_schema.sql
│       ├── 002_auth_triggers.sql
│       ├── 003_quotes.sql
│       └── 004_deepstash_notebooklm.sql
├── ai/                       # Python AI layer (future)
├── test/
│   ├── widget/               # Screen widget tests
│   ├── integration/          # Critical user flow tests
│   └── helpers/              # Shared test data
└── docs/                     # PRD, roadmap, feature matrix, ADRs
```

## Getting Started

```bash
flutter pub get
flutter run -d chrome       # Web (recommended for dev)
flutter run                  # Android/iOS
```

### CI Secrets (for maintainers)

| Secret | Value |
|--------|-------|
| `GOOGLE_SERVICES_JSON` | Base64 of `android/app/google-services.json` |
| `GOOGLE_SERVICE_INFO_PLIST` | Base64 of `ios/Runner/GoogleService-Info.plist` |

## Commands

| Command | Purpose |
|---------|---------|
| `flutter analyze` | Lint check (must pass before commit) |
| `flutter test` | Run all tests |
| `flutter build web` | Production web build |
| `flutter build apk --debug` | Android debug APK |
