@testitem "Dense: forward pass by hand" tags = [:unit] begin
    # identity weights, zero bias, no activation: the layer is the identity
    layer = Dense([1.0 0.0; 0.0 1.0], [0.0, 0.0], identity)
    @test layer([2.0, 3.0]) == [2.0, 3.0]

    # W x + b, with a known activation
    layer = Dense([1.0 2.0], [1.0], identity)
    @test layer([3.0, 4.0]) == [12.0]            # 1*3 + 2*4 + 1

    layer = Dense([1.0 2.0], [1.0], tanh)
    @test layer([3.0, 4.0]) == [tanh(12.0)]
end

@testitem "Dense: shapes from the `nin => nout` constructor" tags = [:unit] begin
    layer = Dense(3 => 7, tanh)
    @test size(layer.W) == (7, 3)
    @test size(layer.b) == (7,)
    @test length(layer([1.0, 2.0, 3.0])) == 7
    @test all(iszero, layer.b)                   # biases start at zero
end

@testitem "Chain: composition order" tags = [:unit] begin
    double = Dense([2.0;;], [0.0], identity)
    plus_one = Dense([1.0;;], [1.0], identity)

    # Chain(f, g) must be g ∘ f, not f ∘ g
    @test Chain(double, plus_one)([3.0]) == [7.0]    # 2*3 then +1
    @test Chain(plus_one, double)([3.0]) == [8.0]    # 3+1 then *2
    @test Chain()([3.0]) == [3.0]                    # empty chain = identity
end

@testitem "Chain: display" tags = [:unit] begin
    net = Chain(Dense(2 => 5, tanh), Dense(5 => 2, identity))
    @test repr(net) == "Chain(Dense(2 => 5, tanh), Dense(5 => 2, identity))"
end

@testitem "glorot: variance scaling and reproducibility" tags = [:unit] begin
    using Random
    W = glorot(Xoshiro(42), 1000, 1000)
    @test size(W) == (1000, 1000)
    @test abs(sum(W) / length(W)) < 0.01                      # centred
    @test isapprox(sum(abs2, W) / length(W), 2 / 2000; rtol = 0.1)  # variance 2/(nin+nout)

    # same seed, same weights
    @test glorot(Xoshiro(1), 3, 4) == glorot(Xoshiro(1), 3, 4)
end

@testitem "the network is generic in the number type" tags = [:unit] begin
    # Nothing is hard-coded to Float64, so exact rational arithmetic flows
    # through. The same property is what lets dual numbers (and hence AD)
    # flow through later.
    layer = Dense([1 // 2 1 // 3], [1 // 6], identity)
    y = layer([1 // 1, 1 // 1])
    @test y == [1 // 1]
    @test eltype(y) == Rational{Int}

    # ... and in Float32, with no promotion to Float64
    layer32 = Dense(Float32[1 2], Float32[0], tanh)
    @test eltype(layer32(Float32[1, 1])) == Float32
end
