import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

df = pd.read_csv("event_table_distance.csv")

sacc_condition = (df.saccade_ecc == -36 ) & (df.time > 500)
sacc_condition = ((df.saccade_ecc < -31) & (df.saccade_ecc > -41) ) & (df.time > 500)
RT = df.ix[sacc_condition, ['trial_ID','saccade_ecc', 'time']].groupby("trial_ID").head(1)
print RT
# plt.hist(RT['time'].values, bins=50 )
RT['time'].plot(kind='density')

fig = plt.figure()
ax = fig.add_subplot()
df2 = df[df.trial_ID<500]
for key, grp in df2[['trial_ID','saccade_ecc', 'time']].groupby("trial_ID"):
    plt.plot(grp['time'], grp["saccade_ecc"], 'o', label=key)

plt.show()