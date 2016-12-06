setwd("/home/c1248317/Bitbucket/Dinasaur/results")

library(R.matlab)

d <- read.csv("distances/table_distance.csv")

r <- readMat("distances/results_distance.mat")

r$results
summary(r$results[,,1])
# Length Class  Mode     
# keys                    1 -none- character
# values                  1 -none- list     
# target.RTs              6 -none- numeric  
# distractor.RTs        500 -none- numeric  
# firing.rate           500 -none- numeric  
# membrane.potential 240000 -none- numeric 
# -- the values are not in the good keys... 

