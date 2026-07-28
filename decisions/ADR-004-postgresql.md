# ADR-004: PostgreSQL as Primary Database

## Status
Accepted

## Context
Need a relational database that can also handle vector embeddings for semantic search.

## Decision
Use PostgreSQL 15+ with pgvector extension.

## Rationale
- Single database for relational + vector data
- No need for separate vector database (Pinecone, Weaviate)
- Mature, reliable, well-understood
- Supabase provides managed PostgreSQL
- pgvector supports all needed operations (cosine similarity, inner product)

## Consequences
- Vector search is approximate (IVFFlat index) — acceptable for v1
- May need dedicated vector DB at scale (Phase 10)
- Migration management needed for schema changes
