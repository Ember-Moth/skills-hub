---
name: design-md
description: Create, adopt, update, validate, and enforce a repository-root DESIGN.md as the visual source of truth. Use when the user asks for a design system, brand or UI direction, wants to choose or mix styles from VoltAgent/awesome-design-md, needs an existing interface distilled into DESIGN.md, asks to validate a DESIGN.md against the Google Labs format, or requests UI implementation/review in a repository whose root contains DESIGN.md.
---

# DESIGN.md workflow

Establish a durable visual contract for coding agents. Combine product-aware design consultation with the Google Labs DESIGN.md format and the VoltAgent style catalog without copying brand identity blindly.

## Operating rules

- Treat the repository-root `DESIGN.md` as the visual source of truth; repository instructions and user requirements still take precedence.
- Inspect `AGENTS.md`, existing UI, tokens, themes, components, assets, and accessibility conventions before proposing changes.
- Preserve unrelated work. Never overwrite an existing `DESIGN.md`; read it, show the intended delta, and edit it deliberately.
- Prefer coherent, product-specific choices over generic “modern” styling or a collage of fashionable details.
- Do not claim that reverse-engineered brand references are official. Do not copy trademarks, proprietary assets, product copy, or unavailable fonts.
- Keep tokens normative and prose explanatory. Never allow prose and token values to disagree.

## Choose the workflow

1. **Use an existing contract**: read `DESIGN.md` before UI work and implement within its tokens and guardrails.
2. **Adopt or remix references**: search the VoltAgent catalog, inspect one to three candidates, then adapt a coherent direction to the product.
3. **Create from project evidence**: infer the current visual language from code, screenshots, assets, or Figma context, then resolve gaps through a concise design consultation.
4. **Update a contract**: preserve stable decisions, change only the requested dimensions, and explain migration impact.
5. **Audit conformance**: compare the implemented UI and token sources against `DESIGN.md`; report concrete drift before changing code unless fixes were requested.

## Discover context

1. Run `git status --short` in a repository.
2. Locate root instructions and design evidence with `rg --files`.
3. Read the product purpose, target users, supported locales/themes, and technical constraints.
4. Inventory existing colors, typography, spacing, radii, elevation, primitives, responsive rules, motion, and accessibility behavior.
5. Distinguish deliberate conventions from one-off or legacy values. Prefer shared tokens and reusable components over isolated screens.

Ask at most one blocking question at a time. When evidence is sufficient, make a concrete recommendation instead of turning the consultation into a form.

## Work with the VoltAgent catalog

Read [references/sources.md](references/sources.md) before adopting or remixing an external style.

Browse the catalog repository or use GitHub's API with existing system tools. Do not require a language runtime or bundled downloader:

```bash
gh api repos/VoltAgent/awesome-design-md/contents/design-md --jq '.[].name'
curl -fL --output <temporary-path>/linear.DESIGN.md \
  https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/linear.app/DESIGN.md
```

Prefer browser or web tools when available. If downloading through the shell, create a temporary directory first and require the target path not to exist. Fetch candidates outside the repository or under a user-approved scratch directory, inspect them, and copy only the decisions that fit the product.

When comparing references, evaluate:

- product and audience fit;
- information density and hierarchy;
- typography availability and multilingual coverage;
- light/dark and responsive suitability;
- accessibility and contrast;
- compatibility with existing components and tokens;
- distinctive traits worth retaining and brand-specific traits that must be removed.

For a remix, name the source of each adopted principle and resolve token conflicts explicitly. Do not average unrelated styles.

## Create the direction

Form a single visual thesis that states mood, material, density, and energy. Cover:

- semantic color roles and state colors;
- type roles, scale, line height, weight, and fallbacks;
- spacing rhythm, grid, container widths, and responsive behavior;
- shapes, radii, borders, shadows, and surface hierarchy;
- component behavior and interaction states;
- motion principles and reduced-motion behavior;
- accessibility constraints and prohibited patterns.

If the user has not chosen a direction, propose up to three genuinely distinct directions with short rationales, recommend one, and wait only when the choice materially changes the result. When visual confirmation matters, create a temporary preview or use available design/image tools; do not add preview artifacts to the product unless requested.

## Write DESIGN.md

Start from [assets/DESIGN.template.md](assets/DESIGN.template.md), then replace every placeholder with evidence-backed decisions. Follow the current Google Labs specification:

- optional YAML frontmatter with `version`, `name`, and typed token groups;
- body sections ordered as Overview, Colors, Typography, Layout, Elevation & Depth, Shapes, Components, and Do's and Don'ts;
- explicit `omitted` entries with reasons for intentionally absent token groups;
- valid CSS color values and `px`, `em`, or `rem` dimensions;
- `{path.to.token}` references for shared values.

Do not invent token values solely to fill the template. Remove irrelevant placeholders and document intentional omissions.

After creation, add a short pointer to the repository's existing agent-instruction file only when the user requested integration or the file already contains UI/design rules. Do not create tool-specific instruction files unnecessarily.

## Validate

Use the project's package runner when available. Otherwise use `npx`:

```bash
npx --yes @google/design.md lint DESIGN.md
```

Fix schema, section-order, token-reference, and contrast errors. Then verify that:

- YAML tokens and prose agree;
- referenced fonts and assets are actually available or have viable fallbacks;
- light/dark, locale, mobile, keyboard, focus, and reduced-motion requirements are covered when applicable;
- implementation token sources can map cleanly to the contract.

If validation cannot run, state why and perform a manual schema and consistency check without claiming lint success.

## Audit implementation

Trace each finding to a concrete file or rendered surface. Prioritize:

1. token values that contradict `DESIGN.md`;
2. inaccessible contrast, focus, motion, or touch behavior;
3. duplicated hard-coded values that bypass the design system;
4. component states or responsive behavior missing from the contract;
5. visual drift that weakens the stated thesis.

Do not report personal taste as a defect. Separate contract violations from optional refinements. Apply fixes only when requested, then run the relevant formatter, type check, tests, build, and visual/browser checks required by the repository.

## Report

State the selected or preserved direction, reference styles used, files changed, Google lint result, implementation checks, and any remaining design decisions. Keep the report concise.
