# humidheat

To replicate results:

1. Download all scripts as well as the contents of the Data folder. Edit masterscript to point to the proper local directories.

2. (Optional) If wanting to replicate Supplemental Figures S3 and S4: from the ECMWF website, download 6-hourly 1000-mb ERA-Interim data for specific humidity (q), temperature (T), u-wind, and v-wind for 1979-2017. Additionally, use ecmwfdownloadscript.sh.py to download 2-m ERA-Interim T and Td data for 1979-2017. Then, use erainterimcalc2mtw to compute 2-m Tw for Southwest Asia.
    
3. Run the four "essential" loops within masterscript.

4. Finally, run makefinalfigures to create any figures that are desired.

5. To recreate the datasets saved in finalarrays.mat, run the script downloadreadandqcdata.

Please contact Colin Raymond (cr2630@columbia.edu) with any questions or to report any bugs.
