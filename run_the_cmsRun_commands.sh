#####################################################################################
#!/bin/bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc481
if [ -r CMSSW_7_1_20/src ] ; then 
     echo release CMSSW_7_1_20 already exists
 else
     # Grabbed this from https://uscms.org/uscms_at_work/computing/setup/batch_systems.shtml
     eval `scramv1 p CMSSW CMSSW_7_1_20`
fi
cd CMSSW_7_1_20/src
eval `scram runtime -sh`

scram b
cd ../../

echo "Starting..............."
echo
date
echo
cmsRun TEMPLATE_LHE_GEN_SIM_cfg.py $1
echo
echo "Finished................"
date
echo


#####################################################################################
# SIM RECO AND STUFF
#####################################################################################
# https://cms-pdmv.cern.ch/mcm/requests?produce=%2FTT_TuneCUETP8M2T4_13TeV-powheg-pythia8%2FRunIISummer15wmLHEGS-MCRUN2_71_V1-v1%2FGEN-SIM&page=0&shown=275417401471
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc530
if [ -r CMSSW_8_0_21/src ] ; then 
 echo release CMSSW_8_0_21 already exists
else
 eval `scramv1 p CMSSW CMSSW_8_0_21`
 #scram p CMSSW CMSSW_8_0_21
fi
cd CMSSW_8_0_21/src
eval `scram runtime -sh`

scram b
cd ../../


echo "Starting..............."
echo
date
echo
cmsRun TEMPLATE-RunIISummer16DR80Premix-DIGIPREMIXRAW_cfg.py $1
echo
echo "Finished................"
date
echo


echo "Starting..............."
echo
date
echo
cmsRun TEMPLATE-RunIISummer16DR80Premix-RECO_cfg.py $1
echo
echo "Finished................"
date
echo


echo "Starting..............."
echo
date
echo
cmsRun TEMPLATE-RunIISummer16MiniAODv2-MINIAODSIM_cfg.py $1
echo
echo "Finished................"
date
echo



#exit

INFILE=$1
FILETAG=`basename $INFILE .lhe`

#####################################################################################
# This directory has to already exist
xrdcp "$FILETAG"_GEN_SIM.root root://cmseos.fnal.gov//store/user/mbellis/signalMC/.
xrdcp "$FILETAG"-RunIISummer16DR80Premix-RECO.root root://cmseos.fnal.gov//store/user/mbellis/signalMC/.
xrdcp "$FILETAG"-RunIISummer16DR80Premix-DIGIPREMIXRAW.root root://cmseos.fnal.gov//store/user/mbellis/signalMC/.
xrdcp "$FILETAG"-RunIISummer16MiniAODv2-MINIAODSIM.root root://cmseos.fnal.gov//store/user/mbellis/signalMC/.

#/eos/uscms/store/user/mbellis
### remove the output file if you don't want it automatically transferred when the job ends
#rm "$FILETAG"*.root
#rm "$FILETAG"*cfg.py
##cd ${_CONDOR_SCRATCH_DIR}
#rm -rf CMSSW_7_1_20
#rm -rf CMSSW_8_0_21

