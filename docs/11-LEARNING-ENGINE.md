# Learning Engine

## Core Loop

```
User action → Event → Learning Engine → Update model → Generate journey
```

## Learner Model

Each profile maintains:

```json
{
  "profile_id": "uuid",
  "knowledge_state": {
    "concept_id": {
      "mastery": 0.0-1.0,
      "last_reviewed": "timestamp",
      "times_practiced": 5,
      "quiz_accuracy": 0.85,
      "next_review": "timestamp"
    }
  },
  "preferences": {
    "preferred_formats": ["card", "quiz"],
    "session_length_minutes": 10,
    "difficulty": "beginner"
  },
  "history": {
    "total_minutes": 320,
    "streak": 12,
    "concepts_learned": 47,
    "quizzes_taken": 89,
    "quiz_accuracy_avg": 0.78
  }
}
```

## Spaced Repetition (v2)

Uses SM-2 algorithm variant:
1. After quiz, calculate quality score (0-5)
2. Update ease factor: `EF = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))`
3. Calculate next interval based on EF and repetition count
4. Schedule `next_review_at` for each mastered concept

## Recommendation Engine (v1)

Simple: topic-based + trending + recently added
Future: full learner model → NEXT BEST LEARNING OBJECT

## Daily Journey Generator

```
Input: Profile + Current model + Due reviews + New content
Output: 5-item journey plan

Algorithm:
1. Fetch due review items (spaced repetition)
2. Fetch incomplete nearby concepts (prerequisites)
3. Fetch new content matching interests
4. Mix and order for flow (review → learn → quiz → discover)
5. Respect daily goal time budget
```

## Progress Tracking

- Mastery: 0.0 → 1.0 based on interactions + quiz results
- Streak: consecutive days with ≥1 learning session
- XP (kids): points for every positive learning action
- Achievement triggers: configurable milestones
