#time ./bin/mg5 madgraph_scripts/script_ttbar_t_BNV_bbar_cbar_mu_tbar_lep_OLD_UFO.mg
#time ./bin/mg5 madgraph_scripts/script_ttbar_t_BNV_bbar_cbar_mu_tbar_had_OLD_UFO.mg
#time ./bin/mg5 madgraph_scripts/script_ttbar_tbar_BNV_b_c_mu_t_lep_OLD_UFO.mg
#time ./bin/mg5 madgraph_scripts/script_ttbar_tbar_BNV_b_c_mu_t_had_OLD_UFO.mg
#
#time ./bin/mg5 madgraph_scripts/script_ttbar_tbar2Wb_W2lnu.mg
#time ./bin/mg5 madgraph_scripts/script_ttbar_tbar2Wb_W2jj.mg
#time ./bin/mg5 madgraph_scripts/script_ttbar_t2Wb_W2lnu.mg
#time ./bin/mg5 madgraph_scripts/script_ttbar_t2Wb_W2jj.mg

#copydir="$HOME/OUTPUT_LHE_FILES"
# On LXPLUS
copydir="../OUTPUT_LHE_FILES"
if [ ! -d $copydir ]; then
    mkdir $copydir
fi

scripts=("madgraph_scripts/script_ttbar_tbar2Wb_W2lnu.mg" "madgraph_scripts/script_ttbar_tbar2Wb_W2jj.mg"  "madgraph_scripts/script_ttbar_t2Wb_W2lnu.mg"  "madgraph_scripts/script_ttbar_t2Wb_W2jj.mg" "madgraph_scripts/script_ttbar_t_BNV_bbar_cbar_mu_tbar_lep_OLD_UFO.mg" "madgraph_scripts/script_ttbar_t_BNV_bbar_cbar_mu_tbar_had_OLD_UFO.mg" "madgraph_scripts/script_ttbar_tbar_BNV_b_c_mu_t_lep_OLD_UFO.mg" "madgraph_scripts/script_ttbar_tbar_BNV_b_c_mu_t_had_OLD_UFO.mg" "madgraph_scripts/script_ttbar_tbar_BNV_b_u_e_t_had_OLD_UFO.mg" "madgraph_scripts/script_ttbar_tbar_BNV_b_u_e_t_lep_OLD_UFO.mg" "madgraph_scripts/script_ttbar_t_BNV_bbar_ubar_e_tbar_had_OLD_UFO.mg" "madgraph_scripts/script_ttbar_t_BNV_bbar_ubar_e_tbar_lep_OLD_UFO.mg")
#scripts=("madgraph_scripts/script_ttbar_tbar_BNV_b_c_mu_t_had_OLD_UFO.mg")
#scripts=("madgraph_scripts/script_ttbar_tbar2Wb_W2lnu.mg" )

#PROC_ttbar_tbar2Wb_W2lnu/Events/run_01/

for script in ${scripts[@]}
do
    echo $script
    pretag=${script#madgraph_scripts/script_}
    tag=${pretag%.mg}
    echo $tag

    time ./bin/mg5_aMC $script

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

