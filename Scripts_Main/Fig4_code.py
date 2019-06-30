#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Dec  5 17:43:12 2018

@author: gytm3
"""
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np, pandas as pd
from netCDF4 import Dataset

#-----------------------------------------------------------------------------#
# Files 
#-----------------------------------------------------------------------------#
maskfile="land_mask.nc" # land/sea mask
areafile="era_area.nc" # cell area (era-int)
gevfile="ReturnGEV_revised.txt" # GEV work
boot_land_f = "boot_land.txt" # Output from R script
boot_sea_f = "boot_sea.txt" # ""

#-----------------------------------------------------------------------------#
# Reading in
#-----------------------------------------------------------------------------#

# Read in the mask
maskobj=Dataset(maskfile,"r")
lon=maskobj["longitude"][:]
lat=maskobj["latitude"][:]
lon2,lat2=np.meshgrid(lon,lat)
mask=np.squeeze(maskobj["lsm"][:,:])
rows=np.arange(len(lat)); cols=np.arange(len(lon))

# Read in the area
areaobj=Dataset(areafile,"r")
area=np.squeeze(areaobj["cell_area"])

# Read in the GEV work -- gives global T required to have TW=35 as the 1-in-30-
# year event
req=pd.read_csv(gevfile,sep=" ")
req_t=req["V3"].values[:]
req_lat=req["V1"].values[:]
req_lon=req["V2"].values[:]
slope=req["V4"]

# Read in boot data
boot_land = np.loadtxt(boot_land_f); print np.median(boot_land)
boot_sea = np.loadtxt(boot_sea_f); print np.median(boot_sea)

# Populate the tw grid 
tw=np.zeros((len(lat),len(lon)))*np.nan
rows_ii=np.array([rows[lat==req_lat[ii]][0] for ii in range(len(req_lat))],dtype=np.int)
cols_ii=np.array([cols[lon==req_lon[ii]][0] for ii in range(len(req_lon))],dtype=np.int)
tw[rows_ii,cols_ii]=req_t

# Populate the slope grid
slope_grid=np.zeros(tw.shape)*np.nan
slope_grid[rows_ii,cols_ii]=slope

# Facilitate area computations
req["area"]=area[rows_ii,cols_ii]
req["land"]=mask[rows_ii,cols_ii]

# Use tw_inc to assess area and land-area above threshold
warming=np.arange(1,5.1,0.1)
area_above=np.zeros(len(warming))
area_above_land=np.zeros(len(warming))
area_above_sea=np.zeros(len(warming))
area_above_sst=np.zeros(len(warming))
te_sea=0
te_land=0
te_sst=0
count=0
for ww in warming:
    ind1=req_t<=ww
    ind2=np.logical_and(ind1,req["land"]==1)
    area_above[count]=np.sum(req["area"][ind1])/1e6
    area_above_land[count]=np.sum(req["area"][ind2])/1e6
    area_above_sea[count]=area_above[count]-area_above_land[count]
    # Find "temps of emergence"
    if area_above_land[count] >0 and te_land == 0:
        te_land=ww
    if area_above[count] >0 and te_sea == 0:
        te_sea=ww   
    if area_above_sst[count] >0 and te_sst == 0:
        te_sst=ww       
    
    count+=1

    
#-----------------------------------------------------------------------------#
# Plotting
#-----------------------------------------------------------------------------#
fig,ax=plt.subplots(3,1)
fig.set_size_inches(5,7)

# GEV
m = Basemap(llcrnrlon=35.,llcrnrlat=15,urcrnrlon=90.,urcrnrlat=32.,\
            rsphere=(6378137.00,6356752.3142),\
            resolution='l',projection='merc',\
            lat_0=15.,lon_0=60.,lat_ts=15.,ax=ax.flat[0],fix_aspect=False)
meridians = np.arange(20.,90.,10.)
parallels = np.arange(15.,32.2,2.5)
x,y=m(lon2,lat2)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(parallels,labels=[1,0,0,0],fontsize=9,linewidth=0.5)
m.drawmeridians(meridians,labels=[0,0,1,0],fontsize=9,linewidth=0.5) 
bins=np.linspace(1,4.,50)
cs=m.contourf(x,y,tw,levels=bins,cmap="hot")
x,y=m(req_lon,req_lat)
m.scatter(x,y,marker=".",s=5,color="k")
cbar = m.colorbar(cs,location='right',pad="5%",format="%.1f",label="$^{\circ}$C")

# Areas
ax.flat[1].plot(warming,area_above_sea,color="green",label="GEV sea",marker=".")
ax.flat[1].plot(warming,area_above_land,color="brown",label="GEV land",marker=".")
ax.flat[1].set_ylim(0,320000)
ax.flat[1].set_xlim(1,4)
ax.flat[1].set_ylabel(r"Area (km$^{2}$)")
ax.flat[1].axvline(te_sea,color="green",linestyle="--")
ax.flat[1].axvline(te_land,color="brown",linestyle="--")
ax.flat[1].legend(loc=2,ncol=3)
plt.tight_layout()

# Histograms
bins=np.linspace(1.25,2.75,50)
ax.flat[2].hist(boot_sea,bins=50,alpha=0.25,color="green")
ax.flat[2].hist(boot_land,bins=50,alpha=0.25,color="brown")
ax.flat[2].axvline(np.median(boot_sea),color="green",linestyle="--")
ax.flat[2].axvline(np.median(boot_land),color="brown",linestyle="--")
ax.flat[2].set_xlim(1,4)
ax.flat[2].set_xlabel(r"$\langle$ T $\rangle$ ($^{\circ}$C)")
ax.flat[2].set_ylabel("Count")

# print the median (5th, 95th)
print "\n\n\n\nLand Median: %.2f (%.2f-->%.2f)" % (np.median(boot_land),\
                          np.percentile(boot_land,5),np.percentile(boot_land,95))
print "Sea Median: %.2f (%.2f-->%.2f)" % (np.median(boot_sea),\
                          np.percentile(boot_sea,5),np.percentile(boot_sea,95))

# Save output 
plt.tight_layout()
fig.savefig("Fig4.png",dpi=300)

# Separate figure with slope
fig,ax=plt.subplots(1,1)
m = Basemap(llcrnrlon=35.,llcrnrlat=15,urcrnrlon=90.,urcrnrlat=32.,\
            rsphere=(6378137.00,6356752.3142),\
            resolution='l',projection='merc',\
            lat_0=15.,lon_0=60.,lat_ts=15.,ax=ax,fix_aspect=False)
meridians = np.arange(20.,80.,10.)
parallels = np.arange(15.,32.2,2.5)
x,y=m(lon2,lat2)
m.drawcoastlines(linewidth=0.5)
m.drawparallels(parallels,labels=[1,0,0,0],fontsize=9,linewidth=0.5)
m.drawmeridians(meridians,labels=[0,0,1,0],fontsize=9,linewidth=0.5) 
bins=np.linspace(0,3,30)
cs=m.contourf(x,y,slope_grid,levels=bins,cmap="hot")
cbar = m.colorbar(cs,location='bottom',pad="5%")
cbar.set_ticks([0.25,0.75,1.25,1.75,2.25,2.75])
cbar.set_label(r"Sensitivity (dimensionless)")
print np.nanmedian(slope)
fig.savefig("Fig4.png",dpi=300)
