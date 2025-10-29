#!/bin/bash

submitdir='merge_submit'
joblist='allmergejobs.list'
#sleep 7200
lstart=801
lend=1100
#for j in `ls $submitdir/*.submit`
for j in `awk '{ if ( NR >= '${lstart}' && NR <= '${lend}' ) print $1}' ${joblist}`
do
	echo $j	
	sbatch $j
	sleep 0.05
done
