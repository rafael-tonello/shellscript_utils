#!/bin/bash

linearAnimation(){ local init=$1; local end=$2; local duration_ms=$3; local callback=$4; local _optional_delay_seconds_=$5
    local initialTime=$(date +%s%3N)
    #eval "echo evaluating \"$callback $init\""
    eval "$callback $init $init"

    local prevVal=$init
    
    while [ true ]; do 
        local currentTime=$(date +%s%3N)
        local elaspedTime=$(( currentTime - initialTime))
        #progress=(diference betwenn 'end' and 'start') divided by 'durantion_ms' multiplied by 'elaspedTime'
        #calculate the progress using the 'bc'
        local progress=$(echo "scale=10; ($end - $init) / $duration_ms * $elaspedTime" | bc)

        #the current value is progress + 'start'
        local current=$(echo "$progress + $init" | bc)

        #if the current value is greater than the end value, break the loop
        if [ $(echo "$current > $end" | bc) -eq 1 ]; then
            break
        fi

        #if [ "$current" == "$prevVal" ]; then
        #    sleep 1
        #    continue
        #fi
        local prevVal=$current

        #call the callback
        #convert double to int
        currentI=$(echo $current | awk '{print int($1)}')
        eval "$callback $current $currentI"

        if [ "$_optional_delay_seconds_" != "" ]; then
            sleep $_optional_delay_seconds_
        fi


    done
    eval "$callback $end $end"

}

rootedAnimation(){ local init=$1; local end=$2; local pot=$3; local duration_ms=$4; local callback_2=$5; local _optional_delay_seconds_=$6
    #uses linearAnimation (to get x values)
    local diference=$(echo "$end - $init" | bc -l)
    local pot=$(echo "scale=10; 1/$pot" | bc -l)
    local maxPot=$(echo "e($pot* l($diference))" | bc -l)

    #calculate the the root (with index 'pot') of the diference
    linearAnimation 0 $diference $duration_ms "__f(){
        local x=\$2
        if [ \$x -eq 0 ]; then
            x=0.0000001
        fi

        #elevate the x to the power of 'pot'
        local y=\$(echo \"e(\$pot*l(\$x))\" | bc -l)
        local y=\$(echo \"\$y/\$maxPot\" | bc -l)
        local y=\$(echo \"\$y*\$diference\" | bc -l)


        local yInt=\$(echo \$y | awk '{print int(\$y)}')
        eval \"\$callback_2 \$y \$yInt\" 
    }; __f" $_optional_delay_seconds_
    local final=$(echo "$end - $init" | bc -l)
    local finalInt=$(echo $final | awk '{print int($final)}')

}

slowDownAnimation(){
    rootedAnimation "$@"
}



potentialAnimation(){ local init=$1; local end=$2; local pot=$3; local duration_ms=$4; local callback_2=$5; local _optional_delay_seconds_=$6
    #can just invert exponentialAnimation values
    local pot=$(echo "scale=10; 1/$pot" | bc -l)

    rootedAnimation $init $end $pot $duration_ms "$callback_2" $_optional_delay_seconds_
    
}

speedUpAnimation(){
    potentialAnimation "$@"
}


#example

linearAnimation 0 100 500 "__f3(){
    #goto line begin
    #tput cuu1

    #point cursor at line begining
    tput cr

    #print '\$2' times '='
    printf "%0.s=" \$(seq 1 \$2)
}; __f3"
printf "\n"

for (( i=0; i<2; i++ )); do
slowDownAnimation 0 100 15 1000 "__f4(){
    #goto line begin
    #tput cuu1

    #point cursor at line begining
    tput cr

    #print '\$2' times '='
    printf "%0.s=" \$(seq 1 \$2)
    #echo \$1
}; __f4"
printf "\n"
done

for (( i=0; i<5; i++ )); do
speedUpAnimation 0 150 3 1000 "__f4(){
    #goto line begin
    #tput cuu1

    #point cursor at line begining
    tput cr

    #print '\$2' times '='
    printf "%0.s=" \$(seq 1 \$2)
    #echo \$1
}; __f4"
printf "\n"
done