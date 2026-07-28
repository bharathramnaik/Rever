# Rever — Agent Guide

## Project Structure
```
Rever/
├── docs/           # Product & technical documentation (00-20)
├── backlog/        # Epics with stories (EPIC-001 onwards)
├── decisions/      # Architecture Decision Records (ADR-001 onwards)
├── lib/            # Flutter application
│   └── src/
│       ├── app/         # App shell, router, providers
│       ├── core/        # Theme, network, shared providers
│       ├── features/    # Feature modules (auth, home, explore, etc.)
│       ├── shared/      # Shared widgets and utilities
│       └── learning_engine/  # Spaced repetition, mastery model
├── supabase/       # Database migrations and seed data
├── ai/             # Python AI layer (FastAPI)
├── admin/          # Next.js admin panel (future)
├── test/           # Flutter tests
└── assets/         # Fonts, images, animations
```

## Commands
- `flutter analyze` — Run linter
- `flutter test` — Run tests
- `flutter run` — Run on connected device
- `dart run build_runner build` — Generate code (Riverpod, Freezed)

## Agent Workflow
1. Read docs/ relevant to your task
2. Check backlog/ for existing work
3. Implement changes following established patterns
4. Run `flutter analyze` and `flutter test`
5. Update docs if behavior changed
6. Commit with descriptive message

## Architecture Rules
- State: Riverpod only
- Navigation: GoRouter only
- HTTP: Dio with Supabase auth interceptor
- Local DB: Drift/SQLite
- Theme: ReverTheme from core/theme
- API calls go through Supabase SDK or Dio client
- All profile-scoped data includes profile_id filter
- RLS policies enforce profile isolation
