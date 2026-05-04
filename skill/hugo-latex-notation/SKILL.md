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

# Equation mode and delimiters

## Mode contract

- The caller chooses inline or display; this skill enforces notation and
  delimiters after that choice.
- Article math must be delimiter-complete: inline `$...$`, display `$$...$$` on
  its own lines.
- Bare LaTeX math is invalid in article prose or headings, except literal code or
  source text.
- Do not use `\(...\)` or `\[...\]` unless the user or Scriptor sets a different
  project delimiter policy.
- Wrap display environments in `$$...$$`; never output bare
  `\begin{...}...\end{...}` as article math.

## Inline/display policy

- Inline math must be short, simple, and grammatical, e.g. `$x$`,
  `$\mathcal{L}$`, `$O(n)$`, or `$f_{\boldsymbol{\theta}}$`.
- Use display math for standalone or complex expressions: chained relations,
  derivations, fractions, sums, products, integrals, limits, `\argmax`,
  `\argmin`, matrices, cases, alignment, long/nested indices, or dense notation.
- Headings may contain only short, simple inline math. Move display math and
  complex formulas into body prose with `$$...$$`.
- Escape or rewrite plain dollar signs outside math when Markdown/rendering
  requires it.
- Use only display environments confirmed by the active renderer.

## Audit checks

- Flag missing `$...$` or `$$...$$` delimiters around article math.
- Flag bare LaTeX math outside literal code/source text.
- Flag `\(...\)`, `\[...\]`, or bare display environments under the default
  `$...$` / `$$...$$` policy.
- Flag display environments whose renderer support is not confirmed locally.
- Flag long or dense inline expressions that should be rewritten as display math.
- Flag trivial display equations that should be inline instead.
- Flag display math or complex formulas in Markdown headings.
- Flag displayed equations that are not integrated into the surrounding prose.

# Equation writing

This section governs how displayed equations are structured, explained, referenced, and audited after the equation mode and delimiters have been chosen.

## Layout and alignment

- Use a single displayed equation for one mathematical statement, definition, or result.
- Use a multi-line aligned display for derivations, chains of equalities or inequalities, or expressions that require multiple logical steps.
- Use only environments that are confirmed to be supported by the local Hugo math setup.
- If local support for alignment environments is unclear, prefer a simpler locally confirmed display structure rather than relying on unverified environments.
- Align related lines on the main relation symbol, usually `=`, `\le`, `\ge`, `\approx`, or `\Rightarrow`.
- Keep one logical transformation per line in a derivation.
- Do not use alignment merely to wrap a long line; each new line should represent a meaningful step.
- If a derivation contains several conceptual phases, split it into multiple displayed equations instead of one oversized block.
- Use piecewise notation for piecewise definitions only when the required environment is supported locally.
- Use matrix environments only when the matrix itself is part of the mathematical content rather than just a formatting convenience.
- Keep spacing, indentation, and alignment style consistent across the whole post.

## References and numbering

- Number equations only when the local Hugo setup supports numbering or referencing and the equation will actually be referenced later.
- If numbering or equation references are not clearly supported locally, prefer unnumbered display math.
- Do not assume that `\label`, `\ref`, or `\eqref` are available in every Hugo setup.
- If labels are supported locally, use a consistent and descriptive label style.
- Do not number every displayed equation by default.
- If an equation is important enough to reference later, ensure that the surrounding prose makes that role clear.
- Integrate equation references grammatically into the sentence rather than treating them as detached metadata.

## Prose and symbol explanation

- Introduce every nontrivial displayed equation with a lead-in sentence or phrase.
- Follow important displayed equations with a brief explanation of what they state, compute, or imply.
- Define newly introduced symbols before or immediately after the equation.
- When several symbols are introduced together, prefer a short explanatory clause or sentence rather than leaving them implicit.
- Do not drop a displayed equation into the text without context.
- Treat displayed equations as part of the surrounding prose and punctuate them when needed.
- If a derivation contains a non-obvious step, explain the reason for that step in prose.
- Prefer explaining the role or meaning of an equation rather than merely restating its symbols in words.

## Audit checks

- Flag displayed equations that are introduced without prose.
- Flag newly introduced symbols that are not defined nearby.
- Flag long derivations written as a single unstructured display when a multi-step layout is needed.
- Flag aligned derivations whose lines are not aligned on a meaningful relation symbol.
- Flag displays that compress multiple logical transformations into one line.
- Flag numbering, labels, or equation references whose local support is not confirmed.
- Flag numbered equations that are never referenced later when numbering is used.
- Flag use of display environments whose local support is not confirmed.
- Flag displayed equations that are too dense and should be split into smaller units.

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

