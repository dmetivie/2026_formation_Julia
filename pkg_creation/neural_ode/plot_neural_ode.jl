using CairoMakie

u1(trajectory) = getindex.(trajectory, 1)
u2(trajectory) = getindex.(trajectory, 2)

initial = predict(theta0)     # before training, for comparison

begin
    fig = Figure(size=(1150, 380))
    ## --- phase portrait --------------------------------------------------------
    ax = Axis(fig[1, 1]; xlabel="u₁", ylabel="u₂", title="Phase portrait")
    lines!(ax, u1(initial), u2(initial); color=:grey70, label="before training")
    lines!(ax, u1(prediction), u2(prediction); color=:firebrick, linewidth=2, label="neural ODE GN")
    lines!(ax, u1(prediction_gd), u2(prediction_gd); color=:royalblue, linewidth=2, label="neural ODE GD")

    scatter!(ax, u1(data), u2(data); color=:black, markersize=7, label="data")
    axislegend(ax; position=:lt, framevisible=false)
    ## --- time series -----------------------------------------------------------
    ax = Axis(fig[1, 2]; xlabel="t", ylabel="u", title="Trajectory")
    scatter!(ax, t_data, u1(data); color=:black, markersize=7, label="data")
    scatter!(ax, t_data, u2(data); color=:black, markersize=7)
    lines!(ax, t_data, u1(prediction); color=:firebrick, linewidth=2, label="u₁ model")
    lines!(ax, t_data, u2(prediction); color=:royalblue, linewidth=2, label="u₂ model")
    axislegend(ax; position=:lb, framevisible=false)
    ## --- loss history ----------------------------------------------------------
    # The two methods are shown against iteration count, which is fair here: one
    # Gauss-Newton iteration and one gradient-descent iteration both cost one
    # Jacobian-or-gradient, i.e. 42 ODE solves.
    ax = Axis(fig[1, 3];
        xlabel="iteration", ylabel="loss", yscale=log10, title="Convergence")
    lines!(ax, 0:(length(descent.history)-1), max.(descent.history, 1.0e-16);
        color=:grey40, linewidth=2, label="gradient descent")
    lines!(ax, 0:(length(result.history)-1), max.(result.history, 1.0e-16);
        color=:firebrick, linewidth=2, label="Gauss-Newton")
    axislegend(ax; position=:rt, framevisible=false)

    save("neural_ode.png", fig)
    @info "wrote $(joinpath(pwd(), "neural_ode.png"))"

    fig
end
