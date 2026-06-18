---
name: cutedsl-basic
description: Use when the user asks about CuTe DSL basics, cutlass.cute, cute.jit, cute.kernel, cute.arch, cute.nvgpu, layouts, tensors, atoms, or basic CuTe DSL skill-writing notes.
---

# CuTe DSL Basic

## Related Skills

- Also use the CUDA skills when the question involves CUDA architecture, PTX, synchronization, memory ordering, tensor cores, TMA, WGMMA, or other low-level GPU semantics.

## Imports

- Use these default CuTe DSL imports.
- Do not add other `cutlass` module imports unless the user explicitly requests them.

```python
import cutlass
import cutlass.cute as cute
import cutlass.pipeline as pipeline
```

## Dtypes

- Define operand and accumulator dtypes as separate variables: `a_dtype`, `b_dtype`, and `acc_dtype`.
- Use separate `a_dtype` and `b_dtype` names even when an API expects a shared A/B dtype.

```python
a_dtype = ...
b_dtype = ...
acc_dtype = ...
```

## Major Terminology

- Use only MN-major and K-major terminology for CuTe DSL operand layouts.
- Do not use row-major or column-major terminology when discussing CuTe DSL major modes.
- Prefer `cute.nvgpu.OperandMajorMode.MN` and `cute.nvgpu.OperandMajorMode.K` for operands.
- Prefer `cute.nvgpu.OutputMajorMode.M` and `cute.nvgpu.OutputMajorMode.N` for outputs when an output-major enum is needed.

## Layout Construction

- When using `cute.make_layout`, always provide both `shape` and `stride`; do not rely on the default stride.
- Define `shape` and `stride` as separate values before constructing the layout.
- Use `cute.make_layout(shape, stride=stride)` because `stride` is a keyword-only argument.

```python
shape = ...
stride = ...
layout = cute.make_layout(shape, stride=stride)
```

## Tensor Access

- When indexing tensors, write the coordinate inline instead of defining a separate coordinate variable.

```python
tile = tensor[(None, rest_coord)]
```

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

## Tiled MMA Construction

- Treat the MMA operation descriptor as an op, not an atom.
- Always create the MMA atom first with `mma_atom = cute.make_mma_atom(mma_op)`, then pass `mma_atom` to `cute.make_tiled_mma(...)`.
- Do not pass `mma_op` directly to `cute.make_tiled_mma(...)`.
- Define `atom_shape_mnk`, `atom_stride_mnk`, and `atom_layout_mnk` separately before constructing the tiled MMA.
- `permutation_mnk` is optional; define it separately only when needed, otherwise omit it.

```python
mma_op = ...
mma_atom = cute.make_mma_atom(mma_op)

atom_shape_mnk = ...
atom_stride_mnk = ...
atom_layout_mnk = cute.make_layout(atom_shape_mnk, stride=atom_stride_mnk)

tiled_mma = cute.make_tiled_mma(mma_atom, atom_layout_mnk)
```

### WMMA

- WMMA is synchronous.
- All `cute.nvgpu.warp` MMA ops support only A K-major and B K-major operand layouts.
- For non-mixed-precision warp-level MMA ops, assert `a_dtype == b_dtype`, define `ab_type = a_dtype`, and pass `ab_type` to the op constructor.
- Supported instruction shapes:
  - `MmaF16BF16Op`: `(16, 8, 8)` or `(16, 8, 16)`.
  - `MmaFP8Op`: `(16, 8, 16)` or `(16, 8, 32)`.
  - `MmaMXF4Op` and `MmaMXF4NVF4Op`: `(16, 8, 64)`.
  - `MmaMXF8Op` and `MmaMXF8F6F4Op`: `(16, 8, 32)`.

```python
assert a_dtype == b_dtype
ab_type = a_dtype

mma_inst_shape_mnk = (16, 8, 16)
mma_op = cute.nvgpu.warp.MmaF16BF16Op(ab_type, acc_dtype, mma_inst_shape_mnk)
```

### WGMMA

- 16-bit WGMMA uses the same A/B type.
- 8-bit WGMMA uses independent A/B types.
- Supported instruction shapes:
  - `MmaF16BF16Op`: `(64, N, 16)`, where `8 <= N <= 256` and `N % 8 == 0`.
  - `MmaF8Op`: `(64, N, 32)`, where `8 <= N <= 256` and `N % 8 == 0`.
  - `MmaI8Op`: `(64, N, 32)`, where `N in {8, 24}` or `N % 16 == 0`, with `8 <= N <= 256`.
- `cute.nvgpu.warpgroup.fence()` orders prior fragment/register setup before WGMMA issue.
- `cute.nvgpu.warpgroup.commit_group()` publishes queued WGMMA instructions as an async completion group.
- `cute.nvgpu.warpgroup.wait_group(n)` waits until at most `n` committed WGMMA groups remain in flight; use `wait_group(0)` before consuming final accumulators.
- Treat `cute.nvgpu.warpgroup.OperandSource` as the operand-A source and define it as a separate `a_src` variable.

```python
assert a_dtype == b_dtype
ab_type = a_dtype

mma_inst_shape_mnk = (64, 128, 16)
a_src = cute.nvgpu.warpgroup.OperandSource.SMEM
a_major_mode = cute.nvgpu.OperandMajorMode.K
b_major_mode = cute.nvgpu.OperandMajorMode.K
mma_op = cute.nvgpu.warpgroup.MmaF16BF16Op(
    ab_type,
    acc_dtype,
    mma_inst_shape_mnk,
    a_src,
    a_major_mode,
    b_major_mode,
)
```
