library(ismev)
library(extRemes)
library(ncdf4)
library(testit)

# Function to evaluate required T (covariate controlling location)
# to yield a given CDF
requiredT <- function(cdf,shape,scale,intercept,slope){
  
  loc <- -scale/shape*((-log(cdf))^-shape-1)+35
  reqT <- (loc-intercept)/slope
  
  return(reqT)
}


# Associate filname for ann-max TW and read in
fin <- "/media/gytm3/WD12TB/Raymond/ERA-I_ANN_MAX_2017.nc"
fob <-nc_open(fin)
tw <- ncvar_get(fob,"tw")
lon <- ncvar_get(fob,"lon")
lat <- ncvar_get(fob,"lat")
time <- ncvar_get(fob,"time")
nlon <- dim(lon)
nlat<- dim(lat)
ntime <- dim(time)

# Associate filename for <T> and read in (note, 1979-onward)
fin2 <- "/media/gytm3/WD12TB/Raymond/HadCRU_ann_anom_pi_1979.nc"
fob2 <- nc_open(fin2)
temp <- ncvar_get(fob2,"temperature_anomaly")
preds<-matrix(temp,nrow=length(temp),ncol=1)

# Repeat but for land-sea mask
fin3 <- "/media/gytm3/WD12TB/Raymond/land_mask.nc"
fob3 <- nc_open(fin3)
lsm <- ncvar_get(fob3,"lsm") # Note that 1 denotes land (0 is sea)

# Parameters for GEV/Bootstrap
thresh <- 30.625 # 99.9th percentile of TW 
return <- 30; p = 1/30; cdf<-1-p # Params for querying amount of warming required
out <- matrix(NA, ncol=2, nrow=119) # Preallocate - based on 'dry run' (determining the number of points we have >30.625)
crit<-qchisq(.95, df=1) # Chi-squared threshold - to reject null hypothesis (no diff between stationary/non)
n <- 0 # Initialise counter
nboot <- 10000 # Number of bootstrap simulations
nk <- 30 # Size of the sample in each iteration of the bootstrap

# ###################################################################################################
# Perform both loops here -- only fit models where non-stationary is statistically better!
# ###################################################################################################

# Allocate for min reqT
boot_land <- matrix(NA, ncol=1, nrow=nboot)
boot_sea <- matrix(NA, ncol=1, nrow=nboot)

# Set li (the scratch indexer) to 1
li <-1 

for (bi in 1:nboot) { # Loop bootstrap iterations
  
  # Allocate for the required T
  scratch <- matrix(NA, ncol=2, nrow=119)
  
  # Generate random number for the sample
  samp <- sample(1:39,nk,replace=TRUE)
  
  for (rr in 1:nlat) { # loop rows
      
      for (cc in 1:nlon) { # loop cols 
        
        if (max(tw[cc,rr,]>=thresh)){
          
          correl <- cor.test(tw[cc,rr,samp],preds[samp])
          
          # Only fit GEVs in places where max TW series is correlated with 
          # global mean temp (we can afford this efficiency because
          # for each iteration of the bootsrap we are only interested in those
          # locations whose TW series is most sensitive to 
          # global mean temp (to locate the temperature of emergence)
          if ( (correl$p.value < 0.1) & (correl$estimate >0) ) {
            
              n <- n+1 # number of sig correlations
              
              # Fit the GEV(s)
              sink("/dev/null")
              fit_stat<-invisible(gev.fit(tw[cc,rr,samp])) # Stationary model 
              fit_mov<-invisible(gev.fit(matrix(tw[cc,rr,samp]),matrix(preds[samp]),mul=1)) # Moving model 
              sink()
      
              # Differece in log-likelihood
              devi<-2*(fit_stat$nllh-fit_mov$nllh)
              
              if  (devi>crit)  { # non-stationary model is significantly better than stationary
                
                # Then compute the amount of warming required...
                rt <- requiredT(cdf,fit_mov$mle[4],fit_mov$mle[3],fit_mov$mle[1],fit_mov$mle[2])
                
                if (rt >0) { # have this condition to remove negative values
                # These occur when the GEV is not fitted correctly (and shape parameter ends up >>1)
                  
                scratch[li,1] <- rt
                scratch[li,2] <- lsm[cc,rr] # 1 = land (0 = sea)
                li <- li+1
                
                }
              }
            }
          }
        }
  }
  out <- na.omit(scratch)
  boot_land[bi] <- min(out[out[,2]==1,1])
  boot_sea[bi] <- min(out[out[,2]==0,1])
  #print(bi)
  
  # reset list index
  li <- 1
}    

# Write the output
write.table(boot_land,"boot_land.txt",row.names=FALSE,col.names=FALSE) # Land simulation
write.table(boot_sea,"boot_sea.txt",row.names=FALSE,col.names=FALSE) # Sea simulation
