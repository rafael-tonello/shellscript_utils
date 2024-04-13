#!/bin/bash
if [ "$1" != "new" ]; then >&2 echo "This must be included through the 'new_f' function in the file 'https://github.com/rafael-tonello/shellscript_utils/blob/main/libs/new.sh'"; exit 1; fi

#wait_remote_host(host_address, timeout_seconds, 1forOn0forOff)
#   Pings the server and returns 0 or 1 according with the ping result and '1forOn0forOff' argument:
#   if remote host is unreachable and '1forOn0forOff' is 0 (off) the function will return true (0);
#   if remote host is reachable and '1forOn0forOff' is 1 (on) the function will also return true (0);
#   any other case, the function will return false (!=0)
#   
#   errors are returned through "_error" variable
this->waitRemoteHost(){
    local host_address=$1
    timeout=$2
    local operation=$3
    if [ "$timeout" == "" ]; then
        timeout=60
    fi
    echo 0 > /tmp/this->_operationsucess
    echo 0 > /tmp/this->_time_to_abort_check_process
    echo 0 > /tmp/timeout
    
    #checkF="sleep $timeout; echo 1 > /tmp/this->_time_to_abort_check_process; echo 1 > /tmp/timeout;"
    #eval $checkF &
    (this->checkF(){
        sleep $timeout; 
        echo 1 > /tmp/this->_time_to_abort_check_process; 
        echo 1 > /tmp/timeout;
    }; this->checkF &)

    while [ true  ]; do
        ping -c 1 $host_address -W 5 -w 5 >/dev/null
        local _rc=$?
        if [ "$_rc" == "0" ] && [ "$operation" == "1" ]; then
            echo 1 > /tmp/this->_operationsucess
            echo 1 > /tmp/this->_time_to_abort_check_process
        fi;

        if [ "$_rc" != "0" ] && [ "$operation" == "0" ]; then
            echo 1 > /tmp/this->_operationsucess
            echo 1 > /tmp/this->_time_to_abort_check_process
        fi;

        
        

        tmp=$(cat /tmp/this->_time_to_abort_check_process)
        if [ "$tmp" == "1" ]; then
            break
        fi
        
        sleep 1
    done

    tmp=$(cat /tmp/this->_operationsucess)
    if [ "$tmp" == "1" ]; then
        return 0;
    fi

    _error="Timeout of $timeout seconds reached"
    return 1
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