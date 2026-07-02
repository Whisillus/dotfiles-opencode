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

## JIT and Runtime

- Use `@cute.jit` for host-side JIT functions, launchers, and reusable compile-time helpers.
- Use `@cute.kernel` for GPU kernel bodies. A `@cute.kernel` body cannot call another `@cute.kernel`.
- JIT function arguments are dynamic by default; annotate compile-time values with `cutlass.Constexpr`.
- Use type annotations for DSL objects passed into kernels when they clarify the ABI, such as `cute.Tensor`, `cute.CopyAtom`, `cute.MmaAtom`, `cute.TiledCopy`, and `cute.TiledMma`.
- Use `kernel(...).launch(...)` from a `@cute.jit` launcher for normal kernel launches.
- Use `cute.compile(...)` when an explicit compiled callable is needed, such as for inspecting generated artifacts or integrating with external launch paths.

```python
@cute.kernel
def kernel(
    tensor: cute.Tensor,
    tile_m: cutlass.Constexpr,
    tile_n: cutlass.Constexpr,
):
    ...

@cute.jit
def launch(
    tensor: cute.Tensor,
    tile_m: cutlass.Constexpr,
    tile_n: cutlass.Constexpr,
):
    grid = (1, 1, 1)
    block = (128, 1, 1)
    kernel(tensor, tile_m, tile_n).launch(grid=grid, block=block)

@cute.jit
def compile_kernel(
    tensor: cute.Tensor,
    tile_m: cutlass.Constexpr,
    tile_n: cutlass.Constexpr,
):
    return cute.compile(kernel, tensor, tile_m, tile_n)
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
