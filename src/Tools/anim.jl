using Observables, GLMakie

phase = Observable(0.0)
x = 0:0.01:10

y = lift(phase) do p
    @. sin(x - p)
end

fig, ax, lin = lines(x, y)
display(fig)

for _phase in 0:0.1:10
    phase[] = _phase
    sleep(1/60)
end
