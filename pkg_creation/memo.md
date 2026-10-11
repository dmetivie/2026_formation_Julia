```{julia}
Template(interactive = false, user = "dmetivie", authors = "David Métivier <david.metivier@inrae.fr>",
julia = v"1.13",
dir=raw"C:\Users\metivier\Dropbox\PC (2)\Documents\cours\2026_formation_Julia\pkg_creatation",
plugins=[
    # Documenter{GitHubActions}(),
    License(; name="MIT"),
    Git(),
    Tests(),
    GitHubActions(;),
    Codecov(),
    Documenter{GitHubActions}(),
    TagBot()
    ]

)("FrejusJuliaAD0")
```


```julia
using BestieTemplate: new_pkg_quick


pkg_destination = joinpath("pkg_creation", "FrejusJuliaOptimization0.jl")
package_owner = "dmetivie"
authors = "David Métivier <david.metivier@inrae.fr>"
new_pkg_quick(
    pkg_destination,
    package_owner,
    authors,
    :tiny,
)

# Resulting folder:
```

```{julia}
using BestieTemplate

pkg_destination = joinpath("pkg_creation", "FrejusJuliaNeuralNetworks0.jl")
package_owner = "dmetivie"
authors = "David Métivier <david.metivier@inrae.fr>"
new_pkg_quick(
    pkg_destination,
    package_owner,
    authors,
    :light,
)

```