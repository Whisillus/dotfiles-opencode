---
name: cutedsl-mma-gemm
description: Use when the user asks about CuTe DSL MMA, GEMM, cute.gemm, tiled MMA, WMMA, WGMMA, warpgroup MMA, MMA atoms, or MMA instruction shapes.
---

# CuTe DSL MMA GEMM

Build MMA code in this order: choose an MMA operation descriptor, create an MMA atom, then create a tiled MMA when tiled MMA partitioning is needed.

## MMA Op

An MMA op describes the instruction family, operand types, accumulator type, instruction shape, and op-specific operand interpretation. Treat the MMA operation descriptor as an op, not an atom.

### Universal MMA Op

Use `cute.nvgpu.MmaUniversalOp` for the generic FMA MMA path, not a tensor-core-specific WMMA or WGMMA instruction.

- The universal op has instruction shape `(1, 1, 1)` and supports all architectures.
- A, B, and accumulator types must be the same type: `Float16`, `Float32`, or `Float64`.

Op inputs:

- `cute.nvgpu.MmaUniversalOp(abacc_dtype)`.

```python
assert a_dtype == b_dtype
assert a_dtype == acc_dtype
abacc_dtype = a_dtype

mma_op = cute.nvgpu.MmaUniversalOp(abacc_dtype)
```

### WMMA Op

Use `cute.nvgpu.warp` MMA ops for synchronous warp-level MMA instructions.

- All `cute.nvgpu.warp` MMA ops support only A K-major and B K-major operand layouts.
- For non-mixed-precision warp-level MMA ops, assert `a_dtype == b_dtype`, define `ab_type = a_dtype`, and pass `ab_type` to the op constructor.
- Supported architectures:
  - `MmaF16BF16Op`: SM80+.
  - `MmaFP8Op`: SM89+.
  - `MmaMXF4Op`, `MmaMXF4NVF4Op`, `MmaMXF8Op`, and `MmaMXF8F6F4Op`: SM120-family, such as `sm_120a`, `sm_120f`, `sm_121a`, and `sm_121f`.
- Supported instruction shapes:
  - `MmaF16BF16Op`: `(16, 8, 8)` or `(16, 8, 16)`.
  - `MmaFP8Op`: `(16, 8, 16)` or `(16, 8, 32)`.
  - `MmaMXF4Op` and `MmaMXF4NVF4Op`: `(16, 8, 64)`.
  - `MmaMXF8Op` and `MmaMXF8F6F4Op`: `(16, 8, 32)`.
- SM120 block-scaled WMMA ops do not take `shape_mnk`; their instruction shape is fixed by the op class.

Op inputs:

- `cute.nvgpu.warp.MmaF16BF16Op(ab_type, acc_dtype, mma_inst_shape_mnk)`.
- `cute.nvgpu.warp.MmaFP8Op(ab_type, acc_dtype, mma_inst_shape_mnk)`.
- `cute.nvgpu.warp.MmaMXF4Op(ab_type, acc_dtype, sf_type)`.
- `cute.nvgpu.warp.MmaMXF4NVF4Op(ab_type, acc_dtype, sf_type)`.
- `cute.nvgpu.warp.MmaMXF8Op(ab_type, acc_dtype, sf_type)`.
- `cute.nvgpu.warp.MmaMXF8F6F4Op(a_dtype, b_dtype, acc_dtype, sf_type)`.

```python
assert a_dtype == b_dtype
ab_type = a_dtype

mma_inst_shape_mnk = (16, 8, 16)
mma_op = cute.nvgpu.warp.MmaF16BF16Op(ab_type, acc_dtype, mma_inst_shape_mnk)
```

### WGMMA Op

Use `cute.nvgpu.warpgroup` MMA ops for asynchronous warpgroup-level MMA instructions.

- 16-bit WGMMA uses the same A/B type.
- 8-bit WGMMA uses independent A/B types.
- Supported architecture: `MmaF16BF16Op`, `MmaF8Op`, and `MmaI8Op` require `sm_90a`.
- Supported instruction shapes:
  - `MmaF16BF16Op`: `(64, N, 16)`, where `8 <= N <= 256` and `N % 8 == 0`.
  - `MmaF8Op`: `(64, N, 32)`, where `8 <= N <= 256` and `N % 8 == 0`.
  - `MmaI8Op`: `(64, N, 32)`, where `N in {8, 24}` or `N % 16 == 0`, with `8 <= N <= 256`.
- WGMMA major-mode legality depends on the op and A operand source:
  - `MmaF16BF16Op` with `a_src = OperandSource.SMEM`: A and B may be `OperandMajorMode.K` or `OperandMajorMode.MN`.
  - `MmaF16BF16Op` with `a_src = OperandSource.RMEM`: keep A `OperandMajorMode.K`; B may be `OperandMajorMode.K` or `OperandMajorMode.MN`.
  - `MmaF8Op` and `MmaI8Op`: A and B must both be `OperandMajorMode.K`.
- Major-mode choices must match the actual SMEM/RMEM fragments used for `cute.gemm(...)`; do not choose `OperandMajorMode.MN` unless the operand path and layout are built for it.

Op inputs:

- `cute.nvgpu.warpgroup.MmaF16BF16Op(ab_type, acc_dtype, mma_inst_shape_mnk, a_src, a_major_mode, b_major_mode)`.
- `cute.nvgpu.warpgroup.MmaF8Op(a_dtype, b_dtype, acc_dtype, mma_inst_shape_mnk, a_src, a_major_mode, b_major_mode)`.
- `cute.nvgpu.warpgroup.MmaI8Op(a_dtype, b_dtype, acc_dtype, mma_inst_shape_mnk, a_src, a_major_mode, b_major_mode)`.

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

## MMA Atom

- Treat the MMA operation descriptor as an op, not an atom.
- Create the MMA atom with `mma_atom = cute.make_mma_atom(mma_op)` after choosing the MMA op.
- Current Universal MMA, WMMA, and WGMMA ops do not need op-specific `cute.make_mma_atom(...)` kwargs.

```python
mma_atom = cute.make_mma_atom(mma_op)
```

## Tiled MMA

- Always create the MMA atom first with `mma_atom = cute.make_mma_atom(mma_op)`, then pass `mma_atom` to `cute.make_tiled_mma(...)`.
- Do not pass `mma_op` directly to `cute.make_tiled_mma(...)`.
- Define `atom_shape_mnk`, `atom_stride_mnk`, and `atom_layout_mnk` separately before constructing the tiled MMA.
- `permutation_mnk` is optional; define it separately only when needed, otherwise omit it.
- `cute.nvgpu.warpgroup.fence()` orders prior fragment/register setup before WGMMA issue.
- `cute.nvgpu.warpgroup.commit_group()` publishes queued WGMMA instructions as an async completion group.
- `cute.nvgpu.warpgroup.wait_group(n)` waits until at most `n` committed WGMMA groups remain in flight; use `wait_group(0)` before consuming final accumulators.

```python
atom_shape_mnk = ...
atom_stride_mnk = ...
atom_layout_mnk = cute.make_layout(atom_shape_mnk, stride=atom_stride_mnk)

tiled_mma = cute.make_tiled_mma(mma_atom, atom_layout_mnk)
```
