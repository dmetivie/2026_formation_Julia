using FrejusJuliaODE0
using Test

# Reference problem: u' = -u, u(0) = 1, whose exact solution is u(t) = exp(-t).
decay(u, p, t) = -u

"Error on u(1) committed by `step` with `nsteps` steps."
function final_error(step, nsteps)
    sol = solve_ode(decay, 1.0, nothing, (0.0, 1.0), nsteps; step = step)
    return abs(sol.u[end] - exp(-1.0))
end

"Empirical convergence order, from the error ratio between dt and dt/2."
observed_order(step, nsteps) = log2(final_error(step, nsteps) / final_error(step, 2nsteps))

@testset "FrejusJuliaODE0.jl" begin

    @testset "one step by hand" begin
        # u' = -u, u = 1, dt = 0.1  ⟹  u₁ = 1 + 0.1 * (-1) = 0.9
        @test euler_step(decay, 1.0, nothing, 0.0, 0.1) ≈ 0.9
        # RK4 on the same step should already match exp(-0.1) to ~1e-7
        @test rk4_step(decay, 1.0, nothing, 0.0, 0.1) ≈ exp(-0.1) atol = 1.0e-7
    end

    @testset "solution container" begin
        sol = euler(decay, 1.0, nothing, (0.0, 1.0), 10)
        @test length(sol.t) == 11            # nsteps + 1 points
        @test length(sol.u) == 11
        @test sol.t[1] == 0.0
        @test sol.t[end] ≈ 1.0
        @test sol.u[1] == 1.0                # the initial condition is kept
    end

    @testset "convergence order" begin
        @test observed_order(euler_step, 1000) ≈ 1 atol = 0.05
        @test observed_order(rk4_step, 10) ≈ 4 atol = 0.2
    end

    @testset "accuracy" begin
        @test euler(decay, 1.0, nothing, (0.0, 1.0), 10_000).u[end] ≈ exp(-1) atol = 1.0e-4
        @test rk4(decay, 1.0, nothing, (0.0, 1.0), 20).u[end] ≈ exp(-1) atol = 1.0e-7
    end

    @testset "systems of equations" begin
        # Harmonic oscillator: after one full period the state must come back.
        A = [0.0 1.0; -1.0 0.0]
        sol = rk4((u, p, t) -> p * u, [1.0, 0.0], A, (0.0, 2π), 200)
        @test sol.u[end] ≈ [1.0, 0.0] atol = 1.0e-6

        # Euler is unstable here: it spirals outwards.
        solE = euler((u, p, t) -> p * u, [1.0, 0.0], A, (0.0, 2π), 200)
        @test sum(abs2, solE.u[end]) > 1.0
    end

    @testset "parameters are passed through" begin
        sol = euler((u, p, t) -> -p * u, 1.0, 3.0, (0.0, 1.0), 10_000)
        @test sol.u[end] ≈ exp(-3.0) atol = 1.0e-3
    end

    @testset "the solver is generic in the number type" begin
        # No `Float64` is hard-coded anywhere, so exact rational arithmetic
        # goes straight through. The very same property is what will let the
        # AD package differentiate this solver later on.
        sol = euler(decay, 1 // 1, nothing, (0 // 1, 1 // 1), 4)
        @test sol.u[end] === (3 // 4)^4
        @test eltype(sol.u) == Rational{Int}
    end

    @testset "argument checking" begin
        @test_throws ArgumentError euler(decay, 1.0, nothing, (0.0, 1.0), 0)
    end

end
