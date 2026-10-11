"""
    FrejusJuliaOptimization0

Newton-type solvers: the same idea — *replace the problem by its local linear
model and solve that* — applied three times.

| function | solves | needs |
|:--|:--|:--|
| [`newton`](@ref) | `F(x) = 0` | `F` and its Jacobian |
| [`gauss_newton`](@ref) | `min ‖r(x)‖²` (least squares) | `r` and its Jacobian |
| [`gradient_descent`](@ref) | `min f(x)` | `f` and its gradient |

Every solver takes the derivative as an *argument*. Where it comes from — a
formula on paper, finite differences, or an automatic differentiation package —
is none of this package's business.

Returned value: a named tuple `(; x, history, converged, iterations)`.

# Example

```jldoctest
julia> using FrejusJuliaOptimization0

julia> sol = newton(x -> x^2 - 2, x -> 2x, 1.0);

julia> sol.x ≈ sqrt(2), sol.iterations
(true, 4)
```
"""
module FrejusJuliaOptimization0

using LinearAlgebra: norm, I

export newton, gauss_newton, gradient_descent

"""
    newton(F, J, x0; tol = 1e-10, maxiter = 100)

Solve `F(x) = 0` by Newton's method: linearise, solve, repeat.

```math
x_{k+1} = x_k - J(x_k)^{-1} F(x_k)
```

`J` must return the derivative of `F` at a point. Works both for a scalar
equation and for a system, with no change: for numbers `a \\ b` is `b / a`, and
for matrices it is a linear solve. One line, two algorithms — that is multiple
dispatch.

Convergence is quadratic *near* a root, and there is no guarantee at all far
from one.

# Examples

A scalar equation:

```jldoctest
julia> newton(x -> x^2 - 2, x -> 2x, 1.0).x ≈ sqrt(2)
true
```

A 2×2 system, same function:

```jldoctest
julia> F(v) = [v[1]^2 + v[2]^2 - 1, v[1] - v[2]];

julia> J(v) = [2v[1] 2v[2]; 1.0 -1.0];

julia> newton(F, J, [1.0, 0.5]).x ≈ [sqrt(2) / 2, sqrt(2) / 2]
true
```

Minimising `f` is the same as solving `∇f = 0`, so there is no separate
"Newton minimiser": feed the gradient and the Hessian.

```jldoctest
julia> newton(x -> [2x[1] - 4], x -> fill(2.0, 1, 1), [0.0]).x   # min of (x-2)²
1-element Vector{Float64}:
 2.0
```
"""
function newton(F, J, x0; tol = 1.0e-10, maxiter = 100)
    x = x0
    r = F(x)
    history = [norm(r)]

    for _ in 1:maxiter
        norm(r) <= tol && break
        x = x - J(x) \ r          # the Newton step
        r = F(x)
        push!(history, norm(r))
    end

    return (; x, history, converged = norm(r) <= tol, iterations = length(history) - 1)
end

"""
    gauss_newton(r, J, x0; λ = 1e-2, tol = 1e-10, maxiter = 100)

Minimise the sum of squares `‖r(x)‖²` of a vector of residuals, by the
Levenberg–Marquardt variant of the Gauss–Newton method.

Writing `r(x + δ) ≈ r(x) - J δ` and minimising over `δ` gives the *normal
equations*; adding a damping `λ` keeps them solvable and the step short:

```math
(J^T J + λ I) δ = J^T r, ~~ x ← x - δ.
```

`λ` is adapted automatically: divided by 3 after a step that lowers the loss
(trust the linear model more), multiplied by 3 after one that does not (fall
back towards a small gradient-descent step). This is what makes the method
robust far from the solution, where plain Gauss–Newton diverges.

Only the Jacobian of the residuals is needed — never a Hessian. That is why
this is the method of choice for fitting a model to data.

# Example

Fitting `a exp(b t)` to noiseless data:

```jldoctest
julia> t = range(0, 1; length = 20);

julia> data = 3.0 .* exp.(-2.0 .* t);

julia> r(θ) = θ[1] .* exp.(θ[2] .* t) .- data;

julia> J(θ) = hcat(exp.(θ[2] .* t), θ[1] .* t .* exp.(θ[2] .* t));

julia> round.(gauss_newton(r, J, [1.0, -1.0]).x; digits = 6)
2-element Vector{Float64}:
  3.0
 -2.0
```
"""
function gauss_newton(r, J, x0; λ = 1.0e-2, tol = 1.0e-10, maxiter = 100)
    x = x0
    residual = r(x)
    loss = sum(abs2, residual)
    history = [loss]
    converged = false

    for _ in 1:maxiter
        Jx = J(x)
        δ = (Jx' * Jx + λ * I) \ (Jx' * residual)   # damped normal equations

        x_try = x - δ
        residual_try = r(x_try)
        loss_try = sum(abs2, residual_try)

        if loss_try < loss
            x, residual, loss = x_try, residual_try, loss_try
            λ = max(λ / 3, 1.0e-12)      # step accepted: trust the linear model
        else
            λ = min(λ * 3, 1.0e12)       # step rejected: be more cautious
        end

        push!(history, loss)

        # Stop on a step that no longer moves: the loss itself need not reach
        # zero, since the data may simply not be reachable by the model.
        if norm(δ) <= tol
            converged = true
            break
        end
    end

    return (; x, history, converged, iterations = length(history) - 1)
end

"""
    gradient_descent(f, ∇f, x0; η = 1e-2, tol = 1e-8, maxiter = 1000)

Minimise `f` by walking downhill: `x ← x - η ∇f(x)`.

Kept here as the baseline to compare against. It needs no linear solve and no
second derivative, but it converges linearly at best, and the step size `η` has
to be guessed.

# Example

```jldoctest
julia> sol = gradient_descent(x -> sum(abs2, x), x -> 2x, [1.0, 1.0]; η = 0.1);

julia> isapprox(sol.x, [0.0, 0.0]; atol = 1e-4)
true
```
"""
function gradient_descent(f, ∇f, x0; η = 1.0e-2, tol = 1.0e-8, maxiter = 1000)
    x = x0
    g = ∇f(x)
    history = [f(x)]

    for _ in 1:maxiter
        norm(g) <= tol && break
        x = x - η * g
        g = ∇f(x)
        push!(history, f(x))
    end

    return (; x, history, converged = norm(g) <= tol, iterations = length(history) - 1)
end

end
