#####################################################################################
#!/bin/bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc481
if [ -r CMSSW_7_1_20/src ] ; then 
     echo release CMSSW_7_1_20 already exists
 else
     scram p CMSSW CMSSW_7_1_20
fi
cd CMSSW_7_1_20/src
eval `scram runtime -sh`
#####################################################################################

##### GEN AND SIM ###################################################################

#####################################################################################

# This is the one with the powheg stuff but I edited it to deal with 3 "final" state particles
# 
# If you download a new one it will only want 2 final state particles
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

#GENERATOR_FRAGMENT="TOP-RunIISummer15wmLHEGS-00035-fragment.py"

scram b
cd ../../

# Generator fragment has to be copied to here
cp $GENERATOR_FRAGMENT CMSSW_7_1_20/src/Configuration/GenProduction/python/.

# ADDED ,SIM to --step, 10/4/2018
cmsDriver.py Configuration/GenProduction/python/"$GENERATOR_FRAGMENT"  --filein file:"$INFILE" --filetype=LHE --fileout file:"$FILETAG".root --mc --eventcontent RAWSIM --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --conditions MCRUN2_71_V1::All --beamspot Realistic50ns13TeVCollision --step GEN,SIM --magField 38T_PostLS1 --python_filename "$FILETAG"_1_cfg.py --no_exec -n -1

cmsRun "$FILETAG"_1_cfg.py

#####################################################################################
# SIM RECO AND STUFF
#####################################################################################
# https://cms-pdmv.cern.ch/mcm/requests?produce=%2FTT_TuneCUETP8M2T4_13TeV-powheg-pythia8%2FRunIISummer15wmLHEGS-MCRUN2_71_V1-v1%2FGEN-SIM&page=0&shown=275417401471
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc530
if [ -r CMSSW_8_0_21/src ] ; then 
 echo release CMSSW_8_0_21 already exists
else
 scram p CMSSW CMSSW_8_0_21
fi
cd CMSSW_8_0_21/src
eval `scram runtime -sh`

scram b
cd ../../

echo
echo $FILETAG
echo
#exit
#####################################################################################


echo "---------------------------------------------------------"
echo "          Starting Step 1                                "
echo "---------------------------------------------------------"

cmsDriver.py step1 --filein "file:"$FILETAG".root" --fileout file:"$FILETAG"-RunIISummer16DR80Premix-00008_step1.root  --pileup_input "dbs:/Neutrino_E-10_gun/RunIISpring15PrePremix-PUMoriond17_80X_mcRun2_asymptotic_2016_TrancheIV_v2-v2/GEN-SIM-DIGI-RAW" --mc --eventcontent PREMIXRAW --datatier GEN-SIM-RAW --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --step DIGIPREMIX_S2,DATAMIX,L1,DIGI2RAW,HLT:@frozen2016 --nThreads 4 --datamix PreMix --era Run2_2016 --python_filename "$FILETAG"-RunIISummer16DR80Premix-00008_1_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n -1 # || exit $? ; 

cmsRun "$FILETAG"-RunIISummer16DR80Premix-00008_1_cfg.py

#####################################################################################

echo "---------------------------------------------------------"
echo "          Starting Step 2                                "
echo "---------------------------------------------------------"

cmsDriver.py step2 --filein file:"$FILETAG"-RunIISummer16DR80Premix-00008_step1.root --fileout file:"$FILETAG"-RunIISummer16DR80Premix-00008.root --mc --eventcontent AODSIM --runUnscheduled --datatier AODSIM --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --step RAW2DIGI,RECO,EI --nThreads 4 --era Run2_2016 --python_filename "$FILETAG"-RunIISummer16DR80Premix-00008_2_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n -1 # || exit $? ; 

cmsRun "$FILETAG"-RunIISummer16DR80Premix-00008_2_cfg.py


#####################################################################################
# Make into MINIAOD
# https://cms-pdmv.cern.ch/mcm/requests?produce=%2FTT_TuneCUETP8M2T4_13TeV-powheg-pythia8%2FRunIISummer16MiniAODv2-PUMoriond17_80X_mcRun2_asymptotic_2016_TrancheIV_v6-v1%2FMINIAODSIM&page=0&shown=4398046511103
#####################################################################################

echo "---------------------------------------------------------"
echo "          Starting Step 3                                "
echo "---------------------------------------------------------"

cmsDriver.py step1 --filein "file:"$FILETAG"-RunIISummer16DR80Premix-00008.root" --fileout file:"$FILETAG"-RunIISummer16MiniAODv2-00061.root --mc --eventcontent MINIAODSIM --runUnscheduled --datatier MINIAODSIM --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --step PAT --nThreads 4 --era Run2_2016 --python_filename "$FILETAG"-RunIISummer16MiniAODv2-00061_1_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n -1 #|| exit $? ; 

cmsRun "$FILETAG"-RunIISummer16MiniAODv2-00061_1_cfg.py

#####################################################################################
# Copy the files over
#####################################################################################
# This directory has to already exist
echo xrdcp $2 root://cmseos.fnal.gov//store/user/mbellis/signalMC/.
     xrdcp $2 root://cmseos.fnal.gov//store/user/mbellis/signalMC/.

#/eos/uscms/store/user/mbellis
### remove the output file if you don't want it automatically transferred when the job ends
rm "$FILETAG"*.root
rm "$FILETAG"*cfg.py
#cd ${_CONDOR_SCRATCH_DIR}
rm -rf CMSSW_7_1_20
rm -rf CMSSW_8_0_21