- Some CS/ML conventions reuse a base symbol across typography families, such as `p` and `\boldsymbol{p}` for scalar and vector probability quantities, or `w_t` and `\boldsymbol{W}` for token symbols and weight matrices.
- Allow such reuse only when the convention is standard, the distinction is introduced explicitly, and no clearer alternative is preferable in the same local context.
- If confusion is likely, rename the less central symbol, e.g. use `N_{\text{vocab}}` instead of `V`.

## Variants and modifiers

- For related variants of the same concept, prefer semantic subscripts, superscripts, or decorations instead of changing to a conflicting base symbol.
- Prefer:
  - `\mathcal{L}_{\text{train}}`, `\mathcal{L}_{\text{test}}`
  - `\boldsymbol{W}_{\text{in}}`, `\boldsymbol{W}_{\text{out}}`
  - `\boldsymbol{h}^{(\ell)}`, `\boldsymbol{h}^{(\ell+1)}`
  - `p_{\text{data}}`, `p_{\boldsymbol{\theta}}`
- For semantic labels, follow `# Subscript / superscript policy` and use `\text{...}` consistently.

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
  - `\mathcal{L}` as loss and `L` as an unrelated scalar in the same derivation

# Variable

## Scalar
- Use lowercase italic for scalar variables: `x`, `y`, `z`, `a`, `b`, `\alpha`, `\beta`, `\lambda`, `\eta`.
- Use hats for scalar estimates or predictions, e.g. `\hat{y}`, `\hat{p}`.
- If a parameter is genuinely scalar rather than a parameter collection, scalar forms such as `\hat{\theta}` or `\theta^*` are allowed.

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

- For detailed probability notation, follow `# Probability and statistics conventions`.
- By default, use uppercase italic for scalar random variables, lowercase italic for scalar realizations, and bold lowercase for observed vectors when vector observations are needed.
- Keep random-variable notation distinct from observed data notation and data-matrix notation.

## Index and dimension conventions

Use the following symbols by default unless a topic strongly requires something else.

### Sizes and dimensions

- `n`: number of samples or training examples
- `d`: input or feature dimension
- `m`: output dimension
- `C`: number of classes
- `V`: vocabulary size by default; if attention notation uses `\boldsymbol{V}` in the same local context, use `N_{\text{vocab}}` instead
- `S`: sequence length
- `N_{\text{layers}}`: number of layers

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

# Subscript / superscript policy

## Subscripts

- Use subscripts for components and entries, e.g. `x_j`, `(\boldsymbol{W})_{ij}`.
- Use subscripts for ordered positions or steps, e.g. `\boldsymbol{h}_t`, `\eta_k`, `\boldsymbol{\theta}_k`.
- Use subscripts for semantic labels, e.g. `\mathcal{L}_{\text{train}}`, `\boldsymbol{W}_{\text{class}}`.
- Use `\text{...}` for semantic labels and multi-character textual labels.
- Do not use subscripts for meanings that should be written as superscript labels, such as sample indices or layer labels.

## Superscripts

- Use superscripts for sample labels, e.g. `\boldsymbol{x}^{(i)}`.
- Use superscripts for layer labels, e.g. `\boldsymbol{W}^{(\ell)}`.
- Use superscripts for powers and exponents, e.g. `x^2`, `\sigma^2`.
- Use structural superscripts such as `^\top`, `^{-1}`, and `^\dagger` for transpose, inverse, and pseudoinverse.
- Use parenthesized superscripts for labels, e.g. `^{(i)}`, `^{(\ell)}`.
- Use plain superscripts for arithmetic powers, e.g. `x^2`, not `x^{(2)}`.
- Do not use superscripts for ordered optimization steps by default; prefer `\boldsymbol{\theta}_k` over `\boldsymbol{\theta}^{(k)}` when `k` denotes a step in a sequence of iterates.

## Combined subscripts and superscripts

- When both are needed, keep their roles distinct and their order consistent.
- Prefer positional or semantic information in the subscript and sample or layer labels in the superscript.
- Prefer `\boldsymbol{x}_t^{(i)}` over `\boldsymbol{x}^{(i)}_t`, and keep that order consistent throughout the post.
- Use the same convention for related quantities, e.g. `\boldsymbol{h}_t^{(\ell)}`, `\boldsymbol{z}_t^{(\ell)}`, and `\boldsymbol{p}_t^{(i)}`.

