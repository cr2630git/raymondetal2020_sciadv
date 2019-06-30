#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 24 16:32:37 2019

@author: gytm3
"""

import matplotlib.pyplot as plt
import numpy as np
import matplotlib.gridspec as gridspec

#=============================================================================#
# Plot 2: Global counts/occurrences of different thresholds 
#=============================================================================#

 # Files (names made sense at the time!)
f2="figure2data.txt" # From Colin
f3="figure2bottompaneldata.txt"# From Colin
f4="figure2toppaneldata.txt" # From Colin
f5="MeanExtreme.txt" # Global mean air temp anomaly (1) max TW (2) (HadCRUT(4))
f6="ERA-I_DJ_FLD_MAX.txt" # Ann field-max TW in ERA-I 
f7="eragridptcounts.txt"# ERA-I counts of exceedance (33,31,29,27)

# Read in
d2=np.loadtxt(f2,delimiter=",")
dbot=np.loadtxt(f3,delimiter=",")
dtop=np.loadtxt(f4,delimiter=",")
dglob=np.loadtxt(f5)
dmax=np.loadtxt(f6)[:-1] # last value is for an incomplete year (2018) -- discard
dera=np.loadtxt(f7) 

# Init figure
f=plt.figure()
gs1 = gridspec.GridSpec(6, 1)
f.set_size_inches(4,7)
gs1.update(hspace=0.00)
gs1.update(left=0.15, right=0.85, wspace=0.05,bottom=0.07,top=0.95)

# TW 33
ax = plt.subplot(gs1[0, 0])
x=np.arange(1979,2018)
ax.plot(x,d2[:,1],color="black")
ax2=ax.twinx()
ax2.plot(x,dera[:,0],color="grey",linestyle="-")
ax2.yaxis.tick_left()
r33=np.corrcoef(d2[:,1],dera[:,0])[0,1]
ax.yaxis.tick_right()
ax.set_yticks([0,75])
ax.set_yticklabels([]); ax.set_xticklabels([])
ax.set_yticklabels([0,75])
ax.set_xlim(1978.5,2018)
ps=np.polyfit(x,d2[:,1],1)
ax.plot(x,np.polyval(ps,x),color="black",linestyle="--")
ps=np.polyfit(x,dera[:,0],1)
ax2.plot(x,np.polyval(ps,x),color="grey",linestyle="--")
ax.text(1980,70,"TW$\geq$33$^{\circ}$C",fontsize=8)
ax.text(1980,50,"$\it{r}$ = %.2f"%r33,fontsize=8)
for item in ([ax.title, ax.xaxis.label, ax.yaxis.label] +
             ax.get_xticklabels() + ax.get_yticklabels()):
    item.set_fontsize(8)
for item in ([ax2.title, ax2.xaxis.label, ax2.yaxis.label] +
             ax2.get_xticklabels() + ax2.get_yticklabels()):
    item.set_fontsize(8)
# TW 31
ax = plt.subplot(gs1[1, 0])
ax.plot(x,d2[:,2],color="black")
ax.yaxis.tick_right()
ax2=ax.twinx()
ax2.plot(x,dera[:,1],color="grey",linestyle="-")
r31=np.corrcoef(d2[:,2],dera[:,1])[0,1]
ax2.yaxis.tick_left()
ax.set_yticks([250,500])
ax.set_yticklabels([]); ax.set_xticklabels([])
ax.set_yticklabels([250,750])
ax.set_xlim(1978.5,2018)
ps=np.polyfit(x,d2[:,2],1)
ax.text(1980,650,"TW$\geq$31$^{\circ}$C",fontsize=8)
ax.plot(x,np.polyval(ps,x),color="black",linestyle="--")
ps=np.polyfit(x,dera[:,1],1)
ax2.plot(x,np.polyval(ps,x),color="grey",linestyle="--")
ax.yaxis.tick_right()
ax.text(1980,500,"$\it{r}$ = %.2f"%r31,fontsize=8)
for item in ([ax.title, ax.xaxis.label, ax.yaxis.label] +
             ax.get_xticklabels() + ax.get_yticklabels()):
    item.set_fontsize(8)
for item in ([ax2.title, ax2.xaxis.label, ax2.yaxis.label] +
             ax2.get_xticklabels() + ax2.get_yticklabels()):
    item.set_fontsize(8)

# TW 29
ax = plt.subplot(gs1[2, 0])
ax.plot(x,d2[:,3],color="black")
ax.yaxis.tick_left()
ax.yaxis.tick_right()
ax2=ax.twinx()
ax2.plot(x,dera[:,2],color="grey",linestyle="-")
r29=np.corrcoef(d2[:,3],dera[:,2])[0,1]
ax.set_yticks([2000,7000])
ax.set_yticklabels([]); ax.set_xticklabels([])
ax.set_yticklabels([2000,7000])
ax.set_xlim(1978.5,2017.5)
ax.yaxis.tick_left()
ps=np.polyfit(x,d2[:,3],1)
ax.plot(x,np.polyval(ps,x),color="black",linestyle="--")
ax.text(1980,6500,"TW$\geq$29$^{\circ}$C",fontsize=8)
ax.plot(x,np.polyval(ps,x),color="black",linestyle="--")
ps=np.polyfit(x,dera[:,2],1)
ax2.plot(x,np.polyval(ps,x),color="grey",linestyle="--")
ax2.yaxis.tick_right()
ax.text(1980,5300,"$\it{r}$ = %.2f"%r29,fontsize=8)
for item in ([ax.title, ax.xaxis.label, ax.yaxis.label] +
             ax.get_xticklabels() + ax.get_yticklabels()):
    item.set_fontsize(8)
    
for item in ([ax2.title, ax2.xaxis.label, ax2.yaxis.label] +
             ax2.get_xticklabels() + ax2.get_yticklabels()):
    item.set_fontsize(8)
# TW 27
ax = plt.subplot(gs1[3, 0])
ax.plot(x,d2[:,4],color="black")
ax.set_xticklabels([])
ax.set_yticks([30000,75000])
ax.set_yticklabels([30000,75000])
ax.yaxis.tick_right()
ax2=ax.twinx()
ax2.plot(x,dera[:,3],color="grey",linestyle="-")
r27=np.corrcoef(d2[:,4],dera[:,3])[0,1]
ax.set_xlim(1978.5,2018)
ps=np.polyfit(x,d2[:,4],1)
ax.text(1980,77000,"TW$\geq$27$^{\circ}$C",fontsize=8)
ax.plot(x,np.polyval(ps,x),color="black",linestyle="--")
ps=np.polyfit(x,dera[:,3],1)
ax2.plot(x,np.polyval(ps,x),color="grey",linestyle="--")
ax.text(1980,63000,"$\it{r}$ = %.2f"%r27,fontsize=8)
ax2.yaxis.tick_right()
for item in ([ax.title, ax.xaxis.label, ax.yaxis.label] +
             ax.get_xticklabels() + ax.get_yticklabels()):
    item.set_fontsize(8)   
for item in ([ax2.title, ax2.xaxis.label, ax2.yaxis.label] +
             ax2.get_xticklabels() + ax2.get_yticklabels()):
    item.set_fontsize(8)
    
# All-time max
ax = plt.subplot(gs1[4, 0])
ax.plot(x,dmax,color="black")
ax.yaxis.tick_right()
#ax.set_yticks([31.2,34.5])
#ax.set_yticklabels([]); ax.set_xticklabels([])
##ax.set_yticklabels([30000,75000])
ax.set_xlim(1978.5,2018)
ps=np.polyfit(x,dmax,1)
ax.text(1980,33.7,"$\it{max}$(TW)",fontsize=8)
ax.plot(x,np.polyval(ps,x),color="black",linestyle="--")
ax.yaxis.set_label_position("right")
for item in ([ax.title, ax.xaxis.label, ax.yaxis.label] +
             ax.get_xticklabels() + ax.get_yticklabels()):
    item.set_fontsize(8)
ax.set_ylabel("$^{\circ}$C")

# Glob mean 
ax = plt.subplot(gs1[5, 0])
ax.plot(x,dglob[:,0],color="k")
ax.set_xlim(1978.5,2018)
ps=np.polyfit(x,dglob[:,0],1)
ax.plot(x,np.polyval(ps,x),color="k",linestyle="--")
ax.text(1980,1.1,r"$\langle$ T $\rangle$",fontsize=8)
# Also scatter TW>=35
ax.scatter(x,np.ones(len(x))*0.4,s=d2[:,0]*70,color="grey",alpha=0.4,edgecolor="black")
ax.scatter(-100,-100,s=70,color="grey",edgecolor="black",\
                   label="1 occurrence of TW$\geq$35$^{\circ}$C",alpha=0.4)
for item in ([ax.title, ax.xaxis.label, ax.yaxis.label] +
             ax.get_xticklabels() + ax.get_yticklabels()):
    item.set_fontsize(8)
ax.legend(loc=9,fontsize=8)
ax.set_ylim([0.25,1.3])
ax.set_xticks([1979,1987,1997,2007,2017])
ax.set_xlabel("Year")
ax.set_ylabel("$^{\circ}$C")
f.savefig("Fig2.1.png",dpi=300)