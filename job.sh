#!/bin/bash
module load r
module load jags
echo $1
Rscript code_nma/project.R $1

