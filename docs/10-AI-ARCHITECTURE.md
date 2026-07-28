# AI Architecture

## Overview

The AI layer transforms public knowledge into personalized learning experiences. All AI outputs are source-grounded and age-appropriate.

## Components

### 1. AI Tutor
- **Purpose**: Answer questions about concepts, grounded in sources
- **Model**: GPT-4o-mini (v1)
- **Context**: Retrieves relevant source chunks + concept context + profile model
- **Guardrails**: Age-appropriate responses, no unrestricted access for kids
- **Flow**: User query → Profile context → RAG over source_chunks → LLM → Response with citations

### 2. Content Generation
- **Purpose**: Generate learning objects from source material
- **Pipeline**:
  ```
  Source text → Chunk → Embed → Store
                       ↓
              LLM generates:
              ├── Card (title + summary + key points)
              ├── Quiz (MCQs with explanations)
              ├── Flashcards (question/answer pairs)
              └── Visual spec (structured for renderer)
  ```

### 3. Visual Specification Format
- **Purpose**: AI outputs structured specs, Flutter renders them
- **No expensive video generation**
- Example:

```json
{
  "type": "process",
  "title": "Water Cycle",
  "nodes": [
    {"id": "ocean", "label": "Ocean", "position": [0, 4]},
    {"id": "evaporation", "label": "Evaporation", "position": [2, 3]},
    {"id": "cloud", "label": "Cloud", "position": [4, 2]},
    {"id": "rain", "label": "Rain", "position": [2, 1]}
  ],
  "connections": [
    {"from": "ocean", "to": "evaporation", "label": "Sun heats"},
    {"from": "evaporation", "to": "cloud", "label": "Water rises"},
    {"from": "cloud", "to": "rain", "label": "Precipitation"},
    {"from": "rain", "to": "ocean", "label": "Collection"}
  ],
  "animations": [
    {"node": "evaporation", "effect": "fade_up", "duration": 1.5},
    {"connection": "ocean->evaporation", "effect": "flow_arrow", "duration": 2.0}
  ]
}
```

### 4. Pedagogical Transformation

```
Question
   ↓
Profile (age, level, style)
   ↓
Knowledge state
   ↓
Retrieved context
   ↓
LLM with persona prompt
   ↓
Age-appropriate explanation
```

### 5. Embedding Pipeline

```
Source → Chunk (500 chars with overlap)
                        ↓
                text-embedding-3-small
                        ↓
                Store in pgvector
                        ↓
                Indexed for RAG queries
```

## AI Agent Organization

```
                    CEO AGENT (Orchestrator)
                          │
       ┌──────────────────┼──────────────────┐
       ↓                  ↓                  ↓
  PRODUCT AGENT       CTO AGENT          UX AGENT
                          │
          ┌───────────────┼────────────────┐
          ↓               ↓                ↓
       MOBILE          BACKEND            AI
       AGENT            AGENT            AGENT
                          │
       ┌──────────────────┼──────────────────┐
       ↓                  ↓                  ↓
      QA               SECURITY         PERFORMANCE
     AGENT              AGENT             AGENT
                          │
                          ↓
                    REVIEW AGENT
                          │
                          ↓
                      YOU (Founder)
```

## Evaluation

- AI-generated content gets human-in-the-loop quality scoring
- Quality metrics: accuracy, age-appropriateness, engagement
- Feedback loop: user interactions → quality score updates
