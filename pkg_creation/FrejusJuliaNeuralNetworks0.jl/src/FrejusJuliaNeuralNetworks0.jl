"""
    FrejusJuliaNeuralNetworks0

A minimal feed-forward neural network: one layer type, one container, and the
two functions that convert a model to and from a flat parameter vector.

A [`Dense`](@ref) layer is the map

```math
x ↦ σ.(W x + b)
```

and a [`Chain`](@ref) applies several of them in a row. That is all a
multi-layer perceptron is.

Optimisers want a single vector of unknowns, not a nest of matrices, so
[`parameters`](@ref) flattens a model into a `Vector` and [`rebuild`](@ref)
puts a model back together from one. Training is then an ordinary
optimisation problem over `Rⁿ`.

# Example

```jldoctest
julia> using FrejusJuliaNeuralNetworks0

julia> model = Chain(Dense(2 => 5, tanh), Dense(5 => 2, identity))
Chain(Dense(2 => 5, tanh), Dense(5 => 2, identity))

julia> nparams(model)
27

julia> length(model([1.0, 2.0]))
2
```
"""
module FrejusJuliaNeuralNetworks0

using Random: AbstractRNG, default_rng

export Dense, Chain, glorot
export nparams, parameters, rebuild

# ---------------------------------------------------------------------------
# Layers
# ---------------------------------------------------------------------------

"""
    Dense(W, b, σ)
    Dense(nin => nout, σ = tanh; rng = Random.default_rng())

A fully connected layer `x -> σ.(W * x + b)`, with `W` of size `nout × nin`.

The layer is *callable*: `layer(x)` evaluates it. Weights are initialised with
[`glorot`](@ref) and biases with zeros.

Note that the types of `W` and `b` are left free (`M` and `V` type parameters).
A `Dense` can therefore hold dual numbers, `Float32`, GPU arrays… without this
file knowing anything about them.

# Example

```jldoctest
julia> layer = Dense([1.0 0.0; 0.0 1.0], [0.0, 0.0], identity);

julia> layer([2.0, 3.0])
2-element Vector{Float64}:
 2.0
 3.0
```
"""
struct Dense{M <: AbstractMatrix, V <: AbstractVector, F}
    W::M
    b::V
    σ::F
end

function Dense(dims::Pair{<:Integer, <:Integer}, σ = tanh; rng::AbstractRNG = default_rng())
    nin, nout = dims
    return Dense(glorot(rng, nout, nin), zeros(nout), σ)
end

# This single line is the forward pass of a layer.
(layer::Dense)(x) = layer.σ.(layer.W * x .+ layer.b)

"""
    Chain(layers...)

Compose layers: `Chain(f, g)(x)` is `g(f(x))`.

# Example

```jldoctest
julia> net = Chain(Dense(1 => 3, tanh), Dense(3 => 1, identity));

julia> size(net([0.5]))
(1,)
```
"""
struct Chain{L <: Tuple}
    layers::L
end

Chain(layers...) = Chain(layers)

# `foldl` threads the input through the layers, left to right.
(net::Chain)(x) = foldl((y, layer) -> layer(y), net.layers; init = x)

"""
    glorot([rng], nout, nin)

Glorot (Xavier) normal initialisation: entries drawn from a centred Gaussian of
variance `2 / (nin + nout)`, which keeps the signal variance roughly constant
from layer to layer.
"""
glorot(rng::AbstractRNG, nout::Integer, nin::Integer) = randn(rng, nout, nin) .* sqrt(2 / (nin + nout))
glorot(nout::Integer, nin::Integer) = glorot(default_rng(), nout, nin)

# ---------------------------------------------------------------------------
# Flat parameter vector <-> model
#
# An optimiser works on a point of Rⁿ. A model is a tuple of matrices and
# vectors. These three functions are the dictionary between the two views.
# ---------------------------------------------------------------------------

"""
    nparams(model)

Total number of trainable parameters (weights + biases).
"""
nparams(layer::Dense) = length(layer.W) + length(layer.b)
nparams(net::Chain) = sum(nparams, net.layers)

"""
    parameters(model)

Flatten every weight and bias of `model` into a single vector, weights first,
layer by layer. Inverse of [`rebuild`](@ref).
"""
parameters(layer::Dense) = vcat(vec(layer.W), layer.b)
parameters(net::Chain) = reduce(vcat, parameters(layer) for layer in net.layers)

"""
    rebuild(model, θ)

Copy of `model` whose parameters are read off the flat vector `θ`, in the order
used by [`parameters`](@ref). The activation functions and the shapes come from
`model`, the numbers from `θ`:

```julia
rebuild(model, parameters(model))   # same model again
```

This is the hinge between the network and the optimiser: `θ -> rebuild(model, θ)`
turns "a network" into "a function of a vector of unknowns", which is something
an optimiser (and an AD system) can chew on.
"""
function rebuild(model, θ::AbstractVector)
    length(θ) == nparams(model) ||
        throw(DimensionMismatch("model needs $(nparams(model)) parameters, got $(length(θ))"))
    new_model, _ = _rebuild(model, θ, firstindex(θ))
    return new_model
end

# Each `_rebuild` consumes its slice of θ and returns where the next one starts.
function _rebuild(layer::Dense, θ, i)
    nout, nin = size(layer.W)
    W = reshape(θ[i:(i + nout * nin - 1)], nout, nin)
    i += nout * nin
    b = θ[i:(i + nout - 1)]
    i += nout
    return Dense(W, b, layer.σ), i
end

function _rebuild(net::Chain, θ, i)
    layers = ()
    for layer in net.layers
        new_layer, i = _rebuild(layer, θ, i)
        layers = (layers..., new_layer)
    end
    return Chain(layers), i
end

# ---------------------------------------------------------------------------
# Pretty printing
# ---------------------------------------------------------------------------

Base.show(io::IO, layer::Dense) =
    print(io, "Dense(", size(layer.W, 2), " => ", size(layer.W, 1), ", ", layer.σ, ")")

function Base.show(io::IO, net::Chain)
    print(io, "Chain(")
    join(io, net.layers, ", ")
    return print(io, ")")
end

end
