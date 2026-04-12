---
name: hugo-latex-notation
description: Defines the house notation standard for mathematical writing in Hugo posts about computer science and machine learning.
---

# Notation

Use this skill as the default notation standard for all mathematical writing in Hugo posts about computer science and machine learning.

- Write math that is compatible with the current Hugo site's configured math renderer, delimiters, and loaded macros.
- If renderer support is unclear, determine compatibility from the local Hugo configuration and math partials first, then fall back to a conservative KaTeX-safe subset.
- Keep notation conventional, explicit, and consistent across the whole post.
- Define symbols on first use and avoid reusing the same base symbol for unrelated meanings.
- State shapes, domains, or roles when they are needed for understanding.
- Prefer clarity over cleverness, and prefer standard CS/ML notation over personal shorthand.
- If the user explicitly specifies notation or symbol names, follow the user’s convention and apply this skill only to keep that convention consistent, clear, and compatible with the site’s configured math renderer.


# Symbol naming and reuse policy

This section governs how symbols are introduced, named, reused, and audited across the entire document.

## Core principle

- Choose symbols that are meaningful, conventional, and easy to remember.
- Within the same local context, a base symbol should usually refer to one concept family.
- Typography alone does not automatically justify reuse. Reuse across typography families is allowed only when the convention is standard, explicitly introduced, and unlikely to cause confusion in the local context.

## Local context

- By default, the local context is the current subsection, derivation, or algorithm block.
- In long sections, the local context may be reset only if the new meaning is introduced explicitly and the previous meaning is no longer active.
- If there is any risk of confusion, choose a new base symbol instead of redefining an old one.

## Meaningful naming

- Prefer symbols that follow established CS/ML conventions.
- Use symbols that suggest the role of the object.
- Prefer:
  - `\boldsymbol{x}` for inputs or feature vectors
  - `\boldsymbol{X}` for data matrices
  - `\boldsymbol{W}` for weight matrices
  - `\boldsymbol{h}` for hidden states
  - `\boldsymbol{z}` for logits or pre-activations
  - `\boldsymbol{p}` for probability vectors
  - `\boldsymbol{\theta}` for trainable parameters
  - `\mathcal{D}` for datasets
  - `\mathcal{L}` for losses or objectives
  - `p` for probability densities or mass functions
  - `f`, `g` for functions or models
- Do not introduce arbitrary letters such as `A`, `B`, or `C` when a more meaningful conventional symbol is available.

## One base symbol, one concept family

- A base symbol should not be reused for unrelated objects in the same local context unless a standard, explicitly introduced convention makes the distinction genuinely clear.
- This restriction applies to:
  - scalars
  - vectors
  - matrices
  - tensors
  - sets
  - functions
  - operators
  - random variables
  - datasets
  - losses and objectives
- Examples of forbidden reuse:
  - `\boldsymbol{X}` for the data matrix and `X` for an unrelated random variable
  - `f` for the prediction function and `f` again for a feature index
  - `\boldsymbol{W}` for weights and `W` again for a sequence window size

## Allowed related reuse

- The same base symbol may be reused only when the meanings are clearly related.
- Allowed examples:
  - `X` for a random variable and `x` for one realization of `X`
  - `\boldsymbol{x}` for a vector and `x_j` for its j-th component
  - `\boldsymbol{W}` for a matrix and `(\boldsymbol{W})_{ij}` for its `(i,j)` entry
  - `f(x)` for a generic function and `f_{\boldsymbol{\theta}}(\boldsymbol{x})` for a parameterized version of that function
  - `\mathcal{X}` for a set and `x \in \mathcal{X}` for an element of that set
- If the relationship is not direct and obvious, use a different base symbol.

## Standard convention exceptions
- Some CS/ML conventions reuse a base symbol across typography families, such as `p` and `\boldsymbol{p}` for scalar and vector probability quantities.
- Allow such reuse only when the convention is standard, the distinction is introduced explicitly, and no clearer alternative is preferable in the same local context.

## Variants and modifiers

- For related variants of the same concept, prefer semantic subscripts, superscripts, or decorations instead of changing to a conflicting base symbol.
- Prefer:
  - `\mathcal{L}_{\text{train}}`, `\mathcal{L}_{\text{test}}`
  - `\boldsymbol{W}_{\text{in}}`, `\boldsymbol{W}_{\text{out}}`
  - `\boldsymbol{h}^{(\ell)}`, `\boldsymbol{h}^{(\ell+1)}`
  - `p_{\text{data}}`, `p_{\boldsymbol{\theta}}`
