this->init(){
    this->idsCounter=0

}

TU_SECONDS=1
TU_MILISECONDS=1000
TU_MICROSECONDS=1000000
this->getTime(){ local magnitude
    magnitude=$1
    if [ "$magnitude" == "" ]; then
        magnitude=$TU_SECONDS
    fi

    if [ "$magnitude" == "$TU_SECONDS" ]; then
        echo $(date +%s)
    elif [ "$magnitude" == "$TU_MILISECONDS" ]; then
        echo $(date +%s%N | cut -b1-13)
    elif [ "$magnitude" == "$TU_MICROSECONDS" ]; then
        echo $(date +%s%N | cut -b1-16)
    else
        echo "Invalid magnitude"
    fi
}

this->getTime_seconds(){
    this->getTime $TU_SECONDS
}

this->getTime_miliseconds(){
    this->getTime $TU_MILISECONDS
}

this->getTime_microseconds(){
    this->getTime $TU_MICROSECONDS
}

this->startTimeout_seconds(){ local timeout="$1"; local onTimeoutFunction="$2"; local onTickFunction="$3";
    local timeoutId=$this->idsCounter
    this->idsCounter=$((this->idsCounter+1))

    local controlFile="/dev/shm/shellscriptutils_timeutils_timeout_control_$timeoutId"
    echo "working" > $controlFile

    (__f(){
        local startTime=$(this->getTime_seconds)
        local elaspedTime=$(( $(date +%s) - $startTime ))
        while [ $(( $(date +%s) - $start )) -lt $timeout ]; do
            if [ "$(cat $controlFile)" == "stop" ]; then
                rm -f $controlFile
                return 0
            fi

            sleep 1;
            elaspedTime=$(( $(date +%s) - $startTime ))
            local remainTime=$(( $timeout - $elaspedTime ))

            if [ "$onTickFunction" != "" ]; then
                eval $onTickFunction $elaspedTime $remainTime $timeout $timeoutId $this
            fi
        done;

        if [ "$onTimeoutFunction" != "" ]; then
            eval $onTimeoutFunction
        fi
    }; __f &)
}

this->stopTimeout(){ local timeoutId="$1"
    local controlFile="/dev/shm/shellscriptutils_timeutils_timeout_control_$timeoutId"
    if [ -f $controlFile ]; then
        if [ "$(cat $controlFile)" == "working" ]; then
            echo "stop" > $controlFile
            return 0
        else
            _error="Timeout already stopped or in an invalid state ($(cat $controlFile))"
            return 1
        fi
    else
        _error="Timeout (id $timeoutId) not found"
        return 1
    fi
}