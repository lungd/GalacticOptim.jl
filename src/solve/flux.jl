const AbstractFluxOptimiser = Union{Flux.Momentum,
                                    Flux.Nesterov,
                                    Flux.RMSProp,
                                    Flux.ADAM,
                                    Flux.RADAM,
                                    Flux.AdaMax,
                                    Flux.OADAM,
                                    Flux.ADAGrad,
                                    Flux.ADADelta,
                                    Flux.AMSGrad,
                                    Flux.NADAM,
                                    Flux.AdaBelief,
                                    Flux.Optimiser}

function __solve(prob::OptimizationProblem, opt::AbstractFluxOptimiser, data = DEFAULT_DATA;
                 maxiters::Number = 0, cb = (args...) -> (false),
                 progress = false, save_best = true, kwargs...)

    if data != DEFAULT_DATA
      maxiters = length(data)
    else
      maxiters = _check_and_convert_maxiters(maxiters)
      data = take(data, maxiters)
    end

    # Flux is silly and doesn't have an abstract type on its optimizers, so assume
    # this is a Flux optimizer
    θ = copy(prob.u0)
    G = copy(θ)

    local x, min_err, min_θ
    min_err = typemax(eltype(prob.u0)) #dummy variables
    min_opt = 1
    min_θ = prob.u0

    f = instantiate_function(prob.f,prob.u0,prob.f.adtype,prob.p)

    t0 = time()
    @withprogress progress name="Training" begin
      for (i,d) in enumerate(data)
        f.grad(G, θ, d...)
        x = f.f(θ, prob.p, d...)
        cb_call = cb(θ, x...)
        if !(typeof(cb_call) <: Bool)
          error("The callback should return a boolean `halt` for whether to stop the optimization process. Please see the sciml_train documentation for information.")
        elseif cb_call
          break
        end
        msg = @sprintf("loss: %.3g", x[1])
        progress && ProgressLogging.@logprogress msg i/maxiters
        Flux.update!(opt, θ, G)

        if save_best
          if first(x) < first(min_err)  #found a better solution
            min_opt = opt
            min_err = x
            min_θ = copy(θ)
          end
          if i == maxiters  #Last iteration, revert to best.
            opt = min_opt
            x = min_err
            θ = min_θ
            cb(θ,x...)
          end
        end
      end
    end

    t1 = time()

    SciMLBase.build_solution(prob, opt, θ, x[1])
    # here should be build_solution to create the output message
end
