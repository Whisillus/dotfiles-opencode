---
name: cutedsl-basic
description: Use whenever writing, reviewing, or debugging CuTe DSL code; covers default imports, JIT/runtime, dtypes, terminology, tensor access, debug workflow, and routing to related CuTe DSL skills.
---

# CuTe DSL Basic

## Related Skills

- Treat this as the entry-point skill for CuTe DSL coding tasks; load it before applying more specialized CuTe DSL skills.
- Also use `cutedsl-layout` when the task involves layouts, tensors, layout algebra, tensor tiling, local partitioning, or thread-value layouts.
- Also use `cutedsl-copy` when the task involves copy operation descriptors, copy atoms, tiled copies, TMA copy setup, bulk copy, or warp matrix copy.
- Also use `cutedsl-mma` when the task involves MMA ops/atoms, tiled MMA, GEMM mainloops, WMMA, or WGMMA.
- Also use `cutedsl-pipeline` when the task involves `cutlass.pipeline`, staged producer/consumer protocols, pipeline state, mbarriers, `cp.async` pipelines, or TMA pipelines.
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

## Tensor Access

- When indexing tensors, write the coordinate inline instead of defining a separate coordinate variable.

```python
tile = tensor[(None, rest_coord)]
```

## Debug

- Use Python `print(...)` for compile-time/static information such as layouts and shapes known during JIT tracing.
- Use `cute.printf(...)` for runtime GPU-side diagnostics; remove it from performance paths after debugging.
- Use `CUTE_DSL_LINEINFO=1` or `GenerateLineInfo` when correlating generated code with Python source.
- Use `CUTE_DSL_KEEP=ir`, `ir-debug`, `ptx`, `cubin`, `llvm`, or `all` to dump generated artifacts.
- Use `CUTE_DSL_PRINT_IR=1` to print generated IR without writing files.
- Use `CUTE_DSL_DUMP_DIR` to redirect dumped artifacts to a known directory.
- Compiled callables can expose generated artifacts such as `__ptx__`, `__cubin__`, and `__mlir__`.
- Use `compute-sanitizer python ...` for memory/race debugging when a kernel produces invalid results or faults.

```python
@cute.jit
def compile_for_debug(
    tensor: cute.Tensor,
    tile_m: cutlass.Constexpr,
    tile_n: cutlass.Constexpr,
):
    print("tensor layout:", tensor.layout)
    kernel.set_name_prefix("debug_kernel")

    debug_options = (
        cute.OptLevel(1),
        cute.EnableAssertions,
        cute.GenerateLineInfo,
        cute.KeepPTX,
        cute.KeepCUBIN,
    )
    compiled = cute.compile[debug_options](kernel, tensor, tile_m, tile_n)

    print(compiled.__mlir__)
    print(compiled.__ptx__)
    return compiled
```
