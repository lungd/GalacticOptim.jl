"""
$(DocStringExtensions.README)
"""
module GalacticOptim

using DocStringExtensions
using Reexport
@reexport using SciMLBase
using Requires
using DiffResults
using Logging, ProgressLogging, Printf, ConsoleProgressMonitor, TerminalLoggers, LoggingExtras
using ArrayInterface, Base.Iterators

import SciMLBase: OptimizationProblem, OptimizationFunction, AbstractADType, __solve

@enum ObjSense MinSense MaxSense

include("utils.jl")
include("function/function.jl")

function __init__()
    # Optimization backends
    @require BlackBoxOptim="a134a8b2-14d6-55f6-9291-3336d3ab0209" include("solve/blackboxoptim.jl")
    @require CMAEvolutionStrategy="8d3b24bd-414e-49e0-94fb-163cc3a3e411" include("solve/cmaevolutionstrategy.jl")
    @require Evolutionary="86b6b26d-c046-49b6-aa0b-5f0f74682bd6" include("solve/evolutionary.jl")
    @require Flux="587475ba-b771-5e3f-ad9e-33799f191a9c" include("solve/flux.jl")
    @require GCMAES="4aa9d100-eb0f-11e8-15f1-25748831eb3b" include("solve/gcmaes.jl")
    @require MathOptInterface="b8f27783-ece8-5eb3-8dc8-9495eed66fee" include("solve/moi.jl")
    @require MultistartOptimization="3933049c-43be-478e-a8bb-6e0f7fd53575" include("solve/multistartoptimization.jl")
    @require NLopt="76087f3c-5699-56af-9a33-bf431cd00edd" begin
        include("solve/nlopt.jl")
        @require QuadDIRECT="dae52e8d-d666-5120-a592-9e15c33b8d7a" include("solve/quaddirect.jl")
    end
    @require Optim="429524aa-4258-5aef-a3af-852621145aeb" include("solve/optim.jl")
    @require Nonconvex="01bcebdf-4d21-426d-b5c4-6132c1619978" begin
        @require ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4" begin
            @require NonconvexBayesian="fb352abc-de7b-48de-9ebd-665b54b5d9b3" include("solve/nonconvex/nonconvex_bayesian.jl")
            @require NonconvexIpopt="bf347577-a06d-49ad-a669-8c0e005493b8" include("solve/nonconvex/nonconvex_ipopt.jl")
            @require NonconvexJuniper="611adb69-ebe7-45d0-83f5-90aabba2c123" include("solve/nonconvex/nonconvex_juniper.jl")
            @require NonconvexMMA="d3d89cbb-4ecd-4604-818d-8d1ff343e4da" include("solve/nonconvex/nonconvex_mma.jl")
            @require NonconvexMultistart="11b12826-7e46-4acf-9706-be0a67f2add7" include("solve/nonconvex/nonconvex_multistart.jl")
            @require NonconvexNLopt="b43a31b8-ff9b-442d-8e31-c163daa8ab75" include("solve/nonconvex/nonconvex_nlopt.jl")
            @require NonconvexPavito="75d5b151-dcdf-4236-8ef5-9c4e63ef33e2" include("solve/nonconvex/nonconvex_pavito.jl")
            @require NonconvexPercival="4296f080-e499-44ba-a02c-ae40015c44d5" include("solve/nonconvex/nonconvex_percival.jl")
            @require NonconvexSearch="75732972-a7cd-4375-b200-958e0814350d" include("solve/nonconvex/nonconvex_search.jl")
        end
    end
    @require Metaheuristics="bcdb8e00-2c21-11e9-3065-2b553b22f898" include("solve/metaheuristics.jl")
    @require NOMAD="02130f1c-4665-5b79-af82-ff1385104aa0" include("solve/nomad.jl")
    @require SpeedMapping="f1835b91-879b-4a3f-a438-e4baacf14412" include("solve/speedmapping.jl")

    # AD backends
    @require FiniteDiff="6a86dc24-6348-571c-b903-95158fe2bd41" include("function/finitediff.jl")
    @require ForwardDiff="f6369f11-7733-5829-9624-2563aa707210" include("function/forwarddiff.jl")
    @require ReverseDiff="37e2e3b7-166d-5795-8a7a-e32c996b4267" include("function/reversediff.jl")
    @require Tracker="9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c" include("function/tracker.jl")
    @require Zygote="e88e6eb3-aa80-5325-afca-941959d7151f" include("function/zygote.jl")
end

export solve

end # module
