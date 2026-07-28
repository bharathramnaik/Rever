# EPIC-001: Foundation

## Status
In Progress

## Description
Set up the Rever project with Flutter, Supabase, and all development tooling.

## Stories

### STORY-001.1: Flutter project scaffold
- Create Flutter project with `flutter create`
- Set up folder structure (lib/src/app, core, features, shared, learning_engine)
- Configure Riverpod, GoRouter, Dio dependencies
- Set up lint rules (analysis_options.yaml)

### STORY-001.2: Supabase project setup
- Create Supabase project
- Configure auth providers (email, Google)
- Set up database with initial schema
- Configure storage buckets
- Deploy first Edge Function (health check)

### STORY-001.3: Theme and design system
- Implement Rever theme (light/dark)
- Create typography configuration
- Implement color tokens
- Build component primitives (button, card, input, chip)
- Create widget testing utilities

### STORY-001.4: CI/CD pipeline
- GitHub Actions workflow for lint + test
- GitHub Actions workflow for build
- Code signing configuration (Android + iOS)
- Fastlane setup for beta deployment

## Acceptance Criteria
- [ ] `flutter analyze` passes with zero errors
- [ ] `flutter test` passes with baseline tests
- [ ] App runs on Android emulator
- [ ] Supabase local instance connects
- [ ] Theme renders correctly on light and dark mode