## Decorations

- Use hats for estimates or predictions, e.g. `\hat{y}`, `\hat{p}`, `\hat{\boldsymbol{\theta}}`.
- Use bars for averages, pooled quantities, or mean values, e.g. `\bar{x}`, `\bar{\boldsymbol{h}}`.
- Use stars for optimal values, e.g. `x^*`, `\boldsymbol{\theta}^*`, `\boldsymbol{w}^*`.
- Define the meaning of each decoration on first use when it is not already obvious from context.
- Keep decoration meanings consistent across the whole post.

## Policy

- Keep the role of each subscript and superscript consistent across the whole post.
- Use subscripts for ordered indexing and semantic labeling by default.
- Use superscripts for labels, powers, and structural operations by default.
- Use braces whenever a subscript or superscript contains more than one token or includes formatting commands.
- Avoid code-like identifiers such as `h_class`, `Wl`, or `theta_k_step` in mathematical notation.

## Avoid

- `h_class` instead of `\boldsymbol{h}_{\text{class}}`
- `W_l` when `\boldsymbol{W}^{(\ell)}` is intended as a layer label
- `\boldsymbol{\theta}^{(k)}` when `k` is an optimization step and `\boldsymbol{\theta}_k` is the intended iterate
- mixed ordering such as `\boldsymbol{x}_t^{(i)}` in one place and `\boldsymbol{x}^{(i)}_t` in another
- using the same superscript style for both labels and arithmetic powers in the same local context

## Audit checks

- Flag semantic labels written without `\text{...}`.
- Flag inconsistent use of subscripts and superscripts for the same role.
- Flag inconsistent ordering of positional and sample or layer indices.
- Flag ambiguous superscripts that could be read as either labels or powers.
- Flag unreadable stacked decorations or index structures.
- Flag code-like identifier patterns that should be rewritten in mathematical notation.


# Probability and statistics conventions

## Events and probabilities
- Use uppercase italic letters such as `A` and `B` for events when event notation is needed.
- Use `\mathbb{P}(A)` for the probability of an event `A`.
- Use `\mathbb{P}(A \mid B)` for conditional probability of an event.
- Use `\mid` for conditioning in probabilities, densities, and expectations; do not use a plain `|` for conditional notation.
- Keep event notation distinct from random-variable notation.

## Probability functions and distributions

- Use lowercase `p` for a probability mass function, probability density, model distribution, or other distribution-dependent scalar quantity when the meaning is clear from context.
- Use forms such as `p(x)`, `p(y \mid \boldsymbol{x})`, or `p(y \mid \boldsymbol{x}; \boldsymbol{\theta})` when conditioning or parameter dependence matters.
- If several distributions appear in the same local context, distinguish them with semantic subscripts or parameter notation, e.g. `p_{\text{data}}(x)` and `p_{\boldsymbol{\theta}}(x)`.
- Use `p(y \mid \boldsymbol{x}; \boldsymbol{\theta})` when the object is a model conditional distribution with explicit parameters.
- When `\boldsymbol{p}` denotes a probability vector, use `p_c` for its `c`-th component.
- Define clearly whether `p` denotes a probability mass function, density, model distribution, empirical estimate, or posterior-like quantity.

## Named distributions

- Use `\sim` for distribution statements, e.g. `X \sim \mathcal{N}(\mu, \sigma^2)`.
- Use named distributions in upright operator style when appropriate, e.g. `\operatorname{Bernoulli}`, `\operatorname{Categorical}`, and similar family names.
- Use `\mathcal{N}(\mu, \sigma^2)` for a Gaussian or normal distribution.
- If distribution parameters have roles such as mean, variance, concentration, or scale, define them on first use.

## Random variables, realizations, and samples

- Use uppercase italic for scalar random variables, e.g. `X`, `Y`, `Z`.
- Use lowercase italic for scalar realizations, e.g. `x`, `y`, `z`.
- Use `x^{(i)}` for the `i`-th observed scalar sample when sample indexing is needed.
- Use `\boldsymbol{x}^{(i)}` for the `i`-th observed vector sample.
- If random vectors are needed, introduce them explicitly and keep the notation distinct from observed vectors and data matrices.
- If `\boldsymbol{X}` already denotes a data matrix, avoid also using `X` or `\boldsymbol{X}` for another unrelated random object in the same local context.
- If a random vector is needed near a data matrix `\boldsymbol{X}`, prefer a different base symbol and define it explicitly.

