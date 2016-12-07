#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Dec  7 10:29:10 2016

@author: Geoffrey Megardon
"""
from scipy.io import loadmat
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os, glob
from enum import Enum
from sympy import *
x, y, z = symbols("x y z")

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

class Threshold(Enum):
    flat = 1
    exponential = 2
    stochastic = 3
    exp_stochastic = 4

    

def getFlatThreshold(fr, threshold, return_slice = False, dt=1, dx=1):
    # fr has the format (trials, space, time)
    # we want to return the position and the time at which the threshold 
    # was passed for the first time. That is two arrays of size len(trials).
    # we also return a slice of the activity at this time. 
    # That gives an array of dimensions = (trials, space).
    # test with: fr = r[0,0]["firing_rate"][0,0]
    trials = np.where(fr>0.85)[0] # those are the trials that passes the trhreshold
    times = np.where(fr>0.85)[2]
    locations = np.where(fr>0.85)[1]
    index = np.zeros_like(np.unique(trials))
    nb_trials = 0
    for i, id in enumerate(np.unique(trials)): # note that pandas could have been used with groubby-apply
        # we use i and id because there maybe trials that did not reach the threshold
        index[i,] = np.argmin(times[(trials==id)]) + nb_trials
        nb_trials += len(times[(trials==id)])
            
    first_time = times[index]*dt
    first_loc = locations[index]*dx
    first_trial = trials[index] # note that this should give np.unique(trials) if there is no omission
    
    if not return_slice:
        return first_trial, first_loc, first_time
    else:
        # activity_slice = fr[first_trial, :, first_time] 
        return first_trial, first_loc, first_time, fr[first_trial, :, first_time] 

# ---- example code (DO NOT REMOVE) ----    
#   activity_slice = fr[first_trial, :, first_time] 
#    print first_time
#    print first_loc
#    plt.imshow(activity_slice)
#    plt.scatter(first_loc, first_trial)
#    plt.imshow(fr[34, :, :]) 
#    # use first_trial[] to avoid problem with trial where the threshold was not reached
#    plt.imshow(fr[first_trial[34], :, :]>0.85)
#    plt.vlines(first_time[0], ymin=0, ymax=200)
#    plt.scatter(first_time[0], first_loc[0])
        

def getFunThreshold(fr, threshold_fun, return_slice = False, space=None, dt=1, dx=1):
    """ 
    Args:
        fr (3d array): has the format (trials, space, time)
        threshold_fun (string): is a string math expression
    Returns:
        first_trial: the trial that passed the threshold
        first_loc: the position at which the threshold was passed for the first
                time for these trials
        first_time: the time at which the threshold was passed
        activity_slices: an array of dimensions = (trials, space).
    """
    # test with: fr = r[0,0]["firing_rate"][0,0]
    symbolic_f = sympify("1-0.5*x/200") # equivalent to np.linspace(1, 0.5, 200)
    symbolic_f = sympify("1*exp(-x/20) + 0.85")
    space = np.arange(fr.shape[1])
    numerical_f = lambdify(x, symbolic_f, 'numpy')
    th = numerical_f(space).reshape((1, fr.shape[1],1))  
    ## th = np.linspace(1,0.5, 200).reshape((1, 200,1)) # just to be sure
    fr_m = fr-th
    plt.figure()
    plt.subplot(221)
    plt.imshow(fr_m[0,:,:]>0)
    plt.subplot(222)
    plt.imshow(fr[0,:,:])
    plt.subplot(223)
    plt.plot(space, th.flatten())
    plt.hlines(1, 0, 200, color='gray')
    for i in xrange(8):
        plt.plot(fr[0, :, 1199/(i+1)], color="black")
    # -------------------------------------------
    symbolic_f = sympify(threshold_fun)
    if space = None:
        space = np.arange(fr.shape[1])
    numerical_f = lambdify(x, symbolic_f, 'numpy')
    threshold = numerical_f(space).reshape((1, fr.shape[1],1)
    # the idea is to subtract the threshold on the space dimension with sweep
    # then we just need to use np.where as before.
    
    trials = np.where(fr>0)[0] # those are the trials that passes the trhreshold
    times = np.where(fr>0)[2]
    locations = np.where(fr>0)[1]
    index = np.zeros_like(np.unique(trials))
    nb_trials = 0
    for i, id in enumerate(np.unique(trials)): # note that pandas could have been used with groubby-apply
        # we use i and id because there maybe trials that did not reach the threshold
        index[i,] = np.argmin(times[(trials==id)]) + nb_trials
        nb_trials += len(times[(trials==id)])
            
    first_time = times[index]*dt
    first_loc = locations[index]*dx
    first_trial = trials[index] # note that this should give np.unique(trials) if there is no omission
    
    if not return_slice:
        return first_trial, first_loc, first_time
    else:
        # activity_slice = fr[first_trial, :, first_time] 
        return first_trial, first_loc, first_time, fr[first_trial, :, first_time] 
    
def getWeightedAverage(values, weight):
# ---- example code (DO NOT REMOVE)
#    values = activity_slice 
#    weight = np.arange(200)
#    plt.subplot(311)
#    plt.imshow(activity_slice)
#    plt.subplot(312)
#    plt.imshow(np.tile(np.arange(200), (99, 1)))
#    plt.subplot(313)
#    plt.imshow((activity_slice * np.tile(weight, (99, 1)))/len(weight))
#   weight = np.tile(weight, (values.shape[0], 1))
#   av = np.sum((values * weight)/len(weight), axis=1)
#   plt.scatter(av, np.arange(values.shape[0]))
    weight = np.tile(weight, (values.shape[0], 1))
    return np.sum((values * weight)/len(weight), axis=1)

    
def loadMatFiles(regex, index=None):
    list_files = glob.glob(regex)
    r = []
    for name in list_files:
        m = loadmat(name)
        r.append(m["results"])
    # we keep the structure of the matlab structure (in case we decide to put everything in one file)
    return np.array(r)