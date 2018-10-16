foreach file($*)

    #set filename = `basename $file`

    #echo $file
    #echo $filename

    #cp $file .
    python build_condor_script_for_private_signal_MC.py $file
    #rm $filename

end
