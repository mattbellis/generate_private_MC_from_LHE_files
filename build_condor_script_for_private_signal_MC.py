import numpy as np
import sys
import subprocess as sp

import os

# Make the log file directory
if not os.path.exists('./condor_log_files'):
    os.makedirs('./condor_log_files')

infile = sys.argv[1]

cmd = "universe = vanilla\n"
cmd += "Executable = execute_on_condor.sh\n"
cmd += "Should_Transfer_Files = YES\n"
cmd += "WhenToTransferOutput = ON_EXIT\n"
cmd += "Transfer_Input_Files = generate_signal_MC_from_LHE_files.sh, my_generator_fragment.py, %s\n" % (infile)
cmd += "Output = condor_log_files/bellis_%s_$(Cluster)_$(Process).stdout\n" % (infile.split('.lhe')[0])
cmd += "Error = condor_log_files/bellis_%s_$(Cluster)_$(Process).stderr\n" % (infile.split('.lhe')[0])
cmd += "Log = condor_log_files/bellis_%s_$(Cluster)_$(Process).log\n" % (infile.split('.lhe')[0])
cmd += "notify_user = mbellis@FNAL.GOV\n"
cmd += "x509userproxy = /tmp/x509up_u47418 \n"
cmd += "Arguments = %s " % (infile)
'''
for infile in infiles:
    prepend = "root://cmsxrootd.fnal.gov//store/user/mbellis"
    #postpend = infile.split('mbellis')[1]
    postpend = infile.split('eos_store')[1]
    filename = "%s/%s " % (prepend, postpend)
    cmd += filename 
'''
cmd += "\n"
cmd += "Queue 1\n"

print(cmd)

outfilename = "cdr_temp_%s.jdl" % (infile.split('.lhe')[0])
outfile = open(outfilename,'w')
outfile.write(cmd)
outfile.close()

# Submit it
condor_cmd = ['condor_submit', outfilename]
sp.Popen(condor_cmd,0).wait()

