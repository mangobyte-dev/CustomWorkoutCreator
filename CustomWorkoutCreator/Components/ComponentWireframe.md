# UI Components Wireframe

## 1. SectionHeader Component

```
┌─────────────────────────────────────────────────────┐
│  WORKOUT DETAILS                              3 items│  ← Optional trailing content
│                                                      │
└─────────────────────────────────────────────────────┘
   ↑ Uppercase text         ↑ Secondary color    ↑ Secondary color
   ↑ Font.footnote                               ↑ Font.footnote
   ↑ 16pt padding left/right
   ↑ 16pt top padding, 8pt bottom padding
```

## 2. CustomRow Component

```
┌─────────────────────────────────────────────────────┐
│                                                      │ ← 12pt vertical padding
│  [Content goes here - fully customizable]           │ ← 16pt horizontal padding
│                                                      │
├─────────────────────────────────────────────────────┤ ← Optional divider (0.5pt)
```

### LabeledRow Variant:
```
┌─────────────────────────────────────────────────────┐
│  Name                                Upper Body      │
│                                                      │
├─────────────────────────────────────────────────────┤
│  Duration                                  45 min    │
│                                                      │
└─────────────────────────────────────────────────────┘
   ↑ Primary color                    ↑ Secondary color
```

## 3. ButtonRow Component

### Primary Style:
```
┌─────────────────────────────────────────────────────┐
│  ┌───────────────────────────────────────────────┐ │
│  │     + Add Exercise                            │ │ ← Tinted background
│  └───────────────────────────────────────────────┘ │ ← Accent color text
└─────────────────────────────────────────────────────┘
```

### Destructive Style:
```
┌─────────────────────────────────────────────────────┐
│  ┌───────────────────────────────────────────────┐ │
│  │     🗑 Delete Workout                          │ │ ← Red tinted background
│  └───────────────────────────────────────────────┘ │ ← Red text
└─────────────────────────────────────────────────────┘
```

### Secondary Style:
```
┌─────────────────────────────────────────────────────┐
│  ┌───────────────────────────────────────────────┐ │
│  │     ↻ Reset                                   │ │ ← Gray background
│  └───────────────────────────────────────────────┘ │ ← Primary text
└─────────────────────────────────────────────────────┘
```

## 4. ExpandableRow Component

### Collapsed State:
```
┌─────────────────────────────────────────────────────┐
│  Interval 1                                      ⌄  │ ← Tap anywhere to expand
│  3 rounds • 30s between • 60s after                │ ← Secondary text, small
├─────────────────────────────────────────────────────┤
```

### Expanded State:
```
┌─────────────────────────────────────────────────────┐
│  Interval 1                                      ⌃  │ ← Tap anywhere to collapse
│  3 rounds • 30s between • 60s after                │
│  ─────────────────────────────────────────────────  │ ← Divider
│                                                      │
│  [Expanded content goes here]                       │ ← Custom content area
│                                                      │
├─────────────────────────────────────────────────────┤
```

## Usage Example - WorkoutDetailView Section:

```
┌─────────────────────────────────────────────────────┐
│  INTERVALS                                    3 items│ ← SectionHeader
│                                                      │
│  ┌─────────────────────────────────────────────┐   │
│  │  Warm-up                                  ⌄  │   │ ← ExpandableRow (collapsed)
│  │  1 round • 5 exercises                       │   │
│  ├─────────────────────────────────────────────┤   │
│  │  Main Set                                 ⌃  │   │ ← ExpandableRow (expanded)
│  │  4 rounds • 45s between • 90s after         │   │
│  │  ───────────────────────────────────────────│   │
│  │                                              │   │
│  │  Push-ups                           8-12 reps│   │ ← CustomRow content
│  │  Effort: 7/10 • 30s rest                    │   │
│  │  ───────────────────────────────────────────│   │
│  │  Pull-ups                           6-10 reps│   │
│  │  Effort: 8/10 • 45s rest                    │   │
│  │                                              │   │
│  ├─────────────────────────────────────────────┤   │
│  │  Cool-down                                ⌄  │   │ ← ExpandableRow (collapsed)
│  │  1 round • 3 exercises                       │   │
│  └─────────────────────────────────────────────┘   │
│                                                      │
│  ┌───────────────────────────────────────────────┐ │
│  │     + Add Interval                            │ │ ← ButtonRow (primary)
│  └───────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

## Key Design Decisions:

1. **Consistent Spacing**: All components use standard iOS padding (12pt vertical, 16pt horizontal)
2. **No Swipe Gestures**: All interactions are tap-based with explicit buttons
3. **Visual Hierarchy**: Clear distinction between headers, content, and actions
4. **Performance**: Pre-computed static values, no dynamic calculations in render
5. **Accessibility**: Clear tap targets, proper contrast ratios
6. **Flexibility**: Components accept custom content while maintaining consistent styling

## Color Scheme:
- Background: systemBackground / systemGroupedBackground
- Text Primary: label
- Text Secondary: secondaryLabel
- Dividers: separator
- Accent: accentColor
- Destructive: systemRed
- Button backgrounds: Tinted versions of text colors