- Use `\text{...}` in semantic subscripts:
  - write `\boldsymbol{W}_{\text{cls}}`
  - not `\boldsymbol{W}_{cls}`

## When a symbol is already taken

- If a conventional symbol is already in use, choose a nearby but distinct alternative.
- Examples:
  - if `\boldsymbol{X}` is the data matrix, use `Z` or `U` for a random variable or latent state
  - if `f` is the model, use `\phi` or `\psi` for feature maps or auxiliary transforms
- Do not force reuse just because the letter is standard in another paper.

## Agent behavior

- Prefer meaningful and conventional symbols.
- Check whether a base symbol is already active in the current local context.
- Avoid reusing symbols across unrelated object types.
- Define every new symbol on first use.
- State the role and shape or domain of important objects when introduced.
- When support is uncertain, avoid package-dependent commands, custom macros, advanced equation references, and nonstandard environments unless they are confirmed locally.

## Audit checks

- Flag same base symbols reused for unrelated meanings.
- Flag same base symbols reused across unrelated object types.
- Flag arbitrary symbols used where a standard meaningful symbol would be clearer.
- Flag symbol redefinition without explicit notice.
- Flag conflicting uses such as:
  - `\boldsymbol{X}` as data matrix and `X` as unrelated random variable
  - `f` as both model and scalar feature
  - `\mathcal{L}` as loss and `L` as number of layers in the same derivation


# Variable

## Scalar

- Use lowercase italic for scalar variables: `x`, `y`, `z`, `a`, `b`, `\alpha`, `\beta`, `\lambda`, `\eta`.
- Use hats for estimates or predictions: `\hat{y}`, `\hat{\theta}`, `\hat{p}`.
- Use bars for averages or pooled quantities: `\bar{x}`, `\bar{\boldsymbol{h}}`.
- Use stars for optimal values: `x^*`, `\theta^*`, `\boldsymbol{w}^*`.

## Vectors

- Use bold lowercase for vectors: `\boldsymbol{x}`, `\boldsymbol{h}`, `\boldsymbol{g}`, `\boldsymbol{\mu}`.
- State the shape or domain on first use if applicable, e.g. `\boldsymbol{x} \in \mathbb{R}^d`.
- Do not mix `\vec{x}`, `\mathbf{x}`, `\bm{x}`, and `\boldsymbol{x}` in the same document.

## Matrices

- Use bold uppercase for matrices: `\boldsymbol{X}`, `\boldsymbol{W}`, `\boldsymbol{A}`, `\boldsymbol{\Sigma}`.
- State the shape on first use if applicable, e.g. `\boldsymbol{W} \in \mathbb{R}^{m \times d}`.

## Tensors

- Use bold uppercase for tensors, e.g. `\boldsymbol{T}`.
- State tensor order and shape explicitly in prose or notation if applicable, e.g.
  `\boldsymbol{T} \in \mathbb{R}^{n \times S \times d}` is a third-order tensor.
- Do not rely on more decorative tensor styles unless the whole site uses them consistently.

## Sets, spaces, and collections

- Use calligraphic uppercase for sets and collections: `\mathcal{D}`, `\mathcal{X}`, `\mathcal{Y}`, `\mathcal{B}`, `\mathcal{H}`.
- Use blackboard bold for number systems and spaces: `\mathbb{R}`, `\mathbb{N}`, `\mathbb{Z}`, `\mathbb{C}`.

## Functions and models

- Use italic lowercase for functions and maps: `f`, `g`.
- Use a plain function such as `f(x)` when no parameters need to be shown.
- Use a parameterized model as `f_{\boldsymbol{\theta}}(\boldsymbol{x})` or `f(\boldsymbol{x}; \boldsymbol{\theta})` when the dependence on learnable parameters matters.
- Use upright operator names for named transforms or procedures: `\operatorname{softmax}`, `\operatorname{diag}`, `\operatorname{rank}`.

## Random variables and realizations

- Use uppercase italic for scalar random variables: `X`, `Y`.
- Use lowercase italic for scalar realizations: `x`, `y`.
- Use bold lowercase for observed vectors: `\boldsymbol{x}`, `\boldsymbol{y}`.


## Index and dimension conventions

Use the following symbols by default unless a topic strongly requires something else.

### Sizes and dimensions

