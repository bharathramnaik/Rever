# System Architecture

## High-Level Architecture

```
                     FLUTTER APP
                Android + iOS (v1)
                      │
              ┌───────┴───────┐
              ↓               ↓
           Adult UI        Kids UI
              │               │
              └───────┬───────┘
                      ↓
                   API / BFF (Supabase Edge Functions)
                      │
     ┌────────────────┼────────────────┐
     ↓                ↓                ↓
 Account/Profile    Learning         Content
     │                │                │
     │          Learning Engine        │
     │                │                │
     └────────────────┼────────────────┘
                      ↓
                  PostgreSQL
                      │
        ┌─────────────┼─────────────┐
        ↓             ↓             ↓
      Vector       Object Store   Knowledge
      (pgvector)    (Supabase     Graph
                     Storage)     (pg + app)
        │                           │
        └────────────┬──────────────┘
                     ↓
                 AI LAYER (Python)
                     │
       ┌─────────────┼─────────────┐
       ↓             ↓             ↓
    Tutor        Generation     Evaluation
       │             │             │
       ├─────────────┼─────────────┤
       ↓             ↓             ↓
    Answers       Cards         Quizzes
                 Visuals       Mastery
                 Stories       Revision
```

## Layer Details

### Flutter App
- State management: Riverpod
- Navigation: GoRouter
- Local persistence: Drift (SQLite) for offline
- HTTP: Dio with interceptors
- Animations: Flutter Canvas + Lottie + Rive

### Backend (Supabase)
- Auth: Supabase Auth (email + Google)
- Database: PostgreSQL 15
- Vector search: pgvector extension
- Storage: Supabase Storage (images, audio)
- Server logic: Supabase Edge Functions (Deno/TypeScript)
- Realtime: Supabase Realtime for live features

### AI Layer (Python)
- API: FastAPI (deployed on Railway/Render)
- LLM: OpenAI GPT-4o-mini (v1), Claude as fallback
- Embeddings: text-embedding-3-small
- Vector DB access: via pgvector
- Visual generation: Structured spec → Flutter renderer

### Admin (Next.js)
- Content management dashboard
- Analytics (PostHog)
- User moderation

## Data Flow

```
User action → Flutter → Riverpod state → Supabase SDK
                                           ↓
                                    Edge Function
                                           ↓
                                    PostgreSQL
                                           ↓
                                    AI Pipeline (if needed)
                                           ↓
                                    Response → UI update
```

## Non-negotiable Decisions

1. **No microservices in v1** — Supabase handles everything backend
2. **Source grounding** — Every AI response cites sources
3. **Offline-first** — Drift local DB syncs with Supabase
4. **Multi-profile isolation** — Never mix data between profiles
