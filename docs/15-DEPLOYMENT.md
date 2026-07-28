# Deployment

## Infrastructure

| Component | Provider | Notes |
|-----------|----------|-------|
| Mobile app | App Store + Play Store | Flutter build |
| Backend | Supabase (managed) | PostgreSQL + Auth + Storage |
| AI API | Render | Python FastAPI |
| Admin panel | Vercel | Next.js |
| CDN | Cloudflare | Images, animations |
| Analytics | PostHog Cloud | Self-host later |
| Crash reporting | Sentry | Flutter + Backend |
| CI/CD | GitHub Actions | |

## Environments

| Environment | Backend | AI | Notes |
|-------------|---------|-----|-------|
| Development | Local Supabase | Local Render dev | Docker compose |
| Staging | Supabase staging | Render staging | For QA |
| Production | Supabase prod | Render prod | Live |

## Deployment Flow

```
Push to main
  ↓
GitHub Actions:
  ├── lint
  ├── test
  ├── build Flutter (Android + iOS)
  ├── deploy Edge Functions
  ├── run DB migrations
  └── deploy AI API
```

## Monitoring
- Uptime monitoring (Supabase status)
- Error tracking (Sentry)
- Performance monitoring (PostHog)
- Server logs (Supabase logs)
