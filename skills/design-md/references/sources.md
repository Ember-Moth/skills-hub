# Sources and adoption rules

Use primary sources and inspect their current contents before adoption.

## Google Labs DESIGN.md

- Repository: <https://github.com/google-labs-code/design.md>
- Specification: <https://github.com/google-labs-code/design.md/blob/main/docs/spec.md>
- CLI package: `@google/design.md`

Treat this as the authority for document structure, token schema, linting, and export behavior. The format is currently marked alpha, so use the installed CLI or current repository instead of relying on memorized details.

Useful commands:

```bash
npx --yes @google/design.md spec --rules
npx --yes @google/design.md lint DESIGN.md
npx --yes @google/design.md diff old.DESIGN.md DESIGN.md
npx --yes @google/design.md export --format dtcg DESIGN.md
```

Do not redirect an export over an existing project file without explicit approval.

## VoltAgent Awesome DESIGN.md

- Repository: <https://github.com/VoltAgent/awesome-design-md>
- Catalog path: `design-md/<slug>/DESIGN.md`
- Raw file pattern: `https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/<slug>/DESIGN.md`

The repository provides reverse-engineered design references from public websites. It is a reference catalog, not an official source for those brands.

Adoption workflow:

1. Select candidates by product category and intended feeling, not popularity alone.
2. Inspect `DESIGN.md`, `preview.html`, and `preview-dark.html` when present.
3. Record which principles are relevant: hierarchy, density, typography roles, palette strategy, layout rhythm, surface model, interaction language.
4. Remove brand names, logos, proprietary assets, product copy, and inaccessible font assumptions.
5. Adapt semantic tokens to the target product and existing implementation.
6. Validate the result with the Google CLI.

Discover styles through the repository UI or, when `gh` is available:

```bash
gh api repos/VoltAgent/awesome-design-md/contents/design-md --jq '.[].name'
```

Download a selected reference with browser/web tools or `curl`. Always write to a new temporary path first; never direct-download over the project's `DESIGN.md`.

Prefer one dominant reference. Use a second only to solve a named gap, such as combining one reference's information density with another's warmer typography. Never blend token values by averaging them.

## gstack design workflow

- Repository: <https://github.com/garrytan/gstack>
- Relevant concepts: `design-consultation`, `design-review`, `design-shotgun`, and `design-html`

Use the workflow concepts rather than copying or executing gstack's Claude-specific scripts:

1. understand product context;
2. research the visual landscape;
3. propose an opinionated coherent system;
4. preview and gather feedback;
5. write the root `DESIGN.md`;
6. review implementation against it.

Invoke an installed gstack workflow only when the user explicitly requests gstack and its runtime requirements are available.
