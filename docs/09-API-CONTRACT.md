# API Contract (Supabase Edge Functions)

## Base URL

```
https://[project].supabase.co/functions/v1
```

## Authentication

All requests require `Authorization: Bearer <supabase_anon_key>` header.
Profile-scoped endpoints also require `X-Profile-ID` header.

## Endpoints

### Profiles

| Method | Path | Description |
|--------|------|-------------|
| POST | `/profiles` | Create profile |
| GET | `/profiles` | List profiles for account |
| GET | `/profiles/:id` | Get profile details |
| PATCH | `/profiles/:id` | Update profile |
| DELETE | `/profiles/:id` | Delete profile |

### Topics

| Method | Path | Description |
|--------|------|-------------|
| GET | `/topics` | List all topics |
| GET | `/topics/:slug` | Get topic with concepts |
| GET | `/topics/:slug/concepts` | List concepts in topic |

### Concepts

| Method | Path | Description |
|--------|------|-------------|
| GET | `/concepts/:id` | Get concept with learning objects |
| GET | `/concepts/:id/learning-objects` | List learning objects for concept |
| GET | `/concepts/:id/relationships` | Get concept relationships |

### Learning

| Method | Path | Description |
|--------|------|-------------|
| POST | `/learn/session/start` | Start learning session |
| PATCH | `/learn/session/:id/end` | End learning session |
| POST | `/learn/progress` | Track interaction |
| GET | `/learn/mastery` | Get profile mastery levels |
| GET | `/learn/review` | Get due review items |

### AI Tutor

| Method | Path | Description |
|--------|------|-------------|
| POST | `/ai/chat` | Send message to AI tutor |
| GET | `/ai/sessions` | List AI sessions |
| GET | `/ai/sessions/:id` | Get session messages |

### Search

| Method | Path | Description |
|--------|------|-------------|
| GET | `/search?q=:query` | Full-text + vector search |

### Library

| Method | Path | Description |
|--------|------|-------------|
| GET | `/library` | List saved objects |
| POST | `/library/save` | Save learning object |
| DELETE | `/library/:id` | Remove saved object |
| PATCH | `/library/:id/notes` | Update notes |

### Journey

| Method | Path | Description |
|--------|------|-------------|
| GET | `/journey/daily` | Get daily learning journey |
| GET | `/journey/streak` | Get streak info |

### Gamification

| Method | Path | Description |
|--------|------|-------------|
| GET | `/gamification/stats` | Get XP, level, achievements |
| GET | `/gamification/achievements` | List achievements |

## Request/Response Formats

All requests and responses use JSON.
Error format: `{ "error": { "code": "string", "message": "string" } }`
Paginated responses: `{ "data": [...], "total": int, "page": int, "page_size": int }`
