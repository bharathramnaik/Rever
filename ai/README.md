# Rever AI Layer

## Learning Compiler Agent Pipeline

Input: Source / Topic / Concept → Output: Learning Objects, Knowledge Map, Quiz

### Pipeline Stages (linear, each stage passes to next)

```
SOURCE AGENT
  → Extracts raw concepts from source text (books, articles, videos)
  → Output: List of concept candidates with source snippets

CONCEPT AGENT
  → Normalizes concepts, matches against existing knowledge graph
  → Detects duplicates, merges or creates new Concept records
  → Output: Canonicalized Concept list

FACT/QUALITY AGENT
  → Verifies claims against source
  → Scores accuracy (0-100), flags unsupported statements
  → Output: Verified concepts with quality scores

PEDAGOGY AGENT
  → Determines difficulty level, age appropriateness
  → Decides learning depth structure (Glance → Apply)
  → Output: Pedagogical plan per concept

VISUAL AGENT
  → Classifies concept type (process, relationship, hierarchy, etc.)
  → Generates VisualSpec JSON for Flutter renderer
  → Output: Structured visual specifications

QUIZ AGENT
  → Generates questions at multiple difficulty levels
  → Creates distractors, answer explanations
  → Output: Quiz objects with quality scores

AGE-ADAPTATION AGENT
  → Adapts content for age bands (5-7, 8-10, 11-13, 14-17, adult)
  → Simplifies language, adjusts examples
  → Output: Age-adapted learning objects

DEDUPLICATION AGENT
  → Cross-references all generated objects against existing DB
  → Flags near-duplicates, merges where appropriate
  → Output: Deduplicated final set

EVALUATION AGENT
  → Calculates composite quality score for each object
  → Applies thresholds (min quality = 70/100)
  → Output: Publish/discard decisions
```

### Quality Scoring

Every Learning Object receives:
- accuracy: 0-100
- clarity: 0-100
- source_support: 0-100
- age_fit: 0-100
- difficulty_fit: 0-100
- educational_value: 0-100
- duplication: 0-100 (inverse — higher = less duplicate)

Threshold for auto-publish: composite >= 75

### Implementation Order

1. Concept Agent + Fact/Quality Agent (basic pipeline)
2. Quiz Agent (highest immediate value)
3. Pedagogy Agent + Age Adaptation (needed for kids mode)
4. Visual Agent (complex — custom Flutter renderer needed)
5. Deduplication + Evaluation (needed before scaling)
