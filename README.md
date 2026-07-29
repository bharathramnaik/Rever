# Rever — Personal Learning OS

AI-powered microlearning for adults and kids. Break down complex topics into bite-sized, visual learning experiences with spaced repetition to ensure retention.

## Current Status

**Phase 1 (Foundation) — ~80% complete** — 50 passing tests

### ✅ Implemented

| Area | Features |
|------|----------|
| **Onboarding** | 4 swipeable intro screens, interest selection (topic grid, multi-select) |
| **Auth** | Google OAuth sign-in, auto profile creation from Google account |
| **Profiles** | Multi-profile switching (Netflix-style grid), fallback demo profiles |
| **Explore** | Topic grid from Supabase, topic → concept navigation |
| **Concept** | Detail screen with depth-based content (Glance/Master), MCQ quiz |
| **Library** | Saved objects tab (with empty state), profile-scoped |
| **Review** | Spaced repetition review screen (SM-2 algorithm) |
| **Sources** | Source catalog, source detail screen |
| **AI Tutor** | Chat UI scaffold (requires OpenAI API key — Phase 3) |
| **Appearance** | Dynamic app icons (morning/evening auto-switch) |
| **Navigation** | GoRouter, bottom nav (Home/Learn/Create/Library/Me), PopScope back handling |
| **Security** | Google service credentials removed from git → GitHub Secrets |
| **CI/CD** | GitHub Actions — analyze, test, build APK + web |

### ❌ Pending (Phase 1)

| Feature | Reason |
|---------|--------|
| Email/password auth | Google OAuth only; email sign-up not implemented |
| Daily goal setting | Goal selector exists in Me screen but not wired to onboarding |
| Profile → Supabase create | Add Profile dialog exists but doesn't insert into DB |
| Library save/bookmark | UI renders saved objects via provider override; Supabase write not wired |
| Full-text search | Search UI not built |
| Daily journey | Personalized 5-item feed not implemented |
| Reading streak persistence | Streak display exists; persistence to Supabase pending |
| Drift offline | SQLite schema exists; offline sync not wired |
| Edge functions | API client configured; edge functions not deployed |

### 🚀 Future Phases

| Phase | Focus | Est. |
|-------|-------|------|
| 2 | Learning Depth: mastery, progress dashboard, learning paths | Next |
| 3 | AI Tutor: GPT integration, RAG pipeline | Blocked (needs API key) |
| 4 | Visual Engine: interactive diagrams, animations | |
| 5 | Knowledge Graph: concept map, mastery heatmap | |
| 6 | Kids Mode: gamification, parent dashboard | |
| 7+ | Learning Spaces, Audio, Adaptive AI, Social, Enterprise | |

## Tech Stack

| Layer | Tech |
|-------|------|
| **Frontend** | Flutter 3.x, Riverpod, GoRouter |
| **Backend** | Supabase (PostgreSQL, Auth, Storage) |
| **AI** | Python FastAPI (future), OpenAI API (Phase 3) |
| **State** | Riverpod (state management, DI) |
| **Local DB** | Drift/SQLite |
| **CI/CD** | GitHub Actions → GitHub Pages (web), APK (Android) |

## Project Structure

```
rever/
├── lib/
│   └── src/
│       ├── app/          # App shell, router, theme provider
│       ├── core/         # Config, network, shared providers
│       ├── features/     # Feature modules (auth, home, explore, …)
│       └── learning_engine/  # Spaced repetition, mastery model
├── supabase/             # DB migrations, seed data, RLS
├── ai/                   # Python AI layer (future)
├── test/
│   ├── widget/           # Screen widget tests
│   ├── integration/      # Critical user flow tests
│   └── helpers/          # Shared test data
├── docs/                 # PRD, roadmap, feature matrix, ADRs
└── backlog/              # Epics with stories (EPIC-001 onward)
```

## Getting Started

```bash
flutter pub get
flutter run -d chrome    # Web
flutter run              # Android/iOS
```

### CI Secrets (for maintainers)

Two repository secrets must be set on GitHub:

| Secret | Value |
|--------|-------|
| `GOOGLE_SERVICES_JSON` | Base64 of `android/app/google-services.json` |
| `GOOGLE_SERVICE_INFO_PLIST` | Base64 of `ios/Runner/GoogleService-Info.plist` |

## Commands

| Command | Purpose |
|---------|---------|
| `flutter analyze` | Lint check (must pass before commit) |
| `flutter test` | Run all 50 tests |
| `flutter build apk --debug` | Android debug APK |
| `flutter build web --base-href=/Rever/` | GitHub Pages deploy |
