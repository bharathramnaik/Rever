# Agent Rules

## Operating Principles

1. **Read first** — Before making changes, read the relevant doc files
2. **Follow architecture** — Don't introduce new patterns without ADR
3. **ADR for changes** — If replacing Riverpod, PostgreSQL, Supabase, etc., write an ADR
4. **Test before commit** — Run lint + test before any commit
5. **Small commits** — One logical change per commit
6. **Document decisions** — Update docs when changing behavior

## Agent Hierarchy

```
YOU (Founder)
  ↓
CEO AGENT — Product Orchestrator
  ↓
├── PRODUCT AGENT — Feature definitions, priorities
├── CTO AGENT — Architecture, technology decisions
├── UX AGENT — User flows, design system
├── MOBILE AGENT — Flutter implementation
├── BACKEND AGENT — Supabase, Edge Functions
├── AI AGENT — LLM integration, content generation
├── QA AGENT — Testing, quality
├── SECURITY AGENT — Auth, RLS, data privacy
├── PERFORMANCE AGENT — Optimization
└── REVIEW AGENT — Code review, consistency
```

## Context Protocol

When an agent is asked to work on a task, it MUST:
1. Read the relevant docs
2. Check backlog for existing task
3. Confirm understanding of the feature's place in the roadmap
4. Check for existing code patterns before implementing
5. Run tests after implementation

## Prohibited Actions

- Making architectural changes without ADR
- Committing secrets or API keys
- Modifying database schema without migration
- Adding dependencies without team review
- Skipping tests for core functionality
