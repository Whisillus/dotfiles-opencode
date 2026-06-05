---
name: cuda-general-reference
description: CUDA general reference map for GPU architecture, CUDA, PTX, NVCC, NVRTC, cuTile, and Tile IR. Use when answering or implementing work about NVIDIA GPU architecture, CUDA programming, GPU kernels, PTX, compiler/runtime compilation, tensor cores, TMA, WGMMA, CUTLASS/CuTe, FlashAttention, FlashMLA, or TileLang.
---

# GPU Architecture and Computing References

Use this skill to quickly locate trusted references for NVIDIA GPU architecture,
CUDA programming, CUDA compilers, PTX, tile programming, and high-performance GPU
kernel examples.

## Reference Priority

1. **Official NVIDIA documentation** for normative CUDA, PTX, compiler, ABI,
   architecture, and toolchain behavior.
2. **Local reference repositories** for implementation patterns, examples, and
   code archaeology. Inspect files directly before making claims about local
   code.
3. **External sources** only when official docs and local references are
   insufficient; label them as non-authoritative.

Always note the CUDA version and GPU target/SM architecture when those details
matter. Do not invent performance numbers or instruction support; verify them in
the relevant guide, source file, benchmark, or release note.

## Local Reference Root

Local references live under:

```text
~/workspace/reference
```

Official and open-source repository snapshots, when available locally, can be
found under `~/workspace/reference`. Inspect that directory directly for the
current set of repositories instead of relying on a hard-coded list.

Treat local repositories as implementation examples, not as CUDA specification.
For official behavior, cross-check NVIDIA docs.

## Official CUDA Documentation Hub

- CUDA Toolkit Documentation: <https://docs.nvidia.com/cuda/>

Use the hub to find current CUDA docs, release notes, programming guides,
compiler documentation, APIs, libraries, profiling tools, samples, architecture
compatibility guides, and architecture tuning guides.

## Core CUDA Programming

| Topic | URL | Use for |
| --- | --- | --- |
| CUDA Programming Guide | <https://docs.nvidia.com/cuda/cuda-programming-guide/index.html> | CUDA programming model, CUDA C++/Python basics, kernels, execution, memory hierarchy, CUDA features, compute capabilities, language extensions, memory model, NVCC overview, tile kernels. |
| CUDA Best Practices Guide | <https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html> | Performance methodology, APOD cycle, profiling, memory optimization, coalescing, shared memory, occupancy, instruction/control-flow optimization, deployment, compatibility practices. |
| CUDA Samples | <https://docs.nvidia.com/cuda/cuda-samples/index.html> | Official sample programs and feature examples. |
| CUDA Demo Suite | <https://docs.nvidia.com/cuda/demo-suite/index.html> | CUDA demo and validation utilities. |

## Tile Programming

| Topic | URL | Use for |
| --- | --- | --- |
| cuTile Python | <https://docs.nvidia.com/cuda/cutile-python/index.html> | Python tile DSL, execution/data/memory model, operations, interoperability, performance tuning, compilation/export, debugging. |
| CUDA Tile IR | <https://docs.nvidia.com/cuda/tile-ir/index.html> | Tile IR specification: programming model, syntax, binary format, type system, semantics, memory model, operations, debug info, stability, optimization guide. |
| Latest CUDA Tile IR | <https://docs.nvidia.com/cuda/tile-ir/latest/index.html> | Latest Tile IR version when the unversioned URL redirects or version-specific details matter. |
| CUDA Tile C++ API Reference | <https://docs.nvidia.com/cuda/cuda-tile-cpp-api-reference/index.html> | CUDA Tile C++ API, `cuda_tile.h`, tile C++ syntax/API details. |

## CUDA Compiler and Runtime Compilation

| Topic | URL | Use for |
| --- | --- | --- |
| NVCC | <https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html> | CUDA compiler driver, compilation phases, `-arch`, `-gencode`, `--gpu-code`, PTX/CUBIN/fatbin generation, device linking, tile compilation, ptxas options. |
| NVRTC Runtime Compilation | <https://docs.nvidia.com/cuda/nvrtc/index.html> | Runtime compilation of CUDA C++ strings, PTX/CUBIN/Tile IR retrieval, supported options, lowered names, PCH, bundled headers, tile compilation. |
| nvJitLink | <https://docs.nvidia.com/cuda/nvjitlink/index.html> | Runtime/JIT linking of device code modules. |
| nvFatbin | <https://docs.nvidia.com/cuda/nvfatbin/index.html> | Fatbinary creation and management. |
| CUDA Binary Utilities | <https://docs.nvidia.com/cuda/cuda-binary-utilities/index.html> | Tools for inspecting CUDA binaries, cubins, fatbins, and generated code artifacts. |

## PTX and Low-Level Programming

