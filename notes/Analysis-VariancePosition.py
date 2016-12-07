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
from modtools import *

os.chdir("/home/c1248317/Bitbucket/Dinasaur/results")
r = loadMatFiles("./distances/results_*_distance.mat")
threshold = Threshold.flat
    
nb_conditions = r.shape[1]
nb_trials = r[0]["firing_rate"][0,0].shape[0]
df = pd.DataFrame(index=np.arange(nb_conditions*nb_trials), 
                  columns=("ID","trial", "TargetPosition", "RT", "ampRT", "ampSacc"))
list_slices = []
for i in xrange(r.shape[1]):
    print "distance", i
    fr = r[i]["firing_rate"][0,0] # I mean, that is seriously uggly
    if threshold == Threshold.flat:
        trial1, pos1, t1, slices = getFlatThreshold(fr, 0.85, return_slice=True)
    elif threshold == Threshold.exponential:
        trial1, pos1, t1, slices = getExpThreshold(fr, 0.85, return_slice=True)
    pos_sacc = getWeightedAverage(slices, np.arange(fr.shape[1]))
    select = np.arange(i*nb_trials, (i+1)*nb_trials)
    df["ID"].loc[select] = (i+1)*nb_trials + np.arange(nb_trials)    
    df["TargetPosition"].loc[select] = r[i]['values'][0,0][0,2] # impressive organization
    df["trial"].loc[select] = trial1
    df["RT"].loc[select] = t1
    df["ampRT"].loc[select] = pos1
    df["ampSacc"].loc[select] = pos_sacc
    list_slices.append(slices)
    
df.to_csv("./distances/results_distance_summary.csv")
bb = np.array(list_slices)
np.save("./distances/results_distance_slices.npy", bb)
print ("saved")




    
