---
name: hugo-write-header
description: Use when writing or reviewing the front matter header for Hugo blog posts.
---

# Hugo Write Header

Use this skill when writing or reviewing the front matter header for Hugo blog posts.

## Rules

- Prefer the local Hugo project's existing header convention.
- If no convention is clear, use YAML front matter with `---` delimiters.
- Include `title`, `date`, `created`, and `math`.
- Use `YYYY-MM-DD` dates unless the local project uses another Hugo-parseable format.
- For existing posts, preserve `created`; update `date` only when the user intends to re-date the post or the local convention treats `date` as the update date.
- If the local convention uses `lastmod` or `updated`, update that field for revisions instead of changing `created`.
- Set `math: true` for posts with math; use `math: false` or omit it only when local convention supports that.
- Omit `weight` unless the post belongs to an ordered sequence or the user asks for it.
- If `weight` is needed and no local convention exists, use `100`; for multiple ordered items use `100`, `200`, `300`.
- Never use `weight: 0`.
- Do not invent tags, categories, images, slug, url, aliases, author, summary, or custom fields unless local convention or the user requires them.

## Fallback Header

```yaml
---
title: Example Title
date: 2026-05-04
created: 2026-05-04
math: true
---
```

## With Weight

```yaml
---
title: Example Title
date: 2026-05-04
created: 2026-05-04
weight: 100
math: true
---
```

## Review Checklist

- Header delimiters match the selected format.
- Dates are valid and consistent.
- `created` matches the intended creation date.
- Date updates preserve the original creation date unless the user explicitly requests otherwise.
- `math` matches whether the post needs math rendering.
- `weight` is omitted unless ordering is intentional.
- Extra fields are supported by local convention or user instruction.
