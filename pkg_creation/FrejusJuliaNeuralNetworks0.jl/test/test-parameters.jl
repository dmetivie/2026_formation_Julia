@testsnippet SmallNet begin
    using Random
    net = Chain(Dense(2 => 4, tanh; rng = Xoshiro(0)), Dense(4 => 3, identity; rng = Xoshiro(1)))
    x = [0.3, -0.7]
end

@testitem "nparams counts weights and biases" tags = [:unit] setup = [SmallNet] begin
    @test nparams(Dense(2 => 4, tanh)) == 4 * 2 + 4
    @test nparams(net) == (4 * 2 + 4) + (3 * 4 + 3)
    @test nparams(net) == length(parameters(net))
end

@testitem "parameters / rebuild round trip" tags = [:unit] setup = [SmallNet] begin
    θ = parameters(net)
    @test rebuild(net, θ)(x) == net(x)          # same model, same answer
    @test parameters(rebuild(net, θ)) == θ      # flatten ∘ rebuild = identity
end

@testitem "rebuild really installs the given numbers" tags = [:unit] begin
    # layout: W (column-major), then b, layer by layer
    template = Dense(2 => 1, identity)
    layer = rebuild(template, [10.0, 20.0, 30.0])
    @test layer.W == [10.0 20.0]
    @test layer.b == [30.0]
    @test layer([1.0, 1.0]) == [60.0]
end

@testitem "rebuild keeps the activation functions" tags = [:unit] setup = [SmallNet] begin
    other = rebuild(net, zeros(nparams(net)))
    @test other.layers[1].σ === tanh
    @test other.layers[2].σ === identity
    @test other(x) == zeros(3)                  # all weights zero -> zero output
end

@testitem "rebuild checks the length" tags = [:unit, :validation] setup = [SmallNet] begin
    @test_throws DimensionMismatch rebuild(net, [1.0, 2.0])
    @test_throws DimensionMismatch rebuild(net, zeros(nparams(net) + 1))
end

@testitem "θ -> rebuild(model, θ)(x) is a plain function of a vector" tags = [:unit] setup = [SmallNet] begin
    # This is the view an optimiser needs: Rⁿ -> Rᵐ, nothing else.
    f(θ) = rebuild(net, θ)(x)
    θ = parameters(net)
    @test f(θ) == net(x)
    @test f(θ) != f(θ .+ 1)
end
