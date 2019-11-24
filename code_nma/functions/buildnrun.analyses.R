buildnrun.analyses <- function(re.model,
                               re.model.params,
                               networks,
                               which.analyses,
                               inputs,
                               use.mapping,
                               save.mcmcs,
                               traceplots) {
  #re.model will be what models the baseline effects using re.model.params <--- a vector of parameters to be supplied
  #    for example, say re.model="dt" and re.model.params=c(1,2,3) then the .bugs file will be modified accordingly
  
  
  
  ### CREATE THE NEW FILE AND PLUG IT IN BELOW
  # NAME THE FILE IN A WAY THAT REFLECTS THE PARAMETERS ENTERRED
  
  
  ## USE MISSING TO CHECK IF A PARAMETER IS GIVEN A VALUE
  ################################## RANDOM BASELINE EFFECTS MODEL ##################################################
  re.model.params.string <- str_c(re.model.params, collapse = ",") #values but separated by commasssss


  cat("The parameter string:\n")
  print(re.model.params.string)
  if (!grepl("?",re.model.params.string)) { 
	  template.random <- "
  #### random effect prior on baseline rates for each of NUMTRIAL trials
  #### 1-st agent is reference, effects for agents 2 thru NUMAGENT relative to this
  
  model {
  
    ### parameter rho, as per PG's notes (Feb 2013)
    rho <- 0.5
    rho.inv <- 1/rho
    rhocomp.inv <- 1/(1-rho)
    
    ### parameter sigma^2, as per notes
    sig2 ~ dunif(0,10)
    sig2.inv <- 1/sig2
    
    ### d[i] is typical log-OR, (i+1)-st agent compared to 1st-agent, as per notes
    for (i in 1:(NUMAGENTS-1)) {
    d[i] ~ dnorm(0, 0.000001)
    }
    
    ### ltnt[] are trick variables to represent correlation structure
    for (i in 1:NUMTRIALS) {
      ltnt[i] ~ dnorm(0, ltnt.prc)
    }
    ltnt.prc <- rho.inv*sig2.inv
    
    ### alpha[i] is i-th trial baseline
    for (i in 1:NUMTRIALS) {
      alpha[i] ~ %s(%s) # MODEL, PARAMS SPECIFIED HERE
    }
    
    alpha.mn ~ dnorm(0,0.000001)
    alpha.prc <- 1/alpha.vr
    alpha.vr ~ dunif(0,10)
    
    
    ### dlta[i,j] is log-OR for j-th agent compared to 1st, in i-th trial
    ### whether or not these arm exists in the i-th trial
    for (i in 1:NUMTRIALS) {
      logit(scsrt[i,1]) <- alpha[i]
      for (j in 2:NUMAGENTS) {
        dlta[i,j-1] ~ dnorm(dlta.mn[i,j-1], dlta.prc)
        dlta.mn[i,j-1] <- ltnt[i]+d[j-1]
        logit(scsrt[i,j]) <- alpha[i]+dlta[i,j-1]
      }
    }
    dlta.prc <- rhocomp.inv*sig2.inv
    
    ### TOTARMS = sum over all trials of number of arms in each trial
    ### think of each trial,arm combo being a row in the data matrix
    ### columns tell which *trial*, which *agent*, number treated (n)
    ### and number of successes (y)
    
    for (i in 1:TOTARMS) {
    y[i] ~ dbin( scsrt[trial[i],agent[i]], n[i]) 
    
    }
    
  }"

  random.text <- sprintf(template.random, re.model, re.model.params.string)
  } else {

    cat("A PRIOR WILL BE PUT ON THE DEGREES OF FREEDOM FOR THE STUDENT T DISTRIBUTION USED TO MODEL THE ALPHAS")
      template.random <-  "
  #### random effect prior on baseline rates for each of NUMTRIAL trials
  #### 1-st agent is reference, effects for agents 2 thru NUMAGENT relative to this
  
  model {
	    
	      ### parameter rho, as per PG's notes (Feb 2013)
	      rho <- 0.5
    rho.inv <- 1/rho
        rhocomp.inv <- 1/(1-rho)
        
        ### parameter sigma^2, as per notes
        sig2 ~ dunif(0,10)
	    sig2.inv <- 1/sig2
	    
	    ### d[i] is typical log-OR, (i+1)-st agent compared to 1st-agent, as per notes
	    for (i in 1:(NUMAGENTS-1)) {
		        d[i] ~ dnorm(0, 0.000001)
	        }
	        
	        ### ltnt[] are trick variables to represent correlation structure
	        for (i in 1:NUMTRIALS) {
			      ltnt[i] ~ dnorm(0, ltnt.prc)
		    }
	        ltnt.prc <- rho.inv*sig2.inv
		    
        ### PUTTING A PRIOR ON df
        for (i in 1:30) {
          pi[i] <- 1/30
        }
        df ~ dcat(pi)

		    ### alpha[i] is i-th trial baseline
		    for (i in 1:NUMTRIALS) {
			          alpha[i] ~ dt(alpha.mn,alpha.prc,df) # MODEL, PARAMS SPECIFIED HERE
		    }
		    
		    alpha.mn ~ dnorm(0,0.000001)
		        alpha.prc <- 1/alpha.vr
		        alpha.vr ~ dunif(0,10)
			    
			    
			    ### dlta[i,j] is log-OR for j-th agent compared to 1st, in i-th trial
			    ### whether or not these arm exists in the i-th trial
			    for (i in 1:NUMTRIALS) {
				          logit(scsrt[i,1]) <- alpha[i]
			      for (j in 2:NUMAGENTS) {
		                      dlta[i,j-1] ~ dnorm(dlta.mn[i,j-1], dlta.prc)
			              dlta.mn[i,j-1] <- ltnt[i]+d[j-1]
				              logit(scsrt[i,j]) <- alpha[i]+dlta[i,j-1]
				            }
			          }
			    dlta.prc <- rhocomp.inv*sig2.inv
			        
			        ### TOTARMS = sum over all trials of number of arms in each trial
			        ### think of each trial,arm combo being a row in the data matrix
			        ### columns tell which *trial*, which *agent*, number treated (n)
			        ### and number of successes (y)
			        
			        for (i in 1:TOTARMS) {
					    y[i] ~ dbin( scsrt[trial[i],agent[i]], n[i]) 
			        
			        }
			        
			      }"
            random.text <- template.random
  }
  #############################################################
  
  
  
  sink(paste0("code_nma/models", "/model-random.bug"))# model.random.name))
  cat(random.text)
  sink()
  
  
  
  ## IS THERE A WAY TO REFERENCE THE GLOBAL which.analyses ???
  ###Select which analyses will be performed###
  which.analyses <- define.all.analyses(names(networks$datasets), 
                                        c(rep("model-random.bug", # MODEL RANDOM
                                              length(networks$datasets)-1), 
                                          "model-fixed.bug"))   # MODEL FIXED
 
  cat("\nAnalyses to be conducted:\n")
  which.analyses

  
  
  
  save(which.analyses, file=paste0(RData.folder,"/whichanalyses.RData"))
  
  
  
  # TODO: add an extra parameter to run.analysis which is the name and modify the output direction
  run.analyses(networks,
               which.analyses,
               inputs="inputs.general.R",
               use.mapping=mapping.needed,
               save.mcmcs=TRUE,
               traceplots=TRUE
               #modelname=model.random.name
               )
  
  
  
  

  
}
