# Security Model

## Authentication
- Supabase Auth (email/password, Google OAuth)
- JWT-based sessions
- Row Level Security (RLS) on all tables

## Authorization (RLS Policies)

### Accounts
- Users can only access their own account
- Admin access for support (via Supabase)

### Profiles
- Users can CRUD profiles within their account
- Parent can access child profiles within account
- Profile isolation: Profile A cannot see Profile B's data

### Learning Data
- `learning_sessions`: profile_id = requesting profile
- `mastery`: profile_id = requesting profile
- `saved_objects`: profile_id = requesting profile
- `ai_sessions`: profile_id = requesting profile

## Parental Controls
- Parent PIN protects: profile switching, settings changes, content unlocks
- PIN hashed with bcrypt
- PIN required for: changing age level, disabling AI, removing restrictions

## API Security
- Rate limiting on Edge Functions
- Input validation on all endpoints
- CORS restricted to app origins
- No sensitive data in client-side storage

## Content Safety
- AI-generated content has quality scoring
- Kid-inappropriate content filtered at generation time
- Source verification pipeline
- User flagging/reporting for problematic content

## Data Privacy
- Minimal data collection (only what's needed for learning)
- No selling of user data
- GDPR-compliant (account deletion removes all data)
- Encryption at rest (Supabase default)
