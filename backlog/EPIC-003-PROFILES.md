# EPIC-003: Multi-Profile System

## Status
In Progress

## Stories

### STORY-003.1: Profile creation
- [ ] Create profile screen (name, avatar, type)
- [ ] Select profile type (adult/child/teen)
- [ ] Age range selection for child profiles
- [ ] Interest selection (topics)

### STORY-003.2: Profile switching
- [x] Profile switcher UI (Netflix-style grid)
- [x] Navigate from onboarding → profiles → home
- [ ] Active profile indicator
- [ ] Quick switch from any screen
- [ ] Profile locking with parent PIN for kids

### STORY-003.3: Profile isolation
- [ ] All queries filtered by profile_id
- [ ] Library, history, progress are profile-scoped
- [ ] AI conversations are profile-scoped
- [ ] Achievements/streaks are profile-scoped

### STORY-003.4: Settings per profile
- [ ] Daily goal setting
- [ ] Difficulty preference
- [ ] Notification preferences
- [ ] Learning style preferences

## Acceptance Criteria
- [x] Profile switching UI exists and navigates correctly
- [ ] User can create up to 5 profiles
- [ ] Profile data is fully isolated
- [ ] Switching profiles shows different content
- [ ] Child profiles require parent PIN to access settings
