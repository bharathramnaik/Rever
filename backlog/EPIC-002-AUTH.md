# EPIC-002: Authentication & Accounts

## Status
Pending

## Stories

### STORY-002.1: Email/Password auth
- Supabase Auth email/password setup
- Sign-up screen with validation
- Login screen
- Password reset flow
- Email verification

### STORY-002.2: Google OAuth
- Google Sign-In integration
- Supabase Google provider config
- One-tap sign-up/login

### STORY-002.3: Account management
- Account screen (email, avatar, name)
- Delete account flow
- Logout

### STORY-002.4: Session management
- Persistent session (auto-login)
- Token refresh handling
- Secure token storage (flutter_secure_storage)

## Acceptance Criteria
- [ ] User can sign up with email/password
- [ ] User can sign in with Google
- [ ] Session persists across app restarts
- [ ] User can reset password
- [ ] User can delete account
