#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Dec  7 10:15:54 2016

@author: Geoffrey Megardon
"""
from scipy.io import loadmat
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os
from modtools import *

threshold_type = "flat085"
threshold_type = "exponential20"

print ("loading data ...")
os.chdir("/home/c1248317/Bitbucket/Dinasaur/results")
os.chdir("/home/c1248317/Bitbucket/Dinasaur/notes/Threshold and Distance")
df = pd.read_csv("./results_summary_"+ threshold_type +"threshold.csv")
slices = np.load("./results_slices_"+ threshold_type +"threshold.npy")

nb_nodes = 200
nb_trials = 200
fix_loc = 50
space = np.arange(nb_nodes) - fix_loc # that is ridiculous ...
weight_array = getArrayFromMath("x", space)
#weight_array = getArrayFromMath("Piecewise((x, x>0),(0, x<=0))", space)
threshold_array = getArrayFromMath(thresholds[threshold_type], 
                                   space, reshaping=(len(space),1))
# we accept nan for the weight, so that the colliculus mays not consider one of its side
# weight_array[0:fix_loc] = np.nan # CHECK THE AVERAGING FUNCTION IF YOU ACTIVATE THIS LINE

for i in xrange(8):
    print "distance", i
    pos_sacc = getWeightedAverage(slices[i], weight_array)
    select = (df.ID >= i*nb_trials) & (df.ID < (i+1)*nb_trials)    
    trials_passed = df["ampAveraging"].notnull() & select
    df.ix[trials_passed, "ampAveraging"] = pos_sacc 

print ("plotting data ...")

# Figure 1 ----------------
# that shows the Race winner position (red) for each "RT slice", and the Averaging position (cyan)
# the RT slices are snapshot of the field activity at the time at which a saccade was triggered
# Here the saccade triggering condition is when a position has reach for the first time the threshold.
plt.figure()
for i, pos in enumerate(np.sort(df["TargetPosition"].unique())):
    print pos
    plt.subplot(3, 3, i+1)
    if slices[i].shape[0] > 0:
        plt.imshow(slices[i], aspect="equal")
        print slices[i].shape
        s = df[df["TargetPosition"] == pos]
        print s.shape
        select = s['ampWinner'].notnull()
        plt.scatter(s.ix[select, "ampWinner"], np.arange(slices[i].shape[0]), c="red", s=5)
        # DON'T FORGET TO RECENTER THE SACCADE ON WHERE IS THE FIXATION!
        plt.scatter(s.ix[select, "ampAveraging"]+fix_loc, np.arange(slices[i].shape[0]), c="cyan", s=5)
    plt.title("Target Position"+str(pos))
plt.tight_layout()

# Figure 2 -----------------
# quick view on one slice:
plt.figure()
plt.plot(slices[i][0,:])
plt.plot(weight_array.flatten()/200.)
from statsmodels.nonparametric.kernel_regression import KernelReg
kde = KernelReg(slices[i][0,:], np.arange(200), 'o')
smooth_slice, y_std = kde.fit(np.arange(0,200))
smooth_mean = np.nansum((smooth_slice * weight_array))/np.nansum(smooth_slice * weight_array/weight_array)
plt.plot(smooth_slice)
plt.vlines(pos_sacc[0] + fix_loc, 0, 1)
plt.vlines(smooth_mean + fix_loc, 0, 1, color='red')
plt.hlines(0, 0, 200)
print pos_sacc


# Figure 3 -------------
# that shows the correlation RT / position for the Winner and the Averaging position
print ("plotting data ...")
plt.figure()
for i, pos in enumerate(np.sort(df["TargetPosition"].unique())):
    print pos
    plt.subplot(3, 3, i+1)
    if slices[i].shape[0] > 0:
        s = df[df["TargetPosition"] == pos]
        print s.shape
        select = s['ampWinner'].notnull()
        RTs = s.ix[select, "RT"]
        amp1 = s.ix[select, "ampWinner"]
        amp2 = s.ix[select, "ampAveraging"] +fix_loc
        x1 = np.arange(amp1.min(), amp1.max())
        x2 = np.arange(amp2.min(), amp2.max())
        p1 = plt.scatter(amp1, RTs, c="red", s=5)
        # DONT FORGET TO RECENTER THE SACCADE ON WHERE IS THE FIXATION!
        p2 = plt.scatter(amp2 , RTs, c="cyan", s=5)
        fit1 = np.polyfit(amp1, RTs, 1)
        fit1_fn = np.poly1d(fit1)
        fit2 = np.polyfit(amp2, RTs, 1)
        fit2_fn = np.poly1d(fit2)
        # fit_fn is now a function which takes in x and returns an estimate for y
        plt.ylim(700, 1200)
        plt.xlim(0, 200)
        plt.plot(x1, fit1_fn(x1), '-r', zorder=10, lw=2)
        plt.plot(x2, fit2_fn(x2), '-g', zorder=10, lw=2)
        plt.xlabel("Positions"); plt.ylabel("Reaction Times")
        plt.legend([p1, p2], ["Winner-take-all", "Sacc. Averaging"], fontsize = 8)

    plt.title("Target Position"+str(pos))
plt.tight_layout()



# plt.figure()
# r = loadMatFiles("./distances/results_*_distance.mat")
# for i, pos in enumerate(np.sort(df["TargetPosition"].unique())):
#    plt.subplot(4, 2, i+1)
#    trial = 34
#    fr = r[i]["firing_rate"]
#    #plt.imshow(fr[trial,:,:] - threshold_array > 0, aspect="equal", vmin=0, vmax=1)
#    plt.imshow(fr.mean(0) - threshold_array > 0, aspect="equal", vmin=0, vmax=1)
#
#    s = df[df["TargetPosition"] == pos]
#    plt.vlines(s["RT"].iloc[trial], ymin=0, ymax=200)
#    plt.scatter(s["RT"].iloc[trial], s["ampWinner"].iloc[trial])
#    plt.title("Target Position"+str(pos))
# plt.tight_layout()

plt.show()
    
    