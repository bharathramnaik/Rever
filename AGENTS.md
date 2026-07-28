# Rever — Agent Guide

## Project Structure
```
Rever/
├── docs/           # Product & technical documentation (00-20)
├── backlog/        # Epics with stories, bug tracking (EPIC-001 onwards)
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
│   ├── unit/models/           # Model unit tests
│   ├── unit/providers/        # Provider unit tests (Riverpod overrides)
│   ├── widget/                # Widget tests for screens
│   ├── integration/           # Critical user flow integration tests
│   └── helpers/               # Shared test data and provider overrides
└── assets/         # Fonts, images, animations
```

## Commands
- `flutter analyze` — Run linter (must pass before commit)
- `flutter test` — Run all tests (currently 51 tests)
- `flutter test test/unit/` — Run only unit tests
- `flutter test test/widget/` — Run only widget tests
- `flutter test test/integration/` — Run only integration tests
- `flutter test --coverage` — Generate coverage report
- `flutter run` — Run on connected device
- `dart run build_runner build` — Generate code (Riverpod, Freezed)

## Testing Conventions
- **Model tests**: Pure unit tests — no mocking needed, test `fromJson()` parsing and edge cases
- **Provider tests**: Use `ProviderContainer` with `overrideWith` to inject test data
  - `FutureProvider` override: `provider.overrideWith((ref) async => testData)`
  - `NotifierProvider` override: `provider.overrideWith(TestNotifier.new)` (create a subclass)
- **Widget tests**: Wrap in `ProviderScope` with overrides, use `MaterialApp` wrapper for screens needing theme/routing
- **Integration tests**: Override all data providers with test data, test full navigation flows
- **Bug tracking**: Add defects to `backlog/bug_tracking.xlsx` (or CSV) per release cycle

## Agent Workflow
1. Read docs/ relevant to your task (especially 14-TESTING.md)
2. Check backlog/ for existing work and open bugs
3. Implement changes following established patterns
4. Run `flutter analyze` and `flutter test` — fix all failures
5. Update docs if behavior changed
6. Log any new bugs found in `backlog/bug_tracking.xlsx`
7. Commit with descriptive message

## Architecture Rules
- State: Riverpod only
- Navigation: GoRouter only
- HTTP: Dio with Supabase auth interceptor
- Local DB: Drift/SQLite
- Theme: ReverTheme from core/theme
- API calls go through Supabase SDK or Dio client
- All profile-scoped data includes profile_id filter
- RLS policies enforce profile isolation
- **No OpenAI API key yet** — AI tutor deferred to Phase 3
