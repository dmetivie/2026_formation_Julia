### A Pluto.jl notebook ###
# v1.0.4

#> custom_attrs = ["hide-enabled"]
#> 
#> [frontmatter]
#> title = "Julia for scientific computing and research"
#> date = "2025-06-23"
#> 
#>     [[frontmatter.author]]
#>     name = "David Métivier"
#>     url = "https://david.metivier.pages.mia.inra.fr/website/"

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 8edb1e45-934a-453c-a5e2-4e5a7847767a
begin
    using BenchmarkTools
    # using Graphs
    using IntervalArithmetic: interval
    using DataFrames
    using Dates

    using LinearAlgebra
    using LogarithmicNumbers
    using Measurements
    using Pkg
    using Distributions
    using Symbolics # Symbolic 
    using Unitful # Physics unit
end

# ╔═╡ dbc5dedf-cc89-4eb2-96dc-9fbeec25025d
begin
    using HypertextLiteral
    using PlutoUI
    using PlutoTeachingTools
    using PlutoExtras
    using PlutoTest
    using ShortCodes
end

# ╔═╡ a3678ab0-3e64-45eb-90cc-afa0760ed701
using CairoMakie

# ╔═╡ 4335b1e5-04bd-4d59-bc20-742de204e5c2
using PlutoLinks

# ╔═╡ 36ffb38f-eee2-4b86-9938-5996f4c98b6c
using PlutoSlides

# ╔═╡ e8fbabaa-a913-4d7b-838b-3fdbcd0d9a2c
import MarkdownLiteral: @markdown

# ╔═╡ 0930e74b-0105-457c-9f8d-5e61352f1c21
beamer_color = "#ff7f50"

# ╔═╡ 6769d96d-1228-4229-be8c-0938cddb2fa9
PlutoSlides.slide_mode_settings(footer_left="David Métivier", footer_center="Julia for scientific computing and research", color_subtitle_bg=beamer_color, h3_title=true, font_size=21,
    max_width="98%"
)

# ╔═╡ 8e31d599-cb5f-44cb-b779-0ed5ce7f7c16
slide_mode_button()

# ╔═╡ 6149c7a3-140e-4204-a6f1-8f09a42d9242
slide_mode_title(
    title="Présentation générale Julia et de quelques écosystèmes\n & Création de packages",
    author=html"""
    <center>David Métivier</center>
    <p>
    INRAE - Montpellier
    </p>
    """,
    color=beamer_color,
    figures=[
        Resource("https://www.science-accueil.org/wp-content/uploads/2021/11/Logo-INRAE_Transparent-1536x406.png", :width => 420),
        Resource("http://davidmetivier.mistea.inrae.fr/pic/logo/logo-en-mistea-couleur.svg", :width => 300)
    ],
    footnote=md"[^credit]: This talk was partly inspired by [Guillaume Dalle Julia talk](https://gdalle.github.io/) + [Valentin Churavy](https://vchuravy.dev/talks/Making_Dynamic_Programs_Run_Fast/) + [Tim Holy lectures](https://github.com/timholy/AdvancedScientificComputing/tree/main) + videos and link shown in the notebook"
)

# ╔═╡ ec18f430-1b1c-4967-9689-6e2904e56ada
md"""
## How I Started Using Julia
"""

# ╔═╡ c0684073-01b1-486e-baf5-71cb4b3f1cad
Columns(
    Resource("http://davidmetivier.mistea.inrae.fr/pic/research/flowchart_inrae.svg", :width => 900),
    md"""
    **Coding experience**

    - Matlab/Mathematica (Internship)
    - C (with GPU) with Gnuplot/xmgrace (School and PhD)
    - Very little Python (School and PhD)
    - Julia (Los Alamos Postdoc 1 2018)

    **Package**
    - [ExpectationMaximization.jl](https://github.com/dmetivie/ExpectationMaximization.jl) (*Developer*)
    - [QuasiMonteCarlo.jl](https://github.com/SciML/QuasiMonteCarlo.jl) (**Contributor**)
    - [StochasticWeatherGenerators.jl](https://github.com/dmetivie/StochasticWeatherGenerators.jl) (*Developer*)
    - [PlutoSlides.jl](https://github.com/dmetivie/PlutoSlides.jl) (*Developer*)
    - Smaller WIP projects [RobustMeans.jl](https://github.com/dmetivie/RobustMeans.jl) + [ABCMethods.jl](https://github.com/dmetivie/ABCMethods.jl) + [PeriodicHiddenMarkovModels.jl](https://github.com/dmetivie/PeriodicHiddenMarkovModels.jl) (*Developer*) 
    + small contributions
    	""";
    widths=[60, 40], gap=0
)

# ╔═╡ 550cf92b-05b3-45e3-bf83-ab1175f1b002
md"""
## Goal of the presentation
"""

# ╔═╡ 80541381-32d8-4ae0-8dc5-569b315fdb46
md"""
!!! note "Program"
	1. **Motivation** for Julia
	2. **Basics**
	3. **Examples**: reference ecosystems and composability
	4. **Writing a package** -- writing & assembling four of them to train ``\frac{\mathrm{d}u}{\mathrm{d}t} = \mathrm{NeuralNetwork}(u).``

    **Goal**: Give you a feeling that this is a **great modern tool for complex scientific problems** and teaching, and that **the language favors collaborative work**.
$(pause())
!!! warning "Later this week"
	- **Multiple dispatch** 
    - **Performance**
	- **Parallelism**: threads, MPI, GPU -- one lecture each
    - **Interface** with other languages
$(pause())
!!! warning "Disclaimer"
	I will present many things: **a lot already exists in other languages**, sometimes as add-ons or wrapped C/C++ libraries.
	
	Julia language and most of its packages are inspired by many cool existing things.
	
	In this talk I want to emphasize the simplicity of some features and how far they can take us.
"""

# ╔═╡ dd796fa6-fa31-4559-9855-f6ade6a6c510
md"""
# The Julia story
"""

# ╔═╡ c90ed7b5-bc3a-4844-9a20-e0797d1a6ca5
md"""
## Thoughts by Gaël Varoquaux in May 2010 (co-founder of scikit-learn)
"""

# ╔═╡ f767e601-08da-436a-a4ea-fc92e18c1bec
Columns(
    webpage("https://gael-varoquaux.info/programming/view_on_scientific_computing.html", ratio="75%"),
    md"""
    !!! danger "My take"
    	I would add **speed/performance** to these requirements
    """,
    widths=[70, 30], gap=0
)



# ╔═╡ 5c1790e6-4b0d-41a3-9a73-a56cce53a4f5
md"""
## Why Julia was created?
"""

# ╔═╡ f289dbb7-29c9-4eac-a281-5bdf4612d1a6
blockquote(
    md"""
    We are power **Matlab** users. Some of us are **Lisp** hackers. Some are **Pythonistas**, others **Rubyists**, still others **Perl** hackers. There are those of us who used **Mathematica** before we could grow facial hair. There are those who still can't grow facial hair. We've generated more **R** plots than any sane person should. **C** is our desert island programming language.

    **We love all of these languages**; they are wonderful and powerful. For the work we do — **scientific computing, machine learning, data mining, large-scale linear algebra, distributed and parallel computing** — each one is perfect for some aspects of the work and terrible for others. **Each one is a trade-off**.

    **We are greedy: we want more.**
    """,
    md"""
    [Why we created Julia](https://julialang.org/blog/2012/02/why-we-created-julia/) -- Jeff Bezanson, Stefan Karpinski, Viral B. Shah, and Alan Edelman (**2012**)
    """
)

# ╔═╡ 98bec6f9-f7f5-4119-82d4-a94ec9c91e9c
blockquote(
    md"""
    Julia is designed to be easy and fast and questions notions generally held to be “laws of nature” by practitioners of numerical computing:
    1. High-level dynamic programs have to be slow.
    2. **One must prototype in one language and then rewrite in another language for speed or deployment.**
    3. There are parts of a system appropriate for the programmer, and other parts that are best left untouched as they have been built by the experts.
    """,
    md"""
    [Julia: A Fresh Approach to Numerical Computing](https://epubs.siam.org/doi/10.1137/141000671) -- Jeff Bezanson, Alan Edelman, Stefan Karpinski, and Viral B. Shah (**2017**)
    """
)

# ╔═╡ 2fbc54ee-1dfc-4a59-8a93-fa23bb69a8ea
md"""
# The Two Languages Problem
"""

# ╔═╡ 19d48875-bd81-4b5c-8cf9-8ef9ff6ef797
md"""
## Scientists vs Developers (1/2)
"""

# ╔═╡ 041375a1-8ee0-4e14-9320-7147c863914b
Resource("https://cdn.hashnode.com/res/hashnode/image/upload/v1681735971356/91b6e886-7ce1-41a3-9d9f-29b7b096e7f2.png")

# ╔═╡ b4694fba-d336-499f-90ee-28e6b37f37e8
md"""
From [My Target Audience](https://scientificcoder.com/my-target-audience) by Matthijs Cox (2023)
"""

# ╔═╡ 603c7e70-77aa-47d9-b7ac-1584108f7f64
md"""
## Scientists vs Developers (2/2)
"""

# ╔═╡ 45388687-1f90-4463-bc1f-ca7e61206ad2
Resource("https://cdn.hashnode.com/res/hashnode/image/upload/v1681735992315/62fdd58f-4630-4120-8eb4-5238740543e8.png")

# ╔═╡ cb538d2a-0d28-4b10-b7da-9729d4c6bd78
md"""
From [My Target Audience](https://scientificcoder.com/my-target-audience) by Matthijs Cox (2023)
"""

# ╔═╡ 9ca7b99a-a3de-40f0-a43b-47a3db74e816
md"""
## Compiled vs Interpreted
"""

# ╔═╡ c28338a5-bbb3-45c0-8a39-786264333d5f
Columns(
    Resource("http://ada-developers-academy.github.io/ada-build/learning-at-ada/ada-languages/images/compiled-interpreted.png", :width => "100%"),
    md"""
    !!! tip "Compilation"
    	- **Ahead of time** (C, C++, Go, Rust, ...): types are statically defined and the code is compiled before execution
    	- **Just-In-Time** (Julia, numba, JAX...): types inferred dynamically and functions compiled at first execution
    	- **Runtime** (Python, R, Matlab, ...): types inferred dynamically and functions compiled during runtime
    """,
    widths=[55, 44], gap=0
)


# ╔═╡ 573a1b02-7269-4c3e-91c1-019ec3a5d358
md"""
Julia is **dynamically** typed, feels like a scripting language, and has good support for interactive use.
Julia doesn't require you to annotate types: it infers them from the types of the arguments.
"""

# ╔═╡ 9059970a-e0e6-4228-b371-1e93d57f66d7
md"""
### Just-In-Time
"""

# ╔═╡ 46dd469b-2acd-4d8a-a112-9b550d27ced8
md"""
!!! note "Just-In-Time (JIT)"
	**Julia** was designed **from the ground up** to allow inference to work well most of the time, not just within a single function but from the entry point of a computational pipeline to its terminus.
"""

# ╔═╡ d8518bca-9dde-496d-b9fc-5565019a0ef0
md"""
!!! warning "JIT in other languages"
	**JIT is native to Julia.**
	
    Matlab and Python e.g. `numba` @jit, sometimes through **add-ons**, attempt to do the same thing, and when it works you get pretty good performance. But it places a lot of requirements on your code and works only in certain circumstances.

	`JAX` now has "native" JIT.
"""

# ╔═╡ e25dd3f8-8483-4632-b3a9-dc8455009a99
md"""
!!! danger "Time To First X (TTFX)"
	The first time you do something in Julia, it takes a while. 
"""

# ╔═╡ 957ee8fd-63d2-4363-a519-13bd73648e48
md"""
## The landmark problem: Writing a `sum` -- *Loops vs Vectorization*
"""

# ╔═╡ 1fb9b22a-61a4-4c4c-b1c2-71b27b303bc2
Columns(
    md"""
    **At school**

    ```bash
    s = 0
    for i in 1:N
      s = s + x[i]
    end
    return s
    ```

    The algorithm, written as the algorithm.
    """,
    md"""
    $(pause())
    **In Python/R/Matlab: don't.**

    $(blockquote(md"the loop is hidden from you in C. **Learning to use vectorized operations is a key skill in R**.", md"[Monash R lesson](https://monashbioinformaticsplatform.github.io/2015-09-28-rbioinformatics-intro-r/03-supp-loops-in-depth.html)"))
    $(blockquote(md"Experienced Matlab users like to say **Life is too short to spend writing for loops.**", md"1998 Getting Started with Matlab manual"))
    """,
    md"""
    $(pause())
    **In Julia: do**

    ```julia
    s = 0
    for i in 1:N
      s = s + x[i]
    end
    return s
    ```

    Same code, *"as fast as `C`"*, and generic on top.
    """,
    gap=1, widths=[27, 46, 27]
)

# ╔═╡ 877544e1-cf7c-4f6e-a746-67e5f418611d
md"""
$(pause())
!!! danger "The middle column is the two-language problem"
	A vectorized `sum` **is** a loop -- written in C, by somebody else.
	- *for loops are slow* was never about loops: in a dynamic language the types are unknown, so **every iteration re-infers them**.
	- The fast path therefore lives in **another language**, and you do not get to touch it.
	- Julia compiles **your** loop for the types it actually sees ⇒ one language, nothing hidden underneath.
"""

# ╔═╡ 13fcef34-89d6-4f7d-9249-1c019f42411c
md"""
### What if I cannot vectorize?
"""

# ╔═╡ 6e880336-8acb-4b78-ac86-2aafaa8e14ad
md"""
!!! danger "Sometimes you simply cannot"
    Complex dependencies on past elements -- a Markov chain, a recursive filter, a neighbor average -- and vectorizing is either impossible or an afternoon gone.

    [^example] Matlab example for averaging pixels; see [here](https://github.com/timholy/AdvancedScientificComputing/blob/main/lectures/intro/intro-julia.ipynb) for context and [here](https://www.mathworks.com/matlabcentral/answers/307297-neighbors-of-a-pixel) for the original post.
"""

# ╔═╡ c1003585-c164-44e3-bf96-c954d06a13cc
blockquote(md"""
I remember working on an **R script that needed to loop through 33 million rows** of data, doing a complicated lag/join/basket kind of computation that would take 18 hours to run. Literally during one of these 18 hour runs, I saw the Julia announcement post and was immediately desperate for the kind of simple performance it promised. **I read the initial manual over a weekend, rewrote my script the following Monday morning, and it ran in 5 minutes.**
""", "Jacob Quinn (2022)")

# ╔═╡ b89236fb-7775-4e16-93dc-bc9a025b3023
md"""
$(pause())
!!! warning "Conclusion"
    - Loops are not slow -- **re-inferring types at every iteration** is.
    - Vectorizing is not always possible, and it is a time sink.
    - Everywhere else the cure is to **rewrite in another language**: that is the two-language problem.
    - In Julia the loop *is* the fast version.
"""

# ╔═╡ 36863f50-68b0-42bc-a038-e5d02c58e8c1
md"""
## Development burden
"""

# ╔═╡ d5662c61-da7c-4303-a5ab-a024711e372b
md"""
!!! note "The usual recipe"
	Performance-critical packages are written in **C/C++/Fortran** for speed, then wrapped in **Python/R/Matlab** for usability.
	
	PyTorch, TensorFlow, Pandas, NumPy, SciPy... all rely on a compiled core, and so do many smaller domain packages.
"""

# ╔═╡ fa424220-a3af-4942-b19e-a0d952435472
Columns(
    md"""
    !!! danger "The cost of the two-language split"
    	- Hard to **read** the source code
    	- Hard to **contribute** (who knows both C++ *and* the wrapper language?)
    	- Hard to **add features** or maintain
    	- Hard to **install** and **reproduce** results
    	- Poorly **composable** outside the package
    """,
    md"""
    !!! warning "A lot of effort"
    	- Writing **glue code** between languages costs engineers, postdocs and years (**before LLMs**)
    	- Many packages **duplicate** the same features instead of sharing code
    	- Each extra language, compiler and dependency multiplies **compatibility** problems
    """
)

# ╔═╡ 499c26ba-8df5-4087-80de-a3efb5293f16
question_box(md"""
Who never ran into **compatibility** or installation issues with Python/R?

The more dependencies (especially across languages and compilers), the more issues with reproducibility, compatibility and installation
			 
**Of course**, this does not mean you won't have any with Julia.
""")

# ╔═╡ 38d6ab9e-3aa0-4890-b8a6-ae1bc3dd4d00
md"""
# Julia Basics
"""

# ╔═╡ 8c4a2e6a-3ee4-484f-a1a6-0bde73d43718
md"""
## Website
"""

# ╔═╡ f45d46f4-9c7f-458a-a26a-429b0294e614
webpage("https://julialang.org/")

# ╔═╡ 28f20cfe-7439-4090-aa23-ec2257a9fc9c
md"""
## Install
"""

# ╔═╡ fc58d729-8594-4607-bf7f-0f730a3be9ac
md"""
#### Windows
"""

