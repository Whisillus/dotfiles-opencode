---
name: cutedsl-copy
description: Use when the user asks about CuTe DSL copy, tiled copy, copy atoms, make_tiled_copy_tv, make_layout_tv, partition_S, partition_D, or copy TV layouts.
---

# CuTe DSL Copy

Build copy code in this order: choose a copy operation descriptor, create a copy atom, then create a tiled copy when a tiled TV mapping is needed.

Copy operation descriptors are ops, not atoms. Create an op first, then pass it to `cute.make_copy_atom(...)`.

## SIMT Copy Op

Use these ops for thread-level SIMT copies between global, shared, and register storage.

- `cute.nvgpu.CopyUniversalOp`: plain assignment-style copy.
- `cute.nvgpu.CopyG2ROp`: global -> register.
- `cute.nvgpu.CopyR2GOp`: register -> global.
- `cute.nvgpu.CopyS2ROp`: shared -> register.
- `cute.nvgpu.CopyR2SOp`: register -> shared.
- These op constructors take no op-specific arguments in current CuTe DSL; pass copy width, memory ordering, scope, and cache hints to `cute.make_copy_atom(...)`.

Op inputs:

- `cute.nvgpu.CopyUniversalOp()`: no inputs.
- `cute.nvgpu.CopyG2ROp()`: no inputs.
- `cute.nvgpu.CopyR2GOp()`: no inputs.
- `cute.nvgpu.CopyS2ROp()`: no inputs.
- `cute.nvgpu.CopyR2SOp()`: no inputs.

```python
copy_op = cute.nvgpu.CopyUniversalOp()
copy_op = cute.nvgpu.CopyG2ROp()
copy_op = cute.nvgpu.CopyR2GOp()
copy_op = cute.nvgpu.CopyS2ROp()
copy_op = cute.nvgpu.CopyR2SOp()
```

## cp.async Copy Op

Use `cute.nvgpu.cpasync.CopyG2SOp` for non-bulk asynchronous global-to-shared copies.

- `CopyG2SOp` is GMEM -> SMEM only.
- `CopyG2SOp` takes only `cache_mode` as an op constructor argument.
- Pass only `num_bits_per_copy` when creating the copy atom; do not pass `memory_order` or `memory_scope` for non-bulk `cp.async`.
- Use `cute.arch.cp_async_commit_group()` to commit issued `cp.async` copies.
- Use `cute.arch.cp_async_wait_group(n)` to wait until at most `n` committed groups remain in flight; use `cute.arch.cp_async_wait_group(0)` before consuming the copied SMEM data.

Op inputs:

- `cute.nvgpu.cpasync.CopyG2SOp(cache_mode=cute.nvgpu.LoadCacheMode.ALWAYS)`.

### Cache Mode

- Use `cute.nvgpu.LoadCacheMode`, not the deprecated `cute.nvgpu.cpasync.LoadCacheMode`, for new code.
- PTX non-bulk `cp.async` documents `.ca` and `.cg`; prefer `ALWAYS` or `GLOBAL` for `CopyG2SOp` unless the backend behavior of another mode has been verified.
- `cute.nvgpu.LoadCacheMode.ALWAYS`: `.ca`, cache at all levels, including L1 and L2.
- `cute.nvgpu.LoadCacheMode.GLOBAL`: `.cg`, cache only at global/L2 level and bypass L1; common for `cp.async`.
- `cute.nvgpu.LoadCacheMode.STREAMING`: `.cs`, evict-first streaming load hint for data likely used once; generic load mode, not a documented PTX non-bulk `cp.async` cache operator.
- `cute.nvgpu.LoadCacheMode.LAST_USE`: `.lu`, last-use load hint; generic load mode, not a documented PTX non-bulk `cp.async` cache operator.
- `cute.nvgpu.LoadCacheMode.NONE`: no explicit cache operator; use backend/default behavior.

```python
copy_op = cute.nvgpu.cpasync.CopyG2SOp(cache_mode=cute.nvgpu.LoadCacheMode.GLOBAL)
copy_atom = cute.make_copy_atom(copy_op, dtype, num_bits_per_copy=128)
```

