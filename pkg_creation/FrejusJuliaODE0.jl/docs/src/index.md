```@meta
CurrentModule = FrejusJuliaODE0
```

# FrejusJuliaODE0

Documentation for [FrejusJuliaODE0](https://github.com/dmetivie/FrejusJuliaODE0.jl):
explicit one-step solvers for

```math
\frac{du}{dt} = f(u, p, t), \qquad u(t_0) = u_0 .
```

## Explicit Euler

```math
u_{n+1} = u_n + \Delta t \, f(u_n, p, t_n)
```

```@example euler
using FrejusJuliaODE0

sol = euler((u, p, t) -> -p * u, 1.0, 2.0, (0.0, 1.0), 1000)
sol.u[end], exp(-2.0)
```

## Classical Runge–Kutta

Four slopes, averaged with weights ``1/6, 1/3, 1/3, 1/6``; order 4, so twenty
steps already beat ten thousand Euler steps:

```@example euler
rk4((u, p, t) -> -2 * u, 1.0, nothing, (0.0, 1.0), 20).u[end]
```

## Choosing the scheme

[`solve_ode`](@ref) takes the one-step method as a keyword argument, so adding a
scheme means adding a function, not editing the loop:

```@example euler
midpoint_step(f, u, p, t, dt) = u + dt * f(u + dt / 2 * f(u, p, t), p, t + dt / 2)

solve_ode((u, p, t) -> -2 * u, 1.0, nothing, (0.0, 1.0), 20; step = midpoint_step).u[end]
```

The full list of functions is in the [Reference](@ref reference) page.
