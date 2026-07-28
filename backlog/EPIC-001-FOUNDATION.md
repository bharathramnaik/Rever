# EPIC-001: Foundation

## Status
Complete

## Description
Set up the Rever project with Flutter, Supabase, and all development tooling.

## Stories

### STORY-001.1: Flutter project scaffold
- [x] Create Flutter project with `flutter create`
- [x] Set up folder structure (lib/src/app, core, features, shared, learning_engine)
- [x] Configure Riverpod, GoRouter, Dio dependencies
- [x] Set up lint rules (analysis_options.yaml)

### STORY-001.2: Supabase project setup
- [x] Create Supabase project
- [x] Configure auth providers (email, Google)
- [x] Set up database with initial schema (migrations)
- [x] Configure RLS policies (including fix for concept_topics read policy)
- [x] Seed data (12 topics, 30 concepts, 40+ learning objects)

### STORY-001.3: Theme and design system
- [x] Implement Rever theme (light/dark)
- [x] Create color tokens
- [x] Build component primitives (card, chip, navigation bar)

### STORY-001.4: CI/CD pipeline
- [x] GitHub Pages deployment (gh-pages branch)
- [ ] GitHub Actions workflow for lint + test
- [ ] Code signing configuration (Android + iOS)
- [ ] Fastlane setup for beta deployment

## Acceptance Criteria
- [x] `flutter analyze` passes with zero errors
- [x] `flutter test` passes with 51 tests
- [x] App runs on Chrome/web (development and production)
- [x] Supabase project connects and serves data
- [x] Theme renders correctly on light and dark mode
