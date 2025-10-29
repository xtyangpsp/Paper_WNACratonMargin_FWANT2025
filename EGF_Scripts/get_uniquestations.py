import sys,os, glob
from seisgo import utils
import pandas as pd

root_dir='data_wnacraton'
data_dir=os.path.join(root_dir,'PAIRS_TWOSIDES')
stainfo_list='station_wnacraton.txt'
stainfo_out='station_wnacraton_withdata.txt'

dirlist=utils.get_filelist(data_dir)
stalist_unique=[]

for d in dirlist:
	flist_temp=utils.get_filelist(d,pattern='_P.h5')
	for f in flist_temp:
		 fhead,ftail=os.path.split(f)
# 		 print(ftail)
		 sta1,sta2=ftail.split('_')[0:2]
		 stalist_unique.append(sta1)
		 stalist_unique.append(sta2)
	stalist_unique=(list(set(stalist_unique)))
#
#print(stalist_unique)
print(len(stalist_unique))

#read in the mast station info list.
sta_in=pd.read_csv(stainfo_list)

sta_out=pd.DataFrame()
for ns in stalist_unique:
    n,s = ns.split('.')
    sta_temp=sta_in[(sta_in.network == n) & (sta_in.station == s)]
    sta_out=pd.concat([sta_out,sta_temp])


sta_out.sort_values(by=['network','station'],inplace=True)
sta_out.reset_index(inplace=True,drop=True)

sta_out.to_csv(stainfo_out,index=False)
