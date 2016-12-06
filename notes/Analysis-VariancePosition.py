#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Dec  5 16:56:11 2016

@author: c1248317
"""

from scipy.io import loadmat
import os, glob
import numpy as np
import pandas as pd

os.chdir("/home/c1248317/Bitbucket/Dinasaur/results")

#r = loadmat("distances/results_1_distance.mat")
#print r.keys()
## ['__function_workspace__', '__version__', 'results', '__header__', '__globals__']
##print r["results"].shape
#r = r["results"]
## (1, 8)
#print r[0,2].shape
## ()   # that is a numpy.void, which mean it can contains anything, as a matlab structure
#print r[0,2].dtype.names
## ('keys', 'values', 'target_RTs', 'distractor_RTs', 'firing_rate', 'membrane_potential')
#print r[0,2]["keys"]

def getFirsThreshold(fr, threshold):
    trials = np.where(fr>0.85)[0]
    times = np.where(fr>0.85)[2]
    for id in np.unique(trials):
        pass
        
    

list_files = glob.glob("./distances/results_*_distance.mat")

r = [[]]
for name in list_files:
    m = loadmat("distances/results_1_distance.mat")
    r[0].append(m["results"])
# we keep the structure of the matlab structure (in case we decide to put everything in one file)
r = np.array(r)

for name in r[0,2].dtype.names:
    print type(r[0,2][name])
    
nb_conditions = r.shape[1]
nb_trials = r[0,0]["firing_rate"][0,0].shape[0]
df = pd.DataFrame(index=np.arange(nb_conditions*nb_trials), 
                  columns=("ID", "TargetPosition", "RT", "ampRT", "ampSacc"))
for i in r.shape[1]:
    fr = r[0,i]["firing_rate"][0,0] # I mean, that is seriously uggly
    pos1, t1 = getFirstThreshold(fr, 0.85)
    pos_sacc = getSaccadeAveraging(fr, t1)
    select = 
    df["ID"].loc[i*nb_trials: (i+1)*nb_trials] = (i+1)*nb_trials + np.arange(nb_trial)
    df["TargetPosition"].loc[i*nb_trials: (i+1)*nb_trials] = (i+1)*nb_trials + np.arange(nb_trial)
    df["RT"].loc[i*nb_trials: (i+1)*nb_trials] = t1
    df["RT"].loc[i*nb_trials: (i+1)*nb_trials] = t1
    df["ampRT"].loc[i*nb_trials: (i+1)*nb_trials] = pos1
    df["ampSacc"].loc[i*nb_trials: (i+1)*nb_trials] = pos_sacc
    