## Warp Matrix Copy Op

Use these ops for warp-level matrix-fragment copies between shared memory and registers.

- Load family: shared -> register.
  - `cute.nvgpu.warp.LdMatrix8x8x16bOp`: SM75+.
  - `cute.nvgpu.warp.LdMatrix8x16x8bOp`: SM100+.
  - `cute.nvgpu.warp.LdMatrix16x8x8bOp`: SM100+.
  - `cute.nvgpu.warp.LdMatrix16x16x8bOp`: SM100+.
- Store family: register -> shared.
  - `cute.nvgpu.warp.StMatrix8x8x16bOp`: SM90+.
  - `cute.nvgpu.warp.StMatrix16x8x8bOp`: SM100+.

Op inputs:

- `LdMatrix8x8x16bOp(transpose=False, num_matrices=1, unpack_bits=None)`.
- `LdMatrix8x16x8bOp(transpose=False, num_matrices=1, unpack_bits=None)`.
- `LdMatrix16x8x8bOp(transpose=True, num_matrices=2, unpack_bits=None)`.
- `LdMatrix16x16x8bOp(transpose=True, num_matrices=1, unpack_bits=None)`.
- `StMatrix8x8x16bOp(transpose=False, num_matrices=1, unpack_bits=None)`.
- `StMatrix16x8x8bOp(transpose=True, num_matrices=1, unpack_bits=None)`.
- `transpose` is a `bool`.
- `num_matrices` is an `int`; valid values are listed below.
- `unpack_bits` is `None`, `4`, or `6` where supported; store ops and `LdMatrix8x8x16bOp` require `None`.

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

## Copy Atom Construction

`cute.make_copy_atom(copy_op, copy_internal_type, **kwargs)` always takes:

- `copy_op`: the copy operation descriptor.
- `copy_internal_type`: the data type used to construct copy TV layouts in units of tensor elements.
- Optional compiler plumbing: `loc`, `ip`; omit in normal code.

Op-specific `cute.make_copy_atom(...)` kwargs for copy ops in this skill:

- `CopyUniversalOp`: `num_bits_per_copy=0`; non-negative `int`; `0` lets the compiler choose best-effort vectorization.
- `CopyG2ROp`: `num_bits_per_copy=0`, `memory_order=MemoryOrder.WEAK`, `memory_scope=MemoryScope.CTA`, `l2_prefetch_size=L2PrefetchSize.NONE`, `l1c_evict_priority=CacheEvictionPriority.EVICT_NORMAL`, `load_cache_mode=LoadCacheMode.ALWAYS`, `shared_space=SharedSpace.CTA`, `invariant=False`.
- `CopyR2GOp`: `num_bits_per_copy=0`, `memory_order=MemoryOrder.WEAK`, `memory_scope=MemoryScope.CTA`, `l1c_evict_priority=CacheEvictionPriority.EVICT_NORMAL`, `store_cache_mode=StoreCacheMode.WRITE_BACK`, `shared_space=SharedSpace.CTA`.
- `CopyS2ROp`: `num_bits_per_copy=0`, `memory_order=MemoryOrder.WEAK`, `memory_scope=MemoryScope.CTA`, `shared_space=SharedSpace.CTA`; rejects other kwargs.
- `CopyR2SOp`: `num_bits_per_copy=0`, `memory_order=MemoryOrder.WEAK`, `memory_scope=MemoryScope.CTA`, `shared_space=SharedSpace.CTA`; rejects other kwargs.
- `cpasync.CopyG2SOp`: requires positive `num_bits_per_copy`; no `memory_order` or `memory_scope`.
- Warp Matrix Copy ops: no op-specific atom kwargs beyond `copy_internal_type`; `transpose`, `num_matrices`, and `unpack_bits` are op constructor inputs.

