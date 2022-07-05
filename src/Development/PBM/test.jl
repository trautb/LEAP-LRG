module Test

export demo
	function demo()
		EB = zeros(10,10)
		dEB_dt = zeros(10,10)
		pi = 3.14159265359
		freq  = 1
		ticks = 1
		c = 1
		dt = 0.1
		dxy = 0.1
		EB[3,2] = sin(0 + 2pi * freq * ticks * dt)
		#phase + 360 * freq * ticks * dt
		EB[7,2] = sin(0 + 2pi * freq * ticks * dt)
		show(stdout, "text/plain", EB)
		c = 1
		#0.1*cos(0.5*pi + pi * (1/50) * 1.0 * 0.1 )
		#0.1*sin(pi + pi * (1/50) * 1.0 * 0.1 )
		#h minimale Änderung
		#h ist breite zwischen patches
		println("\n")
		i = 0
		#dEB_dt = map(((EB,dEB_dt)) -> dEB_dt + 0.1 * 1 * 1  - EB / (0.1 * 0.1),EB,dEB_dt);
		
		dEB_dt = map(dEB_dt -> (dEB_dt + dt) ,dEB_dt);
		show(stdout, "text/plain", dEB_dt)
		println("\n")
		mw_EB = zeros(10,10)
		h = 4
		for i in range(2,stop=9)
			for j in range(2,stop=9)
				mw_EB[i,j] = (4/(h^2))*(EB[i,j-1]+EB[i,j+1] + EB[i-1,j] + EB[i+1,j]-EB[i,j])
				#col-1 + row +1
			end
		end
		println("\n")

		show(stdout, "text/plain", mw_EB)
		#dEB_dt = (dEB_dt * mw_EB)
		#dEB_dt = map(((dEB_dt,EB)) ->  (dEB_dt - EB)/(0.1*0.1),dEB_dt,EB);
		dEB_dt = dEB_dt .*c .*c .* (mw_EB.-EB)./(dxy*dxy) #--> fehler
		attu = 0.03
		dEB_dt = (dEB_dt.*(1 - attu))
		println("\n")
		show(stdout, "text/plain", dEB_dt)

		EB = EB .+ dt .* dEB_dt 

		println("\n")
		show(stdout, "text/plain", EB)

		#Source 0.58 deb/dt =0
		#EB r EB=0.1425, deb/dt = 1.45
	end


end
