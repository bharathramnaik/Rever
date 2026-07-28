# ADR-002: Supabase for Backend

## Status
Accepted

## Context
We need a backend with authentication, database, storage, and serverless functions — with zero initial infrastructure cost.

## Decision
Use Supabase as the primary backend platform.

## Rationale
- Built-in PostgreSQL with Row Level Security
- Built-in auth (email, Google, Apple)
- Built-in storage for images, audio, animations
- Edge Functions (Deno) for server logic
- Realtime subscriptions for live features
- Generous free tier for initial development
- pgvector extension for vector search

## Consequences
- Vendor lock-in consideration (mitigated by using standard PostgreSQL)
- Edge Functions are Deno/TypeScript (separate from Python AI layer)
- Scaling beyond free tier requires paid plan
