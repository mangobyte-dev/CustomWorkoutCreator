# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CustomWorkoutCreator is a SwiftUI-based iOS/macOS application for creating and managing custom workouts.

## SwiftUI Performance Best Practices

### Memory Management Principles
- **Never allocate closures in computed properties** - Pre-compute and store as static data
- **Use static data structures with KeyPaths** instead of runtime closures
- **Avoid repeated allocations** - Cache and reuse expensive objects
- **Pre-compute all static configurations** at compile time
- **Always use `case let` syntax**

### State Management Principles
- **NO ViewModels** - Use @State/@Binding/@Environment only
- **Always use @Observable macro** instead of ObservableObject (40-60% fewer redraws)
- **Minimize state dependencies** - Each state change triggers view updates
- **Isolate state to smallest possible scope** - Don't lift state higher than necessary
- **Bundle related state updates** to reduce re-render cycles

### View Composition Principles
- **Extract frequently updating content into isolated subviews**
- **Avoid conditional view modifiers** - Use ViewBuilder or custom modifiers instead
- **Keep view hierarchies shallow** - Deep nesting impacts performance
- **Use lazy loading for lists** - LazyVStack/LazyHStack for scrollable content
- **Apply drawingGroup() to complex animated views** for GPU optimization

### Environment Access Principles
- **Perform single environment reads** - Bundle all environment access together
- **Cache environment values** in local properties
- **Avoid multiple @Environment property wrappers** in the same view

### Computation Principles
- **Never compute in view body** - Use computed properties or cache results
- **Pre-compute static values** using static let declarations
- **Cache expensive calculations** using @Observable classes
- **Throttle high-frequency updates** to 60fps maximum

### Animation & Gesture Principles
- **Throttle gesture handlers** to display refresh rate (60fps)
- **Isolate animated content** in separate subviews
- **Use explicit animation values** - Never use .animation() without value parameter
- **Minimize the scope of animations** to affected views only

### Resource Management Principles
- **Lazy load images and assets** - Don't pre-load unnecessary resources
- **Use appropriate image formats** and resolutions
- **Cache processed images** to avoid repeated transformations
- **Release resources proactively** when views disappear

### Architecture Principles
- **Follow single responsibility principle** - Each view should have one purpose
- **Use composition over inheritance** - Small, reusable components
- **Implement progressive disclosure** - Simple API with advanced options
- **Keep views pure and declarative** - Logic belongs in @Observable classes, not ViewModels

### Performance Monitoring Principles
- **Profile before optimizing** - Measure actual performance issues
- **Target 60fps for all interactions** - Smooth user experience
- **Keep view body execution under 16ms** - Prevent frame drops
- **Monitor memory usage** - Prevent leaks and excessive allocations

### Common Anti-Patterns to Avoid
- **Don't use GeometryReader excessively** - Causes layout recalculations
- **Don't nest ScrollViews** - Creates gesture conflicts
- **Don't create formatters in view body** - Cache as static properties
- **Don't perform I/O in view updates** - Use async tasks
- **Don't ignore view update cycles** - Understand when views re-render

### Testing & Debugging Principles
- **Use Self._printChanges() to debug re-renders**
- **Profile with Instruments regularly** - Don't guess performance issues
- **Test on lowest-spec target devices** - Ensure broad compatibility
- **Measure render times in DEBUG builds** - Catch regressions early

### Code Organization Principles
- **Group related views together** - Logical folder structure
- **Extract reusable components** - Build a component library
- **Consistent naming conventions** - Clear, descriptive names
- **Document performance-critical code** - Explain optimizations

## Summary

These practices result in:
- 40-70% reduction in CPU usage
- 50-90% reduction in memory allocations
- Consistent 60fps performance
- Responsive user interactions
- Maintainable, scalable codebase

Always prioritize user experience and app performance. Profile regularly and optimize based on actual measurements, not assumptions.