import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

''' We try to replicate the input used by Aline in Dinausaur '''


# -- Threshold and gain function:
# u = np.arange(-100, 100, 0.1)
# A = 1 / (1 + np.exp(-0.07 * u))
# plt.plot(u, A)
# plt.hlines(0.85, -100, 100)
# plt.vlines(u[np.argmin(np.abs(A-0.85))], 0, 1)
# plt.show()


## Input exogeneous input, we don't know if Aline is using tau_on or tau_off
plt.figure(figsize=(8,11))
time = np.arange(0, 100, 0.1) # I think that the nb of step in DINASAUR was of 1200 for 1.2 second
# As found in J. Neurosciences, Bompas and Sumner 2011:
# -- PARAMETERS ---
# global parameters
nb_trials = 100
threshold = 0.85
tau = 10.0
SOA = 80 # not used
leak = 0.01
# Connection parameters -- not used
Act = 250
Inh = 345
theta = 0.7
# -------------------------------------------------------------
# Note that the noise is of variance 50
# which is about 5 by step when divided by the time constant of 10 ms
noise_amplitude = 50.0
baseline_endo_Fixation = 10 # amount of activity on the fixation node, at least for the 300 ms preceding target onset:
# during Fixation:
baseline_exo_Target = 0
baseline_exo_Distractor = 0
baseline_endo_Target = 0
baseline_endo_Distractor = 0
"""those paremeters resulted in baseline activity (in the DNF) of B=0.07 for Target and Distractor location
and B=65 for Fixation location, toward the end of the fixation period"""
# input parameters
# - delta_exo/endo: the delay between an exogenous/endogenous input change and the DNF response
delta_exo = 50 # or 56, 42, 46 ms according to participants
# Trappenberg was using delta_exo = 70 ms
amp_exo_Target = 80 # participant 1
amp_exo_Distractor = 80
delta_endo = 75
amp_endo_Target = 14
amp_endo_Distractor = 14
amp_endo_Fixation = 10

# Trappenberg's function
def g(u):
    return 1 / (1 + np.exp(-0.07 * u))

# -- INPUT CONSTRUCTION ---
# make a transient exogenous input:
# input_exo_Target = amp_exo_Distractor*np.exp(-(time-delta_exo)/10) # tau_on
# input_exo_Target[time<=delta_exo] = 0
input_exo_Target = np.zeros_like(time)
# make a step endogenous input:
input_endo_Target = np.zeros_like(time)
# input_endo_Target[time>75] = 14


# -- SIMULATIONS --

# simulation with noise:
noiseTrials = np.zeros((nb_trials, len(time)))
for row in xrange(noiseTrials.shape[0]):
    print "\rTrial", row,
    noise_t = noise_amplitude * np.random.randn(len(time))
    Ut1noise = [0]
    for i in xrange(len(time)):
        Ut1noise.append( Ut1noise[-1] + (-leak*Ut1noise[-1] + input_exo_Target[i] + input_endo_Target[i] + noise_t[i])/tau )
    noiseTrials[row,:] = Ut1noise[0:-1]

noiseTrials_U = pd.DataFrame(noiseTrials.T)
noiseTrials_r = pd.DataFrame(g(noiseTrials.T))

# simulation without noise:
Ut1 = [0]
for i in xrange(len(time)): ## note that Ut1[-1] is equivalent to i-1
    Ut1.append( Ut1[i-1] + (-leak*Ut1[i-1] + input_exo_Target[i] + input_endo_Target[i])/tau )

# -- FIGURE --
plt.subplot(311)
plt.suptitle("Leak = "+str(leak), fontsize=20)
plt.title("Inputs")
plt.plot(time, input_exo_Target)
plt.plot(time, input_endo_Target)
plt.legend(["exogenous", "endogenous"])

ax2 = plt.subplot(312)
plt.title("Membrane Potential, i.e., u(t)")
noiseTrials_U.plot(x=time, ax=ax2, cmap="plasma", alpha=0.2, legend=False)
plt.plot(time, Ut1[0:-1], color= "red")
plt.plot(time, Ut1noise[0:-1], color="gray")
plt.ylim([-300, 300])
# plt.legend(["without noise", "with noise"])

ax3 = plt.subplot(313)
plt.title("Firing Rate, i.e., \n (1 / (1 + exp(-0.07 * u(t)))) ")
noiseTrials_r.plot(x=time, ax=ax3, cmap="viridis", alpha=0.2, legend=False)
plt.plot(time, g(np.array(Ut1[0:-1]) ) )
plt.plot(time, g(np.array(Ut1noise[0:-1])), color="gray")
plt.hlines(threshold, 0, 200)
plt.ylim([-0.1, 1.1])
# plt.legend(["without noise", "with noise", "Threshold to Saccade"])
plt.tight_layout()
plt.subplots_adjust(top=0.92)
plt.show()
