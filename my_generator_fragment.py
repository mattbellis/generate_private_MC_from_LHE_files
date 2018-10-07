import FWCore.ParameterSet.Config as cms

externalLHEProducer = cms.EDProducer("ExternalLHEProducer",
    args = cms.vstring('/cvmfs/cms.cern.ch/phys_generator/gridpacks/slc6_amd64_gcc481/13TeV/powheg/V2/TT_hdamp_Tune4_NNPDF30/TT_hdamp_Tune4_NNPDF30_13TeV_powheg_hvq.tgz'),
    nEvents = cms.untracked.uint32(5000),
    numberOfParameters = cms.uint32(1),
    outputFile = cms.string('cmsgrid_final.lhe'),
    scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh')
)

#Link to datacards:
#https://github.com/cms-sw/genproductions/blob/master/bin/Powheg/production/TT_hdamp_TuneT4_NNPDF30_13TeV_powheg/TT_hdamp_TuneT4_NNPDF30_13TeV_powheg.input


import FWCore.ParameterSet.Config as cms
from Configuration.Generator.Pythia8CommonSettings_cfi import *
from Configuration.Generator.Pythia8CUEP8M1Settings_cfi import *
from Configuration.Generator.Pythia8PowhegEmissionVetoSettings_cfi import *
generator = cms.EDFilter("Pythia8HadronizerFilter",
maxEventsToPrint = cms.untracked.int32(1),
pythiaPylistVerbosity = cms.untracked.int32(1),
filterEfficiency = cms.untracked.double(1.0),
pythiaHepMCVerbosity = cms.untracked.bool(False),
comEnergy = cms.double(13000.),
PythiaParameters = cms.PSet(
pythia8CommonSettingsBlock,
pythia8CUEP8M1SettingsBlock,
pythia8PowhegEmissionVetoSettingsBlock,
processParameters = cms.vstring(
        'POWHEG:nFinal = 3', ## Number of final state particles
        ## (BEFORE THE DECAYS) in the LHE
        ## other than emitted extra parton
        'TimeShower:mMaxGamma = 1.0',#cutting off lepton-pair production
        ##in the electromagnetic shower
        ##to not overlap with ttZ/gamma* samples
        'Tune:pp 14',
        'Tune:ee 7',
        'MultipartonInteractions:ecmPow=0.25208',
        'SpaceShower:alphaSvalue=0.1108',
        'PDF:pSet=LHAPDF6:NNPDF30_lo_as_0130',
        'MultipartonInteractions:pT0Ref=2.197139e+00',
        'MultipartonInteractions:expPow=1.608572e+00',
        'ColourReconnection:range=6.593269e+00',
),
parameterSets = cms.vstring('pythia8CommonSettings',
#'pythia8CUEP8M1Settings',
'pythia8PowhegEmissionVetoSettings',
'processParameters'
)
)
)
ProductionFilterSequence = cms.Sequence(generator)
