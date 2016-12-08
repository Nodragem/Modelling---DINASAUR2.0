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

os.chdir("/home/c1248317/Bitbucket/Dinasaur/results")
r = loadMatFiles("./distances/results_*_distance.mat")
os.chdir("/home/c1248317/Bitbucket/Dinasaur/notes/Thresold and Distance")
df = pd.read_csv("./results_summary_"+ threshold_type +"threshold.csv")
bb = np.load("./results_slices_"+ threshold_type +"threshold.npy")
space = np.arange(200)
threshold_array = getArrayFromMath(thresholds[threshold_type], 
                                   space, reshaping=(len(space),1))

plt.figure()
for i, pos in enumerate(np.sort(df["TargetPosition"].unique())):
    print pos
    plt.subplot(4, 2, i+1)
    plt.imshow(bb[i], aspect="equal")
    print bb[i].shape
    s = df[df["TargetPosition"] == pos]
    print s.shape
    select = s['ampWinner'].notnull()
    plt.scatter(s.ix[select, "ampWinner"], np.arange(bb[i].shape[0]), c="red", s=5)
    plt.scatter(s.ix[select, "ampAveraging"], np.arange(bb[i].shape[0]), c="cyan", s=5)
    plt.title("Target Position"+str(pos))
plt.tight_layout()
    
plt.figure()
for i, pos in enumerate(np.sort(df["TargetPosition"].unique())):
    plt.subplot(4, 2, i+1)
    trial = 34
    fr = r[i]["firing_rate"][0,0]
    #plt.imshow(fr[trial,:,:] - threshold_array > 0, aspect="equal", vmin=0, vmax=1)
    plt.imshow(fr.mean(0) - threshold_array > 0, aspect="equal", vmin=0, vmax=1)
    
    s = df[df["TargetPosition"] == pos]
    plt.vlines(s["RT"].iloc[trial], ymin=0, ymax=200)
    plt.scatter(s["RT"].iloc[trial], s["ampWinner"].iloc[trial])
    plt.title("Target Position"+str(pos))
plt.tight_layout()

plt.show()
    
    