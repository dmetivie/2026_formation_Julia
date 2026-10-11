# FrejusJuliaOptimization0

[![BestieTemplate](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/JuliaBesties/BestieTemplate.jl/main/docs/src/assets/badge.json)](https://github.com/JuliaBesties/BestieTemplate.jl)


> Teaching package — ANF Julia pour le HPC, Fréjus.
> Newton-type solvers, written from scratch.

One idea, three uses: **replace the problem by its local linear model, solve
that, repeat.**

| function | solves | needs |
|:--|:--|:--|
| `gauss_newton` | $\min \lVert r(x) \rVert^2$ | $r$ and its Jacobian |
| `gradient_descent` | $\min f(x)$ | $f$ and its gradient |

## Usage

```julia
using FrejusJuliaOptimization0

# a system of two nonlinear equations
F(v) = [v[1]^2 + v[2]^2 - 1, v[1] - v[2]]
J(v) = [2v[1] 2v[2]; 1.0 -1.0]
gauss_newton(F, J, [1.0, 0.5]).x
```

All three return `(; x, history, converged, iterations)`.

## What is interesting here

**Scalar and vector Newton are literally the same line of code:**

```julia
x = x - J(x) \ r
```

For numbers, `a \ b` is `b / a`. For matrices, it is a linear solve. Multiple
dispatch picks the right one; the algorithm is written once.

**The derivative is an argument, not a dependency.** This package never asks
*where* `J` comes from — hand-derived, finite differences, or an AD package:

```julia
newton(f, x -> derivative(f, x), 1.0)   # with FrejusJuliaAD0 loaded
```

That is why these four packages can be written in parallel by four people and
only meet at the end.

**Minimising is solving `∇f = 0`**, so there is no separate Newton minimiser —
pass the gradient and the Hessian to `newton`.

**Damping is what makes it work.** `gauss_newton` adds `λI` to the normal
equations and adapts `λ`: divided by 3 after a step that lowers the loss,
multiplied by 3 after one that does not. Without it, Gauss–Newton diverges as
soon as the starting point is poor. This is the Levenberg–Marquardt method, and
it is why `gauss_newton` — not `gradient_descent` — is what trains the neural
ODE.

## Layout of the package

| Path | Content |
| --- | --- |
| `src/FrejusJuliaOptimization0.jl` | the three solvers |
| `test/runtests.jl` | roots, convergence order, damping, a divergent case |

This package was generated with the **`:tiny`** BestieTemplate profile: no
`docs/` folder, no CI, just `src` and `test`. Compare with `FrejusJuliaODE0`
(`:light`) and `FrejusJuliaAD0` (PkgTemplates) to see what each level adds.

## Limitation (on purpose)

No line search, no trust region, no sparse or matrix-free linear algebra, no
box constraints, and the Jacobian is formed densely. For the real thing see
[NonlinearSolve.jl](https://github.com/SciML/NonlinearSolve.jl) and
[Optimization.jl](https://github.com/SciML/Optimization.jl).
