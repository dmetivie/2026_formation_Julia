# FrejusJuliaNeuralNetworks0

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://dmetivie.github.io/FrejusJuliaNeuralNetworks0.jl/stable)
[![Development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://dmetivie.github.io/FrejusJuliaNeuralNetworks0.jl/dev)
[![Test workflow status](https://github.com/dmetivie/FrejusJuliaNeuralNetworks0.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/dmetivie/FrejusJuliaNeuralNetworks0.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/dmetivie/FrejusJuliaNeuralNetworks0.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/dmetivie/FrejusJuliaNeuralNetworks0.jl)
[![Docs workflow Status](https://github.com/dmetivie/FrejusJuliaNeuralNetworks0.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/dmetivie/FrejusJuliaNeuralNetworks0.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![BestieTemplate](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/main/docs/src/assets/badge.json)](https://github.com/JuliaBesties/BestieTemplate.jl)


> Teaching package — ANF Julia pour le HPC, Fréjus.
> A multi-layer perceptron in ~100 lines of Julia.

**What you build:** dense layers (affine + activation), chains (composition), and the glue to convert between a model and a flat parameter vector.

## The two halves

**Part 1: Layers** — a `Dense` layer computes
$$x \longmapsto \sigma.(W x + b)$$
and a `Chain` stacks them. Both are callable (you call them like functions).

**Part 2: Flat parameters** — optimisers want $\theta \in \mathbb{R}^n$, but your model is a struct of matrices. You need:
- `parameters(model)` → flatten to a vector (for the optimiser)
- `rebuild(model, θ)` → unflatten back to matrices (to run the network)

Once `rebuild` exists, the optimiser never touches your model directly — it works on the flat vector.

## Starter code

```julia
struct Dense{M, V, F}
    W::M           # weights, shape (nout, nin)
    b::V           # bias, shape (nout,)
    σ::F           # activation function
end

# Make a Dense layer callable
(layer::Dense)(x) = layer.σ.(layer.W * x .+ layer.b)

struct Chain{L <: Tuple}
    layers::L
end

# Chain composition: apply each layer in sequence
(NNet::Chain)(x) = foldl((y, f) -> f(y), NNet.layers; init = x)
```

That is the hard part. The rest is:
1. Write `nparams(model)` — count parameters
2. Write `parameters(model)` — stack all W's and b's into one vector
3. Write `rebuild(model, θ)` — pull them back out and reconstruct the struct

## Why it matters

**No type hardcoding.** `Dense{M,V,F}` leaves array types free. Feed it `Float32`, `Rational`, or `Dual` numbers — the same forward pass works unchanged. That is why the optimiser, which knows nothing about dual numbers, can differentiate through this code anyway.

**Callable objects.** A layer *is* a function, so you call it like `layer(x)`, not `forward(layer, x)`. Clean Julia idiom.

## Layout of the package

| Path | Content |
| --- | --- |
| `src/FrejusJuliaNeuralNetworks0.jl` | layers, chain, flatten/unflatten |
| `test/test-layers.jl` | forward pass, shapes, initialisation |
| `test/test-parameters.jl` | `nparams`, `parameters`, `rebuild` |
| `docs/` | Documenter.jl site |

Tests use [TestItems.jl](https://github.com/julia-vscode/TestItems.jl): each `@testitem` is independently runnable from the VS Code test explorer.
