#time ./bin/mg5 madgraph_scripts/script_ttbar_t_BNV_bbar_cbar_mu_tbar_lep_OLD_UFO.mg
#time ./bin/mg5 madgraph_scripts/script_ttbar_t_BNV_bbar_cbar_mu_tbar_had_OLD_UFO.mg
#time ./bin/mg5 madgraph_scripts/script_ttbar_tbar_BNV_b_c_mu_t_lep_OLD_UFO.mg
#time ./bin/mg5 madgraph_scripts/script_ttbar_tbar_BNV_b_c_mu_t_had_OLD_UFO.mg
#
#time ./bin/mg5 madgraph_scripts/script_ttbar_tbar2Wb_W2lnu.mg
#time ./bin/mg5 madgraph_scripts/script_ttbar_tbar2Wb_W2jj.mg
#time ./bin/mg5 madgraph_scripts/script_ttbar_t2Wb_W2lnu.mg
#time ./bin/mg5 madgraph_scripts/script_ttbar_t2Wb_W2jj.mg

# From Enrique
# if you want/need N events for  2018, 
# we usually request N*42/59 for 2017, 
# N*19/59 for 2016 and 
# N*17/59 for 2016APV. 

# 
#Nevents = {}
#Nevents['2018'] =    '250k'
#Nevents['2017'] =    '180k'
#Nevents['2016'] =    '100k'
#Nevents['2016APB'] = '100k'

topcopydir="$HOME/OUTPUT_LHE_FILES"
# On LXPLUS
#topcopydir="../OUTPUT_LHE_FILES"
if [ ! -d $topcopydir ]; then
    mkdir $topcopydir
fi

scripts=("madgraph_scripts/script_ttbar_tbar2Wb_W2lnu.mg" "madgraph_scripts/script_ttbar_tbar2Wb_W2jj.mg"  "madgraph_scripts/script_ttbar_t2Wb_W2lnu.mg"  "madgraph_scripts/script_ttbar_t2Wb_W2jj.mg" "madgraph_scripts/script_ttbar_t_BNV_bbar_cbar_mu_tbar_lep_OLD_UFO.mg" "madgraph_scripts/script_ttbar_t_BNV_bbar_cbar_mu_tbar_had_OLD_UFO.mg" "madgraph_scripts/script_ttbar_tbar_BNV_b_c_mu_t_lep_OLD_UFO.mg" "madgraph_scripts/script_ttbar_tbar_BNV_b_c_mu_t_had_OLD_UFO.mg" "madgraph_scripts/script_ttbar_tbar_BNV_b_u_e_t_had_OLD_UFO.mg" "madgraph_scripts/script_ttbar_tbar_BNV_b_u_e_t_lep_OLD_UFO.mg" "madgraph_scripts/script_ttbar_t_BNV_bbar_ubar_e_tbar_had_OLD_UFO.mg" "madgraph_scripts/script_ttbar_t_BNV_bbar_ubar_e_tbar_lep_OLD_UFO.mg")
#scripts=("madgraph_scripts/script_ttbar_tbar_BNV_b_c_mu_t_had_OLD_UFO.mg")
#scripts=("madgraph_scripts/script_ttbar_tbar2Wb_W2lnu.mg" )

#PROC_ttbar_tbar2Wb_W2lnu/Events/run_01/

################################################################################
for script in ${scripts[@]}
do
    for campaign in '2018' '2017' '2016' '2016APV'
    do
        echo 

        #####################################################
        # Make the directory to where we'll copy these out
        #####################################################
        if [ ! -d $topcopydir/$campaign ]; then
            mkdir $topcopydir/$campaign
        fi

        copydir=$topcopydir/$campaign

        #####################################################
        # Clean up the PROC dir before we run again
        #####################################################
        procdir="PROC_"$tag
        if [ -d $procdir ]; then
            ls $procdir
            rm -rf $procdir
        fi

        #####################################################
        # Set the number of events
        #####################################################
        Nevents='1k'
        #if [ $campaign == '2018' ]; then
            #Nevents='200k'
        #elif [ $campaign == '2017' ]; then
            #Nevents='150k'
        #elif [ $campaign == '2016' ]; then
            #Nevents='75k'
        #elif [ $campaign == '2016APV' ]; then
            #Nevents='75k'
        #fi

        # Edit the number of events to be generated
        sed -i "s/set nevents.*/set nevents $Nevents/" $script

        #####################################################
        echo $campaign $script
        pretag=${script#madgraph_scripts/script_}
        tag=${pretag%.mg}
        echo $tag


        # Run MadGraph
        #time ./bin/mg5_aMC $script
        #####################################################
    
        #####################################################
        # Copy over the output files to the proper
        # directory
        #####################################################
        for rundir in '_01' '_02' '_03' '_04' '_05' '_06' '_07' '_08'
        do
            echo $rundir
            outdir="PROC_"$tag"/Events/run"$rundir"/"
            lhefile_gz=$outdir"unweighted_events.lhe.gz"
            lhefile=$outdir"unweighted_events.lhe"
            echo $outdir
    
            if [ -e $outdir ]; then
                ls $outdir
            fi
     
            if [ -e $lhefile_gz ]; then
                echo gunzip $lhefile_gz
                gunzip $lhefile_gz
            fi
    
            if [ -e $lhefile ]; then
                copyfile=$copydir"/"$tag"$rundir"".lhe"
                echo cp $lhefile $copyfile
                cp $lhefile $copyfile
            fi
            echo
        done
    done
done

