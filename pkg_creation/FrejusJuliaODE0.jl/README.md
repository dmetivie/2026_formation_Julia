# FrejusJuliaODE0

[![Stable Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://dmetivie.github.io/FrejusJuliaODE0.jl/stable)
[![Development documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://dmetivie.github.io/FrejusJuliaODE0.jl/dev)
[![Test workflow status](https://github.com/dmetivie/FrejusJuliaODE0.jl/actions/workflows/Test.yml/badge.svg?branch=main)](https://github.com/dmetivie/FrejusJuliaODE0.jl/actions/workflows/Test.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/dmetivie/FrejusJuliaODE0.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/dmetivie/FrejusJuliaODE0.jl)
[![Docs workflow Status](https://github.com/dmetivie/FrejusJuliaODE0.jl/actions/workflows/Docs.yml/badge.svg?branch=main)](https://github.com/dmetivie/FrejusJuliaODE0.jl/actions/workflows/Docs.yml?query=branch%3Amain)
[![BestieTemplate](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/main/docs/src/assets/badge.json)](https://github.com/JuliaBesties/BestieTemplate.jl)


> Teaching package — ANF Julia pour le HPC, Fréjus.
> Explicit one-step ODE solvers, written from scratch.

Integrate

$$\frac{du}{dt} = f(u, p, t), \qquad u(t_0) = u_0$$

with the explicit Euler scheme

$$u_{n+1} = u_n + \Delta t \, f(u_n, p, t_n)$$

or with classical RK4.

## Usage

```julia
using FrejusJuliaODE0

# Scalar: u' = -p u
sol = euler((u, p, t) -> -p * u, 1.0, 2.0, (0.0, 1.0), 1000)
sol.t      # times
sol.u      # states
sol.u[end] # ≈ exp(-2)

# System: harmonic oscillator, with RK4
A = [0.0 1.0; -1.0 0.0]
sol = rk4((u, p, t) -> A * u, [1.0, 0.0], nothing, (0.0, 2π), 200)
```

## What is interesting here

**The time-stepper is just an argument.** You can pass a function, *or* dispatch on a type.
The idiomatic Julia way:

```julia
abstract type AbstractODEStep end
struct EulerStep <: AbstractODEStep end
struct RK4Step <: AbstractODEStep end

function step_update(::EulerStep, f, u, p, t, dt)
    u + dt * f(u, p, t)
end
function step_update(::RK4Step, f, u, p, t, dt)
    k1 = f(u, p, t)
    k2 = f(u + dt/2*k1, p, t + dt/2)
    # ... and so on
end

solve_ode(f, u0, p, tspan, nsteps; step = EulerStep()) # dispatch on type
```

This lets students write their own `MyStep <: AbstractODEStep` and `step_update(::MyStep, ...)` without modifying the driver.

**The signature is `f(u, p, t)`**, the SciML convention.

**Nothing is typed `Float64`.** Integrating with `Rational` arithmetic is exact:

```julia
julia> euler((u, p, t) -> -u, 1//1, nothing, (0//1, 1//1), 4).u[end]
81//256
```

## Layout of the package

| Path | Content |
| --- | --- |
| `src/FrejusJuliaODE0.jl` | the whole package: two steppers and one driver |
| `test/runtests.jl` | tests, including a measured convergence order (1 vs 4) |
| `docs/` | Documenter.jl site |
