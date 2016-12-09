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
import re
x, y, z = symbols("x y z")

# ----- example code (DO NOT REMOVE) ----    
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
# --------------------------------------
#Piecewise((-x, x<=0)
 
thresholds = {"flat085": "0.85",
              #"exponential20": "1*exp(-x/20) + 0.85",
              "exponential20": "Piecewise(\
              (1*exp(x/20) + 0.85, x< 0),\
              (1*exp(-x/20) + 0.85, x>=0) )",
              "exponential10": "1*exp(-x/10) + 0.85",
              "inverse": "1/x + 0.85"}
    

def getFlatThreshold(fr, threshold, return_slice = False, dt=1, dx=1):
    """
    # fr has the format (trials, space, time)
    # we want to return the position and the time at which the threshold 
    # was passed for the first time. That is two arrays of size len(trials).
    # we also return a slice of the activity at this time. 
    # That gives an array of dimensions = (trials, space).
    # test with: fr = r[0,0]["firing_rate"][0,0] 
    """
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
    # --------------------------------------------
    if not return_slice:
        return first_trial, first_loc, first_time
    else:
        # activity_slice = fr[first_trial, :, first_time] 
        return first_trial, first_loc, first_time, fr[first_trial, :, first_time] 


     
def getArrayFromMath(expression, space, reshaping = None):
    # ----- example code (DO NOT REMOVE) ----    
#    expression = thresholds[threshold_type]
#    nb_nodes = r[0]["firing_rate"][0,0].shape[1]
#    space = np.arange(nb_nodes) - r[0]["fixation"][0,0][0,0]
#    reshaping=(1, len(space),1)
    #------------------
    symbolic_f = sympify(expression)
    numerical_f = lambdify(x, symbolic_f, 'numpy')
    threshold = numerical_f(space)
    if np.isscalar(threshold): # sympy stupidly return a scaler if the function is a constant
        threshold = np.repeat(threshold, len(space))
    if reshape is None:
        return threshold
    else:
        return threshold.reshape(reshaping)

def getFunThreshold(fr, threshold_array, return_slice = False, dt=1, dx=1):
    """ 
    Args:
        fr (3d array): has the format (trials, space, time)
        threshold_array (array): used the function getArryFromMath(), 
                should be an array of shape: (1, fr.shape[1], 1)
    Returns:
        first_trial: the trial that passed the threshold
        first_loc: the position at which the threshold was passed for the first
                time for these trials
        first_time: the time at which the threshold was passed
        activity_slices: an array of dimensions = (trials, space).
    """
    # ----- example code (DO NOT REMOVE) ----    
#    # test with: fr = r[0,0]["firing_rate"][0,0]
#    symbolic_f = sympify("1-0.5*x/200") # equivalent to np.linspace(1, 0.5, 200)
#    symbolic_f = sympify("1*exp(-x/20) + 0.85")
#    symbolic_f = sympify("1*exp(-x/20) + 0.85")
#    space = np.arange(fr.shape[1])
#    numerical_f = lambdify(x, symbolic_f, 'numpy')
#    th = numerical_f(space).reshape((1, fr.shape[1],1))  
#    ## th = np.linspace(1,0.5, 200).reshape((1, 200,1)) # just to be sure
#    fr_m = fr-th
#    plt.figure()
#    plt.subplot(221)
#    plt.imshow(fr_m[0,:,:]>0)
#    plt.subplot(222)
#    plt.imshow(fr[0,:,:])
#    plt.subplot(223)
#    plt.plot(space, th.flatten())
#    plt.hlines(1, 0, 200, color='gray')
#    for i in xrange(8):
#        plt.plot(fr[0, :, 1199/(i+1)], color="black")
    # -------------------------------------------
    # the idea is to subtract the threshold on the space dimension with sweep
    # then we just need to use np.where as before.
    fr_m = fr - threshold_array
    trials = np.where(fr_m > 0)[0] # those are the trials that passes the trhreshold
    times = np.where(fr_m > 0)[2]
    locations = np.where(fr_m > 0)[1]
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
#bb = np.load("./results_slices_exponential20threshold.npy")
#    activity_slice = bb[7]
#    # --- mock data ---
#    x = np.arange(200)
#    X, Y = np.meshgrid(x,x)
#    activity_slice = np.exp(-(X-Y)**2/30.0**2)
#    # --- mock data ---
#    values = activity_slice 
#    offset = 50
#    weight = np.arange(200.0) - offset
#    weight[weight<0] = np.nan
#    weight = np.tile(weight, (values.shape[0], 1))
#    plt.figure()
#    plt.subplot(411)
#    plt.imshow(activity_slice)
#    plt.subplot(412)
#    plt.imshow(weight)
#    plt.subplot(413)
#    plt.imshow((activity_slice * weight))
#   av = np.sum((values * weight), axis=1)/np.sum(weight, axis=1)
#   av1 = np.sum((values * weight), axis=1)/np.sum(values, axis=1)
#    av2 = np.nansum((values * weight), axis=1)/np.nansum(values * weight/weight, axis=1)
#   plt.subplot(411)
#   plt.scatter(av2+offset, np.arange(200), c='red')
#   plt.subplot(414)
#   plt.plot(activity_slice[0])
#   plt.vlines(av1[0]+offset, 0, 1)
# ---------------------------------------------------------------
    weight = np.tile(weight, (values.shape[0], 1))
    # we accept nan for the weight, so that the colliculus mays not consider one of its side
    return np.nansum((values * weight), axis=1)/np.sum(values, axis=1)
#    USE IF nan IN WEIGHT:
#        np.nansum((values * weight), axis=1)/np.nansum(values *  np.isfinite(weight), axis=1)


    
def loadMatFiles(regex, index=None):
    list_files = glob.glob(regex)
    numbers = [int(re.findall(r'\d+', s)[-1]) for s in list_files]
    list_files = [x for y, x in sorted(zip(numbers, list_files))]
    r = []
    for name in list_files:
        m = loadmat(name)
        r.append(m["results"])
    # we keep the structure of the matlab structure (in case we decide to put everything in one file)
    return np.array(r)