- `n`: number of samples or training examples
- `d`: input or feature dimension
- `m`: output dimension
- `C`: number of classes
- `V`: vocabulary size by default; if attention notation uses `\boldsymbol{V}` in the same local context, use `N_{\text{vocab}}` instead
- `S`: sequence length
- `L`: number of layers

### Indices

- `i`: sample index
- `j`: feature or component index
- `t`: time step or token position
- `s`: second sequence position, often used with attention or pairwise sequence terms
- `\ell`: layer index
- `k`: optimization step or iteration index
- `c`: class index

### Policy

- Use `i` for samples and keep it that way throughout the section.
- Use `t` for time or token position and do not reuse it for temperature or threshold in the same local scope.
- Use `\ell` for layers instead of `l` to avoid confusion with the number `1`.
- Use `\tau` for temperature to avoid conflict with `S` for sequence length and with other common uses of `T`.
- State dimensions explicitly on first introduction of the main objects.


# Linear algebra conventions

- Treat vectors as column vectors by default unless stated otherwise.

## Shapes

- State shapes when first introducing vectors, matrices, and tensors.
- Restate shapes near an equation when dimensional consistency is important to the derivation.
- If a dimension is not obvious from context, make it explicit.

## Vector orientation

- Treat `\boldsymbol{x}` as a column vector by default.
- Use `\boldsymbol{x}^\top` only when a row vector is explicitly needed.
- Do not switch between row-vector and column-vector interpretations without saying so.

## Entries, rows, and columns

- Use `x_j` for the `j`-th component of a vector.
- For an ordinary matrix over scalars, use `(\boldsymbol{W})_{ij}` for the `(i,j)` scalar entry when entry-level notation is needed.
- By default, vector components and matrix entries are assumed to be scalars.
- If a vector or matrix is block-structured and an indexed component or entry is itself a vector or matrix, state that explicitly and use block notation consistently.
- Use `\boldsymbol{X}_{i,:}` and `\boldsymbol{X}_{:,j}` only when row-column indexing is necessary.
- If rows and columns have semantic roles, state them explicitly.

## Multiplication and products

- Use juxtaposition for matrix-vector and matrix-matrix multiplication: `\boldsymbol{W}\boldsymbol{x}`.
- Use parentheses when needed to make grouping and precedence clear.
- Use `\odot` for elementwise multiplication: `\boldsymbol{x} \odot \boldsymbol{y}`.
- Use `\otimes` only for Kronecker products or tensor products when that is truly intended.
- Do not use the same notation for matrix multiplication and elementwise multiplication.

## Transpose, inverse, and pseudoinverse

- Use `^\top` for transpose.
- Use `^{-1}` for inverse.
- Use `^\dagger` for pseudoinverse.
- Use inverse notation only when the inverse is well defined or the intended meaning is stated clearly.

## Norms, absolute values, and inner products

- Use `\lVert \boldsymbol{x} \rVert_2` for the Euclidean norm.
- Use `\lVert \boldsymbol{W} \rVert_F` for the Frobenius norm.
- Use `\lvert x \rvert` for absolute value.
- Use `\langle \boldsymbol{x}, \boldsymbol{y} \rangle` for abstract inner products.
- Use `\boldsymbol{x}^\top \boldsymbol{y}` when the Euclidean coordinate form is specifically intended.
- Do not mix `|`, `\|`, `\lvert`, and `\lVert` inconsistently in the same post.

## Identity, zero objects, and operators

- Use `\boldsymbol{0}` for zero vectors or zero matrices when the shape is clear from context.
- Use `\boldsymbol{I}` for the identity matrix, and state its shape when it is not obvious.
- Use `\operatorname{diag}(\boldsymbol{x})` for a diagonal matrix constructed from a vector.
- Use `\operatorname{tr}(\boldsymbol{A})` for trace.
- Use `\operatorname{rank}(\boldsymbol{A})` for rank.
- Use `\det(\boldsymbol{A})` for determinant when determinant notation is needed.

## Concatenation

- Use `[ \boldsymbol{x} ; \boldsymbol{y} ]` for vertical concatenation only if needed and define it once before using it.
- Use horizontal concatenation notation only if it is defined explicitly and remains unambiguous.
- Prefer block-matrix notation when it is clearer than shorthand concatenation.

## Policy

- Keep linear algebra notation consistent across the whole post.
- When dimensions are important to the argument, make them explicit rather than leaving them implicit.
- If an operation could be interpreted in more than one way, rewrite it so the intended meaning is obvious.

## Audit checks

