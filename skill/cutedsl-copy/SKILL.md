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

## Generic SIMT Copy

Use these ops for thread-level SIMT copies between global, shared, and register storage.

- `cute.nvgpu.CopyUniversalOp`: plain assignment-style copy.
- `cute.nvgpu.CopyG2ROp`: global → register.
- `cute.nvgpu.CopyR2GOp`: register → global.
- `cute.nvgpu.CopyS2ROp`: shared → register.
- `cute.nvgpu.CopyR2SOp`: register → shared.

```python
copy_op = cute.nvgpu.CopyUniversalOp()
```

## Warp Matrix Copy

Use these ops for warp-level matrix-fragment copies between shared memory and registers.

- Load family: shared → register.
  - `cute.nvgpu.warp.LdMatrix8x8x16bOp`: SM75+.
  - `cute.nvgpu.warp.LdMatrix8x16x8bOp`: SM100+.
  - `cute.nvgpu.warp.LdMatrix16x8x8bOp`: SM100+.
  - `cute.nvgpu.warp.LdMatrix16x16x8bOp`: SM100+.
- Store family: register → shared.
  - `cute.nvgpu.warp.StMatrix8x8x16bOp`: SM90+.
  - `cute.nvgpu.warp.StMatrix16x8x8bOp`: SM100+.

Valid `num_matrices` values in CuTe DSL:

- `LdMatrix8x8x16bOp`: `1`, `2`, `4`.
- `LdMatrix8x16x8bOp`: `1`, `2`, `4`.
- `LdMatrix16x8x8bOp`: `2`, `4`.
- `LdMatrix16x16x8bOp`: `1`, `2`.
- `StMatrix8x8x16bOp`: `1`, `2`, `4`.
- `StMatrix16x8x8bOp`: `1`, `2`, `4`.

Transpose support in CuTe DSL:

- `LdMatrix8x8x16bOp`: `transpose` is optional.
- `LdMatrix8x16x8bOp`: `transpose` is not supported.
- `LdMatrix16x8x8bOp`: `transpose=True` is required.
- `LdMatrix16x16x8bOp`: `transpose=True` is required.
- `StMatrix8x8x16bOp`: `transpose` is optional.
- `StMatrix16x8x8bOp`: `transpose=True` is required.

```python
load_op = cute.nvgpu.warp.LdMatrix8x8x16bOp(transpose=False, num_matrices=4)
store_op = cute.nvgpu.warp.StMatrix8x8x16bOp(transpose=False, num_matrices=4)
```
