using Observables, GLMakie

function animo()
    phase = Observable(0.0)
    T = 0:0.1:10

    s = lift(phase) do t
        @. sin(T - t)
    end

    fig, _ = lines(T,s)
    display(fig)

    for t in T
        phase[] = t
        sleep(1/60)
    end
end
