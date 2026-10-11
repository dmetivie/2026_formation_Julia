using Test
using VisualizerPlots
using PDESchoolBase

# Mock network so this package is testable standalone, before the real
# Network package (teams C/D) exists — that independence is the whole
# point of building against the shared interface instead of against
# each other's code directly.
struct MockNet <: PDESchoolBase.AbstractSurrogate end
PDESchoolBase.predict(::MockNet, x, θ) = [sin(π * x[1])]

@testset "VisualizerPlots" begin
    net = MockNet()
    θ = Float64[]  # unused by MockNet, but predict's signature needs one

    p1 = plot_solution(net, θ, x -> sin(π * x))
    @test p1 !== nothing

    p2 = plot_loss([1.0, 0.5, 0.1, 0.05, 0.01])
    @test p2 !== nothing

    # MockNet ignores θ, so any placeholder values work here — the point
    # is just to check plot_training runs across a sequence of snapshots.
    snapshots = [Float64[] for _ in 1:5]
    anim = plot_training(net, snapshots, x -> sin(π * x))
    @test anim !== nothing
end
