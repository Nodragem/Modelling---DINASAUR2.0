import time, os, re, glob
from scipy.io import loadmat
import numpy as np

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

os.chdir("/home/c1248317/Bitbucket/Dinasaur/results")
t0 = time.time()
r = loadMatFiles("./distances/results_*_distance.mat")
t1 = time.time()
print t1 - t0
# 22.6525719166


os.chdir("/home/c1248317/Bitbucket/Dinasaur/notes/Thresold and Distance")
import time
t0 = time.time()
r = np.load('./temp_file.npy')
t1 = time.time()
print t1 - t0
# 29.0933139324

