using Test
using VisualizerMakie
using PDESchoolBase

struct MockNet <: PDESchoolBase.AbstractSurrogate end
PDESchoolBase.predict(::MockNet, x, θ) = [sin(π * x[1])]

@testset "VisualizerMakie" begin
    net = MockNet()
    θ = Float64[]

    p1 = plot_solution(net, θ, x -> sin(π * x))
    @test p1 !== nothing

    p2 = plot_loss([1.0, 0.5, 0.1, 0.05, 0.01])
    @test p2 !== nothing

    snapshots = [Float64[] for _ in 1:5]  # MockNet ignores θ
    mktempdir() do d
        path = plot_training(net, snapshots, x -> sin(π * x);
                              path=joinpath(d, "training.mp4"))
        @test path !== nothing
    end
end
