# ADR-005: Unified Learning Object Model

## Status
Accepted

## Context
Rather than being structurally tied to "cards", we need a flexible content model that supports multiple formats.

## Decision
Create a unified `learning_objects` table with a `type` discriminator and JSONB `content` field.

## Rationale
- Single table for all content types (card, diagram, flowchart, quiz, flashcard, story, audio, etc.)
- JSONB `content` allows schema-less flexibility per type
- Easy to add new types without migration
- Consistent querying and embedding across all types
- Discriminator pattern is well-understood

## Consequences
- JSONB validation must happen at application layer
- Indexing specific JSONB paths may be needed for performance
- Some queries may be more complex than separate tables
