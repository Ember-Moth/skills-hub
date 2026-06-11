# Pitfalls

Use this reference when GPUI code fails to compile or behaves unexpectedly.

## Pitfalls To Fill

- Missing trait imports.
- Incorrect `Render` signatures.
- Capturing borrowed values in event handlers.
- Mutating entities without notification.
- Holding context references across async boundaries.
- Confusing app-scoped and window-scoped context.
- Styling methods that require specific imports or feature gates.
- Zed-only helpers accidentally used in standalone GPUI apps.

## Entry Format

````markdown
## Symptom

Error:

```text
compiler or runtime message
```

Cause:

Fix:

Verified example:
````