# ╔═╡ faa36c56-bd6b-45b7-89b6-1555a2515bfd
webpage("https://apps.microsoft.com/detail/julia/9NJNWW8PVKMN?hl=fr-fr&gl=FR&rtc=1", ratio="25%")

# ╔═╡ af6007fc-39ac-401d-a03d-16fe39917951
md"""
#### Linux/Mac 
"""

# ╔═╡ 24b9edbe-88e6-4ede-bb59-5c32d8f1514c
md"""
Simply do
```bash
curl -fsSL https://install.julialang.org | sh
```
"""

# ╔═╡ 8bb3e448-2686-4499-8323-2d981ac122cd
md"""
Both give you [**`juliaup`**](https://github.com/JuliaLang/juliaup), the version manager:

```bash
juliaup add 1.13          # several versions side by side
juliaup default 1.13
juliaup update
julia +1.10 script.jl     # run with a specific one
```

Current stable: **v1.13.1**.
"""

# ╔═╡ f67f535b-3d05-4bd6-a7bd-21556f4c41dc
md"""
## Editors
"""

# ╔═╡ 1ead6b3e-3e1c-49b0-a834-fd587b00c5a5
md"""
### The essentials
"""

# ╔═╡ 1a1b54fd-61e3-4fd3-a3d7-77f015c9d0be
md"""
**REPL (Terminal)**

!!! tip "Good for"
	- Package `]`, environment management
	- Shell mode `;`
	- Quick look/computations
	- Extensions: R console, TerminalPager.jl, etc.
    - Can be connected to LLMs e.g. [Kaimon.jl](https://kahliburke.github.io/Kaimon.jl/dev/) 

**VsCode (IDE)**

!!! tip "Good for"
    - IDE features (IntelliSense, Highlighting, etc)
	- Execute using REPL or script
	- Development (with package, git, etc)
	- Profiling
    - Debugging (so so)
	- Plot panel
	- ...
"""

# ╔═╡ b9d8f2f3-f2b2-4f35-b792-df71e240d92a
md"""
### Jupyter (notebook)
"""

# ╔═╡ e715e9bb-a9cb-49d8-ac75-16e67a4667db
md"""
!!! tip "Good for"
	- Showing work
	- Report like document 
    - Widely adopted
    - JupyterLab 

!!! danger "Not ideal for (it improved a lot)"
	- Development
	- Sharing/Reproducibility e.g. `.ipynb` format!
"""

# ╔═╡ 62c5b08c-b574-4043-8bab-5493f2462dd7
md"""
!!! note "Did you notice"
	**Ju**(lia) **Py**(thon) **R**
"""

# ╔═╡ b527f54c-53ae-4aa6-a5f2-c61fa6633bd3
md"""
### Pluto (notebook)
"""

# ╔═╡ 6232d13a-c1f9-4df2-8549-e43f6fc4ed9f
md"""
!!! tip "Good for"
	- Interactivity
	- Sharing/Reproducibility e.g. `.jl` format!
	- Teaching
	- Presentation/Report like document
  
!!! danger "Bad for"
	- Heavy notebooks
	- No IDE like features
	- Development
	- Pkg env sometimes
"""

# ╔═╡ 489823e8-1e5f-4493-a0c3-2dbbec842142
md"""
#### Reactive notebooks
"""

# ╔═╡ a4500168-ea47-4f03-8c2e-e08901d82d2d
@bind date_start DatePicker(default=today())

# ╔═╡ 5e0ded8d-db7e-45b7-8511-64c8f1632185
Columns(
    md"""Choose your color $(@bind main_color ColorStringPicker(default = "#3333B3"))""",
    md"""Choose your frequency Ω = $(@bind Ω PlutoUI.Slider(1:0.1:10; show_value=true))"""
)


# ╔═╡ 07a6cf77-e119-4050-a109-3fa1377f3fdb
Ω^2

# ╔═╡ ed04f3b6-dcba-4d2c-b539-bf4d77ff33b3
md"""
#### Teaching

Evaluate student code automatically on the following task.

Define a function `mydouble` that takes two inputs and computes their doubled sum.
"""

# ╔═╡ 0ca63687-c9c6-4027-a461-1ceaa35eee55
md"""
### Other tools
"""

# ╔═╡ 4d51f9cb-60fd-4e05-a97c-724080cb317f
Columns(
    md"""
    !!! tip "Well established"
    	- [**Quarto**](https://quarto.org/) -- one source → html, pdf, slides, website. Julia, Python and R in the same document.

    !!! note "Advanced Pluto usage"
    	- [**Pluto Desktop**](https://github.com/JuliaPluto/PlutoDesktop) → standalone app, no Julia install required (useful for students) 
    	- [**Space Station**](https://github.com/GroupTherapyOrg/SpaceStation.jl) → IDE like for Pluto
    	- [**Advanced Pluto Notebook**](https://marketplace.visualstudio.com/items?itemName=juliapluto-pankgeorg.advanced-vscode-extension) extension brings Pluto into VSCode.
    """,
    md"""
    !!! note "Newer, Julia only"
    	- [**KaimonSlate.jl**](https://kahliburke.github.io/KaimonSlate.jl/dev/)
    	- [**Bonito Book**](https://bonitobook.org/website/)
    	
    	Both worth a look

    !!! danger "This talk"
    	is a Pluto notebook rendered with [PlutoSlides.jl](https://github.com/dmetivie/PlutoSlides.jl). One file for the slides, the live demo and the hand-out.
    """,
    widths=[50, 50], gap=1
)

# ╔═╡ 2ce2824f-52b7-444e-950f-5370b4ba59e0
md"""
## Julia Base
"""

# ╔═╡ 70e72f56-4cca-4858-ac9c-f84bd7ae5029
md"""
### Syntax
"""

# ╔═╡ 22b1bb59-f0de-4888-9b9c-fbaf0fab773c
md"""
One-line function definitions and $\LaTeX$ symbols
"""

# ╔═╡ 53d07c05-a15a-450a-83c4-4da91dd5b6a5
😸 = 1

# ╔═╡ 3447169b-b41f-4b63-9251-ef6d14846b82
md"""
Not just good looking: improve readability!
"""

# ╔═╡ e832133e-6b8a-4557-be97-6d54f2e1b6b3
2 ∈ 4:7    # returns `false`

# ╔═╡ 4ef6d842-457d-447b-b7c1-27ae00b10c4b
[1, 5] ⊆ 1:5  # returns `true`

# ╔═╡ 459e2de0-afc8-4032-ad3c-72c53a55d270
x -> x^2

# ╔═╡ 89e86e3a-674c-4c49-b59d-ddf09060e106
md"""
### Built-in arrays
"""

# ╔═╡ b0e2f33c-bc5d-49ec-bcc5-47e4054eb7e8
A = [1 1;
    1 0]

# ╔═╡ 383d27d6-bb3f-4728-ad9e-2f55a9899782
A^10

# ╔═╡ da86214e-a69a-4bd8-a2aa-746a4fd5f6c9
md"""
### Broadcast
"""

# ╔═╡ 000e169f-0ce4-43f0-8414-7d932427dcd5
md"""
- Vectorization of operators and functions just with dot.
  * It is a language feature
  * It works with every function
- Vectorization is not **naturally** faster than loops but might be more convenient sometimes.
"""

# ╔═╡ f140a80d-1ec3-4a0c-b35b-1d117c3e7adc
exp.([1, 2, 3])

# ╔═╡ 7f8e1d7e-b7a0-42f2-80ce-f0e98cdea9d2
[1, 2, 3] .=> ["a", "b", "c"]

# ╔═╡ 2345567b-3d2d-4b9c-bac6-2d753280fb48
md"""
### MetaProgramming (macros)
"""

# ╔═╡ e9cf406d-2f81-4bb1-98f7-b9b6d118fd08
md"""
Basically metaprogramming refers to a variety of ways a program has knowledge of itself or can manipulate itself. [See docs for more details](https://docs.julialang.org/en/v1/manual/metaprogramming/)

!!! note "In practice: cool macros"
	- Use to have simple call to other language
	- `@time`, `@.`, `@ode_def` `@lie`, `@reaction_network`, ...

```julia
macro time(ex)
  return quote
    local t0 = time_ns()
    local val = $ex
    local t1 = time_ns()
    println("elapsed time: ", (t1-t0)/1e9, " seconds")
    val
  end
end
```
"""

# ╔═╡ e500f340-b53c-46b2-a3fd-46d563c86df9
md"""
### Types
"""

