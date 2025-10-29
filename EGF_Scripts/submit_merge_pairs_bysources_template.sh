#!/bin/bash
#SBATCH -J TEMPLATESTATION.mg  #job name to remember
#SBATCH -n 30  #number of CPU cores you request for the job
#SBATCH -A standby  #queue to submit the job
#SBATCH --mem-per-cpu 15G  #requested memory per CPU
#SBATCH -t 04:00:00   #requested time day-hour:minute
#SBATCH -o %x.out  #path and name to save the output file
#SBATCH -e %x.err  #path to save the error file

module purge			#clean up the modules
module load rcac		#reload rcac modules.
module use /depot/xtyang/etc/modules
module load conda-env/seisgo-py3.7.6

python merge_pairs_bysources_MPI.py $SLURM_NTASKS TEMPLATESTATION
