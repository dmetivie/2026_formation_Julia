```@meta
CurrentModule = FrejusJuliaNeuralNetworks0
```

# FrejusJuliaNeuralNetworks0

Documentation for [FrejusJuliaNeuralNetworks0](https://github.com/dmetivie/FrejusJuliaNeuralNetworks0.jl):
a minimal multi-layer perceptron.

## The model

A [`Dense`](@ref) layer is

```math
x \longmapsto \sigma.(W x + b),
```

and a [`Chain`](@ref) composes several of them.

```@example nn
using FrejusJuliaNeuralNetworks0, Random

model = Chain(Dense(2 => 5, tanh; rng = Xoshiro(1)), Dense(5 => 2, identity; rng = Xoshiro(2)))
```

```@example nn
model([1.0, 2.0])
```

## From a model to a vector of unknowns

An optimiser minimises over ``\mathbb{R}^n``; it has no notion of a layer. The
pair [`parameters`](@ref) / [`rebuild`](@ref) translates between the two views.

```@example nn
θ = parameters(model)
length(θ), nparams(model)
```

```@example nn
rebuild(model, θ)([1.0, 2.0]) == model([1.0, 2.0])
```

So the function an optimiser actually sees is

```@example nn
predict(θ, x) = rebuild(model, θ)(x)
predict(θ, [1.0, 2.0])
```

a perfectly ordinary function of a vector — which is also, conveniently, a
function an automatic differentiation package can handle.

The full list of functions is in the [Reference](@ref reference) page.