```python
copy_op = cute.nvgpu.CopyG2ROp()
copy_atom = cute.make_copy_atom(
    copy_op,
    dtype,
    num_bits_per_copy=0,
    memory_order=cute.nvgpu.MemoryOrder.WEAK,
    memory_scope=cute.nvgpu.MemoryScope.CTA,
    l2_prefetch_size=cute.nvgpu.L2PrefetchSize.NONE,
    l1c_evict_priority=cute.nvgpu.CacheEvictionPriority.EVICT_NORMAL,
    load_cache_mode=cute.nvgpu.LoadCacheMode.ALWAYS,
    shared_space=cute.nvgpu.SharedSpace.CTA,
    invariant=False,
)

copy_op = cute.nvgpu.CopyR2GOp()
copy_atom = cute.make_copy_atom(
    copy_op,
    dtype,
    num_bits_per_copy=0,
    memory_order=cute.nvgpu.MemoryOrder.WEAK,
    memory_scope=cute.nvgpu.MemoryScope.CTA,
    l1c_evict_priority=cute.nvgpu.CacheEvictionPriority.EVICT_NORMAL,
    store_cache_mode=cute.nvgpu.StoreCacheMode.WRITE_BACK,
    shared_space=cute.nvgpu.SharedSpace.CTA,
)
```

### Memory Order

- `memory_order` is a `cute.make_copy_atom(...)` kwarg, not a copy-op constructor argument.
- It applies to `CopyG2ROp`, `CopyR2GOp`, `CopyS2ROp`, and `CopyR2SOp` atom construction.
- It does not apply to `CopyUniversalOp` or non-bulk `cp.async` `CopyG2SOp`; `CopyG2SOp` uses `cache_mode` on the op and `num_bits_per_copy` on the atom.
- `memory_order` controls synchronization semantics on supported specialized SIMT copy atoms.
- PTX loads support `.weak`, `.relaxed.scope`, and `.acquire.scope`; stores support `.weak`, `.relaxed.scope`, and `.release.scope`.
- Use `cute.nvgpu.MemoryOrder.WEAK` when ordering is established by another synchronization mechanism.
- Use `cute.nvgpu.MemoryOrder.RELAXED` for atomic/strong memory operations without acquire or release ordering.
- Use `cute.nvgpu.MemoryOrder.ACQUIRE` for load-side acquire ordering.
- Use `cute.nvgpu.MemoryOrder.RELEASE` for store-side release ordering.
- `ACQ_REL`, `SC`, `MMIO`, `CONSTANT`, and `VOLATILE` are exposed enum values; verify the target op and PTX support before using them.

### Memory Scope

- `memory_scope` is a `cute.make_copy_atom(...)` kwarg, not a copy-op constructor argument.
- It applies to `CopyG2ROp`, `CopyR2GOp`, `CopyS2ROp`, and `CopyR2SOp` atom construction.
- It does not apply to `CopyUniversalOp` or non-bulk `cp.async` `CopyG2SOp`; `CopyG2SOp` uses `cache_mode` on the op and `num_bits_per_copy` on the atom.
- `memory_scope` controls which threads can participate in the synchronization semantics requested by `memory_order`.
- `cute.nvgpu.MemoryScope.CTA`: block/CTA scope.
- `cute.nvgpu.MemoryScope.CLUSTER`: cluster scope; requires cluster-capable target support.
- `cute.nvgpu.MemoryScope.GPU`: device scope.
- `cute.nvgpu.MemoryScope.SYS`: system scope.

### L2 Prefetch

- `l2_prefetch_size` is an L2 cache prefetch-size hint for the generated global load; it does not change the actual load width.
- Valid values: `NONE`, `RESERVED`, `SIZE_64B`, `SIZE_128B`, and `SIZE_256B`.
- Prefer `NONE` unless tuning shows an L2 prefetch hint improves the target kernel.

### L1 Eviction Priority

- `l1c_evict_priority` is an L1 cache eviction-priority hint for generated global loads or stores; it does not change the copied value.
- Valid values: `EVICT_NORMAL`, `EVICT_FIRST`, `EVICT_LAST`, `EVICT_UNCHANGED`, and `NO_ALLOCATE`.
- `EVICT_FIRST`: prefer evicting this line earlier.
- `EVICT_LAST`: prefer keeping this line longer.
- `NO_ALLOCATE`: avoid allocating the line in L1.
- `EVICT_UNCHANGED`: preserve the existing cache eviction priority when possible.
- Prefer `EVICT_NORMAL` unless profiling or a known access pattern justifies another hint.

