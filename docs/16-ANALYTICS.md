# Analytics (PostHog)

## Events to Track

### User Events
- `account_created`
- `profile_created`
- `profile_switched`
- `onboarding_completed`

### Learning Events
- `concept_viewed`
- `concept_completed`
- `quiz_started`
- `quiz_completed`
- `quiz_answer_correct`
- `quiz_answer_wrong`
- `learning_object_interacted`
- `learning_session_started`
- `learning_session_ended`

### AI Events
- `ai_tutor_query_sent`
- `ai_tutor_response_received`
- `ai_tutor_feedback` (helpful/not helpful)

### Engagement Events
- `daily_journey_viewed`
- `streak_milestone` (3, 7, 14, 30, 60, 90 days)
- `achievement_unlocked`
- `content_saved`
- `search_performed`

### Retention Events
- `day_1_retention`
- `day_7_retention`
- `day_30_retention`

## Properties
- `profile_id`
- `profile_type` (adult/child)
- `topic_id`
- `concept_id`
- `learning_object_type`
- `session_duration`
