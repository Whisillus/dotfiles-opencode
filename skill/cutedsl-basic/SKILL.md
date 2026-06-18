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
