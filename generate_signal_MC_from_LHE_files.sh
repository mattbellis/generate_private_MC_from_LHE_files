#####################################################################################
#!/bin/bash
#echo "Starting job on " `date` #Date/time of start of job
#echo "Running on: `uname -a`" #Condor job is running on this node
#echo "System software: `cat /etc/redhat-release`" #Operating System on that node
#source /cvmfs/cms.cern.ch/cmsset_default.sh  ## if a tcsh script, use .csh instead of .sh
#tar -zxf CMSSW7120.tgz
#rm CMSSW7120.tgz
#export SCRAM_ARCH=slc6_amd64_gcc481
##eval `scramv1 project CMSSW CMSSW_7_1_20`
#cd CMSSW_7_1_20/src/
#scramv1 b ProjectRename
#eval `scramv1 runtime -sh` # cmsenv is an alias not on the workers

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
#####################################################################################

##### GEN AND SIM ###################################################################

#####################################################################################

# This is the one with the powheg stuff 
# 
#GENFRAG="TOP-RunIISummer15wmLHEGS-00035"
# USING THIS BUT MADE A COPY OF IT
#curl -s --insecure https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/"$GENFRAG" --retry 2 --create-dirs -o Configuration/GenProduction/python/"$GENFRAG"-fragment.py
#[ -s Configuration/GenProduction/python/"$GENFRAG"-fragment.py ] # || exit $?;

# NOT USING THIS ONE
#GENFRAG="TOP-RunIISummer15GS-00044"

GENERATOR_FRAGMENT="my_generator_fragment.py"
INFILE=$1
FILETAG=`basename $INFILE .lhe`

#HOME=""
#echo "Unsetting HOME....."

echo "Basename is "$FILETAG

#GENERATOR_FRAGMENT="TOP-RunIISummer15wmLHEGS-00035-fragment.py"

# Need to make the directory where things go
mkdir Configuration
mkdir Configuration/GenProduction
mkdir Configuration/GenProduction/python

scram b
cd ../../

#ls -ltr

# Generator fragment has to be copied to here
cp $GENERATOR_FRAGMENT CMSSW_7_1_20/src/Configuration/GenProduction/python/.

# ADDED ,SIM to --step, 10/4/2018
cmsDriver.py Configuration/GenProduction/python/"$GENERATOR_FRAGMENT"  --filein file:"$INFILE" --filetype=LHE --fileout file:"$FILETAG"_GEN_SIM.root --mc --eventcontent RAWSIM --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --conditions MCRUN2_71_V1::All --beamspot Realistic50ns13TeVCollision --step GEN,SIM --magField 38T_PostLS1 --python_filename "$FILETAG"_LHE_GEN_SIM_cfg.py --no_exec -n -1

cat "$FILETAG"_LHE_GEN_SIM_cfg.py
#cmsRun "$FILETAG"_LHE_GEN_SIM_cfg.py

ls -ltr

#exit

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

ls -ltr

echo
echo $FILETAG
echo
#exit
#####################################################################################


echo "---------------------------------------------------------"
echo "          Starting Step 1                                "
echo "---------------------------------------------------------"

cmsDriver.py step1 --filein "file:"$FILETAG"_GEN_SIM.root" --fileout file:"$FILETAG"-RunIISummer16DR80Premix-DIGIPREMIXRAW.root  --pileup_input "dbs:/Neutrino_E-10_gun/RunIISpring15PrePremix-PUMoriond17_80X_mcRun2_asymptotic_2016_TrancheIV_v2-v2/GEN-SIM-DIGI-RAW" --mc --eventcontent PREMIXRAW --datatier GEN-SIM-RAW --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --step DIGIPREMIX_S2,DATAMIX,L1,DIGI2RAW,HLT:@frozen2016 --nThreads 4 --datamix PreMix --era Run2_2016 --python_filename "$FILETAG"-RunIISummer16DR80Premix-DIGIPREMIXRAW_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n -1 # || exit $? ; 

echo "Dump output"
echo
cat "$FILETAG"-RunIISummer16DR80Premix-DIGIPREMIXRAW_cfg.py
echo
echo
echo

exit

#cmsRun "$FILETAG"-RunIISummer16DR80Premix-DIGIPREMIXRAW_cfg.py

#####################################################################################

#exit

echo "---------------------------------------------------------"
echo "          Starting Step 2                                "
echo "---------------------------------------------------------"

cmsDriver.py step2 --filein file:"$FILETAG"-RunIISummer16DR80Premix-DIGIPREMIXRAW.root --fileout file:"$FILETAG"-RunIISummer16DR80Premix-RECO.root --mc --eventcontent AODSIM --runUnscheduled --datatier AODSIM --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --step RAW2DIGI,RECO,EI --nThreads 4 --era Run2_2016 --python_filename "$FILETAG"-RunIISummer16DR80Premix-RECO_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n -1 # || exit $? ; 

#cmsRun "$FILETAG"-RunIISummer16DR80Premix-RECO_cfg.py


#####################################################################################
# Make into MINIAOD
# https://cms-pdmv.cern.ch/mcm/requests?produce=%2FTT_TuneCUETP8M2T4_13TeV-powheg-pythia8%2FRunIISummer16MiniAODv2-PUMoriond17_80X_mcRun2_asymptotic_2016_TrancheIV_v6-v1%2FMINIAODSIM&page=0&shown=4398046511103
#####################################################################################

echo "---------------------------------------------------------"
echo "          Starting Step 3                                "
echo "---------------------------------------------------------"

cmsDriver.py step1 --filein "file:"$FILETAG"-RunIISummer16DR80Premix-RECO.root" --fileout file:"$FILETAG"-RunIISummer16MiniAODv2-MINIAODSIM.root --mc --eventcontent MINIAODSIM --runUnscheduled --datatier MINIAODSIM --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --step PAT --nThreads 4 --era Run2_2016 --python_filename "$FILETAG"-RunIISummer16MiniAODv2-MINIAODSIM_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n -1 #|| exit $? ; 

#cmsRun "$FILETAG"-RunIISummer16MiniAODv2-MINIAODSIM_cfg.py

ls -ltr

exit

#####################################################################################
# Copy the files over
#####################################################################################
# This directory has to already exist
echo xrdcp "$FILETAG".root root://cmseos.fnal.gov//store/user/mbellis/signalMC/.
     xrdcp "$FILETAG".root root://cmseos.fnal.gov//store/user/mbellis/signalMC/.
     xrdcp "$FILETAG"-RunIISummer16DR80Premix-00008_step1.root root://cmseos.fnal.gov//store/user/mbellis/signalMC/.
     xrdcp "$FILETAG"-RunIISummer16DR80Premix-00008.root root://cmseos.fnal.gov//store/user/mbellis/signalMC/.
     xrdcp "$FILETAG"-RunIISummer16MiniAODv2-00061.root root://cmseos.fnal.gov//store/user/mbellis/signalMC/.

#/eos/uscms/store/user/mbellis
### remove the output file if you don't want it automatically transferred when the job ends
#rm "$FILETAG"*.root
#rm "$FILETAG"*cfg.py
#cd ${_CONDOR_SCRATCH_DIR}
#rm -rf CMSSW_7_1_20
#rm -rf CMSSW_8_0_21

