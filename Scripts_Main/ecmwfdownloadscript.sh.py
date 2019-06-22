#!/bin/sh

#
#  
#
#  Created by Regular on 4/19/18.
# For variable names, see https://www.ecmwf.int/en/research/projects/ensembles/data-archiving
# 168.128 for td2m, 167.128 for t2m
#
#!/usr/bin/env python
from ecmwfapi import ECMWFDataServer
server = ECMWFDataServer()
server.retrieve({
"class": "ei",
"dataset": "interim",
"date": "2017-01-01/to/2017-12-31",
"expver": "1",
"grid": "0.5/0.5",
"levtype": "sfc",
"param": "168.128",
"step": "0",
"stream": "oper",
"time": "00:00:00/06:00:00/12:00:00/18:00:00",
"type": "an",
"target": "td2m2017",
"format": "netcdf"
})
