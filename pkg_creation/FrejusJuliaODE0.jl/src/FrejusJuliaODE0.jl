"""
    FrejusJuliaODE0

Explicit one-step solvers for ordinary differential equations

```math
du/dt = f(u, p, t), ~~ u(t_0) = u_0
```

written as simply as possible: an *explicit Euler* step, a *classical RK4* step,
and a driver that marches either of them over a time span.

The right-hand side takes `(u, p, t)` — state, parameters, time — which is the
signature used by [DifferentialEquations.jl](https://docs.sciml.ai), so the `f`
you write here can be handed to a real solver without a single change.

# Example

```jldoctest
julia> using FrejusJuliaODE0

julia> sol = euler((u, p, t) -> -p * u, 1.0, 2.0, (0.0, 1.0), 1000);

julia> abs(sol.u[end] - exp(-2.0)) < 1e-3
true
```
"""
module FrejusJuliaODE0

export euler_step, rk4_step, solve_ode, euler, rk4

"""
    euler_step(f, u, p, t, dt)

One explicit (forward) Euler step

```math
u_{n+1} = u_n + Δt · f(u_n, p, t_n)
```

First-order accurate: halving `dt` halves the error.
"""
euler_step(f, u, p, t, dt) = u + dt * f(u, p, t)

"""
    rk4_step(f, u, p, t, dt)

One step of the classical fourth-order Runge–Kutta scheme: four slopes, averaged
with weights `1/6, 1/3, 1/3, 1/6`.

Same signature as [`euler_step`](@ref) — which is the whole point, see
[`solve_ode`](@ref).
"""
function rk4_step(f, u, p, t, dt)
    k1 = f(u, p, t)
    k2 = f(u + dt / 2 * k1, p, t + dt / 2)
    k3 = f(u + dt / 2 * k2, p, t + dt / 2)
    k4 = f(u + dt * k3, p, t + dt)
    return u + dt / 6 * (k1 + 2k2 + 2k3 + k4)
end

"""
    solve_ode(f, u0, p, tspan, nsteps; step = euler_step)

Integrate `du/dt = f(u, p, t)` from `u0` over `tspan = (t0, tend)` with `nsteps`
steps of equal size, using `step` as the one-step method.

Returns a named tuple `(; t, u)`, so that `sol.u[end]` is the final state — the
same spelling as a DifferentialEquations.jl solution.

`step` being an ordinary argument, the *same* driver runs Euler, RK4.

# Example

```jldoctest
julia> sol = solve_ode((u, p, t) -> -u, 1.0, nothing, (0.0, 1.0), 10; step = rk4_step);

julia> round(sol.u[end]; digits = 6)
0.36788
```
"""
function solve_ode(f, u0, p, tspan, nsteps::Integer; step = euler_step)
    nsteps > 0 || throw(ArgumentError("nsteps must be positive, got $nsteps"))
    t0, tend = tspan
    dt = (tend - t0) / nsteps
    ts = [t0 + k * dt for k in 0:nsteps]

    # What type is a state? Not necessarily `typeof(u0)`: if `p` carries dual
    # numbers, the trajectory is dual-valued even though `u0` is a plain
    # `Vector{Float64}`. Asking Julia for the type of one step gets this right
    # for free — and keeps the loop below fast.
    U = typeof(step(f, u0, p, t0, dt))
    us = Vector{U}(undef, nsteps + 1)
    us[1] = u0

    for k in 1:nsteps
        us[k + 1] = step(f, us[k], p, ts[k], dt)
    end

    return (; t = ts, u = us)
end

"""
    euler(f, u0, p, tspan, nsteps)

[`solve_ode`](@ref) with the explicit Euler step. Convergence order 1.
"""
euler(f, u0, p, tspan, nsteps) = solve_ode(f, u0, p, tspan, nsteps; step = euler_step)

"""
    rk4(f, u0, p, tspan, nsteps)

[`solve_ode`](@ref) with the classical Runge–Kutta step. Convergence order 4.
"""
rk4(f, u0, p, tspan, nsteps) = solve_ode(f, u0, p, tspan, nsteps; step = rk4_step)

end