### Generic SIMT Cache Mode

- `load_cache_mode` and `store_cache_mode` are parallel cache-mode hints, but they use separate enums and apply to different copy directions.
- `CopyG2ROp` accepts `load_cache_mode` when creating the copy atom.
- `CopyR2GOp` accepts `store_cache_mode` when creating the copy atom.
- `CopyS2ROp` and `CopyR2SOp` do not accept cache-mode kwargs.
- `cute.nvgpu.LoadCacheMode.ALWAYS`: `.ca`, cache at all levels, including L1 and L2.
- `cute.nvgpu.LoadCacheMode.GLOBAL`: `.cg`, cache only at global/L2 level and bypass L1.
- `cute.nvgpu.LoadCacheMode.STREAMING`: `.cs`, evict-first streaming load hint for data likely used once.
- `cute.nvgpu.LoadCacheMode.LAST_USE`: `.lu`, last-use load hint.
- `cute.nvgpu.LoadCacheMode.NONE`: no explicit load cache operator; use backend/default behavior.
- `cute.nvgpu.StoreCacheMode.WRITE_BACK`: `.wb`, cache write-back at coherent levels.
- `cute.nvgpu.StoreCacheMode.GLOBAL`: `.cg`, cache only at global/L2 level and bypass L1.
- `cute.nvgpu.StoreCacheMode.STREAMING`: `.cs`, evict-first streaming store hint.
- `cute.nvgpu.StoreCacheMode.WRITE_THROUGH`: `.wt`, write-through system-level store behavior.
- `cute.nvgpu.StoreCacheMode.NONE`: no explicit store cache operator; use backend/default behavior.

### Shared Space

- `shared_space` selects the shared-memory address space used by the generated copy instruction.
- It applies to `CopyG2ROp`, `CopyR2GOp`, `CopyS2ROp`, and `CopyR2SOp` atom construction.
- `cute.nvgpu.SharedSpace.CTA`: shared memory is addressed within a CTA.
- `cute.nvgpu.SharedSpace.CLUSTER`: shared memory is addressed in cluster shared-memory space; use only when targeting cluster-capable kernels and instructions.
- Prefer `CTA` unless the copy intentionally uses cluster shared-memory addressing.

### Invariant

- `invariant` marks a global load as reading data that does not change for the relevant execution.
- It applies only to `CopyG2ROp` atom construction.
- Use `invariant=True` only when the loaded global memory value is known not to change for the relevant execution; otherwise leave it as `False`.

## Tiled Copy Construction

- Always create the copy atom first with `copy_atom = cute.make_copy_atom(copy_op, dtype)`, then pass `copy_atom` to tiled-copy construction.
- Do not pass `copy_op` directly to `cute.make_tiled_copy(...)`, `cute.make_tiled_copy_tv(...)`, `cute.make_tiled_copy_A(...)`, or `cute.make_tiled_copy_B(...)`.
- In most cases, use `cute.make_tiled_copy_tv(copy_atom, thr_layout, val_layout)` instead of `cute.make_tiled_copy`.
- Define `thr_layout` and `val_layout` as separate values before constructing the tiled copy.
- Define `tiler_mn` and `layout_tv` with `cute.make_layout_tv(thr_layout, val_layout)` when the tile shape or TV mapping is needed for tensor tiling, inspection, or explanation.
- For MMA operand retiling, use `cute.make_tiled_copy_A(copy_atom, tiled_mma)` or `cute.make_tiled_copy_B(copy_atom, tiled_mma)` after atom construction.

```python
copy_op = ...
copy_atom = cute.make_copy_atom(copy_op, dtype)

thr_layout = ...
val_layout = ...
tiler_mn, layout_tv = cute.make_layout_tv(thr_layout, val_layout)
tiled_copy = cute.make_tiled_copy_tv(copy_atom, thr_layout, val_layout)
```

```python
copy_op = ...
copy_atom = cute.make_copy_atom(copy_op, dtype)
tiled_copy = cute.make_tiled_copy_A(copy_atom, tiled_mma)
```
