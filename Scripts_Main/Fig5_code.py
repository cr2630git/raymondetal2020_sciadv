#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This script explores maximum TW values in the reanalysis data 
"""

import datetime, matplotlib.pyplot as plt
import numpy as np
from netCDF4 import Dataset
from mpl_toolkits.basemap import Basemap
from netcdftime import utime

def conTimes(time_str="",calendar="",times=np.empty(1),safe=False):

    """
    This function takes a time string (e.g. hours since 0001-01-01 00:00:00),
    along with a numpy array of times (hours since base) and returns: year, month, day.
	
    Inefficient at present (with mulitple vectorize calls), but sufficient
    """

    timeObj=utime(time_str,calendar=calendar)

    # set up the functions
    f_times = np.vectorize(lambda x: timeObj.num2date(x))
    f_year = np.vectorize(lambda x: x.year)
    f_mon = np.vectorize(lambda x: x.month)
    f_day = np.vectorize(lambda x: x.day)
    f_hour = np.vectorize(lambda x: x.hour)
    
    # Call them
    pyTimes = f_times(times); year = f_year(pyTimes); mon = f_mon(pyTimes)
    day = f_day(pyTimes); hour = f_hour(pyTimes)
    
    # check that 'proper' datetime has been returned:
    if safe:
        year=np.atleast_1d(year); mon=np.atleast_1d(mon); day=np.atleast_1d(day)
        pyTimes = np.array([datetime(year[ii],mon[ii],day[ii]) for ii in \
        range(len(year))])

    return year,mon,day,hour,pyTimes

def movStat(series,ind,obj,method,span):
    
    """
    This function calculates the moving statistic over an arbitary-length 
    window. It does this by simple iteration, so may be slow for large series.
    We access the particular method of the 'object' module by using 
    "getattr".
    
    """
    f = getattr(obj,method)
    n = len(series)
    outData = np.zeros(n-span+1)
    outInd = np.zeros((outData.shape))
    even=False
    row = 0
    if span % 2 == 0:
        even = True
    for ii in range(span,len(series)+1):
        outData[row] = f(series[ii-span:ii])
        row +=1   
    if even:        
        ist=np.int(span/2.-1); istp=np.int(-(span/2.))
        outInd=ind[ist:istp]+0.5     
    else:
        ist=np.int((span-1)/2.); istp=np.int(-(span-1)/2.)
        outInd=ind[ist:istp]
        
    return outData,outInd

# Plot timeseries (left panel)
fig5,ax=plt.subplots(1,2)
# Filename (Will need changing to reflect local storage)
sstfile="HadISST_ANN_MAX.nc"
sstf=Dataset(sstfile,"r")
sst=np.squeeze(sstf["sst"][:])
time_s=sstf["time"]
ax.flat[0].plot(np.arange(1870,2018),sst,color="k",marker=".")
ax.flat[0].set_ylabel("SST ($^{\circ}$C)")
ax.flat[0].set_xlabel("Year")
year_s,mon_s,day_s,hour_s,pyTimes_s=\
conTimes(time_str=time_s.units,calendar=time_s.calendar,times=time_s[:],\
            safe=False)
outData,outInd=movStat(sst,year_s,np,"mean",30)
ax.flat[0].plot(outInd,outData,linestyle="--",color="orange",linewidth=2)
ax.flat[0].set_xlim(1870,2018)
ax.flat[0].axhline(35,color="red")

# Plot grid (right panel)
# Ditto re. filename
sstfile="HadISST_sst_c_grid.nc"
sstf=Dataset(sstfile,"r")
sst=np.squeeze(sstf["sst"][:,:,:])
lonsst=sstf["longitude"][:]
latsst=sstf["latitude"][:]
lon2,lat2=np.meshgrid(lonsst,latsst)
m = Basemap(llcrnrlon=30.,llcrnrlat=10,urcrnrlon=75.,urcrnrlat=40.,\
            rsphere=(6378137.00,6356752.3142),\
            resolution='l',projection='merc',\
            lat_0=15.,lon_0=60.,lat_ts=15.,ax=ax.flat[1],fix_aspect=False)
m.drawcoastlines(linewidth=0.8,color="cyan")
x,y=m(lon2,lat2)
plotArr=sst*1.
plotArr[plotArr<28]=np.nan
bins=np.linspace(np.nanmin(plotArr),np.nanmax(plotArr),50)
cs=m.contourf(x,y,plotArr,levels=bins,cmap="hot")
# draw parallels.
parallels = np.arange(-90.,90,20.)
m.drawparallels(parallels,labels=[1,0,0,0],fontsize=8,linewidth=0.1)
# draw meridians
meridians = np.arange(-180.,180.,30.)
m.drawmeridians(meridians,labels=[0,0,1,0],fontsize=8,linewidth=0.1)
cbar = m.colorbar(cs,location='bottom',pad="5%")
cbar.set_ticks([28,29,30,31,32,33,34,35,36,37])
cbar.set_label("SST ($^{\circ}$C)")
# scatter exceedances 
ind=plotArr>=35
coords=np.column_stack(((lon2[ind]).flatten(),(lat2[ind]).flatten()))
x,y=m(coords[:,0],coords[:,1])
m.scatter(x,y,color="blue",s=2,marker=".")

# Export
fig5.set_size_inches(7,4)
fig5.savefig("Fig5.png",dpi=300)
