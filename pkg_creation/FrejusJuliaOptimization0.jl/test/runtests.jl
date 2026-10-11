using FrejusJuliaOptimization0
using Test
using LinearAlgebra: norm

@testset "FrejusJuliaOptimization0.jl" begin

    @testset "newton: scalar root" begin
        sol = newton(x -> x^2 - 2, x -> 2x, 1.0)
        @test sol.x ≈ sqrt(2)
        @test sol.converged
        @test sol.iterations < 10                  # quadratic convergence
        @test issorted(sol.history; rev = true)    # residual decreases
    end

    @testset "newton: quadratic convergence" begin
        # Near a simple root the number of correct digits doubles each step.
        sol = newton(x -> x^2 - 2, x -> 2x, 1.0)
        errors = abs.(sol.history)
        # e_{k+1} ≲ C e_k²  ⟹  the last error is tiny after a handful of steps
        @test errors[4] < errors[3]^1.5
    end

    @testset "newton: the same code solves a system" begin
        # Intersection of the unit circle with the line y = x.
        F(v) = [v[1]^2 + v[2]^2 - 1, v[1] - v[2]]
        J(v) = [2v[1] 2v[2]; 1.0 -1.0]

        sol = newton(F, J, [1.0, 0.5])
        @test sol.x ≈ [sqrt(2) / 2, sqrt(2) / 2]
        @test sol.converged
        @test norm(F(sol.x)) < 1.0e-10
    end

    @testset "newton: minimising = solving grad f = 0" begin
        # f(x) = (x₁ - 2)² + 3(x₂ + 1)²
        ∇f(x) = [2 * (x[1] - 2), 6 * (x[2] + 1)]
        H(x) = [2.0 0.0; 0.0 6.0]

        sol = newton(∇f, H, [0.0, 0.0])
        @test sol.x ≈ [2.0, -1.0]
        @test sol.iterations == 1                  # exact in one step: f is quadratic
    end

    @testset "newton: gives up gracefully" begin
        # x³ - 2x + 2 makes Newton cycle between 0 and 1 forever.
        sol = newton(x -> x^3 - 2x + 2, x -> 3x^2 - 2, 0.0; maxiter = 20)
        @test !sol.converged
        @test sol.iterations == 20
    end

    @testset "gauss_newton: exact fit of an exponential" begin
        t = range(0, 1; length = 20)
        data = 3.0 .* exp.(-2.0 .* t)

        r(θ) = θ[1] .* exp.(θ[2] .* t) .- data
        J(θ) = hcat(exp.(θ[2] .* t), θ[1] .* t .* exp.(θ[2] .* t))

        sol = gauss_newton(r, J, [1.0, -1.0])
        @test sol.x ≈ [3.0, -2.0] atol = 1.0e-6
        @test sol.history[end] < 1.0e-18
        @test sol.converged
    end

    @testset "gauss_newton: noisy data, loss stops above zero" begin
        t = range(0, 1; length = 30)
        truth = 2.0 .* t .+ 1.0
        noise = [0.1 * sin(17k) for k in 1:30]      # deterministic "noise"
        data = truth .+ noise

        r(θ) = θ[1] .* t .+ θ[2] .- data
        J(θ) = hcat(collect(t), ones(length(t)))    # linear model: constant Jacobian

        sol = gauss_newton(r, J, [0.0, 0.0])
        @test sol.x ≈ [2.0, 1.0] atol = 0.1         # close to truth, not equal
        @test sol.history[end] > 0                  # cannot fit the noise
        @test sol.history[end] < sol.history[1]
    end

    @testset "gauss_newton: the loss never increases" begin
        t = range(0, 2; length = 25)
        data = 1.5 .* exp.(-0.5 .* t)
        r(θ) = θ[1] .* exp.(θ[2] .* t) .- data
        J(θ) = hcat(exp.(θ[2] .* t), θ[1] .* t .* exp.(θ[2] .* t))

        # Start far away: plain Gauss-Newton would blow up, damping saves us.
        sol = gauss_newton(r, J, [-5.0, 4.0])
        @test issorted(sol.history; rev = true)
        @test sol.history[end] < 1.0e-10
    end

    @testset "gradient_descent" begin
        sol = gradient_descent(x -> sum(abs2, x), x -> 2x, [1.0, 1.0]; η = 0.1)
        @test sol.x ≈ [0.0, 0.0] atol = 1.0e-4
        @test sol.converged
        @test issorted(sol.history; rev = true)
    end

    @testset "gradient_descent is slower than newton" begin
        # Both find the minimum of (x-2)²; count the iterations.
        f(x) = sum(abs2, x .- 2)
        ∇f(x) = 2 .* (x .- 2)
        H(x) = fill(2.0, 1, 1)

        gd = gradient_descent(f, ∇f, [0.0]; η = 0.1)
        nt = newton(∇f, H, [0.0])

        @test gd.x ≈ [2.0] atol = 1.0e-4
        @test nt.x ≈ [2.0]
        @test nt.iterations < gd.iterations
    end

    @testset "the derivative is just an argument" begin
        # Nothing forces an analytic derivative: a finite difference works too
        # (badly), and this afternoon an AD package will do better.
        fd(f, h) = x -> (f(x + h) - f(x - h)) / 2h

        f(x) = x^2 - 2
        sol = newton(f, fd(f, 1.0e-6), 1.0)
        @test sol.x ≈ sqrt(2) atol = 1.0e-8
    end

end
