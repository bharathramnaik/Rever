# ADR-003: Riverpod for State Management

## Status
Accepted

## Context
Need a state management solution that is testable, composable, and handles async well.

## Decision
Use Riverpod over Bloc, Provider, or GetX.

## Rationale
- Compile-time safety (no runtime ProviderNotFoundException)
- Better testability (ProviderContainer overrides)
- No BuildContext dependency for accessing state
- Code generation for reduced boilerplate (Riverpod 2.x)
- Built-in async handling (AsyncValue)
- Well-maintained by the Flutter community

## Consequences
- Learning curve for team
- Code generation step in build process
- Slightly more verbose than GetX for simple cases
