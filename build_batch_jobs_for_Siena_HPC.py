import numpy as np
import subprocess as sp

import os
import sys

import time

###############################################################################
def write_output_file(mg_file, batchfilename ):

    output = ""
    output += "#!/bin/bash -l\n"
    output += "#$ -cwd\n"
    output += "#$ -V\n"
    output += "#$ -N bellis_{0} \n".format((batchfilename.replace('/','_')))
    output += "#$ -j y\n"
    output += "#$ -o hpc_script_logs/bellis_$JOB_ID_{0}.log\n".format(mg_file.replace('/','_'))
    output += "#$ -q sos.q\n"
    #output += "#$ -q allsmp.q\n"
    output += "\n"
    output += "# To run the simulation do from the command line:\n"
    output += "# qsub <thisfilename>\n"
    output += "\n"
    #output += "source /etc/profile.d/modules.sh\n"
    output += "\n"
    output += "module load modules GNUStack/cmake\n"
    output += "module load GNUCompiler\n"
    output += "module load Python2\n"
    #output += "export PYTHONPATH=/usr/local/anaconda3/lib:$PYTHONPATH\n"
    #output += "export LD_LIBRARY_PATH=/usr/local/anaconda3/lib:/usr/local/gcc-6.3.0/lib64/:$LD_LIBRARY_PATH\n"
    output += "\n"
    output += "# REMINDER! This is all in bash\n"
    output += "\n"
    output += "date\n"
    output += "echo $SHELL\n"
    output += "\n"
    output += "pwd\n"
    output += "\n"
    #output += "tag=\"%s\"\n" % (tag)
    output += "\n"
    #output += "echo \"outputfile: \" $outputfilename\n"
    output += "\n"
    output += "cd ~/MG5_aMC_v2_7_0 \n"
    output += './bin/mg5_aMC {0}'.format(mg_file) + '\n'
    output += "\n"
    output += "date \n"
    output += " \n"
    output += "echo \"Job $JOB_ID is complete.\" | sendmail mbellis@siena.edu \n"

    #print output

    outfile = open(batchfilename,'w')
    outfile.write(output)
    outfile.close()



################################################################################
# Main function
################################################################################
def main():

    mg_filename = sys.argv[1]
    njobs = 10

    for i in range(njobs):

        infile_tag = mg_filename.split('/')[-1].split(',mg')[0]

        tag = "{0}_{1}".format(infile_tag, str(i))

        batchfilename = "hpc_scripts/batch_%s.sh" % (tag)

        ########################################
        ########################################
        write_output_file(mg_filename,batchfilename)
        print(batchfilename)
        cmd = ['qsub', batchfilename]
        print(cmd)
        sp.Popen(cmd,0).wait()
        time.sleep(1)


################################################################################
################################################################################
if __name__=='__main__':
	main()