- Flag missing shapes when dimensional consistency matters.
- Flag ambiguous multiplication notation.
- Flag inconsistent norm, absolute value, or inner product delimiters.
- Flag undefined row, column, or entry notation.
- Flag inverse notation used without enough context to justify it.
- Flag block vectors or block matrices whose block structure is used without being stated explicitly.

# Sequence conventions

## Basic sequence notation

- Use `x_{1:S}` for a scalar sequence.
- Use `\boldsymbol{x}_{1:S}` for a vector-valued sequence.
- Use `w_{1:S}` for a sequence of discrete tokens or token IDs.
- Interpret `x_{1:S}`, `\boldsymbol{x}_{1:S}`, and `w_{1:S}` as sequences indexed from `1` through `S`, inclusive at both endpoints.
- Use `x_t` or `\boldsymbol{x}_t` for the element at position `t`.
- Use `S` for sequence length unless the user or source material specifies another convention.

## Sequence indices

- Use `t` for the primary sequence position.
- Use `s` for a second sequence position in pairwise or attention-style expressions.
- Use `r` as a dummy summation index when needed.
- Do not reuse `t` or `s` for unrelated meanings in the same local context.

## Variable-length sequences

- Use `S_i` for the length of the `i`-th sequence.
- Write the `i`-th scalar sequence as `x_{1:S_i}^{(i)}` when sample indexing is needed.
- Write the `i`-th vector-valued sequence as `\boldsymbol{x}_{1:S_i}^{(i)}` when sample indexing is needed.
- Keep the order of indices consistent within a post, e.g. prefer `\boldsymbol{x}_t^{(i)}` over mixing `\boldsymbol{x}_t^{(i)}` and `\boldsymbol{x}^{(i)}_t`.

## Hidden states and contextual representations

- Use `\boldsymbol{h}_t` for the hidden state or contextual representation at position `t`.
- Use `\bar{\boldsymbol{h}}` only for a pooled or aggregated sequence representation, and define the pooling operation when it is introduced.
- Use `\boldsymbol{h}_t^{(\ell)}` for the representation at position `t` in layer `\ell` when layer indexing is needed.
- Do not switch between `\boldsymbol{h}_t` and unrelated hidden-state symbols without explanation.

## Whole-sequence representations

- When vectors are treated as column vectors by default, represent a full sequence matrix consistently with that convention.
- Prefer `\boldsymbol{H} = [\boldsymbol{h}_1, \dots, \boldsymbol{h}_S] \in \mathbb{R}^{d \times S}` when columns correspond to sequence positions.
- If a row-major sequence matrix is used instead, state it explicitly and keep that convention consistent throughout the post.
- If the full sequence object is not represented as a matrix, define clearly whether it is a tuple, list, or ordered collection.

## Pairwise sequence quantities

- Use `e_{t,s}` for pairwise scores when the score from position `t` to position `s` is not yet normalized.
- Use `\alpha_{t,s}` for normalized pairwise weights such as attention weights.
- Define clearly what the first and second indices mean whenever pairwise notation is introduced.
- Use `\boldsymbol{A} \in \mathbb{R}^{S \times S}` for a pairwise weight or attention matrix only when the matrix interpretation is useful.

## Attention-specific notation

- Use `\boldsymbol{Q}`, `\boldsymbol{K}`, and `\boldsymbol{V}` when explicitly discussing attention mechanisms.
- State the shapes of `\boldsymbol{Q}`, `\boldsymbol{K}`, and `\boldsymbol{V}` on first use.
- If vocabulary size is needed in the same local context, rename it to `N_{\text{vocab}}` rather than reusing `V`.
- For self-attention over one sequence, keep the position indices and the sequence length tied to the same convention.
- For cross-attention or interactions between two sequences, define separate sequence lengths explicitly instead of overloading a single symbol.

## Policy

- Keep sequence length, sequence position, sample index, and layer index visually and semantically distinct.
- Define whether a sequence consists of scalars, tokens, embeddings, or hidden states on first use.
- If both element-level and whole-sequence notation are used, make their relationship explicit.
- Prefer consistent sequence notation across the whole post rather than switching between multiple conventions copied from different sources.

## Audit checks

- Flag inconsistent use of `S` and `T` for sequence length within the same post.
- Flag inconsistent ordering of sample and position indices.
- Flag undefined sequence length symbols.
- Flag pairwise notation whose index roles are not explained.
- Flag whole-sequence matrix shapes that conflict with the stated vector orientation.
