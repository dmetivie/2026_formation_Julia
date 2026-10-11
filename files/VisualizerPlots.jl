module VisualizerPlots

using Plots
using PDESchoolBase: predict

export plot_solution, plot_loss, plot_training

"""
    plot_solution(net, θ, exact_u; n=200)

Compare the network's prediction against the exact solution over [0, 1].

`net` can be *any* concrete Network type built during the workshop —
this function never needs to know which one. That's resolved by
dispatch on `predict` from PDESchoolBase.

Convention: `predict(net, x, θ)` takes one point as a vector, e.g.
`predict(net, [0.3], θ)`. Confirm this matches what the Network team
(C/D) actually implemented — mismatched conventions between packages
are a very real thing to sort out at assembly time.
"""
function plot_solution(net, θ, exact_u; n=200)
    xs = range(0, 1; length=n)
    u_pred = [predict(net, [x], θ)[1] for x in xs]
    u_true = exact_u.(xs)

    # TODO: plot u_true vs xs, overlay u_pred, add a legend and axis
    # labels. Usual pattern:
    #   plot(xs, u_true; label="exact", linewidth=2)
    #   plot!(xs, u_pred; label="PINN", linewidth=2, linestyle=:dash,
    #         xlabel="x", ylabel="u(x)", title="PINN vs exact solution")
    error("TODO: implement plot_solution")
end

"""
    plot_loss(history)

Plot the training loss curve. PINN losses typically span several
orders of magnitude, so a log10 y-axis is usually the right call.
"""
function plot_loss(history)
    # TODO: plot(history; yscale=:log10, xlabel="iteration",
    #            ylabel="loss", title="Training loss", label=false,
    #            linewidth=2)
    error("TODO: implement plot_loss")
end

"""
    plot_training(net, θ_snapshots, exact_u; xs=range(0, 1; length=200))

Animate the network's prediction as it trains — one frame per snapshot
of θ. Needs the Optimizer's `callback` hook to collect snapshots, e.g.:

    snapshots = []
    cb(iter, θ, l) = iter % 50 == 0 && push!(snapshots, copy(θ))
    θ★, hist = optimize!(opt, loss, θ0; callback=cb)

Returns a Plots `Animation`; save it with
`gif(anim, "training.gif"; fps=10)`.
"""
function plot_training(net, θ_snapshots, exact_u; xs=range(0, 1; length=200))
    u_true = exact_u.(xs)
    ylims = (minimum(u_true) - 0.3, maximum(u_true) + 0.3)

    @animate for θ in θ_snapshots
        u_pred = [predict(net, [x], θ)[1] for x in xs]
        plot(xs, u_true; label="exact", linewidth=2, ylim=ylims)
        plot!(xs, u_pred; label="PINN", linewidth=2, linestyle=:dash,
              xlabel="x", ylabel="u(x)", title="Training in progress")
    end
end

end # module VisualizerPlots
