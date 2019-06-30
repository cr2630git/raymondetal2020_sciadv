#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 24 17:57:11 2019

@author: gytm3
"""
import matplotlib.pyplot as plt
import numpy as np
from netCDF4 import Dataset
from mpl_toolkits.basemap import Basemap

# Filnames -- change to reflect place in file system -- note rel. path here
eraigridf="ERA-I_DJ_TIM_MAX.nc"
eraifldf="ERA-I_DJ_FLD_MAX.txt"
eraigrid=Dataset(eraigridf,"r")

# Load 
eraigrid_tw=eraigrid["TW"][:,:,:]
erai_max=np.max(eraigrid_tw,axis=0)
erai_fld_tw=np.loadtxt(eraifldf)
loni=eraigrid["lon"][:]
lati=eraigrid["lat"][:]
loni2,lati2=np.meshgrid(loni,lati)
loniC2=np.roll(loni2,239,axis=1); loniC2[loniC2>180]-=360
erai_maxC=np.roll(erai_max,239,axis=1)

# Global plots of max TW
fig,ax=plt.subplots(2,1)
m = Basemap(llcrnrlon=-130.,llcrnrlat=-40,urcrnrlon=160.,urcrnrlat=50.,\
            rsphere=(6378137.00,6356752.3142),\
            resolution='l',projection='merc',\
            lat_0=0.,lon_0=60.,lat_ts=0.,ax=ax.flat[0])
m.drawcoastlines(linewidth=0.1)
x,y=m(loniC2,lati2)
plotArr=erai_maxC*1.
plotArr[plotArr<27]=np.nan
bins=np.linspace(np.nanmin(plotArr),np.nanmax(plotArr),50)
cs=m.contourf(x,y,plotArr,levels=bins,cmap="hot")
# draw parallels.
parallels = np.arange(-90.,90,20.)
m.drawparallels(parallels,labels=[1,0,0,0],fontsize=8,linewidth=0.1)
# draw meridians
meridians = np.arange(-180.,180.,40.)
m.drawmeridians(meridians,labels=[0,0,1,0],fontsize=8,linewidth=0.1)
# Set up lon/lats for plotting rectangle...
lon_r=np.array([30,100,100,30,30])
lat_r=np.array([8,8,40,40,8])
x,y=m(lon_r,lat_r)
m.plot(x,y,color="magenta")
for item in ([ax.flat[0].title, ax.flat[0].xaxis.label, ax.flat[0].yaxis.label] +
             ax.flat[0].get_xticklabels() + ax.flat[0].get_yticklabels()):
    item.set_fontsize(8)

# South Asia
m = Basemap(llcrnrlon=30.,llcrnrlat=8,urcrnrlon=100.,urcrnrlat=40.,\
            rsphere=(6378137.00,6356752.3142),\
            resolution='l',projection='merc',\
            lat_0=15.,lon_0=60.,lat_ts=15.,ax=ax.flat[1])
m.drawcoastlines(linewidth=0.8,color="cyan")
x,y=m(loniC2,lati2)
cs=m.contourf(x,y,plotArr,levels=bins,cmap="hot")
# draw parallels.
parallels = np.arange(-90.,90,20.)
m.drawparallels(parallels,labels=[1,0,0,0],fontsize=8,linewidth=0.1)
# draw meridians
meridians = np.arange(-180.,180.,30.)
m.drawmeridians(meridians,labels=[0,0,1,0],fontsize=8,linewidth=0.1)
cbar = m.colorbar(cs,location='bottom',pad="5%")
cbar.set_ticks([28,29,30,31,32,33,34])
#cbar.set_label("T$_{w}$($^{\circ}$C)")
cbar.set_label("WBT ($^{\circ}$C)",fontsize=8)
for item in ([ax.flat[1].title, ax.flat[1].xaxis.label, ax.flat[1].yaxis.label] +
             ax.flat[1].get_xticklabels() + ax.flat[1].get_yticklabels()):
    item.set_fontsize(8)
fig.savefig("FigS5.png",dpi=300)
