# Testing Strategy

## Levels

### Unit Tests
- Flutter: `flutter test` (Riverpod providers, models, utils)
- Backend: Edge Function unit tests
- AI: Python pytest (generators, validators)

### Widget Tests
- Flutter widget tests for all components
- Golden tests for visual components

### Integration Tests
- Flutter: `integration_test/` for critical flows
  - Onboarding → Home
  - Search → Learn → Quiz
  - Profile creation
  - Save → Library

### End-to-End Tests
- Supabase local emulator for backend testing
- Postman/Newman collections for API contract testing

## Testing Goals
- Coverage: 80%+ on core logic
- All widget tests pass
- Integration tests cover all critical paths
- No regression on existing functionality

## CI/CD (GitHub Actions)
- PR: lint + unit test + build check
- Merge to main: full test suite + deploy to staging
- Tag release: deploy to production
