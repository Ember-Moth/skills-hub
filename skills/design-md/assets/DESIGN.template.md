---
version: alpha
name: Project Design System
description: Replace with the product-specific visual thesis.
colors:
  primary: "#005FCC"
  background: "#FFFFFF"
  surface: "#F5F5F5"
  text: "#111111"
  muted: "#666666"
  on-primary: "#FFFFFF"
typography:
  display:
    fontFamily: Replace Me
    fontSize: 48px
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: -0.02em
  body:
    fontFamily: Replace Me
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.5
rounded:
  sm: 4px
  md: 8px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
components:
  primary-button:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    padding: "{spacing.md}"
  page:
    backgroundColor: "{colors.background}"
    textColor: "{colors.text}"
    typography: "{typography.body}"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text}"
    rounded: "{rounded.md}"
    padding: "{spacing.lg}"
  supporting-text:
    textColor: "{colors.muted}"
    typography: "{typography.body}"
---

# Project Design System

## Overview

Describe the product, audience, visual thesis, density, emotional target, and the principles that make the direction distinctive.

## Colors

Explain each semantic color role, interaction state, theme behavior, and contrast constraint. Keep every value aligned with the frontmatter tokens.

## Typography

Define display, heading, body, label, data, and code roles; document fallbacks and multilingual coverage.

## Layout

Define the grid, containers, spacing rhythm, composition, breakpoints, responsive behavior, and touch targets.

## Elevation & Depth

Define how surfaces establish hierarchy through borders, tint, shadow, blur, or deliberate flatness.

## Shapes

Define radii, strokes, icon geometry, clipping, and shape rules.

## Components

Define the visual and interaction behavior of foundational components, including hover, active, focus, disabled, loading, empty, and error states.

## Do's and Don'ts

### Do

- List product-specific rules that reinforce the visual thesis.

### Don't

- List concrete anti-patterns and forbidden deviations.
