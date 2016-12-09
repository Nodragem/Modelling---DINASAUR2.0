#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Dec  5 16:56:11 2016

@author: Geoffrey Megardon
"""

from scipy.io import loadmat
import os, glob
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
os.chdir("/home/c1248317/Bitbucket/Dinasaur/notes/Thresold and Distance")
from modtools import *

os.chdir("/home/c1248317/Bitbucket/Dinasaur/results")
r = loadMatFiles("./distances/results_*_distance.mat")
threshold_type = "exponential20" # find the type of threshold in modtools

nb_nodes = r[0]["firing_rate"][0,0].shape[1] 
space = np.arange(nb_nodes) - r[0]["fixation"][0,0][0,0] # that is ridiculous ...
threshold_array = getArrayFromMath(thresholds[threshold_type], 
                                   space, reshaping=(1, len(space),1))
weight_array = getArrayFromMath("x", space)

list_slices = []
nb_conditions = r.shape[0]
nb_trials = r[0]["firing_rate"][0,0].shape[0]
df = pd.DataFrame(index=np.arange(nb_conditions*nb_trials), 
                  columns=("ID","trial", "TargetPosition", "RT", "ampWinner", "ampAveraging"))
df["ID"] = np.arange(nb_conditions*nb_trials)    

for i in xrange(nb_conditions):
    print "distance", i
    fr = r[i]["firing_rate"][0,0] # I mean, that is seriously uggly
    trial1, pos1, t1, slices = getFunThreshold(fr, threshold_array, return_slice=True)
    pos_sacc = getWeightedAverage(slices, weight_array)
    select = (df.ID >= i*nb_trials) & (df.ID < (i+1)*nb_trials)    
    df.ix[select, "TargetPosition"] = r[i]['values'][0,0][0,3] # impressive organization
    df.ix[select, "trial"] = np.arange(nb_trials)
    trials_passed = df["trial"].isin(trial1) & select
    df.ix[trials_passed, "RT"] = t1 
    df.ix[trials_passed, "ampWinner"] = pos1 
    df.ix[trials_passed, "ampAveraging"] = pos_sacc 
    list_slices.append(slices)
    
os.chdir("/home/c1248317/Bitbucket/Dinasaur/notes/Thresold and Distance")
df.to_csv("./results_summary_"+ threshold_type +"threshold.csv")
bb = np.array(list_slices)
np.save("./results_slices_"+ threshold_type +"threshold.npy", bb)
print ("saved")




    