# ╔═╡ fbb026ed-d295-44dc-93c5-1455f3ffd848
Columns(
    PlantUML("@startmindmap
+ Number
++ Complex{<:Real}
++ Real
+++ Irrational
+++ Rational{<:Integer}
+++ Integer
++++ Bool
++++ Signed
+++++ BigInt
+++++ Int8, Int16, Int32, Int64, Int128
++++ Unsigned
+++++ UInt8, UInt16, UInt32, UInt64, UInt128
+++ AbstractFloat
++++ BigFloat
++++ Float16, Float32, Float64
@endmindmap"),
    md"""
    ```julia
    abstract type Number end
    abstract type Real          <: Number end
    abstract type AbstractFloat <: Real end
    abstract type Integer       <: Real end
    abstract type Signed        <: Integer end
    abstract type Unsigned      <: Integer end
    ```
    [^Ref]: See documentation on [Types](https://docs.julialang.org/en/v1/manual/types/)

    Types are **not** mandatory but can be specified when needed! 
    """, widths=[60, 40], gap=0)

# ╔═╡ 6782cd70-71dd-4504-a6b6-e4b0da3d9126
Float16<:AbstractFloat

# ╔═╡ 772d1148-5181-425e-b2ca-365aa2b5c2a4
md"""
### Clever compiler
"""

# ╔═╡ e6429073-ffe9-4153-b90f-e55b27e2817d
md"""
All the previous abstractions do not compromise efficiency, for two reasons. 
"""

# ╔═╡ 42dd87b3-b9a2-4f57-bcac-3a191ab76380
md"""
!!! note "Clever compiler (1/2)"
	The compiler infers variable types very well.
"""

# ╔═╡ 4cd408a5-f78a-4393-9ffe-61598f17f326
fill(2, 3)

# ╔═╡ c9fe918e-6910-41f8-9042-a35e7fe1fd00
md"""
!!! note "Clever compiler (2/2)"
	The compiler generates low-level code that is adapted to the variable types it has inferred.
"""

# ╔═╡ 9c024d61-b080-4d33-8bdf-d887daad54a6
md"""
Basic operations like the sum have hundreds of implementations, each designed for specific combinations of input types.
"""

# ╔═╡ 5a13d6f6-cb6b-4e2b-b190-0f9bdfaf3098
md"""
# Multiple Dispatch
"""

# ╔═╡ ee3c9d50-72e2-4f11-b486-1275d20d5c72
md"""
!!! warning "For today"
	Multiple dispatch has **its own lecture** later this week.
	Here I only want you to see *why* it makes packages compose.

[**JuliaCon 2019 | The Unreasonable Effectiveness of Multiple Dispatch | Stefan Karpinski**](https://www.youtube.com/watch?v=kc9HwsxE1OY)
"""

# ╔═╡ 6e9558f8-9d76-43ca-9578-598e3d9e0b69
md"""
## What is multiple dispatch
"""

# ╔═╡ aef14e22-cac9-4dda-be67-7f71174492d1
md"""
!!! tip "Multiple dispatch (Polymorphism) in Julia"
	- Dispatch on **all** arguments of a function
    Example: `f(x::Integer, y::AbstractFloat)` and `f(x::AbstractFloat, y::Integer)` can have different implementations.
	- Dispatch depends on the **Type** of the argument not the class 
	
    1. **Generic algorithms** abstractly express high-level algorithms decoupled from implementation details
	2. **Common Type** shared by many different packages

    Example: 
"""

# ╔═╡ 777dbb78-1915-40eb-9d7b-0b0662bd9ebf
Columns(md"""
```julia
rand(Exponential(1.0))
rand(Exponential(1.0), 10)
rand(Normal(0, 1))
rand(Normal(0, 1), 1,5,6)
```
""",
    md"""
    ```julia
    power(x, n::Integer) = prod(x for _ in 1:n)
    power(x, n::AbstractFloat) = exp(n * log(x))
    ```
    """)

# ╔═╡ c531ed94-708a-4ea3-a227-bc6ed79761c8
md"""
## Type/Class sharing
"""

# ╔═╡ d5059a11-fbb1-4d01-9931-6de4e297768c
md"""
!!! warning "Class Based Object Oriented `x.f(y)`"
	Methods **live inside** the `class` definition. To add a new method on a type you do not own, you must either
	1. **Edit the original class** (you need write access & must maintain it), or
	2. **Inherit from it** with a new class (your method won't apply to the original type nor its other subclasses)

```python
# Dog comes from some library you imported
class Dog:
    def speak(self):      # method trapped inside the class
        return "Woof"

d = Dog()
d.speak()                 # ok
d.fetch()                 # AttributeError: you cannot add `fetch` from outside
```

!!! danger "'Solutions'"
	1. Convince the authors to add your method (they'll have to maintain it & cannot easily remove it)
	2. Subclass into `MyDog` & your method won't apply to other `Dog`s
	3. Give up on dispatch: use an external function `fetch(d)` instead of `d.fetch()`
	4. Give up code sharing
"""

# ╔═╡ 5b605cde-da9f-447c-b1e5-15a78e669701
md"""
!!! tip "In Julia functional programming `f(x,y)`"
	Functions live **outside** types: you can add methods on a type **after** it is defined, even one you do not own. That's it!

```julia
struct Dog end            # type from some package
speak(::Dog) = "Woof"     # its package defines `speak`

# You, in *another* package, just add behavior. No editing, no subclassing:
fetch(::Dog) = "🐕 brings the ball back"
```

You extend in **both directions** (the *expression problem*): add new methods on existing types **and** make existing functions (`+`, `sort`, `plot`, ...) work on your new types.

$\to$ Generic functions are properly namespaced, i.e. `MyPackage.foo` and `YourPackage.foo` are separate functions
"""

# ╔═╡ 88a0d6d8-5d1a-49b2-abb3-a9200932cd7b
md"""
#### More detailed example
"""

# ╔═╡ 8b18afe0-c62a-4cc3-8b41-1ba527309484
md"""
Example of "multiple dispatch" (Jupyter notebook): [`notebook_2_multiple_dispach_on_animals.ipynb`](https://github.com/dmetivie/MyJuliaIntroDocs.jl/blob/master/notebooks/notebook_2_multiple_dispach_on_animals.ipynb)
"""

# ╔═╡ a3771e8a-1b07-4d31-b4ad-19e3ede8ffaa
md"""
## Expressiveness
"""

# ╔═╡ 6097217e-c193-4877-af31-6430636988bf
Resource("https://github.com/dmetivie/MyJuliaIntroDocs.jl/blob/master/figs/expressiveness_with_dask.png?raw=true")

# ╔═╡ 7e3a8d7f-2c99-4d56-b78e-ba68cf400fbe
md"""
[^from]: Tim Holy [this video](https://youtu.be/jFhL8EVrz7s?t=286), that [notebook](https://github.com/timholy/AdvancedScientificComputing/blob/main/lectures/intro/intro-julia.ipynb) and [this paper](https://arxiv.org/abs/2109.09973)
"""

# ╔═╡ b5f1432a-6c49-4325-90a3-a1acb91f9862
md"""
## Composability
"""

# ╔═╡ 787b287f-1738-40e0-852d-a48bf4e5e14e
Columns(
    Twitter(1589676578560102400),
    md"""
    !!! tip "In Julia"
    	One language + type sharing + multiple dispatch

    	⇒ Amazing, unexpected combination and code reuse

    	⇒ Improving a package can benefit the **whole** ecosystem

    !!! warning "What is NOT code reuse?"
        Recoding basic stuff because of incompatible frameworks `tensorflow.random.uniform`, `numpy.random.rand`, `torch.rand`, `jax.random.uniform`
    """)


# ╔═╡ 1353c885-8bfb-4065-bce7-c31bb0184815
md"""
## Multiple dispatch showcase
"""

# ╔═╡ 1ab4495a-0743-451e-9429-9c3487d1f772
md"""
Custom function `mynorm` that computes the sum of squares of a vector.
"""

# ╔═╡ bbafd906-f6fe-4fa0-8adc-9daa8dfb8f18
mynorm(v) = sum(abs2, v)

# ╔═╡ c627f0a8-dc70-4381-ae91-565e5a627be8
v = [1, 2, 3]

# ╔═╡ 9c34951b-8b73-46b4-9886-45f8267e983f
mynorm(v)

# ╔═╡ cf9eb011-8eed-4636-96e3-8fbac9731aee
md"""
Logarithmic numbers to prevent numerical underflow (LogarithmicNumbers.jl):
"""

# ╔═╡ 194f6e29-9731-4cb1-8c3d-38e414d566f4
v_log = LogFloat64.(v)

# ╔═╡ 32b08849-80e0-4b35-b95d-871672bb2f91
mynorm(v_log)

# ╔═╡ 2b3b8b03-601e-49af-b5ef-6c582c398996
md"""
Numbers with physical units (Unitful.jl):
"""

# ╔═╡ 88929c5a-d416-4c63-82fd-be5f29f5eb6c
md"""
Numbers with [uncertainties](https://en.wikipedia.org/wiki/Propagation_of_uncertainty) ([Measurements.jl](https://github.com/JuliaPhysics/Measurements.jl))
"""

# ╔═╡ 4de4e9fc-5b61-4a6c-b225-e4609ba6944f
v_meas = [1 ± 0.1, 2 ± 0.2, 3 ± 0.3]

# ╔═╡ aff1f60c-4eab-4ca5-850d-949750925ff3
mynorm(v_meas)

# ╔═╡ ffbdbe06-0b26-4500-a503-8e2bd749d495
md"""
Intervals (IntervalArithmetic.jl)
"""

# ╔═╡ 745e4629-c57b-450d-896f-f0627a3c880b
v_interv = [interval(0.9, 1.1), interval(1.8, 2.2), interval(2.7, 3.3)]

# ╔═╡ 278c52ec-3108-41e3-9c9f-76ccbafc9401
mynorm(v_interv)

# ╔═╡ f16925a8-1b04-4403-8bca-333132ca9518
md"""
Computer algebra (Symbolics.jl).

You must enable/uncomment the cell to download Symbolics.jl package (which was removed to make notebook lighter). Then enable the following cells
"""

# ╔═╡ 1ee6da4b-a3ef-44df-a95e-6502070e928f
Symbolics.@variables p, q, r

# ╔═╡ 65c2d1ed-6fd1-47f1-b51b-269c7941ae2f
md"""
## Generic & Efficient code
"""

# ╔═╡ f8a0b5ec-1623-4f25-b6dc-c859dab34037
md"""
Julia is near **Pareto-optimal** in terms of **lines of code** vs **efficiency**.

- [Computer Language Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/fastest/julia-python3.html)
- [Energy efficiency of programming languages](https://sites.google.com/view/energy-efficiency-languages/updated-functional-results-2020)
- [ChatGPT works best in Julia for LLM Code Generation over Python/R](https://arxiv.org/pdf/2308.04477.pdf) (see Figure 1).
"""

# ╔═╡ 782b4b45-8f00-4805-b70f-6a527d5dba60
Columns(
    md"""
    !!! note "Personal experience: The Expectation Maximization algorithm"
    	[ExpectationMaximization.jl](https://github.com/dmetivie/ExpectationMaximization.jl/tree/master) versatile + fast
    """,
    Resource("https://raw.githubusercontent.com/dmetivie/ExpectationMaximization.jl/refs/heads/master/benchmark/timing_K_2.svg", :width => "90%"),
    widths=[40, 60], gap=2
)

# ╔═╡ 31ce0ecf-69ea-41c6-970f-7117d8399ad2
md"""
# Ecosystems
"""

# ╔═╡ 1b04af0e-ae4f-470c-bbe3-2ed9e571ded1
md"""
## An ecosystem of small things
"""

# ╔═╡ 60f2cab8-8c93-4f9a-938a-debcddde2496
md"""
!!! note "Two populations"
	- A few **big reference ecosystems/organizations**: SciML, JuliaStats, JuliaData, JuliaGraphs, JuliaGPU, Makie, JuMP...
	- Hundreds of **tiny packages** doing exactly one thing, e.g. [ToeplitzMatrices.jl](https://github.com/JuliaLinearAlgebra/ToeplitzMatrices.jl)

!!! tip "The philosophy"
	One package = **one mathematical object**, or one algorithm.

	Small ⇒ easy to test, to document, to review, to trust. And it composes with the rest precisely *because* it only talks about its own object.

!!! danger "The consequence"
	Your small package can be useful to someone else.
"""

# ╔═╡ edef726b-0eb6-46b9-935e-c151977d15a0
md"""
## Statistics
"""

# ╔═╡ fac73484-defd-442c-89f6-9eff9f5749da
md"""
!!! tip "Statistics & inference"
	- `StatsBase.jl`, `Distributions.jl`
	- built on top: `Copulas.jl`, `ExpectationMaximization.jl`, `AdditionalDistributions.jl`, ...
	- `Turing.jl` -- Bayesian inference
	- `HiddenMarkovModels.jl`, `GLM.jl`
	- `MLJ.jl` -- one interface over many ML packages
"""

# ╔═╡ b61894d9-bdbd-4f9b-b4ec-a6dd555a5aec
dist = Normal(-1) #Exponential(5)

# ╔═╡ 913904ea-4ff1-43d9-86a2-e851b2138dd6
mean(dist)

# ╔═╡ 3819d633-4531-4053-b063-501c7060d7a5
data = rand(dist, 500)

# ╔═╡ 8e93923a-fb4f-42d4-a735-ecd9bf40c307
pdf(dist, 5.2)

# ╔═╡ dbc44103-8163-4d02-802a-765dba4b905f
hist(data)

# ╔═╡ 4449508f-df28-4d2d-aa14-46dd0902de46
rand(dist, 1, 5)

# ╔═╡ 48ca2c1f-cc8e-4268-9f25-2efc655ddfac
md"""
## Automatic Differentiation
"""

# ╔═╡ 9dfe81c9-db99-4a2e-bd81-43cc8e057f42
md"""
!!! tip "Definition"
    - Automatic differentiation is a technique to compute the derivative of a function by applying the chain rule to the elementary operations that compose it.
    
    - It is not symbolic differentiation, nor numerical differentiation.

    ⇒ In Julia most of the code can be automatically differentiated out of the box. 
    
    **Extremely useful for optimization, machine learning, etc.**
"""

# ╔═╡ bf54a867-1338-4305-85b7-f39b7db066e9
md"""
**Example**: Babylonian square root algorithm
"""

# ╔═╡ d604a886-8c56-49b6-8ea4-601ed10e48ed
md"""
What if I want to compute its derivative?
"""

# ╔═╡ a6503d55-de44-4b37-bfb4-ae44914db52e
md"""
#### Symbolic differentiation
"""

# ╔═╡ 23dc3660-3d24-4c04-be68-b4d4a0358f87
@variables x

# ╔═╡ f5fc05e5-34f3-4473-8dcc-a5a98b18c145
md"""
#### Numerical Differentiation 
"""

# ╔═╡ 5baf566f-3544-46e8-913c-8e88c00be991
h = 0.01

# ╔═╡ 70fc7904-fdd8-4d7c-b51d-028c04a56ddf
md"""
#### Automatic Differentiation (Forward)
"""

# ╔═╡ 7afd6c30-b290-45ad-8ddf-7c28a4b34872
struct Dual{T} <: Number
    x::T
    δ::T
end

# ╔═╡ b3571522-6d85-4ea9-8a7c-b3fac6b600c3
Base.:+(a::Dual, b::Dual) = Dual(a.x + b.x, a.δ + b.δ)

# ╔═╡ bb0d1784-6093-4404-adf2-78aa322f7085
😸 + 😸

# ╔═╡ 6fabb945-3626-452b-a471-4abcadbb9592
function λ(x, y)
    1+1
end

# ╔═╡ 8c1fc621-500f-484d-91d8-75e8d564ce9e
f(x) = x[1]^2 + x[2]^2

# ╔═╡ e498d0c5-104e-4db6-91fc-9562faa7dfb4
[1, 2, 3] .+ 1

# ╔═╡ ac7408c8-c366-46ab-9515-93bc55dda4ac
(1+2.)::AbstractFloat

# ╔═╡ ee8b8ad6-70d9-49d5-b2c0-1be93da8255c
(1+2)::Int

# ╔═╡ 16af7868-f4fe-4720-98f7-095f96b0ac7a
@which 1 + 1

# ╔═╡ b676581c-a8ec-44ae-a4d3-31efd57ef445
@which true + true

# ╔═╡ 29b05d28-662a-4413-ba9c-bd45e9e50135
@which 1//1 + 1//1

# ╔═╡ f0d0773c-e933-487d-939d-5bba8e886fb5
1//3 + 1//2

# ╔═╡ cf12ffe3-42b0-43f7-bf2a-bc13ea12ce05
@which 1.0 + 1.0

# ╔═╡ 8a1c1942-ec43-452f-9b35-0a99587b26d8
@which [1 0] + [0 1]

# ╔═╡ 18a34595-d7ee-4131-939f-a48f197e87f1
length(methods(+))

# ╔═╡ 36aff0f4-5a82-4987-ba75-c2a66b3286e8
rand(dist) + 1

# ╔═╡ 73ebd870-8e95-4dee-8e63-3cfcb9018e08
Base.:*(m::Real, a::Dual) = Dual(m * a.x, m * a.δ)

# ╔═╡ 46088004-6d59-4059-8536-b571810d8646
t = 0:0.01:2π

# ╔═╡ e283e03a-b0f6-485a-94c7-93db9a5ddd40
date = range(; start=date_start, step=Day(1), length=length(t));

# ╔═╡ 1055b847-6fa9-4f0d-924a-45d8b9d45ad0
lines(date, sin.(2Ω * t); color=main_color, linewidth=4)

# ╔═╡ 957ee6e2-25db-41c9-a5a9-8b8efb39e6ff
mydouble(x, y) = 1 * (x + y) # try 2 instead of 1

# ╔═╡ add00c30-7aa9-47f9-ac3b-4a1e97e23d09
let
    if @isdefined mydouble
        x, y = 3, 2
        try
            z = mydouble(x, y)
            if z isa promote_type(typeof(x), typeof(y))
                if z ≈ 2(x + y)
                    correct()
                else
                    almost(md"`mydouble` returns the wrong numerical value")
                end
            else
                almost(md"`mydouble` returns the wrong type")
            end
        catch e
            keep_working(md"`mydouble` throws an error")
        end
    else
        keep_working(md"`mydouble` is not defined")
    end
end

# ╔═╡ 228acf65-2f5b-4e45-9a7e-2bdef932105f
cartesian(r, θ, ϕ=0) = r*sin(θ)*cos(ϕ), r*sin(θ)*sin(ϕ), r*cos(θ)

# ╔═╡ 577205fb-1ab3-4305-9add-042315b079c9
∇f(x) = [2x[1], 2x[2]]

# ╔═╡ 5726299f-3857-4467-bea2-dceefb9ba7b7
∇²f(x) = 2*I(2)

# ╔═╡ 42636eea-3e50-4b2d-a711-6d75d0a14014
∇²f([1., 0.5])

# ╔═╡ aa3e7729-3b2e-4824-92af-09d15894b521
function myfillmat(x, n)
    v2 = fill(x, n)
    v = sqrt.(v2)
    M = v * v'
    return M
end

# ╔═╡ 988269f3-1e76-4cc3-88a9-392620efc000
@code_warntype myfillmat(2, 3)

# ╔═╡ d6cda712-e20b-40e4-9366-f9ee41a2c690
v_unit = [Float64(1)u"mm", 2u"m", 3u"m"]

# ╔═╡ e4917b3b-b497-4657-8335-6e182da37318
mynorm(v_unit)

# ╔═╡ 60f2d10b-1bba-4c94-8758-05262cc77bad
v_symb = [1p, 2q, 3r]

# ╔═╡ 7410adcc-44a4-434d-84a6-dd108f53c414
mynorm(v_symb)

# ╔═╡ 88b5be8c-8b2c-4b04-9f91-c7fe5929ddc2
Base.:/(a::Dual, b::Dual) = Dual(a.x / b.x, (b.x * a.δ - a.x * b.δ) / b.x^2)

# ╔═╡ 9506fe42-d4a2-4055-8429-021ff5bebb8b
φ₁(x) = exp(-x^2) / √(2π)

# ╔═╡ 37e6add7-46c6-4ece-9b14-f2bafb66a8a1
φ₁.([1, 2, 3])

# ╔═╡ e0c14edc-3971-42e3-96c3-1086cde97b1e
@time rand(10^5);

# ╔═╡ f3b572ef-b338-4b12-b1b8-08364fabf487
@time myfillmat(2, 3)

# ╔═╡ 2ea84a40-f68a-465e-bf76-e8edb2573429
function mysqrt(x)
    y = x
    for k in 1:3
        y = 1/2 * (y + x / y)
    end
    return y
end

# ╔═╡ d666646f-a1b9-4ca6-8ef4-15557312cc8c
mysqrt(2)

# ╔═╡ 88365be6-675c-4b01-ab45-45baadf37325
Symbolics.derivative(mysqrt(x), x)

# ╔═╡ a335cbea-aab6-45e2-9bbb-7d19a3e2d68f
(mysqrt(2+h) - mysqrt(2)) / h

# ╔═╡ 962eb933-3d01-41ae-898d-2e97553ffa6b
mysqrt(Dual(2, 1))

# ╔═╡ 8e362a49-fdfe-499d-abf1-40005f25aec8
1 / (2√2)

# ╔═╡ 44aab99a-1443-47d7-ab9c-84499fdb2db8
md"""
### Which AD backend?
"""

# ╔═╡ f7cdac03-ac02-47e0-b669-f5ae860df57d
Columns(
    md"""
    You just wrote `Dual` by hand. In practice you pick one:

    | package | mode | good for |
    |:--|:--|:--|
    | `ForwardDiff.jl` | forward | few inputs -- exactly the `Dual` above |
    | `Zygote.jl` | reverse | many inputs, source-to-source |
    | `Enzyme.jl` | both | LLVM level, very fast, handles mutation |
    | `Mooncake.jl` | both | pure Julia, newer |

    ```{julia}
    value_and_gradient(f, AutoForwardDiff(), x)
    value_and_gradient(f, AutoEnzyme(), x)
    ```
    """,
    md"""
    !!! tip "One interface: DifferentiationInterface.jl"
    	[`DifferentiationInterface.jl`](https://github.com/JuliaDiff/DifferentiationInterface.jl) wraps all of them. Swap `AutoForwardDiff()` for `AutoEnzyme()` and re-run -- your code does not move.

    !!! warning "Downside"
    	This much choice is fairly **unique to Julia**, and it is also the hard part: supporting several of them in one code base costs.
    """,
    widths=[48, 52], gap=1
)

# ╔═╡ 83aa29be-fd0c-45f2-942f-e3ae7db415be
md"""
### SciML
"""

# ╔═╡ e8b03545-6a95-447f-885b-f442b2c08515
webpage("https://docs.sciml.ai/Overview/stable/", ratio="45%")

# ╔═╡ 0662f0dc-8f65-4b65-8ca4-fe4978fb2da6
md"""
| package | what it does |
|:--|:--|
| `DifferentialEquations.jl` | ODE/DAE/SDE/etc. solvers |
| `ModelingToolkit.jl` | symbolic model → simplification |
| `Optimization.jl` | one front-end over ~20 optimizer backends |
| `NonlinearSolve.jl` | solve `F(x) = 0`, robustly |
| `LinearSolve.jl` | solve `Ax = b`, swap factorization/preconditioner |
| `Integrals.jl` | integral computations (differentiable) |
| `Lux.jl` | neural networks |
| `SciMLSensitivity.jl` | differentiate *through* a solver ⇒ neural ODEs, UDEs |
| `NeuralPDE.jl` | physics-informed neural networks |
| `QuasiMonteCarlo.jl` | low-discrepancy sampling |

**One shape for all of them**: build a *problem*, pick an *algorithm*, call `solve`.

```julia
using Optimization, OptimizationOptimJL, ForwardDiff

rosenbrock(u, p) = (p[1] - u[1])^2 + p[2] * (u[2] - u[1]^2)^2

f    = OptimizationFunction(rosenbrock, AutoForwardDiff())  # AD backend: one word
prob = OptimizationProblem(f, [0.0, 0.0], [1.0, 100.0])     # u0, p
sol  = solve(prob, BFGS())                                  # LBFGS(), NelderMead(), Ipopt.Optimizer(), ...

sol.u          # minimiser
sol.objective
```

`ODEProblem`, `NonlinearProblem`, `IntegralProblem` read exactly the same way.

!!! note "Spot the pattern"
	`Optimization.jl`, `MLJ.jl`, `DifferentiationInterface.jl`: a **thin shared interface**, many independent backends behind it. Change one line, keep the code.
"""

# ╔═╡ c6607e2d-46b4-4487-a78c-8c9096b7cca4
md"""
### Outside SciML
"""

# ╔═╡ e9380969-66f7-4e81-baac-e09821e6e5e8
md"""
!!! tip "Optimization"
	- [`JuMP.jl`](https://jump.dev/) -- algebraic modeling for LP/MILP/NLP/conic, its own DSL and its own solver list (HiGHS, Ipopt, Gurobi, ...)
	- [`Optim.jl`](https://github.com/JuliaNLSolvers/Optim.jl) -- the classic unconstrained/box-constrained solvers, pure Julia
	- [`Manopt.jl`](https://manoptjl.org/) + `Manifolds.jl` -- optimization on manifolds
	- `NLopt.jl`, `Ipopt.jl` -- thin wrappers over the reference C/Fortran libraries

!!! tip "PDE"
	- [`Ferrite.jl`](https://github.com/Ferrite-FEM/Ferrite.jl) -- finite elements, low level, you assemble yourself
	- [`Gridap.jl`](https://github.com/gridap/Gridap.jl) -- FEM written from the weak form, close to the maths
	- etc.
"""

# ╔═╡ 499176b7-20ab-4ca1-a3e5-c33b34c59c35
md"""
### Composability in action: Bayesian inference of ODE parameters
"""

# ╔═╡ 98688cd7-a0da-4ed7-a6d4-83c62a4904ee
Columns(
    md"""
    !!! warning "The task"
    	Given noisy data $(t_i, y_i)$, **recover the parameters $p$** of a dynamical system.
    	
    	**Example** -- predator/prey (Lotka–Volterra), $p = (\alpha, \beta, \gamma, \delta)$:
    	```math
    	\frac{\mathrm{d}u}{\mathrm{d}t} = f(u, p, t)
    	```
    	Fit the solution to the data, *and* quantify uncertainty on $p$ → **Bayesian inference**.
    """,
    md"""
    !!! danger "The monolithic nightmare"
    	One package would need to be expert in **all** of:
    	- ODE solvers
    	- optimization (not just derivative-free methods e.g. Nelder-Mead)
    	- automatic differentiation
    	- Bayesian sampling (MCMC)
    	
    	(+ likely some C/C++ glue) → hard to maintain
    """,
    widths=[55, 45], gap=1
)

# ╔═╡ 75a7cf61-10c7-4788-8e18-af5a28112c0d
md"""
!!! tip "The Julia way: assemble specialists"
	Each package does **one** thing well, and they **compose** out of the box:
"""

# ╔═╡ b49ef5bd-543c-4841-bb6b-40a588173efe
Columns(
    md"""
    | Package | Specialty |
    |:--|:--|
    | `OrdinaryDiffEq.jl` | solve the ODE |
    | `Turing.jl` | Bayesian inference (MCMC) |
    | `Optimization.jl` | find the best fit |
    | `ForwardDiff`/`Zygote` | differentiate the solver |
    """,
    md"""
    !!! note "Why it just works"
    	**Shared types + multiple dispatch**: Turing knows how to differentiate through the ODE solver, the solver accepts AD
    	
    	⇒ **No glue code, no rewrite.** Swap optimization for Bayesian by changing a few lines.
    """,
    widths=[45, 55], gap=0
)

# ╔═╡ 93b29b75-24f8-494a-a1f8-48b7d5a44b79
md"""
Live example: Optimization + ODEs + Bayesian (Pluto notebook) [`notebook_4_Optim_DiffEq.jl`](https://github.com/dmetivie/MyJuliaIntroDocs.jl/blob/master/notebooks/notebook_4_Optim_DiffEq.jl)

More details: [Chris Rackauckas — Probabilistic programming through differentiable programming](https://www.youtube.com/watch?v=rEwBxCBl92k)
"""

# ╔═╡ 05c088e3-572b-4bcd-aa60-5a8265dacfd7
md"""
## Calling other languages
"""

# ╔═╡ 109b6045-fdf3-41eb-977c-a6d5717cee8b
md"""
Interfaces with C(++), Python and R are solid and easy to use.
"""

# ╔═╡ 1081e62b-5575-461d-a293-53fd4db551d8
webpage("https://dmetivie.github.io/Pluto_export/SWG_coding_challenges/Talk_DM_quarto.html", ratio="75%")

# ╔═╡ 13328cb8-56c3-47bf-a375-0a5758492ebd
md"""
### Data
"""

# ╔═╡ 82c6dfe8-080a-4b8d-ae80-a6bfaafd3281
Columns(
    md"""
    !!! tip "Tables.jl: the ecosystem in one interface"
    	A tiny package whose only job is to define **what a table is**. Everything below speaks it, so they are interchangeable:

    	`DataFrames.jl`, `CSV.jl`, `Arrow.jl`, `DuckDB.jl`, `XLSX.jl`, etc.

    	Reference ecosystem: [JuliaData](https://github.com/JuliaData).
    """,
    md"""
    !!! note "In practice"
    	```julia
    	df = CSV.read("runs.csv", DataFrame)
    	Arrow.write("runs.arrow", df)
    	DuckDB.query(con, "SELECT ...") |> DataFrame
    	```

    	Any producer, any consumer, **no conversion code** -- and no copy at all for the columnar ones.

    	Same pattern as `Optimization.jl` and `DifferentiationInterface.jl`.
    """,
    widths=[50, 50], gap=1
)

# ╔═╡ d20b5ccc-280a-47fe-bf2d-5ece3bf370d7
DataFrame(
    date=[Date(2022, 2, 3), Date(2022, 2, 4), Date(2022, 2, 6), Date(2022, 2, 8)],
    mesh=[16, 32, 64, 128],
    dt=[1e-2, 5e-3, 2.5e-3, 1.25e-3],
    err=[4.1e-2, 1.03e-2, 2.6e-3, 6.4e-4],
)

# ╔═╡ 46dd0c2c-9460-4d9f-9f8b-df5dabd4daf1
md"""
`DataFrames.jl` is the workhorse, and it is fast: see the [H2O db-benchmark](https://h2oai.github.io/db-benchmark/) (groupby and join up to 1e9 rows).

**Then pick the grammar you already know:**

| front-end | feels like |
|:--|:--|
| `DataFramesMeta.jl` | `@chain`, `@rsubset`, `@transform` -- macro over DataFrames |
| `Tidier.jl` + `TidierPlots.jl` | R's `dplyr` / `ggplot2` |
| `Query.jl` | LINQ |
| `DuckDB.jl` | SQL |

They all consume and return the same tables, so you can mix them in one script.
"""

# ╔═╡ b49f8963-6f6c-423b-8559-3bf538f7ae88
webpage("https://tidierorg.github.io/Tidier.jl/v1.6.1/")

# ╔═╡ d7987ebe-ad03-4b64-b975-572c5f5cbcdb
md"""
## Plotting
"""

# ╔═╡ a85b075e-eabe-44c1-a8cd-bb3b31853a9a
# webpage("https://docs.makie.org/dev/")
md"""
Example **Makie.jl**: One API and lot of backends (static, interactive, web, raytracing, GPU, maps, ...)
"""

# ╔═╡ ec26ebf6-db22-407c-a56f-106a181cf69c
Columns(
    blockquote(
        md"""
        [...] The fact that a single plotting ecosystem can cover the entire spectrum from high-performance 3D scenes to publication-ready figures is just exceptional. [...]
        """,
        md"""Rémi Vezy, CIRAD, developer of [PlantGeom.jl](https://vezy.github.io/PlantGeom.jl/stable/) for plant-scale digital twins"""
    ),
    Resource("https://makie.org/website/bonito/png/plants9877348102989772360.png", :width=>600)
)

# ╔═╡ 03d44655-419c-4529-94c0-4fd7dc29b10c
webpage("https://makie.org/website/")

# ╔═╡ 762ea5df-f187-471c-bd77-941f6136edc3
md"""
## Agents
"""

# ╔═╡ a52ab745-7ebe-4c25-99e3-1f3e207320f2
webpage("https://juliadynamics.github.io/Agents.jl/stable/")

# ╔═╡ cb7ea381-1732-4578-8bf8-1d8839350371
md"""
## For Biologists
"""

# ╔═╡ 2b3d27a3-9814-4a18-b8e0-96fe8cde6f63
md"""
[This paper](https://www.nature.com/articles/s41592-023-01832-z) sells Julia pretty well for Biologists (and others)
"""

# ╔═╡ 7bdc98d0-86ff-431d-95ae-201da3ca8a83
Resource("https://media.springernature.com/full/springer-static/image/art%3A10.1038%2Fs41592-023-01832-z/MediaObjects/41592_2023_1832_Fig2_HTML.png?as=webp", :width => 1100)

# ╔═╡ cafb809f-a58f-442b-add0-faffa322e601
md"""
## Web application
"""

# ╔═╡ a240b703-7200-42c7-91cc-e7b9c6113684
webpage("https://phenoweathergame.institut-agro.fr/", ratio="60%", width="100%")

# ╔═╡ 1edf689e-2119-4007-be02-eb7aae43db3b
md"""
# Community
"""

# ╔═╡ 6426c5be-4336-4705-b37d-426d748f420d
md"""
## Julia features favor a lively community
"""

# ╔═╡ cc87181a-5b6f-4d02-bb11-0698530478b9
md"""
!!! note
	1. Composability $\Rightarrow$ **Code reuse**, connected community
	2. **One unique language favors contributions** (no need to both know C/C++ and Python/R)
	3. One unique language helps to **read other codes**. Example [`Exponential` distribution](https://github.com/JuliaStats/Distributions.jl/blob/master/src/univariate/continuous/exponential.jl) from `Distributions.jl`
"""

# ╔═╡ b62b5753-fb75-493e-ae37-75331384a747
md"""
- You can actually help improve both the **ecosystem** (packages) and the **language** itself
- Open source dev will teach you good programming practices
- Easier with LLMs
- The community is very helpful

!!! note "Fun Fact"
	I registered the [9,999th package](https://github.com/JuliaRegistries/General/pull/91965) `PeriodicHiddenMarkovModels.jl`. A few minutes later came the 10,000th one
"""

# ╔═╡ 1665a02f-6053-4a60-8cff-70bd0fe5dc93
md"""
## Events
"""

# ╔═╡ 4be1270c-be70-4bdd-a015-ad92ff765124
md"""
#### Every year: JuliaCon

- A great conference with plenty of topics
- Introductory tutorials
- Remote option
"""

# ╔═╡ 982de518-2ab6-4299-8624-c1074a880082
md"""
#### European JuliaCon
- JuliaCon Local Eindhoven 2023
- JuliaCon Local Paris 2025
"""

# ╔═╡ a47cced1-e43f-4c17-85b1-20c65df7ff32
md"""
#### France
"""

# ╔═╡ a0312030-1ade-42d3-9a5c-332ac0cffc7a
md"""
By Pierre Navaro
- Julia and Optimization Days (since 2022)
- [CNRS mailing list](https://listes.services.cnrs.fr/wws/subscribe/julia) newsletter
- Website
- Monthly talk [Café Julia](https://calcul.math.cnrs.fr/cafe-julia-5.html)


[**Julia4HPC : Formation au Langage Julia pour le Calcul Haute Performance**](https://julia4hpc.sciencesconf.org/?lang=fr) 12-16 oct. 2026 Frejus
"""

# ╔═╡ 2e92ad87-c34d-4828-9706-2d6e379790b6
md"""
# Packages
"""

# ╔═╡ b9a6db73-62bf-4b59-acee-4c30aac9eea0
md"""
## What is inside a package
"""

# ╔═╡ 148d022e-6aa3-4a55-b2f4-b56702c5ef48
md"""
```
MyPackage.jl/
├── Project.toml           # name, uuid, version, deps, [compat]
├── src/
│   └── MyPackage.jl       # the module: using/import, include(...), export
├── test/
│   └── runtests.jl        # ] test
├── docs/                  # Documenter.jl -> a website
├── ext/                   # extensions: loaded only if another package is
└── .github/workflows/     # CI, doc build, TagBot
```

!!! note "The folder has `.jl`, the module does not"
	`MyPackage.jl/` is the **repository**, `module MyPackage` is the **code**.
"""

# ╔═╡ c05cc8b3-14cd-4162-9e25-0a75fcd9a4e0
md"""
## Templates
"""

# ╔═╡ 9ccc7d0c-ada6-4db4-a6e5-fa3a8b365e20
md"""
You do not write those files by hand.

| | |
|:--|:--|
| [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl) | the classic, plugins à la carte |
| [`BestieTemplate.jl`](https://github.com/JuliaBesties/BestieTemplate.jl) | opinionated (`:tiny`, `:light`, full). Applies to an **existing** package too, one feature at a time |

- [Official guide: developing a package](https://julialang.org/contribute/developing_package/)
- [The BestieTemplate FAQ](https://juliabesties.github.io/BestieTemplate.jl/stable/30-questions/) explains what **every** generated file is for -- read it once, it saves hours
"""

# ╔═╡ c3c8a624-1e4f-473d-ac08-f70cf0ccd119
md"""
## Exercise: Fitting neural ODE with four handmade & independent packages 
"""

# ╔═╡ 8340f5b5-ba71-4701-9e58-a6cebdc06ecc
md"""
!!! note "Groups of four -- one package each"
	| who | package | provides |
	|:--|:--|:--|
	| 1 | `FrejusJuliaAD0` | derivatives, by dual numbers |
	| 2 | `FrejusJuliaODE0` | explicit Euler / RK4 |
	| 3 | `FrejusJuliaNeuralNetworks0` | dense layers, chain, flat parameter vector |
	| 4 | `FrejusJuliaOptimization0` | Newton, Gauss--Newton, gradient descent |

	At the end the four are assembled, **unchanged**, to train
	```math
	\frac{\mathrm{d}u}{\mathrm{d}t} = \mathrm{NeuralNetwork}(u)
	```
	on data.
"""

# ╔═╡ f9fd3f7a-ba90-4899-ba7d-102cfabf1b0a
md"""
## The two rules
"""

# ╔═╡ a10060ce-d713-4028-b966-664df23da4af
md"""
!!! danger "1. No package depends on any other"
	This is what lets the four of you work **in parallel**.

!!! danger "2. Write generic code"
	No `::Float64` in a signature, no `zeros(3)` where the element type should come from the input. Ask for the least you need.

$(pause())
!!! tip "Rule 2 is what makes rule 1 possible"
	The AD package will push its `Dual` numbers through the ODE solver and through the network -- code that has **never heard of a dual number**.

	Written generically, it works. 

	**That is the lesson of the afternoon.** See the `README.md` of the exercise.
"""

# ╔═╡ 717c91a4-d012-4769-b49d-271d6d30e1e8
md"""
# Conclusion
"""

# ╔═╡ 320a0bed-d778-4d39-99be-27f93ad5a263
md"""
## Conclusion
"""

# ╔═╡ e916b054-dce2-4f26-890c-5826f0a832c4
md"""
!!! note "One language"
	- **Multiple dispatch** + a single shared type system → naturally reusable, composable code
	- Reading, contributing to, and extending other people's packages requires *no* language switch
	
    ⇒ Favors **collaborative work** and a healthier open-source ecosystem

!!! tip "Efficiency without sacrificing expressiveness"
	- JIT compilation → C-level speed with high-level syntax
	- **Automatic differentiation out of the box** — not just for neural networks, but for *any* Julia code (ODEs, physical models, custom algorithms...)
	- Personal example: training a neural ODE for lake temperature forecasting — one coherent Julia pipeline, no glue code from data loading to model training to visualization

$(pause())
!!! warning "A rich, extensible ecosystem"
	- State-of-the-art packages: DataFrames.jl, DifferentialEquations.jl, Symbolics.jl, JuMP.jl, Makie.jl...
	- New packages compose easily with existing ones (no rewrite/glue code needed)
	- Seamless interoperability with **C, Python, R**, ... — keep your irreplaceable libraries

!!! tip "A great community"
	- One shared language lowers the barrier to contribution
	- Active forums, JuliaCon, local events (Café Julia, France...)
"""

# ╔═╡ bab7ce3d-4cee-487a-b5d6-cd08f8c1145b
md"""
# Resource
"""

# ╔═╡ 0a573998-6a80-4dad-99cb-6d9d56745b10
md"""
- [Modern Julia Workflows](https://modernjuliaworkflows.github.io/): A must-read for beginner and advanced users.
- [Julia Academy](https://juliaacademy.com/p/intro-to-julia) and here for the [first lecture video](https://www.youtube.com/watch?v=4igzy3bGVkQ&list=PLP8iPy9hna6SCcFv3FvY_qjAmtTsNYHQE)
- [DataFrames.jl Cheat Sheet](https://ahsmart.com/assets/pages/data-wrangling-with-data-frames-jl-cheat-sheet/DataFramesCheatSheet_v1.x_rev1.pdf?ref=juliafordatascience.com), also look at [DataFramesMeta.jl](https://juliadata.org/DataFramesMeta.jl/stable/)
- [Julia Data Science](https://juliadatascience.io/): Big overview aimed at data science
- [doggo dot jl Youtube videos](https://www.youtube.com/@doggodotjl) and [associated repo](https://github.com/julia4ta/tutorials): Tutorials over plenty of basic and advanced topics.
"""

# ╔═╡ 9794b531-30a4-46a3-97d2-443e6289ba6d
md"""
I should definitely add more!
"""

# ╔═╡ ad25926a-31e8-48c2-b22e-f96009a4872a
md"""
!!! warning
    Sometimes you will find resources that are a bit outdated. The language and packages have evolved quite rapidly over the past few years.
	Always check the dates. More than 3 years old might be too old.
"""

# ╔═╡ dcc8adf2-6354-4d2a-908d-5ec93b8f5bd2
md"""
# Appendix
"""

# ╔═╡ 4a5ba23a-df28-4f34-9f24-ae1a07c6e5c0
md"""
## Packages used
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
IntervalArithmetic = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
LogarithmicNumbers = "aa2f6b4e-9042-5d33-9679-40d3a6b85899"
MarkdownLiteral = "736d6165-7244-6769-4267-6b50796e6954"
Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoExtras = "ed5d0301-4775-4676-b788-cf71e66ff8ed"
PlutoLinks = "0ff47ea0-7a50-410d-8455-4348d5de0420"
PlutoSlides = "ccaada3e-fbb3-407e-96e9-78c3ad6e4026"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
ShortCodes = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"
Symbolics = "0c5d862f-8b57-4792-8d23-62f2024744c7"
Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[compat]
BenchmarkTools = "~1.8.0"
CairoMakie = "~0.15.15"
DataFrames = "~1.8.2"
Distributions = "~0.25.131"
HypertextLiteral = "~1.0.0"
IntervalArithmetic = "~1.0.12"
LogarithmicNumbers = "~1.4.1"
MarkdownLiteral = "~0.1.5"
Measurements = "~2.14.1"
PlutoExtras = "~0.7.19"
PlutoLinks = "~0.1.8"
PlutoSlides = "~0.3.4"
PlutoTeachingTools = "~0.4.7"
PlutoTest = "~0.2.4"
PlutoUI = "~0.7.83"
ShortCodes = "~0.4.3"
Symbolics = "~7.45.0"
Unitful = "~1.29.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.13.1"
manifest_format = "2.1"
project_hash = "03ae1504c01c706f07f5749318ce801f5d1b0045"

[[deps.ADTypes]]
deps = ["PrecompileTools"]
git-tree-sha1 = "629de23e1c16911b439dabd2303c08af9575b226"
registries = "General"
uuid = "47edcb42-4c32-4615-8424-f2b9edc5f35b"
version = "1.24.0"

    [deps.ADTypes.extensions]
    ADTypesChainRulesCoreExt = "ChainRulesCore"
    ADTypesConstructionBaseExt = "ConstructionBase"
    ADTypesEnzymeCoreExt = "EnzymeCore"

    [deps.ADTypes.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
registries = "General"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
git-tree-sha1 = "e71ee7b4aa06b045259a7d6101e1cb45ad140bce"
registries = "General"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.1"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
registries = "General"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "MacroTools"]
git-tree-sha1 = "7063ad1083578215c7c4bf410368150abe8d5524"
registries = "General"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.45"

    [deps.Accessors.extensions]
    AxisKeysExt = "AxisKeys"
    IntervalSetsExt = "IntervalSets"
    LinearAlgebraExt = "LinearAlgebra"
    StaticArraysExt = "StaticArrays"
    StructArraysExt = "StructArrays"
    TestExt = "Test"
    UnitfulExt = "Unitful"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "dee8388a9bec89c8713ad176f96960ae2f98598a"
registries = "General"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.7.4"
weakdeps = ["SparseArrays", "StaticArrays"]

    [deps.Adapt.extensions]
    AdaptSparseArraysExt = "SparseArrays"
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AdaptivePredicates]]
git-tree-sha1 = "7e651ea8d262d2d74ce75fdf47c4d63c07dba7a6"
registries = "General"
uuid = "35492f91-a3bd-45ad-95db-fcad7dcfedb7"
version = "1.2.0"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
registries = "General"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e092fa223bf66a3c41f9c022bd074d916dc303e7"
registries = "General"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "d57bd3762d308bded22c3b82d033bff85f6195c6"
registries = "General"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.4.0"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra"]
git-tree-sha1 = "1aec1ff0dcaa83a484e7f72097562fa3102c6722"
registries = "General"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.30.2"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceAMDGPUExt = "AMDGPU"
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceCUDSSExt = ["CUDSS", "CUDA"]
    ArrayInterfaceChainRulesCoreExt = "ChainRulesCore"
    ArrayInterfaceChainRulesExt = "ChainRules"
    ArrayInterfaceFillArraysExt = "FillArrays"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceGPUArraysCoreTrackerExt = ["GPUArraysCore", "Tracker"]
    ArrayInterfaceMetalExt = "Metal"
    ArrayInterfaceReverseDiffExt = "ReverseDiff"
    ArrayInterfaceSparseArraysExt = "SparseArrays"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    AMDGPU = "21141c5a-9bdb-4563-92ae-f87d6854732e"
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    CUDSS = "45b445bb-4962-46a0-9369-b4df9d0f772e"
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    FillArrays = "1a297f60-69ca-5386-bcde-b61e274b549b"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    Metal = "dde4c033-4e86-420c-a63e-0dd931031962"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Automa]]
deps = ["PrecompileTools", "TranscodingStreams"]
git-tree-sha1 = "94eab0b3ccdcac361188cc661daf69d4433c1818"
registries = "General"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "1.2.0"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "01b8ccb13d68535d73d2b0c23e39bd23155fb712"
registries = "General"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.1.0"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "4126b08903b777c88edf1754288144a0492c05ad"
registries = "General"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.8"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BaseDirs]]
git-tree-sha1 = "8c290a1b223deaeea9aea44b235d24546da8eb98"
registries = "General"
uuid = "18cc8868-cbac-4acf-b575-c8ff214dc66f"
version = "1.4.0"

[[deps.BenchmarkTools]]
deps = ["Compat", "JSON", "Logging", "PrecompileTools", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "9670d3febc2b6da60a0ae57846ba74670290653f"
registries = "General"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.8.0"

[[deps.Bijections]]
git-tree-sha1 = "a2d308fcd4c2fb90e943cf9cd2fbfa9c32b69733"
registries = "General"
uuid = "e2ed5e7c-b2de-5872-ae92-c73ca462fb04"
version = "0.2.2"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
registries = "General"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
registries = "General"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CRC32c]]
uuid = "8bf52ea8-c179-5cab-976a-9e18b702a9bc"
version = "1.11.0"

[[deps.CRlibm]]
deps = ["CRlibm_jll"]
git-tree-sha1 = "66188d9d103b92b6cd705214242e27f5737a1e5e"
registries = "General"
uuid = "96374032-68de-5a5b-8d9e-752f78720389"
version = "1.0.2"

[[deps.CRlibm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e329286945d0cfc04456972ea732551869af1cfc"
registries = "General"
uuid = "4e9b3aee-d8a1-5a3d-ad8b-7d824db253f0"
version = "1.0.1+0"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "71aa551c5c33f1a4415867fe06b7844faadb0ae9"
registries = "General"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.1.1"

[[deps.CairoMakie]]
deps = ["CRC32c", "Cairo", "Cairo_jll", "Colors", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "PrecompileTools"]
git-tree-sha1 = "1cda0b7d5abfc95357dae18aca934d401f7869ad"
registries = "General"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.15.15"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "7b841680738c19948120f6e4cf8d0200518bd564"
registries = "General"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.8+0"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9cb23bbb1127eefb022b022481466c0f1127d430"
registries = "General"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.2"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "12177ad6b3cad7fd50c8b3825ce24a99ad61c18f"
registries = "General"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.26.1"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "REPL", "UUIDs"]
git-tree-sha1 = "cfb7a2e89e245a9d5016b70323db412b3a7438d5"
registries = "General"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "3.0.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "970758a3d591a2a5c2a907c53f2e2f8c1b1d3537"
registries = "General"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.9"

[[deps.CodecZstd]]
deps = ["TranscodingStreams", "Zstd_jll"]
git-tree-sha1 = "da54a6cd93c54950c15adf1d336cfd7d71f51a56"
registries = "General"
uuid = "6b39b394-51ab-5f42-8807-6242bab2b4c2"
version = "0.8.7"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON"]
git-tree-sha1 = "07da79661b919001e6863b81fc572497daa58349"
registries = "General"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.2"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b0fd3f56fa442f81e0a47815c92245acfaaa4e34"
registries = "General"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.31.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "61761f58648aa7217445f24f841839b78c712232"
registries = "General"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.3"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
registries = "General"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Reexport"]
git-tree-sha1 = "291665b547f137df070e4dd83e432b5fee8cc4a0"
registries = "General"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.2"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
registries = "General"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.CommonMark]]
deps = ["PrecompileTools"]
git-tree-sha1 = "7c8fe02c7eb6fe22e89d3990123a2a931ca8fcfb"
registries = "General"
uuid = "a80b9123-70ca-4bc0-993e-6e3bcb318db6"
version = "1.0.4"

    [deps.CommonMark.extensions]
    CommonMarkMarkdownASTExt = "MarkdownAST"
    CommonMarkMarkdownExt = "Markdown"

    [deps.CommonMark.weakdeps]
    Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
    MarkdownAST = "d0879d2d-cac2-40c8-9cee-1863dc0c7391"

[[deps.CommonSolve]]
deps = ["PrecompileTools"]
git-tree-sha1 = "6c389fa857f6ca5a95474b52a52023fd77f24cb7"
registries = "General"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.14"

[[deps.CommonWorldInvalidations]]
deps = ["PrecompileTools"]
git-tree-sha1 = "7c4ea0adfb7238bf4678aa36325863fab6163f6f"
registries = "General"
uuid = "f70d9fcc-98c5-4d4a-abd7-e4cdeebd8ca8"
version = "1.2.2"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "9d8a54ce4b17aa5bdce0ea5c34bc5e7c340d16ad"
registries = "General"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.Compiler]]
git-tree-sha1 = "382d79bfe72a406294faca39ef0c3cef6e6ce1f1"
registries = "General"
uuid = "807dbc54-b67e-4c79-8afb-eafe4df6f2e1"
version = "0.1.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.5.5+2"

[[deps.CompositeTypes]]
git-tree-sha1 = "bce26c3dab336582805503bed209faab1c279768"
registries = "General"
uuid = "b152e2b5-7a66-4b01-a709-34e65c35f657"
version = "0.1.4"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
registries = "General"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ComputePipeline]]
deps = ["Observables", "Preferences"]
git-tree-sha1 = "7bc84b769c1d384315e7b5c4ac03a6c303e6cf35"
registries = "General"
uuid = "95dc2771-c249-4cd0-9c9f-1f3b4330693c"
version = "0.1.8"

[[deps.ConstructionBase]]
git-tree-sha1 = "b4b092499347b18a015186eae3042f72267106cb"
registries = "General"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.6.0"
weakdeps = ["IntervalSets", "LinearAlgebra", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
registries = "General"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.CoreMath]]
deps = ["CoreMath_jll"]
git-tree-sha1 = "8c0480f92b1b1796239156a1b9b1bfb1b39499b4"
registries = "General"
uuid = "b7a15901-be09-4a0e-87d2-2e66b0e09b5a"
version = "0.1.0"

[[deps.CoreMath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a692a4c1dc59a4b8bc0b6403876eb3250fde2bc3"
registries = "General"
uuid = "a38c48d9-6df1-5ac9-9223-b6ada3b5572b"
version = "0.1.0+0"

[[deps.Crayons]]
git-tree-sha1 = "54b76cbb40d9a0f5368c880725b2f141da77c94f"
registries = "General"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.2.0"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
registries = "General"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "5fab31e2e01e70ad66e3e24c968c264d1cf166d6"
registries = "General"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.8.2"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "b0bc6d2cad1fed8b7fd59a1551a991cb3d2809e6"
registries = "General"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.6"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
registries = "General"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DelaunayTriangulation]]
deps = ["AdaptivePredicates", "EnumX", "ExactPredicates", "Random"]
git-tree-sha1 = "4ac548adcad90c1d5d677af13568a748af4c952b"
registries = "General"
uuid = "927a84f5-c5f4-47a5-9785-b46e178433df"
version = "1.6.7"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "79a2aca180a85c690c58a020d47b426954b590f8"
registries = "General"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.16.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "Roots", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "a958ab3a40c755563f5e1405c0846cb0446bf19d"
registries = "General"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.131"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsSparseConnectivityTracerExt = "SparseConnectivityTracer"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    SparseConnectivityTracer = "9f842d2f-2579-4b1d-911e-f412cf18a3f5"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
registries = "General"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.DomainSets]]
deps = ["CompositeTypes", "FunctionMaps", "IntervalSets", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "6ac879a64381881dc24f96a15e13e80204439906"
registries = "General"
uuid = "5b8099bc-c8ec-5219-889f-1d9e522a28bf"
version = "0.8.3"
weakdeps = ["Makie", "Random", "RecipesBase"]

    [deps.DomainSets.extensions]
    DomainSetsMakieExt = "Makie"
    DomainSetsRandomExt = "Random"
    DomainSetsRecipesBaseExt = "RecipesBase"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.DynamicPolynomials]]
deps = ["LinearAlgebra", "MultivariatePolynomials", "MutableArithmetics", "Reexport", "StarAlgebras"]
git-tree-sha1 = "b95c4325301d86a6a1b59790b71f7269a8702dd5"
registries = "General"
uuid = "7c1d4256-1411-5781-91ec-d7bc3513ac07"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
registries = "General"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.EnumX]]
git-tree-sha1 = "c49898e8438c828577f04b92fc9368c388ac783c"
registries = "General"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.7"

[[deps.ExactPredicates]]
deps = ["IntervalArithmetic", "Random", "StaticArrays"]
git-tree-sha1 = "83231673ea4d3d6008ac74dc5079e77ab2209d8f"
registries = "General"
uuid = "429591f6-91af-11e9-00e2-59fbe8cec110"
version = "2.2.9"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "2bfb1e047e2ad0a5ca94365340bde8005d637568"
registries = "General"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.8.4+0"

[[deps.ExprTools]]
git-tree-sha1 = "d2e49e7efd29719d6f28b891b0e0e159daa9d2b4"
registries = "General"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.11"

[[deps.ExproniconLite]]
git-tree-sha1 = "c13f0b150373771b0fdc1713c97860f8df12e6c2"
registries = "General"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.10.14"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libva_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d9d3cd382f2c999f684e6bfa4039fcc16c153b6f"
registries = "General"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "9.0.2+0"

[[deps.FFTA]]
deps = ["AbstractFFTs", "DocStringExtensions", "LinearAlgebra", "MuladdMacro", "Primes", "Random", "Reexport"]
git-tree-sha1 = "65e55303b72f4a567a51b174dd2c47496efeb95a"
registries = "General"
uuid = "b86e33f2-c0db-4aa1-a6e0-ab43e668529e"
version = "0.3.1"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "6621fef488e496356c9c9625d0562c12a6070819"
registries = "General"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.20.0"

    [deps.FileIO.extensions]
    HTTPExt = "HTTP"

    [deps.FileIO.weakdeps]
    HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"

[[deps.FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport"]
git-tree-sha1 = "a1b2fbfe98503f15b665ed45b3d149e5d8895e4c"
registries = "General"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.9.0"

    [deps.FilePaths.extensions]
    FilePathsGlobExt = "Glob"
    FilePathsURIParserExt = "URIParser"
    FilePathsURIsExt = "URIs"

    [deps.FilePaths.weakdeps]
    Glob = "c27321d9-0574-5035-807b-f59d2c89b15c"
    URIParser = "30578b45-9adc-5946-b283-645ec420af67"
    URIs = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "3bab2c5aa25e7840a4b065805c0cdfc01f3068d2"
registries = "General"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.24"
weakdeps = ["Mmap", "Test"]

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "086b5fbd032baf544678cc15b52b015e4c4aceb8"
registries = "General"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.17.1"
weakdeps = ["PDMats", "SparseArrays", "StaticArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStaticArraysExt = "StaticArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
registries = "General"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
registries = "General"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
registries = "General"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "907369da0f8e80728ab49c1c7e09327bf0d6d999"
registries = "General"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.1.1"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "70329abc09b886fd2c5d94ad2d9527639c421e3e"
registries = "General"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.14.3+1"

[[deps.FreeTypeAbstraction]]
deps = ["BaseDirs", "ColorVectorSpace", "Colors", "FreeType", "GeometryBasics", "Mmap"]
git-tree-sha1 = "4ebb930ef4a43817991ba35db6317a05e59abd11"
registries = "General"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.8"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
registries = "General"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.FunctionMaps]]
deps = ["CompositeTypes", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "31bd99a57edf98990d1c21486032963955450e8d"
registries = "General"
uuid = "a85aefff-f8ca-4649-a888-c8e5398bc76c"
version = "0.1.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.Gamma]]
deps = ["LogExpFunctions"]
git-tree-sha1 = "becc397f7cfb06e343496ae6ffb04818a851da51"
registries = "General"
uuid = "a0844989-3bd2-4988-8bea-c9407ab0941b"
version = "1.2.0"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "LinearAlgebra", "PrecompileTools", "Random", "StaticArrays"]
git-tree-sha1 = "ec46c5825710fa1a15d468acb2d93cc939a7a5fe"
registries = "General"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.5.13"

    [deps.GeometryBasics.extensions]
    ExtentsExt = "Extents"
    GeometryBasicsGeoInterfaceExt = "GeoInterface"
    IntervalSetsExt = "IntervalSets"

    [deps.GeometryBasics.weakdeps]
    Extents = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
    GeoInterface = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
registries = "General"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
registries = "General"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Giflib_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3efbbc027441271444dcd0c0a46f2d119dc4329"
registries = "General"
uuid = "59f7168a-df46-5410-90c8-f2779963d0ec"
version = "6.1.3+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "090526e65de8f69648ac156daae153de8b56df62"
registries = "General"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.88.3+0"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "a641238db938fff9b2f60d08ed9030387daf428c"
registries = "General"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.3"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "69ffb934a5c5b7e086a0b4fee3427db2556fba6e"
registries = "General"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.16+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "DataStructures", "Inflate", "LinearAlgebra", "Random", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "dbb2b976f605b220dfe139d6db9f3859680da09e"
registries = "General"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.15.0"
weakdeps = ["Distributed", "SharedArrays"]

    [deps.Graphs.extensions]
    GraphsSharedArraysExt = "SharedArrays"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "ef70da5e123a06a29e2d6ddff0f09985bc226491"
registries = "General"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.11.3"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "9d9531a9cb63a9edc33836414e82a07e81710de2"
registries = "General"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "100.14004.0+0"

[[deps.HypergeometricFunctions]]
deps = ["Gamma", "LinearAlgebra"]
git-tree-sha1 = "31bb6c92405c084617facc1d7ed9eb6c402d061e"
registries = "General"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.30"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
registries = "General"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
registries = "General"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
registries = "General"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "e12629406c6c4442539436581041d372d69c55ba"
registries = "General"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.12"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
registries = "General"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageCore]]
deps = ["ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "8c193230235bbcee22c8066b0374f63b5683c2d3"
registries = "General"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.5"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs", "WebP"]
git-tree-sha1 = "f0f005f997dfb8c5fe23920d99458a9619873893"
registries = "General"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.10"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "2a81c3897be6fbcde0802a0ebe6796d0562f63ec"
registries = "General"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.10"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "dcc8d0cd653e55213df9b75ebc6fe4a8d3254c65"
registries = "General"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.2.2+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
registries = "General"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
registries = "General"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.InlineStrings]]
git-tree-sha1 = "06b65886c7577a3784d616e29f1302c2e36e389d"
registries = "General"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.6"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.IntegerMathUtils]]
git-tree-sha1 = "c72458f1962faeb003bf23cbdb75164fe6280906"
registries = "General"
uuid = "18e54dd8-cb9d-406c-a71d-865a43cbb235"
version = "0.1.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "48922d06068130f87e43edef52382e6a94305ae6"
registries = "General"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.16.3"

    [deps.Interpolations.extensions]
    InterpolationsForwardDiffExt = "ForwardDiff"
    InterpolationsUnitfulExt = "Unitful"

    [deps.Interpolations.weakdeps]
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.IntervalArithmetic]]
deps = ["CRlibm", "CoreMath", "MacroTools", "OpenBLASConsistentFPCSR_jll", "Printf", "Random", "RoundingEmulator"]
git-tree-sha1 = "1c531bf0f8a5c60a340926e058fd3f209b5eef5d"
registries = "General"
uuid = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
version = "1.0.12"

    [deps.IntervalArithmetic.extensions]
    IntervalArithmeticArblibExt = "Arblib"
    IntervalArithmeticDiffRulesExt = "DiffRules"
    IntervalArithmeticForwardDiffExt = "ForwardDiff"
    IntervalArithmeticIntervalSetsExt = "IntervalSets"
    IntervalArithmeticIrrationalConstantsExt = "IrrationalConstants"
    IntervalArithmeticLinearAlgebraExt = "LinearAlgebra"
    IntervalArithmeticMakieExt = "Makie"
    IntervalArithmeticRecipesBaseExt = "RecipesBase"
    IntervalArithmeticSparseArraysExt = "SparseArrays"

    [deps.IntervalArithmetic.weakdeps]
    Arblib = "fb37089c-8514-4489-9461-98f9c8763369"
    DiffRules = "b552c78f-8df3-52c6-915a-8e097449b14b"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    IrrationalConstants = "92d709cd-6900-40b7-9082-c6be49f344b6"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.IntervalSets]]
git-tree-sha1 = "0db6aea5b64caa1c47e9fdd27394f0296f05e8bf"
registries = "General"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.15"
weakdeps = ["Makie", "Random", "RecipesBase", "Statistics"]

    [deps.IntervalSets.extensions]
    IntervalSetsMakieExt = "Makie"
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

[[deps.InverseFunctions]]
git-tree-sha1 = "a779299d77cd080bf77b97535acecd73e1c5e5cb"
registries = "General"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.17"
weakdeps = ["Dates", "Test"]

    [deps.InverseFunctions.extensions]
    InverseFunctionsDatesExt = "Dates"
    InverseFunctionsTestExt = "Test"

[[deps.InvertedIndices]]
git-tree-sha1 = "6da3c4316095de0f5ee2ebd875df8721e7e0bdbe"
registries = "General"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.1"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
registries = "General"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
registries = "General"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
registries = "General"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
registries = "General"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
registries = "General"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "4657a834b01ce00f2b94546095c4350617b9af2c"
registries = "General"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.10.0"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.Jieko]]
deps = ["ExproniconLite"]
git-tree-sha1 = "2f05ed29618da60c06a87e9c033982d4f71d0b6c"
registries = "General"
uuid = "ae98c720-c025-4a4a-838c-29b094483192"
version = "0.2.1"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "9496de8fb52c224a2e3f9ff403947674517317d9"
registries = "General"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.6"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "037babc10853eeb8e585418922246cb97b8e5b74"
registries = "General"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.2.0+1"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random"]
git-tree-sha1 = "210525997a2434caa497655f86d151b1bcad0dce"
registries = "General"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.12.0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTA", "Interpolations", "StatsBase"]
git-tree-sha1 = "9eda8292dd3268b3b7ec9df21bbfac24e177ec52"
registries = "General"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.12"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
registries = "General"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "39bca05343661c347aae0bca57a5994a0bf4f08d"
registries = "General"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.2.0+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e5b100780d4d30d63b4618d7930d48af409c1772"
registries = "General"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "23.1.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f88f3ccef05a6a72a0cf0ed417c8fd68530f4ab2"
registries = "General"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.1"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "df7566479bd64f20bd16b09960145e70160ffb3b"
registries = "General"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.12"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
registries = "General"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "1.0.0"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "Zstd_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.18.0+1"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "PCRE2_jll", "Zlib_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.1+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl", "OpenSSL_jll", "Zlib_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.104+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
registries = "General"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
registries = "General"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
registries = "General"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc3ad4faf30015a3e8094c9b5b7f19e85bdf2386"
registries = "General"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.42.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "aebd334d06cee9f24cea70bd19a39749daf73881"
registries = "General"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.3+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d620582b1f0cbe2c72dd1d5bd195a9ce73370ab1"
registries = "General"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.42.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.13.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "b85e2797b2409570e84c4de46238c0ed5f6476ae"
registries = "General"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "1.0.2"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.LogarithmicNumbers]]
deps = ["Random"]
git-tree-sha1 = "34828f5fd2583085e2a73d444f6317327826ab50"
registries = "General"
uuid = "aa2f6b4e-9042-5d33-9679-40d3a6b85899"
version = "1.4.1"

    [deps.LogarithmicNumbers.extensions]
    LogarithmicNumbersForwardDiffExt = "ForwardDiff"

    [deps.LogarithmicNumbers.weakdeps]
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoweredCodeUtils]]
deps = ["CodeTracking", "Compiler", "JuliaInterpreter"]
git-tree-sha1 = "497f602dc6d4d894e000ad6ee13b6dfd3c0be94a"
registries = "General"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "3.10.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
registries = "General"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
registries = "General"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Makie]]
deps = ["Animations", "Base64", "CRC32c", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "ComputePipeline", "Contour", "Dates", "DelaunayTriangulation", "Distributions", "DocStringExtensions", "Downloads", "FFMPEG_jll", "FileIO", "FilePaths", "FixedPointNumbers", "Format", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageBase", "ImageIO", "InteractiveUtils", "Interpolations", "IntervalSets", "InverseFunctions", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MacroTools", "Markdown", "MathTeXEngine", "Observables", "OffsetArrays", "PNGFiles", "Packing", "Pkg", "PlotUtils", "PolygonOps", "PrecompileTools", "Printf", "REPL", "Random", "RelocatableFolders", "Scratch", "ShaderAbstractions", "SignedDistanceFields", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun", "Unitful"]
git-tree-sha1 = "5f6f5d1b1fb7ff98c9a083bbfd4c661a9808e758"
registries = "General"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.24.15"

    [deps.Makie.extensions]
    MakieDynamicQuantitiesExt = "DynamicQuantities"

    [deps.Makie.weakdeps]
    DynamicQuantities = "06fc5a27-2a28-4c7c-a15d-362465fb6821"

[[deps.MappedArrays]]
git-tree-sha1 = "0ee4497a4e80dbd29c058fcee6493f5219556f40"
registries = "General"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.3"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MarkdownLiteral]]
deps = ["CommonMark", "HypertextLiteral"]
git-tree-sha1 = "e88f9af659a0cc9326fa464427f71ae6c9a83381"
registries = "General"
uuid = "736d6165-7244-6769-4267-6b50796e6954"
version = "0.1.5"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "UnicodeFun"]
git-tree-sha1 = "aa1078778be5a8e5259ff04fbc3d258b3e78d464"
registries = "General"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.6.9"

[[deps.Measurements]]
deps = ["Calculus", "LinearAlgebra", "Printf"]
git-tree-sha1 = "cb47f69a1cab9dcec7ff4a5d6e163410d6905866"
registries = "General"
uuid = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
version = "2.14.1"

    [deps.Measurements.extensions]
    MeasurementsBaseTypeExt = "BaseType"
    MeasurementsJunoExt = "Juno"
    MeasurementsMakieExt = "Makie"
    MeasurementsRecipesBaseExt = "RecipesBase"
    MeasurementsSpecialFunctionsExt = "SpecialFunctions"
    MeasurementsUnitfulExt = "Unitful"

    [deps.Measurements.weakdeps]
    BaseType = "7fbed51b-1ef5-4d67-9085-a4a9b26f478c"
    Juno = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
    Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
registries = "General"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
registries = "General"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
registries = "General"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.Moshi]]
deps = ["ExproniconLite", "Jieko"]
git-tree-sha1 = "3f234cf937eb1d58f613440ecb022da784ad34d4"
registries = "General"
uuid = "2e0e35c7-a2e4-4343-998d-7ef72827ed2d"
version = "0.3.13"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2026.8.13"

[[deps.MuladdMacro]]
deps = ["PrecompileTools"]
git-tree-sha1 = "283bf85d4a767481dd924dff0eee1735e95f449e"
registries = "General"
uuid = "46d2c3a1-f734-5fdb-9937-b9b9aeba4221"
version = "0.2.7"

[[deps.MultivariatePolynomials]]
deps = ["DataStructures", "LinearAlgebra", "MutableArithmetics", "StarAlgebras"]
git-tree-sha1 = "65f1160de342181533efa7061f86539d420ab81d"
registries = "General"
uuid = "102ac46a-7ee4-5c85-9060-abc95bfdeaa3"
version = "0.5.20"
weakdeps = ["ChainRulesCore", "Latexify"]

    [deps.MultivariatePolynomials.extensions]
    LatexifyExt = "Latexify"
    MultivariatePolynomialsChainRulesCoreExt = "ChainRulesCore"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "7fc67976fca2c577ca96257061e4785463bb9fb8"
registries = "General"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.8.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "dbd2e8cd2c1c27f0b584f6661b4309609c5a685e"
registries = "General"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.4"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
registries = "General"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
registries = "General"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.OffsetArrays]]
git-tree-sha1 = "117432e406b5c023f665fa73dc26e79ec3630151"
registries = "General"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.17.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
registries = "General"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLASConsistentFPCSR_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "38a93f17e431141c6470bb67a88952a7c4f0e928"
registries = "General"
uuid = "6cdc7f73-28fd-5e50-80fb-958a8875b1af"
version = "0.3.34+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.30+0"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "97db9e07fe2091882c765380ef58ec553074e9c7"
registries = "General"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.3"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e9ae72527609bb66882d38ad009ffd47ca5713fb"
registries = "General"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.4.16+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.6+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
registries = "General"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e2bb57a313a74b8104064b7efd01406c0a50d2ff"
registries = "General"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.6.1+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "f9b03759e9ef463718934fbed30820b39997511e"
registries = "General"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "2.0.2"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.46.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "123266c25174ef6c8d4718920abc206452cf8de6"
registries = "General"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.41"
weakdeps = ["StatsBase"]

    [deps.PDMats.extensions]
    StatsBaseExt = "StatsBase"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "32b657a0d57c310a1a172bfc8c8cf68c5e674323"
registries = "General"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.5"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "bc5bf2ea3d5351edf285a06b0016788a121ce92c"
registries = "General"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.5.1"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
registries = "General"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1912a9f1b9ca55005b03ba075f8e19993583e237"
registries = "General"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.58.2+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools"]
git-tree-sha1 = "663e8b48b789916221e0765393b289ca6c88f24e"
registries = "General"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "3.0.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "e4a6721aa89e62e5d4217c0b21bd714263779dda"
registries = "General"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.46.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "Zstd_jll", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.13.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
registries = "General"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Reexport", "Statistics"]
git-tree-sha1 = "ddcc36fd83fb4cd459a53c891981697bde0d3de6"
registries = "General"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.5.1"

[[deps.PlutoExtras]]
deps = ["AbstractPlutoDingetjes", "DocStringExtensions", "HypertextLiteral", "InteractiveUtils", "Markdown", "PlutoUI", "REPL", "Random"]
git-tree-sha1 = "4c22e592ee2013d9da1275d0134c35fdffceb25d"
registries = "General"
uuid = "ed5d0301-4775-4676-b788-cf71e66ff8ed"
version = "0.7.19"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "844a829c8dc9fd0fe62eced22bc2d0dfd66a3f51"
registries = "General"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.1.0"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "aea4eede5ab3ee188906d0cf3bbfa36eb543dccc"
registries = "General"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.8"

[[deps.PlutoSlides]]
deps = ["Base64", "HypertextLiteral", "MIMEs", "PlutoUI", "Printf"]
git-tree-sha1 = "cbc70c10ce285d0f334023e5da3634dee4e5dc8f"
registries = "General"
uuid = "ccaada3e-fbb3-407e-96e9-78c3ad6e4026"
version = "0.3.4"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "Latexify", "Markdown", "PlutoUI"]
git-tree-sha1 = "90b41ced6bacd8c01bd05da8aed35c5458891749"
registries = "General"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.4.7"

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "09d065f418b85a6ea4be2236d2f33dd720fb1d2a"
registries = "General"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.4"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e189d0623e7ce9c37389bac17e80aac3b0302e75"
registries = "General"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.83"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
registries = "General"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
registries = "General"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "edbeefc7a4889f528644251bdb5fc9ab5348bc2c"
registries = "General"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "5005266de4bfe50e53ff44a5cb5c540b6e47a254"
registries = "General"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.6.0"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "REPL", "Reexport", "StringManipulation", "StyledStrings", "Tables"]
git-tree-sha1 = "99fd8f32ab6728ff205cddd24e2d9ea6cbb498d3"
registries = "General"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "3.5.0"

    [deps.PrettyTables.extensions]
    PrettyTablesExcelExt = "XLSX"
    PrettyTablesTypstryExt = "Typstry"
    PrettyTablesWriteDocxExt = "WriteDocx"

    [deps.PrettyTables.weakdeps]
    Typstry = "f0ed7684-a786-439e-b1e3-3b82803b501e"
    WriteDocx = "d049ceea-54ee-41d7-a26f-ba29db3b6599"
    XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[[deps.Primes]]
deps = ["IntegerMathUtils"]
git-tree-sha1 = "25cdd1d20cd005b52fc12cb6be3f75faaf59bb9b"
registries = "General"
uuid = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"
version = "0.5.7"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Profile]]
deps = ["StyledStrings"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "fbb92c6c56b34e1a2c4c36058f68f332bec840e7"
registries = "General"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
registries = "General"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "472daaa816895cb7aee81658d4e7aec901fa1106"
registries = "General"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "5e8e8b0ab68215d7a2b14b9921a946fee794749e"
registries = "General"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.3"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["Base64", "Dates", "FileWatching", "InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
registries = "General"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
registries = "General"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.ReadOnlyArrays]]
git-tree-sha1 = "e6f7ddf48cf141cb312b078ca21cb2d29d0dc11d"
registries = "General"
uuid = "988b38a3-91fc-5605-94a2-ee2116b3bd83"
version = "0.2.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "0c0dcffc464cda2ff33fc8ffc1dd1bdd53cd98be"
registries = "General"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.4.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
registries = "General"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
registries = "General"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
registries = "General"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.Revise]]
deps = ["CRC32c", "CodeTracking", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Preferences", "REPL", "UUIDs"]
git-tree-sha1 = "177e0fc0e89b18c567e90d04f841a8304b22f097"
registries = "General"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.17.2"
weakdeps = ["Distributed"]

    [deps.Revise.extensions]
    DistributedExt = "Distributed"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "5b3d50eb374cea306873b371d3f8d3915a018f0b"
registries = "General"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.9.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6d40b2fe70437b01397d2a4d5b020008da4e7019"
registries = "General"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.2+0"

[[deps.Roots]]
deps = ["Accessors", "CommonSolve", "Printf"]
git-tree-sha1 = "e6ffa7bd4f8d0b8744d18f219304738d952f9a37"
registries = "General"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "3.0.11"

    [deps.Roots.extensions]
    RootsChainRulesCoreExt = "ChainRulesCore"
    RootsForwardDiffExt = "ForwardDiff"
    RootsIntervalRootFindingExt = "IntervalRootFinding"
    RootsSymPyExt = "SymPy"
    RootsSymPyPythonCallExt = "SymPyPythonCall"
    RootsUnitfulExt = "Unitful"

    [deps.Roots.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalRootFinding = "d2bf35a9-74e0-55ec-b149-d360ff49b807"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
    SymPyPythonCall = "bc8888f7-b21e-4b7c-a06a-5d9c9496438c"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.RoundingEmulator]]
git-tree-sha1 = "40b9edad2e5287e05bd413a38f61a8ff55b9557b"
registries = "General"
uuid = "5eaf0fd0-dfba-4ccb-bf02-d820a40db705"
version = "0.2.1"

[[deps.RuntimeGeneratedFunctions]]
deps = ["ExprTools", "PrecompileTools", "SHA", "Serialization"]
git-tree-sha1 = "9bb075002b40849582905394bb3031fb77aa102d"
registries = "General"
uuid = "7e49a35a-f44a-4d26-94aa-eba1b4ca6b47"
version = "0.5.27"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "1.0.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "e24dc23107d426a096d3eae6c165b921e74c18e4"
registries = "General"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.7.2"

[[deps.SciMLPublic]]
deps = ["PrecompileTools"]
git-tree-sha1 = "74685afb51732a464fbce79a72708f7c4203ceb7"
registries = "General"
uuid = "431bcebd-1456-4ced-9d72-93c2757fff0b"
version = "1.3.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
registries = "General"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "084c47c7c5ce5cfecefa0a98dff69eb3646b5a80"
registries = "General"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.10"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "c5391c6ace3bc430ca630251d02ea9687169ca68"
registries = "General"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.2"

[[deps.ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays"]
git-tree-sha1 = "57aa595158717ef165e6f5ab639fe2e3178c0a2b"
registries = "General"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.5.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
version = "1.11.0"

[[deps.ShortCodes]]
deps = ["Base64", "CodecZlib", "Downloads", "JSON", "LinearAlgebra", "Memoize", "URIs", "UUIDs"]
git-tree-sha1 = "dfd33ccf2c15de2d1a5c53b7ca45eb3a39241f8d"
registries = "General"
uuid = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"
version = "0.4.3"

    [deps.ShortCodes.extensions]
    QRCodersExt = "QRCoders"

    [deps.ShortCodes.weakdeps]
    QRCoders = "f42e9828-16f3-11ed-2883-9126170b272d"

[[deps.SignedDistanceFields]]
deps = ["Statistics"]
git-tree-sha1 = "3949ad92e1c9d2ff0cd4a1317d5ecbba682f4b92"
registries = "General"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.1"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "7ddb0b49c109481b046972c0e4ab02b2127d6a75"
registries = "General"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.6"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "2c79185e5261b159474903598c571ddd9f12ff7b"
registries = "General"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.6"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "13cd91cc9be159e3f4d95b857fa2aa383b53772a"
registries = "General"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.3"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.13.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "429071b23f4c9a13fb6582f807cc2ef454082408"
registries = "General"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.9.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "be1cf4eb0ac528d96f5115b4ed80c26a8d8ae621"
registries = "General"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.2"

[[deps.StarAlgebras]]
deps = ["LinearAlgebra", "MutableArithmetics", "SparseArrays"]
git-tree-sha1 = "235b1f9d287bbf34083b3d0829343a7942c0ad1c"
registries = "General"
uuid = "0c0c59c1-dc5f-42e9-9a8b-b5dc384a6cd1"
version = "0.3.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "de349d5585559b692f518b6d3fc7c179d64b2364"
registries = "General"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.23"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6ab403037779dae8c514bad259f32a447262455a"
registries = "General"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.4"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
registries = "General"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
registries = "General"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "adb9da019510162e67a4493fc235c23203d8b09e"
registries = "General"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.13"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "91a5737baed20ee31f3faea0e51f57461f6a689e"
registries = "General"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "2.2.1"
weakdeps = ["ChainRulesCore", "InverseFunctions"]

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

[[deps.StringManipulation]]
deps = ["PrecompileTools", "StyledStrings"]
git-tree-sha1 = "9e3a02d73a8f0a9be04e677dbef758aab40f8bea"
registries = "General"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.6.1"

[[deps.StructArrays]]
deps = ["ConstructionBase", "DataAPI", "Tables"]
git-tree-sha1 = "ad8002667372439f2e3611cfd14097e03fa4bccd"
registries = "General"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.7.3"

    [deps.StructArrays.extensions]
    StructArraysAdaptExt = "Adapt"
    StructArraysGPUArraysCoreExt = ["GPUArraysCore", "KernelAbstractions"]
    StructArraysLinearAlgebraExt = "LinearAlgebra"
    StructArraysSparseArraysExt = "SparseArrays"
    StructArraysStaticArraysExt = "StaticArrays"

    [deps.StructArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "b814d5005d6a529d740ffe06f8a86396f6501138"
registries = "General"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.9.2"

    [deps.StructUtils.extensions]
    StructUtilsLazilyInitializedFieldsExt = ["LazilyInitializedFields"]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    LazilyInitializedFields = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.10.1+0"

[[deps.SymbolicIndexingInterface]]
deps = ["Accessors", "ArrayInterface", "PrecompileTools", "RuntimeGeneratedFunctions", "StaticArraysCore"]
git-tree-sha1 = "7eb6da9656581ac9fbffaef3ef7950a090a5002a"
registries = "General"
uuid = "2efcf032-c050-4f8e-a9bb-153293bab1f5"
version = "0.3.55"
weakdeps = ["PrettyTables"]

    [deps.SymbolicIndexingInterface.extensions]
    SymbolicIndexingInterfacePrettyTablesExt = "PrettyTables"

[[deps.SymbolicLimits]]
deps = ["PrecompileTools", "SymbolicUtils", "TermInterface"]
git-tree-sha1 = "3780b4d8aaa1db8996a67146ac7d4ac20606f56e"
registries = "General"
uuid = "19f23fe9-fdab-4a78-91af-e7b7767979c3"
version = "1.2.1"

[[deps.SymbolicUtils]]
deps = ["AbstractTrees", "ArrayInterface", "Combinatorics", "ConstructionBase", "DataStructures", "DocStringExtensions", "DynamicPolynomials", "EnumX", "ExproniconLite", "Graphs", "LinearAlgebra", "MacroTools", "Moshi", "MultivariatePolynomials", "MutableArithmetics", "NaNMath", "OrderedCollections", "PrecompileTools", "ReadOnlyArrays", "SciMLPublic", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArraysCore", "SymbolicIndexingInterface", "TaskLocalValues", "TermInterface", "WeakCacheSets"]
git-tree-sha1 = "e7fe3d29734bafc2bf6fee1d4584c6c00259af79"
registries = "General"
uuid = "d1185830-fcd6-423d-90d6-eec64667417b"
version = "4.50.0"

    [deps.SymbolicUtils.extensions]
    SymbolicUtilsChainRulesCoreExt = "ChainRulesCore"
    SymbolicUtilsDistributionsExt = "Distributions"
    SymbolicUtilsLabelledArraysExt = "LabelledArrays"
    SymbolicUtilsReverseDiffExt = "ReverseDiff"

    [deps.SymbolicUtils.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
    LabelledArrays = "2ee39098-c373-598a-b85f-a56591580800"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"

[[deps.Symbolics]]
deps = ["ADTypes", "AbstractPlutoDingetjes", "ArrayInterface", "Bijections", "CommonWorldInvalidations", "ConstructionBase", "DataStructures", "DiffRules", "DocStringExtensions", "DomainSets", "DynamicPolynomials", "IntervalSets", "Libdl", "LinearAlgebra", "LogExpFunctions", "MacroTools", "Markdown", "Moshi", "MultivariatePolynomials", "MutableArithmetics", "NaNMath", "PrecompileTools", "Preferences", "Primes", "RecipesBase", "RuntimeGeneratedFunctions", "SciMLPublic", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArraysCore", "SymbolicIndexingInterface", "SymbolicLimits", "SymbolicUtils", "TermInterface"]
git-tree-sha1 = "6db949c4792666ca619f6ed32d70dd76052fd265"
registries = "General"
uuid = "0c5d862f-8b57-4792-8d23-62f2024744c7"
version = "7.45.0"

    [deps.Symbolics.extensions]
    SymbolicsD3TreesExt = "D3Trees"
    SymbolicsDistributionsExt = "Distributions"
    SymbolicsForwardDiffExt = "ForwardDiff"
    SymbolicsGroebnerExt = "Groebner"
    SymbolicsHypergeometricFunctionsExt = "HypergeometricFunctions"
    SymbolicsLatexifyExt = ["Latexify", "LaTeXStrings"]
    SymbolicsNemoExt = "Nemo"
    SymbolicsStaticArraysExt = "StaticArrays"
    SymbolicsSymPyExt = "SymPy"
    SymbolicsSymPyPythonCallExt = "SymPyPythonCall"

    [deps.Symbolics.weakdeps]
    D3Trees = "e3df1716-f71e-5df9-9e2d-98e193103c45"
    Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    Groebner = "0b43b601-686d-58a3-8a1c-6623616c7cd4"
    HypergeometricFunctions = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
    LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
    Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
    Nemo = "2edaba10-b0f1-5616-af89-8c11ac63239a"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
    SymPyPythonCall = "bc8888f7-b21e-4b7c-a06a-5d9c9496438c"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
registries = "General"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "a94d9bdda1b7bed0046cea645639ab3f62196fac"
registries = "General"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.14.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TaskLocalValues]]
git-tree-sha1 = "67e469338d9ce74fc578f7db1736a74d93a49eb8"
registries = "General"
uuid = "ed4db957-447d-4319-bfb6-7fa9ae7ecf34"
version = "0.1.3"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
registries = "General"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.TermInterface]]
git-tree-sha1 = "d673e0aca9e46a2f63720201f55cc7b3e7169b16"
registries = "General"
uuid = "8ea1fca8-c5ef-4a55-8b96-4e9afe9c9a3c"
version = "2.0.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TiffImages]]
deps = ["CodecZstd", "ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "PrecompileTools", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "9ca5f1f2d42f80df4b8c9f6ab5a64f438bbd9976"
registries = "General"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.11.9"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
registries = "General"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
registries = "General"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
registries = "General"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.URIs]]
git-tree-sha1 = "908fec9df6c5de98548ead82a468c95ccf6cd263"
registries = "General"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.7.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
registries = "General"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "1f0f9f401753701a7e4113b5056ca38d33875b55"
registries = "General"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.29.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    ForwardDiffExt = "ForwardDiff"
    InverseFunctionsUnitfulExt = "InverseFunctions"
    LatexifyExt = ["Latexify", "LaTeXStrings"]
    NaNMathExt = "NaNMath"
    PrintfExt = "Printf"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"
    LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
    Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
    NaNMath = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
    Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.WeakCacheSets]]
git-tree-sha1 = "386050ae4353310d8ff9c228f83b1affca2f7f38"
registries = "General"
uuid = "d30d5f5c-d141-4870-aa07-aabb0f5fe7d5"
version = "0.1.0"

[[deps.WebP]]
deps = ["CEnum", "ColorTypes", "FileIO", "FixedPointNumbers", "ImageCore", "libwebp_jll"]
git-tree-sha1 = "aa1ca3c47f119fbdae8770c29820e5e6119b83f2"
registries = "General"
uuid = "e3aaa7dc-3e4b-44e0-be63-ffb868ccd7c1"
version = "0.1.3"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "248a7031b3da79a127f14e5dc5f417e26f9f6db7"
registries = "General"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.1.0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e52eca002a11c30a858185efdfb15311e1c7a6bf"
registries = "General"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.4+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "808090ede1d41644447dd5cbafced4731c56bd2f"
registries = "General"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.13+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
registries = "General"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
registries = "General"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "1a4a26870bf1e5d26cd585e38038d399d7e65706"
registries = "General"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.8+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "75e00946e43621e09d431d9b95818ee751e6b2ef"
registries = "General"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.2+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
registries = "General"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libpciaccess_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "58972370b81423fc546c56a60ed1a009450177c3"
registries = "General"
uuid = "a65dc6b1-eb27-53a1-bb3e-dea574b5389e"
version = "0.19.0+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
registries = "General"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
registries = "General"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["CompilerSupportLibraries_jll", "Libdl"]
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
registries = "General"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1210ba774d3427387d307bf1f416d699b7c39417"
registries = "General"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.15.1+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "cb007192783c56d8249db4cf0e3495001edfe414"
registries = "General"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.5+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.libdrm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libpciaccess_jll"]
git-tree-sha1 = "28e57478e8a160d346a19c28b3fffb9273bcc9c2"
registries = "General"
uuid = "8e53e030-5e6c-5a89-a30b-be5b7263a166"
version = "2.4.134+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
registries = "General"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "1fcd6cf05d23adab0b5ffc496d020537215751dc"
registries = "General"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.59+1"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "libpng_jll"]
git-tree-sha1 = "e067c8bae65bb40866552296a2d5b4dc65b8928f"
registries = "General"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.80.702+0"

[[deps.libva_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "libdrm_jll"]
git-tree-sha1 = "7dbf96baae3310fe2fa0df0ccbb3c6288d5816c9"
registries = "General"
uuid = "9a156e7d-b971-5f62-b2c9-67348b8fb97c"
version = "2.23.0+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
registries = "General"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.libwebp_jll]]
deps = ["Artifacts", "Giflib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libglvnd_jll", "Libtiff_jll", "libpng_jll"]
git-tree-sha1 = "52d3b9475133c3bc8c0a7f90f18bfc8cdb5a443a"
registries = "General"
uuid = "c5f90fcd-3b7e-5836-afba-fc50a0988cb2"
version = "1.6.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.67.1+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.8.2+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
registries = "General"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
registries = "General"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"

[registries.General]
url = "https://github.com/JuliaRegistries/General.git"
uuid = "23338594-aafe-5451-b93e-139f81909106"
"""

# ╔═╡ Cell order:
# ╠═dbc5dedf-cc89-4eb2-96dc-9fbeec25025d
# ╠═a3678ab0-3e64-45eb-90cc-afa0760ed701
# ╠═4335b1e5-04bd-4d59-bc20-742de204e5c2
# ╠═36ffb38f-eee2-4b86-9938-5996f4c98b6c
# ╠═e8fbabaa-a913-4d7b-838b-3fdbcd0d9a2c
# ╠═0930e74b-0105-457c-9f8d-5e61352f1c21
# ╠═6769d96d-1228-4229-be8c-0938cddb2fa9
# ╠═8e31d599-cb5f-44cb-b779-0ed5ce7f7c16
# ╟─6149c7a3-140e-4204-a6f1-8f09a42d9242
# ╟─ec18f430-1b1c-4967-9689-6e2904e56ada
# ╟─c0684073-01b1-486e-baf5-71cb4b3f1cad
# ╟─550cf92b-05b3-45e3-bf83-ab1175f1b002
# ╟─80541381-32d8-4ae0-8dc5-569b315fdb46
# ╟─dd796fa6-fa31-4559-9855-f6ade6a6c510
# ╟─c90ed7b5-bc3a-4844-9a20-e0797d1a6ca5
# ╟─f767e601-08da-436a-a4ea-fc92e18c1bec
# ╟─5c1790e6-4b0d-41a3-9a73-a56cce53a4f5
# ╟─f289dbb7-29c9-4eac-a281-5bdf4612d1a6
# ╟─98bec6f9-f7f5-4119-82d4-a94ec9c91e9c
# ╟─2fbc54ee-1dfc-4a59-8a93-fa23bb69a8ea
# ╟─19d48875-bd81-4b5c-8cf9-8ef9ff6ef797
# ╟─041375a1-8ee0-4e14-9320-7147c863914b
# ╟─b4694fba-d336-499f-90ee-28e6b37f37e8
# ╟─603c7e70-77aa-47d9-b7ac-1584108f7f64
# ╟─45388687-1f90-4463-bc1f-ca7e61206ad2
# ╟─cb538d2a-0d28-4b10-b7da-9729d4c6bd78
# ╟─9ca7b99a-a3de-40f0-a43b-47a3db74e816
# ╟─c28338a5-bbb3-45c0-8a39-786264333d5f
# ╟─573a1b02-7269-4c3e-91c1-019ec3a5d358
# ╟─9059970a-e0e6-4228-b371-1e93d57f66d7
# ╟─46dd469b-2acd-4d8a-a112-9b550d27ced8
# ╟─d8518bca-9dde-496d-b9fc-5565019a0ef0
# ╟─e25dd3f8-8483-4632-b3a9-dc8455009a99
# ╟─957ee8fd-63d2-4363-a519-13bd73648e48
# ╟─1fb9b22a-61a4-4c4c-b1c2-71b27b303bc2
# ╟─877544e1-cf7c-4f6e-a746-67e5f418611d
# ╟─13fcef34-89d6-4f7d-9249-1c019f42411c
# ╟─6e880336-8acb-4b78-ac86-2aafaa8e14ad
# ╟─c1003585-c164-44e3-bf96-c954d06a13cc
# ╟─b89236fb-7775-4e16-93dc-bc9a025b3023
# ╟─36863f50-68b0-42bc-a038-e5d02c58e8c1
# ╟─d5662c61-da7c-4303-a5ab-a024711e372b
# ╟─fa424220-a3af-4942-b19e-a0d952435472
# ╟─499c26ba-8df5-4087-80de-a3efb5293f16
# ╟─38d6ab9e-3aa0-4890-b8a6-ae1bc3dd4d00
# ╟─8c4a2e6a-3ee4-484f-a1a6-0bde73d43718
# ╟─f45d46f4-9c7f-458a-a26a-429b0294e614
# ╟─28f20cfe-7439-4090-aa23-ec2257a9fc9c
# ╟─fc58d729-8594-4607-bf7f-0f730a3be9ac
# ╟─faa36c56-bd6b-45b7-89b6-1555a2515bfd
# ╟─af6007fc-39ac-401d-a03d-16fe39917951
# ╟─24b9edbe-88e6-4ede-bb59-5c32d8f1514c
# ╟─8bb3e448-2686-4499-8323-2d981ac122cd
# ╟─f67f535b-3d05-4bd6-a7bd-21556f4c41dc
# ╟─1ead6b3e-3e1c-49b0-a834-fd587b00c5a5
# ╟─1a1b54fd-61e3-4fd3-a3d7-77f015c9d0be
# ╟─b9d8f2f3-f2b2-4f35-b792-df71e240d92a
# ╟─e715e9bb-a9cb-49d8-ac75-16e67a4667db
# ╟─62c5b08c-b574-4043-8bab-5493f2462dd7
# ╟─b527f54c-53ae-4aa6-a5f2-c61fa6633bd3
# ╟─6232d13a-c1f9-4df2-8549-e43f6fc4ed9f
# ╟─489823e8-1e5f-4493-a0c3-2dbbec842142
# ╠═a4500168-ea47-4f03-8c2e-e08901d82d2d
# ╠═07a6cf77-e119-4050-a109-3fa1377f3fdb
# ╠═e283e03a-b0f6-485a-94c7-93db9a5ddd40
# ╟─5e0ded8d-db7e-45b7-8511-64c8f1632185
# ╠═46088004-6d59-4059-8536-b571810d8646
# ╠═1055b847-6fa9-4f0d-924a-45d8b9d45ad0
# ╟─ed04f3b6-dcba-4d2c-b539-bf4d77ff33b3
# ╠═957ee6e2-25db-41c9-a5a9-8b8efb39e6ff
# ╟─add00c30-7aa9-47f9-ac3b-4a1e97e23d09
# ╟─0ca63687-c9c6-4027-a461-1ceaa35eee55
# ╟─4d51f9cb-60fd-4e05-a97c-724080cb317f
# ╟─2ce2824f-52b7-444e-950f-5370b4ba59e0
# ╟─70e72f56-4cca-4858-ac9c-f84bd7ae5029
# ╟─22b1bb59-f0de-4888-9b9c-fbaf0fab773c
# ╠═9506fe42-d4a2-4055-8429-021ff5bebb8b
# ╠═53d07c05-a15a-450a-83c4-4da91dd5b6a5
# ╠═bb0d1784-6093-4404-adf2-78aa322f7085
# ╠═6fabb945-3626-452b-a471-4abcadbb9592
# ╠═228acf65-2f5b-4e45-9a7e-2bdef932105f
# ╟─3447169b-b41f-4b63-9251-ef6d14846b82
# ╠═e832133e-6b8a-4557-be97-6d54f2e1b6b3
# ╠═4ef6d842-457d-447b-b7c1-27ae00b10c4b
# ╠═8c1fc621-500f-484d-91d8-75e8d564ce9e
# ╠═577205fb-1ab3-4305-9add-042315b079c9
# ╠═5726299f-3857-4467-bea2-dceefb9ba7b7
# ╠═42636eea-3e50-4b2d-a711-6d75d0a14014
# ╠═459e2de0-afc8-4032-ad3c-72c53a55d270
# ╟─89e86e3a-674c-4c49-b59d-ddf09060e106
# ╠═b0e2f33c-bc5d-49ec-bcc5-47e4054eb7e8
# ╠═383d27d6-bb3f-4728-ad9e-2f55a9899782
# ╟─da86214e-a69a-4bd8-a2aa-746a4fd5f6c9
# ╟─000e169f-0ce4-43f0-8414-7d932427dcd5
# ╠═e498d0c5-104e-4db6-91fc-9562faa7dfb4
# ╠═f140a80d-1ec3-4a0c-b35b-1d117c3e7adc
# ╠═37e6add7-46c6-4ece-9b14-f2bafb66a8a1
# ╠═7f8e1d7e-b7a0-42f2-80ce-f0e98cdea9d2
# ╟─2345567b-3d2d-4b9c-bac6-2d753280fb48
# ╟─e9cf406d-2f81-4bb1-98f7-b9b6d118fd08
# ╠═e0c14edc-3971-42e3-96c3-1086cde97b1e
# ╟─e500f340-b53c-46b2-a3fd-46d563c86df9
# ╟─fbb026ed-d295-44dc-93c5-1455f3ffd848
# ╠═6782cd70-71dd-4504-a6b6-e4b0da3d9126
# ╠═ac7408c8-c366-46ab-9515-93bc55dda4ac
# ╠═ee8b8ad6-70d9-49d5-b2c0-1be93da8255c
# ╟─772d1148-5181-425e-b2ca-365aa2b5c2a4
# ╟─e6429073-ffe9-4153-b90f-e55b27e2817d
# ╟─42dd87b3-b9a2-4f57-bcac-3a191ab76380
# ╠═4cd408a5-f78a-4393-9ffe-61598f17f326
# ╠═aa3e7729-3b2e-4824-92af-09d15894b521
# ╠═f3b572ef-b338-4b12-b1b8-08364fabf487
# ╠═988269f3-1e76-4cc3-88a9-392620efc000
# ╟─c9fe918e-6910-41f8-9042-a35e7fe1fd00
# ╠═16af7868-f4fe-4720-98f7-095f96b0ac7a
# ╠═b676581c-a8ec-44ae-a4d3-31efd57ef445
# ╠═29b05d28-662a-4413-ba9c-bd45e9e50135
# ╠═f0d0773c-e933-487d-939d-5bba8e886fb5
# ╠═cf12ffe3-42b0-43f7-bf2a-bc13ea12ce05
# ╠═8a1c1942-ec43-452f-9b35-0a99587b26d8
# ╟─9c024d61-b080-4d33-8bdf-d887daad54a6
# ╠═18a34595-d7ee-4131-939f-a48f197e87f1
# ╟─5a13d6f6-cb6b-4e2b-b190-0f9bdfaf3098
# ╟─ee3c9d50-72e2-4f11-b486-1275d20d5c72
# ╟─6e9558f8-9d76-43ca-9578-598e3d9e0b69
# ╟─aef14e22-cac9-4dda-be67-7f71174492d1
# ╟─777dbb78-1915-40eb-9d7b-0b0662bd9ebf
# ╟─c531ed94-708a-4ea3-a227-bc6ed79761c8
# ╟─d5059a11-fbb1-4d01-9931-6de4e297768c
# ╟─5b605cde-da9f-447c-b1e5-15a78e669701
# ╟─88a0d6d8-5d1a-49b2-abb3-a9200932cd7b
# ╟─8b18afe0-c62a-4cc3-8b41-1ba527309484
# ╟─a3771e8a-1b07-4d31-b4ad-19e3ede8ffaa
# ╟─6097217e-c193-4877-af31-6430636988bf
# ╟─7e3a8d7f-2c99-4d56-b78e-ba68cf400fbe
# ╟─b5f1432a-6c49-4325-90a3-a1acb91f9862
# ╟─787b287f-1738-40e0-852d-a48bf4e5e14e
# ╟─1353c885-8bfb-4065-bce7-c31bb0184815
# ╟─1ab4495a-0743-451e-9429-9c3487d1f772
# ╠═bbafd906-f6fe-4fa0-8adc-9daa8dfb8f18
# ╠═c627f0a8-dc70-4381-ae91-565e5a627be8
# ╠═9c34951b-8b73-46b4-9886-45f8267e983f
# ╟─cf9eb011-8eed-4636-96e3-8fbac9731aee
# ╠═194f6e29-9731-4cb1-8c3d-38e414d566f4
# ╠═32b08849-80e0-4b35-b95d-871672bb2f91
# ╟─2b3b8b03-601e-49af-b5ef-6c582c398996
# ╠═d6cda712-e20b-40e4-9366-f9ee41a2c690
# ╠═e4917b3b-b497-4657-8335-6e182da37318
# ╟─88929c5a-d416-4c63-82fd-be5f29f5eb6c
# ╠═4de4e9fc-5b61-4a6c-b225-e4609ba6944f
# ╠═aff1f60c-4eab-4ca5-850d-949750925ff3
# ╟─ffbdbe06-0b26-4500-a503-8e2bd749d495
# ╠═745e4629-c57b-450d-896f-f0627a3c880b
# ╠═278c52ec-3108-41e3-9c9f-76ccbafc9401
# ╟─f16925a8-1b04-4403-8bca-333132ca9518
# ╠═1ee6da4b-a3ef-44df-a95e-6502070e928f
# ╠═60f2d10b-1bba-4c94-8758-05262cc77bad
# ╠═7410adcc-44a4-434d-84a6-dd108f53c414
# ╟─65c2d1ed-6fd1-47f1-b51b-269c7941ae2f
# ╟─f8a0b5ec-1623-4f25-b6dc-c859dab34037
# ╟─782b4b45-8f00-4805-b70f-6a527d5dba60
# ╟─31ce0ecf-69ea-41c6-970f-7117d8399ad2
# ╟─1b04af0e-ae4f-470c-bbe3-2ed9e571ded1
# ╟─60f2cab8-8c93-4f9a-938a-debcddde2496
# ╟─edef726b-0eb6-46b9-935e-c151977d15a0
# ╟─fac73484-defd-442c-89f6-9eff9f5749da
# ╠═b61894d9-bdbd-4f9b-b4ec-a6dd555a5aec
# ╠═913904ea-4ff1-43d9-86a2-e851b2138dd6
# ╠═3819d633-4531-4053-b063-501c7060d7a5
# ╠═8e93923a-fb4f-42d4-a735-ecd9bf40c307
# ╠═dbc44103-8163-4d02-802a-765dba4b905f
# ╠═36aff0f4-5a82-4987-ba75-c2a66b3286e8
# ╠═4449508f-df28-4d2d-aa14-46dd0902de46
# ╟─48ca2c1f-cc8e-4268-9f25-2efc655ddfac
# ╟─9dfe81c9-db99-4a2e-bd81-43cc8e057f42
# ╟─bf54a867-1338-4305-85b7-f39b7db066e9
# ╠═2ea84a40-f68a-465e-bf76-e8edb2573429
# ╠═d666646f-a1b9-4ca6-8ef4-15557312cc8c
# ╟─d604a886-8c56-49b6-8ea4-601ed10e48ed
# ╟─a6503d55-de44-4b37-bfb4-ae44914db52e
# ╠═23dc3660-3d24-4c04-be68-b4d4a0358f87
# ╠═88365be6-675c-4b01-ab45-45baadf37325
# ╟─f5fc05e5-34f3-4473-8dcc-a5a98b18c145
# ╠═5baf566f-3544-46e8-913c-8e88c00be991
# ╠═a335cbea-aab6-45e2-9bbb-7d19a3e2d68f
# ╟─70fc7904-fdd8-4d7c-b51d-028c04a56ddf
# ╠═7afd6c30-b290-45ad-8ddf-7c28a4b34872
# ╠═b3571522-6d85-4ea9-8a7c-b3fac6b600c3
# ╠═73ebd870-8e95-4dee-8e63-3cfcb9018e08
# ╠═88b5be8c-8b2c-4b04-9f91-c7fe5929ddc2
# ╠═962eb933-3d01-41ae-898d-2e97553ffa6b
# ╠═8e362a49-fdfe-499d-abf1-40005f25aec8
# ╟─44aab99a-1443-47d7-ab9c-84499fdb2db8
# ╟─f7cdac03-ac02-47e0-b669-f5ae860df57d
# ╟─83aa29be-fd0c-45f2-942f-e3ae7db415be
# ╟─e8b03545-6a95-447f-885b-f442b2c08515
# ╟─0662f0dc-8f65-4b65-8ca4-fe4978fb2da6
# ╟─c6607e2d-46b4-4487-a78c-8c9096b7cca4
# ╟─e9380969-66f7-4e81-baac-e09821e6e5e8
# ╟─499176b7-20ab-4ca1-a3e5-c33b34c59c35
# ╟─98688cd7-a0da-4ed7-a6d4-83c62a4904ee
# ╟─75a7cf61-10c7-4788-8e18-af5a28112c0d
# ╟─b49ef5bd-543c-4841-bb6b-40a588173efe
# ╟─93b29b75-24f8-494a-a1f8-48b7d5a44b79
# ╟─05c088e3-572b-4bcd-aa60-5a8265dacfd7
# ╟─109b6045-fdf3-41eb-977c-a6d5717cee8b
# ╟─1081e62b-5575-461d-a293-53fd4db551d8
# ╟─13328cb8-56c3-47bf-a375-0a5758492ebd
# ╟─82c6dfe8-080a-4b8d-ae80-a6bfaafd3281
# ╠═d20b5ccc-280a-47fe-bf2d-5ece3bf370d7
# ╟─46dd0c2c-9460-4d9f-9f8b-df5dabd4daf1
# ╟─b49f8963-6f6c-423b-8559-3bf538f7ae88
# ╟─d7987ebe-ad03-4b64-b975-572c5f5cbcdb
# ╟─a85b075e-eabe-44c1-a8cd-bb3b31853a9a
# ╟─ec26ebf6-db22-407c-a56f-106a181cf69c
# ╟─03d44655-419c-4529-94c0-4fd7dc29b10c
# ╟─762ea5df-f187-471c-bd77-941f6136edc3
# ╟─a52ab745-7ebe-4c25-99e3-1f3e207320f2
# ╟─cb7ea381-1732-4578-8bf8-1d8839350371
# ╟─2b3d27a3-9814-4a18-b8e0-96fe8cde6f63
# ╟─7bdc98d0-86ff-431d-95ae-201da3ca8a83
# ╟─cafb809f-a58f-442b-add0-faffa322e601
# ╟─a240b703-7200-42c7-91cc-e7b9c6113684
# ╟─1edf689e-2119-4007-be02-eb7aae43db3b
# ╟─6426c5be-4336-4705-b37d-426d748f420d
# ╟─cc87181a-5b6f-4d02-bb11-0698530478b9
# ╟─b62b5753-fb75-493e-ae37-75331384a747
# ╟─1665a02f-6053-4a60-8cff-70bd0fe5dc93
# ╟─4be1270c-be70-4bdd-a015-ad92ff765124
# ╟─982de518-2ab6-4299-8624-c1074a880082
# ╟─a47cced1-e43f-4c17-85b1-20c65df7ff32
# ╟─a0312030-1ade-42d3-9a5c-332ac0cffc7a
# ╟─2e92ad87-c34d-4828-9706-2d6e379790b6
# ╟─b9a6db73-62bf-4b59-acee-4c30aac9eea0
# ╟─148d022e-6aa3-4a55-b2f4-b56702c5ef48
# ╟─c05cc8b3-14cd-4162-9e25-0a75fcd9a4e0
# ╟─9ccc7d0c-ada6-4db4-a6e5-fa3a8b365e20
# ╟─c3c8a624-1e4f-473d-ac08-f70cf0ccd119
# ╟─8340f5b5-ba71-4701-9e58-a6cebdc06ecc
# ╟─f9fd3f7a-ba90-4899-ba7d-102cfabf1b0a
# ╟─a10060ce-d713-4028-b966-664df23da4af
# ╟─717c91a4-d012-4769-b49d-271d6d30e1e8
# ╟─320a0bed-d778-4d39-99be-27f93ad5a263
# ╟─e916b054-dce2-4f26-890c-5826f0a832c4
# ╟─bab7ce3d-4cee-487a-b5d6-cd08f8c1145b
# ╟─0a573998-6a80-4dad-99cb-6d9d56745b10
# ╟─9794b531-30a4-46a3-97d2-443e6289ba6d
# ╟─ad25926a-31e8-48c2-b22e-f96009a4872a
# ╟─dcc8adf2-6354-4d2a-908d-5ec93b8f5bd2
# ╟─4a5ba23a-df28-4f34-9f24-ae1a07c6e5c0
# ╠═8edb1e45-934a-453c-a5e2-4e5a7847767a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
