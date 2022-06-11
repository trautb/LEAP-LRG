mat = ones(10,10)

mat[3,2] = sin(1.57 + 360 * (1/50) * 1.0 * 0.1)
#phase + 360 * freq * ticks * dt
mat[7,2] = sin(1.57 + 360 * (1/50) * 1.0 * 0.1)
show(stdout, "text/plain", mat)


#h minimale Änderung
#h ist breite zwischen patches

mat = map(x -> 0.1*cos(1.57+360 * (1/50) * 1.0 * 0.1), mat)


