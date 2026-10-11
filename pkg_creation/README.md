# Exercise — four packages, one neural ODE

**ANF Julia pour le HPC, Fréjus — day 1, afternoon.**

Work in groups of four. **Each member writes one package.** At the end of the session the four packages are put together, unchanged, to train a neural ODE:

```math
\dfrac{\mathrm{d}u}{\mathrm{d}t} = \mathrm{NN}_\theta(u)
```

where $\mathrm{NN}_\theta$ is a small neural network whose weights $\theta$ are fitted to data.

| who | package | provides |
| --- | --- | --- |
| 1 | `FrejusJuliaAD0` | derivatives, by dual numbers |
| 2 | `FrejusJuliaODE0` | explicit Euler / RK4 time integration |
| 3 | `FrejusJuliaNeuralNetworks0` | dense layers, chain, flat parameter vector |
| 4 | `FrejusJuliaOptimization0` | Newton, Gauss–Newton, gradient descent |

Assembly: [`neural_ode/train_neural_ode.jl`](neural_ode/train_neural_ode.jl).

## The two rules

**1. No package depends on any other.** This is what lets the four of you work in parallel.

**2. Write generic code.** No `::Float64` in a signature, no `zeros(3)` where the element type should come from the input, no
`Vector{Float64}` buffer. Ask for the least you need.

Rule 2 is what makes rule 1 possible. The AD package will push its `Dual` numbers through the ODE solver and through the neural network — code that has never heard of a dual number and never will. If those two packages are written generically, it works; if not, it does not. 

## Mathematical Specification

**Each package computes a specific mathematical operation, using only generic code and basic types.**

| Package | Computes | Input | Output |
|---------|----------|-------|--------|
| **AD** | $\nabla f, J_f$ via forward mode | $f : \mathbb{R}^n \to \mathbb{R}^m$ | $\mathbb{R}^n$ or $\mathbb{R}^{m \times n}$ |
| **ODE** | $u(t_{k+1})$ from $u(t_k)$ | $\dot{u} = f(u,p,t)$, $u_0$ | trajectory $\{u_k\}$ |
| **NN** | $\sigma.(Wx+b)$ and flat $\theta$ | weights $W,b$, parameters $\theta$ | callable layer, flat/unflatten |
| **Optim** | $\arg\min_x \lVert r(x) \rVert^2$ or $\min_x f(x)$ | residuals $r$ or loss $f$ | solution $x^*$, history |

## The contract

The four packages meet only in the final script, so the names and signatures below have to be agreed *before* you start.

Replace the `0` by the number of your group.

```julia
# package 1 — FrejusJuliaAD0
Dual(x, δ)                       # a number; δ is the derivative part
derivative(f, x::Number)         # f'(x)
gradient(f, x::AbstractVector)   # ∇f, as a vector
jacobian(f, x::AbstractVector)   # m × n matrix, column i = ∂f/∂xᵢ

# package 2 — FrejusJuliaODE0
abstract type AbstractODEStep end  # idiomatic: abstract supertype
struct EulerStep <: AbstractODEStep end
solve_ode(f, u0, p, tspan, nsteps; step = EulerStep())   # -> (; t, u)

# package 3 — FrejusJuliaNeuralNetworks0
Dense(nin => nout, σ)            # callable: layer(x) = σ.(W*x .+ b)
Chain(layers...)                 # callable: net(x)
nparams(model)                   # how many numbers to fit
parameters(model)                # model  -> flat Vector
rebuild(model, θ)                # Vector -> model

# package 4 — FrejusJuliaOptimization0
gauss_newton(r, J, x0)           # minimise ‖r(x)‖² (Levenberg–Marquardt)
gradient_descent(f, ∇f, x0)      # minimise f
# each returns (; x, history, converged, iterations)
```

**Key design:** package 4 never asks where `J` comes from (hand-derived, FD, or AD),
and packages 2 and 3 never hardcode `Float64`. That is what makes genericity work.

## What "writing a package" means

For each of you, the same checklist:

- [ ] **code** in `src/`, split into files and `include`d from the main module
- [ ] **`export`** the handful of names a user needs — and only those
- [ ] **docstrings** on every exported name: signature, one sentence, an example
- [ ] **dependencies** declared in `Project.toml` (`] add LinearAlgebra`, …)
- [ ] **tests** in `test/`, run with `] test`, that would catch a sign error
- [ ] **README** saying what the package is for, in three lines
- [ ] **docs** (`docs/make.jl`) for the packages that have a `docs/` folder

A good test is not `@test f(1) == f(1)`. Test against something you know
independently: an analytic derivative, a convergence order, an exactly solvable
case, a round trip (`rebuild(model, parameters(model))`).

## Package-specific hints

**Package 1 (AD):** Implement one operation (`+`, `*`, `/`, etc.) at a time, starting with multiplication: `(a*b)' = a'*b + a*b'`. Test against `f(x)=x^2, f'(2)=4`.

**Package 2 (ODE):** The one-step update is one line. Test your Euler step on `u' = -u, u(0)=1` → `u(t) = exp(-t)`. Then check RK4 reaches higher order.

**Package 3 (NN):** Start with **just** one `Dense` layer. Write `(layer::Dense)(x) = layer.σ.(layer.W * x .+ layer.b)` and test it by hand. Then write `nparams`. Then `parameters` and `rebuild` — these are mechanical flattening/unflattening. Only then add `Chain`.
```julia
struct Dense{M, V, F}
    W::M           # weights, shape (nout, nin)
    b::V           # bias, shape (nout,)
    σ::F           # activation function
end

# Make a Dense layer callable
(layer::Dense)(x) = layer.σ.(layer.W * x .+ layer.b)

struct Chain{L <: Tuple}
    layers::L
end

# Chain composition: apply each layer in sequence
(NNet::Chain)(x) = foldl((y, f) -> f(y), NNet.layers; init = x)
```
The rest is:
1. Write `nparams(model)` — count parameters
2. Write `parameters(model)` — stack all W's and b's into one vector
3. Write `rebuild(model, θ)` — pull them back out and reconstruct the struct


**Package 4 (Optim):** Implement gradient descent and [Gauss–Newton](https://en.wikipedia.org/wiki/Gauss%E2%80%93Newton_algorithm#Julia) first (normal equations `(J'*J) \ (J'*r)`). Note that Levenberg–Marquardt (add `λ*I`) is a one-line fix for robustness. Test on a quadratic: `f(x) = x^2`, optimal at `x=0`.