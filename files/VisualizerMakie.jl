module VisualizerMakie

using CairoMakie
using PDESchoolBase: predict

export plot_solution, plot_loss, plot_training

"""
    plot_solution(net, θ, exact_u; n=200)

Same contract as VisualizerPlots's version — same name, same
signature, different backend underneath. That's the point: the driver
script calls whichever `plot_solution` it imported, without caring
which package it came from.
"""
function plot_solution(net, θ, exact_u; n=200)
    xs = range(0, 1; length=n)
    u_pred = [predict(net, [x], θ)[1] for x in xs]
    u_true = exact_u.(xs)

    # TODO: build a Makie Figure/Axis, `lines!` both curves, add a
    # legend. Usual pattern:
    #   fig = Figure()
    #   ax = Axis(fig[1, 1]; xlabel="x", ylabel="u(x)",
    #             title="PINN vs exact solution")
    #   lines!(ax, xs, u_true; label="exact")
    #   lines!(ax, xs, u_pred; label="PINN", linestyle=:dash)
    #   axislegend(ax)
    #   fig
    error("TODO: implement plot_solution")
end

"""
    plot_loss(history)

Plot the training loss curve on a log10 y-axis.
"""
function plot_loss(history)
    # TODO:
    #   fig = Figure()
    #   ax = Axis(fig[1, 1]; xlabel="iteration", ylabel="loss",
    #             title="Training loss", yscale=log10)
    #   lines!(ax, history)
    #   fig
    error("TODO: implement plot_loss")
end

"""
    plot_training(net, θ_snapshots, exact_u; xs=range(0, 1; length=200),
                  path="training.mp4", fps=10)

Same idea as VisualizerPlots's version — one frame per θ snapshot —
written to `path` (mp4 or gif, depending on the extension). Returns
`path`. Uses a Makie `Observable` so only the changed line gets
redrawn each frame rather than rebuilding the whole figure.
"""
function plot_training(net, θ_snapshots, exact_u; xs=range(0, 1; length=200),
                        path="training.mp4", fps=10)
    u_true = exact_u.(xs)
    fig = Figure()
    ax = Axis(fig[1, 1]; xlabel="x", ylabel="u(x)", title="Training in progress")
    lines!(ax, xs, u_true; label="exact")
    pred = Observable([predict(net, [x], first(θ_snapshots))[1] for x in xs])
    lines!(ax, xs, pred; label="PINN", linestyle=:dash)
    axislegend(ax)

    record(fig, path, θ_snapshots; framerate=fps) do θ
        pred[] = [predict(net, [x], θ)[1] for x in xs]
    end
    path
end

end # module VisualizerMakie