| Topic | URL | Use for |
| --- | --- | --- |
| PTX ISA | <https://docs.nvidia.com/cuda/parallel-thread-execution/index.html> | PTX syntax, machine model, state spaces, types, memory consistency, instruction set, tensor/tensor-core instructions, target ISA support. |
| Inline PTX Assembly | <https://docs.nvidia.com/cuda/inline-ptx-assembly/index.html> | CUDA `asm()` syntax, constraints, volatile/memory clobber guidance, namespace/memory-space pitfalls, inline PTX error checking. |
| PTX Interoperability | <https://docs.nvidia.com/cuda/ptx-writers-guide-to-interoperability/index.html> | ABI-compliant PTX, data representation, function calling sequence, parameter passing, atomics ABI, debug information, C++ interoperability. |
| PTX Compiler APIs | <https://docs.nvidia.com/cuda/ptx-compiler-api/index.html> | Runtime compilation of PTX strings into GPU assembly code, compiler handles, options, logs, compiled-program retrieval, custom caching. |

## Architecture Compatibility and Tuning

| Topic | URL |
| --- | --- |
| Blackwell Compatibility Guide | <https://docs.nvidia.com/cuda/blackwell-compatibility-guide/index.html> |
| Hopper Compatibility Guide | <https://docs.nvidia.com/cuda/hopper-compatibility-guide/index.html> |
| Ada Compatibility Guide | <https://docs.nvidia.com/cuda/ada-compatibility-guide/index.html> |
| NVIDIA Ampere GPU Architecture Compatibility Guide | <https://docs.nvidia.com/cuda/ampere-compatibility-guide/index.html> |
| Turing Compatibility Guide | <https://docs.nvidia.com/cuda/turing-compatibility-guide/index.html> |
| CUDA Compatibility | <https://docs.nvidia.com/deploy/cuda-compatibility/index.html> |
| Blackwell Tuning Guide | <https://docs.nvidia.com/cuda/blackwell-tuning-guide/index.html> |
| Hopper Tuning Guide | <https://docs.nvidia.com/cuda/hopper-tuning-guide/index.html> |
| Ada Tuning Guide | <https://docs.nvidia.com/cuda/ada-tuning-guide/index.html> |
| NVIDIA Ampere GPU Architecture Tuning Guide | <https://docs.nvidia.com/cuda/ampere-tuning-guide/index.html> |
| Turing Tuning Guide | <https://docs.nvidia.com/cuda/turing-tuning-guide/index.html> |

## CUDA APIs and Compiler SDK

| Topic | URL | Use for |
| --- | --- | --- |
| CUDA Runtime API | <https://docs.nvidia.com/cuda/cuda-runtime-api/index.html> | Runtime API calls, memory management, launches, streams, events, graphs, errors. |
| CUDA Driver API | <https://docs.nvidia.com/cuda/cuda-driver-api/index.html> | Low-level driver API, module loading, contexts, JIT options, launches. |
| CUDA Math API | <https://docs.nvidia.com/cuda/cuda-math-api/index.html> | Device math functions and numerical behavior. |
| libNVVM API | <https://docs.nvidia.com/cuda/libnvvm-api/index.html> | NVVM compiler API. |
| libdevice User's Guide | <https://docs.nvidia.com/cuda/libdevice-users-guide/index.html> | Device math bitcode library. |
| NVVM IR | <https://docs.nvidia.com/cuda/nvvm-ir-spec/index.html> | NVVM IR specification for compiler work. |

## Quick Lookup

- CUDA programming model, memory hierarchy, compute capabilities: CUDA
  Programming Guide.
- Kernel performance, coalescing, shared memory, occupancy, instruction
  throughput, profiling methodology: CUDA Best Practices Guide and the relevant
  architecture tuning guide.
- Build flags, `-arch`, `-gencode`, PTX/CUBIN/fatbin, ptxas diagnostics: NVCC.
- Runtime CUDA C++ compilation: NVRTC; runtime PTX compilation: PTX Compiler
  APIs; runtime linking: nvJitLink.
- PTX syntax/instruction semantics/memory model: PTX ISA.
- Inline `asm()` in CUDA C++: Inline PTX Assembly.
- ABI-compliant generated PTX and linking with other PTX/CUDA code: PTX
  Interoperability.
- Tile programming: CUDA Programming Guide tile-kernel sections, cuTile Python,
  CUDA Tile IR, CUDA Tile C++ API, and relevant local repository docs when
  present.
- Real high-performance kernel examples: relevant local repositories under
  `~/workspace/reference` when present.

## Working Rules

- Ask for or infer the target GPU architecture (`sm_80`, `sm_90`, `sm_100`,
  etc.) and CUDA Toolkit version before making architecture-specific claims.
- Prefer local `grep`/glob/read inspection for local repositories; prefer
  official NVIDIA URLs for specifications.
- For performance-sensitive advice, separate what is specified, what is a common
  optimization heuristic, and what requires benchmarking.
- When citing an instruction, API, compiler flag, or architecture capability,
  verify the exact spelling and support constraints in the relevant reference.
