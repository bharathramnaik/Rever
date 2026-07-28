# Key Decisions Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-07-28 | Flutter over React Native | Performance, animation capability, single codebase for adult+kids UI engines |
| 2026-07-28 | Supabase over custom backend | Minimize initial investment, built-in auth+DB+storage+realtime |
| 2026-07-28 | Riverpod over Bloc | Less boilerplate, better composition, testable |
| 2026-07-28 | PostgreSQL + pgvector | Single database for relational + vector, no extra infra |
| 2026-07-28 | Python AI layer over JS | Better ML ecosystem, easier LLM integration |
| 2026-07-28 | Render over Railway | User preference, similar free tier, wider adoption |
| 2026-07-28 | Drift/SQLite for local | Offline-first without complexity of sync engines |
| 2026-07-28 | Visual spec format (no video gen) | Dramatically cheaper than generating videos per concept |
| 2026-07-28 | Multi-profile at account level | Essential for family use case, Netflix-style UX |
| 2026-07-28 | No microservices in v1 | Premature optimization, Supabase scales vertically |
| 2026-07-28 | GoRouter for navigation | Official Flutter recommendation, type-safe routes |
| 2026-07-28 | Next.js for admin | Familiar React ecosystem, Vercel deployment |
