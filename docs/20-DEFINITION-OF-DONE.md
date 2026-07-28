# Definition of Done

A feature is "done" when ALL of the following are true:

## Code
- [ ] Implementation matches the PRD / feature spec
- [ ] Code follows project conventions (style, patterns, naming)
- [ ] No dead code, commented code, or debug logs
- [ ] All new files have proper imports and no unused deps

## Testing
- [ ] Unit tests written for all business logic
- [ ] Widget tests for UI components
- [ ] Integration tests for critical flows
- [ ] All tests pass (green)

## Quality
- [ ] Linter passes with zero warnings
- [ ] No new security concerns (RLS, auth checked)
- [ ] Performance is acceptable (< 200ms response, < 60fps UI)
- [ ] Works offline for previously loaded content

## Documentation
- [ ] Relevant docs updated (if behavior changed)
- [ ] API changes reflected in API contract doc
- [ ] New features added to feature matrix

## Review
- [ ] Code reviewed by at least one other agent
- [ ] No architectural drift from established patterns
- [ ] Edge cases handled (loading, error, empty states)

## Acceptance
- [ ] Feature matches the acceptance criteria in the backlog item
- [ ] Tested on both Android and iOS (or noted if platform-specific)
