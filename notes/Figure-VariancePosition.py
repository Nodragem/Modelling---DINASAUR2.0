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


os.chdir("/home/c1248317/Bitbucket/Dinasaur/results")
df = pd.read_csv("./distances/results_distance_summary.csv")
bb = np.load("./distances/results_distance_slices.npy")
r = loadMatFiles("./distances/results_*_distance.mat")

plt.figure()
for i, pos in enumerate(np.sort(df["TargetPosition"].unique())):
    print pos
    plt.subplot(4, 2, i+1)
    plt.imshow(bb[i,:,:], aspect="equal")
    print bb[i, :,:].shape
    s = df[df["TargetPosition"] == pos]
    print s.shape
    plt.scatter(s["ampRT"], np.arange(len(s["ampRT"])), c="red", s=5)
    plt.scatter(s["ampSacc"], np.arange(len(s["ampSacc"])), c="cyan", s=5)
    plt.title("Target Position"+str(pos))
plt.tight_layout()
    
plt.figure()
for i, pos in enumerate(np.sort(df["TargetPosition"].unique())):
    plt.subplot(4, 2, i+1)
    trial = 34
    fr = r[i]["firing_rate"][0,0]
    plt.imshow(fr[trial,:,:] > 0.85, aspect="equal")
    s = df[df["TargetPosition"] == pos]
    plt.vlines(s["RT"].iloc[trial], ymin=0, ymax=200)
    plt.scatter(s["RT"].iloc[trial], s["ampRT"].iloc[trial])
    plt.title("Target Position"+str(pos))
plt.tight_layout()

    
    