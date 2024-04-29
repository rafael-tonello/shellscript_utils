function aa(){
    echo "aa: $1"
}


aa_hook=$(declare -f aa)
function aa(){
    echo "bb: $1"
    #run original aa with the same arguments
    eval "_hockedaa_$aa_hook"; _hockedaa_aa "$@"
}



#hooking new_f
original_new_f=$(declare -f new_f)
function new_f(){
    echo "new_f: $1"
    #do other things and change parameters before call the original new_f

    #run original new_f with the same arguments
    eval "_hockednew_f_$original_new_f"; _hockednew_f_new_f "$@"
}

#hooking new_f
eval "_hockednew_f_$(declare -f new_f)"
function new_f(){
    echo "new_f: $1"
    #do other things and change parameters before call the original new_f

    #run original new_f with the same arguments
    _hockednew_f_new_f "$@"
}