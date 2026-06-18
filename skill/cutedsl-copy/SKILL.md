---
name: cutedsl-copy
description: Use when the user asks about CuTe DSL copy, tiled copy, copy atoms, make_tiled_copy_tv, make_layout_tv, partition_S, partition_D, or copy TV layouts.
---

# CuTe DSL Copy

## Tiled Copy Construction

- In most cases, use `cute.make_tiled_copy_tv(copy_atom, thr_layout, val_layout)` instead of `cute.make_tiled_copy`.
- Define `thr_layout` and `val_layout` as separate values before constructing the tiled copy.
- Define `tiler_mn` and `layout_tv` with `cute.make_layout_tv(thr_layout, val_layout)` when the tile shape or TV mapping is needed for tensor tiling, inspection, or explanation.

```python
thr_layout = ...
val_layout = ...
tiler_mn, layout_tv = cute.make_layout_tv(thr_layout, val_layout)
tiled_copy = cute.make_tiled_copy_tv(copy_atom, thr_layout, val_layout)
```
