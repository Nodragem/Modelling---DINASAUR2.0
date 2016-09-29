import numpy as np
import matplotlib.pyplot as plt

''' We try to replicate the input used by Aline in Dinausaur '''

def g(u):
    return 1 / (1 + np.exp(-0.07 * u))
## Threshold and gain function:
#u = np.arange(-100, 100, 0.1)
#A = 1 / (1 + np.exp(-0.07 * u))
#plt.plot(u, A)
#plt.hlines(0.85, -100, 100)
#plt.vlines(u[np.argmin(np.abs(A-0.85))], 0, 1)
#plt.show()

##
# Note that the noise is of variance 50
# which is about 5 by step when divided by the time constant of 10 ms

## Input exogeneous input, we don't know if Aline is using tau_on or tau_off
plt.figure(figsize=(8,11))
time = np.arange(0, 200, 0.1)

plt.subplot(311)
plt.title("Inputs")
a_exo = 80*np.exp(-(time-50)/10) # tau_on
a_exo[time<=50] = 0
plt.plot(time, a_exo)
a_endo = np.zeros(a_exo.shape)
a_endo[time>75] = 14
plt.plot(time, a_endo)
plt.legend(["exogenous", "endogenous"])


noise_t = 50*np.random.randn(len(time))
# simulation with noise:
Ut1noise = [0]
for i in xrange(len(a_endo)):
    Ut1noise.append( Ut1noise[-1] + (-Ut1noise[-1] + a_exo[i] + a_endo[i] + noise_t[i])/10 )
# simulation without noise:
Ut1 = [0]
for i in xrange(len(a_endo)):
    Ut1.append( Ut1[-1] + (-Ut1[-1] + a_exo[i] + a_endo[i])/10 )

plt.subplot(312)
plt.title("Membrane Potential / u(t)")
plt.plot(time, Ut1[0:-1], color= "red")
plt.plot(time, Ut1noise[0:-1], color="pink")
plt.legend(["without noise", "with noise"])

plt.subplot(313)
plt.title("Firing Rate, e.g: \n (1 / (1 + exp(-0.07 * u(t)))) ")
plt.plot(time, g(np.array(Ut1[0:-1]) ) )
plt.plot(time, g(np.array(Ut1noise[0:-1]) ) , color="cyan")
plt.hlines(0.85, 0, 200)
plt.legend(["without noise", "with noise", "Threshold to Saccade"])
plt.tight_layout()
plt.show()