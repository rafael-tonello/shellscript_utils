#!/bin/bash
if [ "$1" != "new" ]; then >&2 echo "This must be included through the 'new_f' function in the file 'https://github.com/rafael-tonello/shellscript_utils/blob/main/libs/new.sh'"; exit 1; fi

#wait_remote_host(host_address, timeout_seconds, 1forOn0forOff)
#   Pings the server and returns 0 or 1 according with the ping result and '1forOn0forOff' argument:
#   if remote host is unreachable and '1forOn0forOff' is 0 (off) the function will return true (0);
#   if remote host is reachable and '1forOn0forOff' is 1 (on) the function will also return true (0);
#   any other case, the function will return false (!=0)
#   
#   errors are returned through "_error" variable
this->waitRemoteHost(){ local host_address=$1; local timeout=$2; local operation=$3;
    if [ "$timeout" == "" ]; then
        timeout=60
    fi

    if [ "$operation" == "" ]; then
        $operation=1
    fi

    local file_operationDone=/tmp/netutilssh_operationDone_$RANDOM
    echo "" > $file_operationDone

    (this->checkF(){
        local start=$(date +%s)
        while [ $(( $(date +%s) - $start )) -lt $timeout ]; do
            tmp=$(cat $file_operationDone)
            if [ "$tmp" != "" ]; then
                return 0
            fi

            sleep 0.75
        done

        echo "timeout" > $file_operationDone; 
    }; this->checkF &)

    while [ true  ]; do

    
        ping -c 1 $host_address -W 2 -w 2 >/dev/null 2>&1
        local _rc=$?


        if [ "$_rc" == "0" ] && [ "$operation" == "1" ]; then
            echo "sucess" > $file_operationDone
        fi;

        if [ "$_rc" != "0" ] && [ "$operation" == "0" ]; then
            echo "sucess" > $file_operationDone
        fi;

        tmp=$(cat $file_operationDone)
        if [ "$tmp" != "" ]; then
            break
        fi
        sleep 1
    done

    tmp=$(cat $file_operationDone)
    if [ "$tmp" == "sucess" ]; then
        return 0;
    elif [ "$tmp" == "timeout" ]; then
        _error="Timeout of $timeout seconds reached"
        return 1
    else
        _error="Unknown error"
        return 1
    fi
}

#wait_waitRemoteHostBeOn(host_address, timeout_seconds)
#   checks if remote host is active (reachable through network)
#   a helper to this->waitRemoteHost function that calls it with '1forOn0forOff'=1. 
this->waitRemoteHostBeOn(){
    this->waitRemoteHost "$1" "$2" "1"
    if [ "$?" != "0" ]; then
        _error="Remote machine did not turn on: $_error"
        return 1
    fi

    return 0
}

#wait_waitRemoteHostBeOff(host_address, timeout_seconds)
#   checks if remote host is inactive (unreachable through network)
#   a helper to this->waitRemoteHost function that calls it with '1forOn0forOff'=0. 
this->waitRemoteHostBeOff(){
    this->waitRemoteHost "$1" "$2" "0"
    if [ "$?" != "0" ]; then
        _error="Remote machine did not turn off: $_error"
        return 1
    fi

    return 0
}