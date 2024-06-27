#!/bin/bash

#eventbus class

this->init(){ local namespace=$1;
    new "sharedmemory" this->_memory "" 1 "$namespace"
    this->_memory->setVar "listeners.count" 0

}

this->finalize(){
    this->_memory->finalize
}

this->on(){ local event=$1; local callback=$2;
    this->_memory->lockVar "listeners.count"
    local count=$(this->_memory->getVar "listeners.count")
    this->_memory->setVar "listeners.count" $((count+1))

    this->_memory->setVar "listeners.$count.event" "$event"
    this->_memory->setVar "listeners.$count.callback" "$callback"

    this->_memory->unlockVar "listeners.count"
}

this->emit(){ local event=$1;
    this->_memory->lockVar "listeners.count"
    local count=$(this->_memory->getVar "listeners.count")
    this->_memory->unlockVar "listeners.count"
    local seqMax=$(( count-1 ))
    shift;
    for i in $(seq 0 $seqMax); do
        local e=$(this->_memory->getVar "listeners.$i.event")
        local c=$(this->_memory->getVar "listeners.$i.callback")

        if [ "$e" == "$event" ]; then
            local argVars="";
            local count=0
            for arg in "$@"; do
                eval "arg$count=\"$arg\""
                argVars="$argVars \"\$arg$count\""
                count=$((count+1))
            done

            eval "$c $argVars"
        fi
    done
}