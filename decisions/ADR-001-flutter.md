# ADR-001: Flutter for Mobile Development

## Status
Accepted

## Context
We need to build a cross-platform mobile app with rich animations, two UI engines (adult + kids), and complex interactive diagrams.

## Decision
Use Flutter over React Native.

## Rationale
- Single codebase for Android + iOS
- Superior animation capabilities (Canvas, CustomPainter, Rive, Lottie)
- Better performance for interactive diagrams and flowcharts
- Growing ecosystem and community
- Dart is well-suited for large codebases

## Consequences
- Need Dart developers (or learning curve)
- Less native module ecosystem than React Native
- Web support is secondary (not primary target)