## Conditioning and independence

- Use `\mathbb{P}(A \mid B)` for conditional event probabilities.
- Use `p(y \mid \boldsymbol{x})` or `p(y \mid \boldsymbol{x}; \boldsymbol{\theta})` for conditional distributions.
- Use `\mathbb{E}[X \mid Y]` for conditional expectation.
- Use `X \perp Y` for independence when independence notation is needed.
- Use `X \perp Y \mid Z` for conditional independence when that distinction matters.
- Define clearly what is being conditioned on whenever conditional notation is introduced.

## Expectations and statistical operators

- Use `\mathbb{E}[X]` for expectation.
- Use `\mathbb{E}[f(X)]` for the expectation of a transformed random variable.
- Use subscripted expectation notation such as `\mathbb{E}_{X \sim p}[f(X)]` when the underlying distribution must be explicit.
- Use `\operatorname{Var}(X)` for variance.
- Use `\operatorname{Cov}(X, Y)` for covariance.
- Use upright operator style consistently for statistical operators such as `\operatorname{Var}` and `\operatorname{Cov}`.
- If correlation notation is needed, use an upright operator form such as `\operatorname{Corr}(X, Y)` and define it explicitly.

## Means, variances, and covariance

- Use `\mu` for a scalar mean.
- Use `\sigma^2` for a scalar variance.
- Use `\boldsymbol{\mu}` for a vector mean.
- Use `\boldsymbol{\Sigma}` for a covariance matrix.
- State clearly whether a quantity is scalar, vector-valued, or matrix-valued when that is not obvious from context.
- If a variance, covariance, or mean is estimated rather than population-level, mark that distinction explicitly.

## Empirical and estimated quantities

- Use `\bar{x}` for a scalar sample mean.
- Use `\bar{\boldsymbol{x}}` for a vector sample mean.
- Use `\hat{p}` for an estimated probability when a scalar estimate is intended.
- Use hats for estimated statistics, e.g. `\hat{\mu}` and `\hat{\boldsymbol{\Sigma}}`.
- Distinguish empirical quantities from population quantities when both appear in the same discussion.
- If both a distribution and its estimate appear locally, make the distinction explicit rather than relying on context alone.

## Probability notation in CS and ML writing

- Keep probability notation distinct from optimization notation and loss notation.
- Do not use `\mathcal{L}` for both loss and likelihood in the same local context.
- If likelihood notation is needed, prefer expressing it through the probability model directly, e.g. `p(x; \boldsymbol{\theta})` or `p_{\boldsymbol{\theta}}(x)`, unless a separate likelihood symbol is defined explicitly.
- Keep model distributions, empirical distributions, and posterior-like quantities visually distinct, e.g. `p_{\text{data}}`, `p_{\boldsymbol{\theta}}`, and other clearly labeled forms.
- If the same section uses both probability vectors and probability functions, define the distinction explicitly between `\boldsymbol{p}` and `p(\cdot)`.

## Policy

- Keep probability notation, statistical notation, and data notation semantically distinct.
- Define whether a symbol denotes a random variable, realization, sample, parameter, or statistic on first use.
- Define whether a probability expression is unconditional, conditional, parameterized, empirical, or estimated when that distinction matters.
- Keep scalar, vector, and matrix statistical quantities visually distinct.
- If notation from a source paper conflicts with this house style, follow the user or source convention only if the distinction remains explicit and consistent locally.

## Audit checks
- Flag ambiguous uses of `p` whose meaning is not clear from context.
- Flag inconsistent use of random variables, realizations, and samples.
- Flag undefined conditioning variables or parameters in conditional probabilities or expectations.
- Flag use of plain `|` instead of `\mid` for conditional probability, density, or expectation notation.
- Flag covariance, variance, expectation, or correlation notation written inconsistently with the house operator style.
- Flag reuse of data-matrix symbols as unrelated random objects in the same local context.
- Flag probability-vector notation and probability-function notation that are used together without an explicit distinction.
- Flag likelihood notation that conflicts with the established use of `\mathcal{L}` for loss or objective notation.
- Flag empirical and population quantities that are not clearly distinguished when both are present.
