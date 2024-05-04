#!/bin/bash

#eventbus class

this->init(){ local namespace=$1;
    new "sharedmemory" this->_memory "" 1 "$namespace"

}

this->finalize(){
    this->_memory->finalize
}

this->on(){ local event=$1; local callback=$2;
    this->_memory->lockVar "listeners.count"
    local count=$(this->_memory->getVar "listeners.count")
    this->_memory->setVar "listeners.count" $((count+1))

    this->_memory->setVar "listeners.$count.event" $event
    this->_memory->setVar "listeners.$count.callback" $callback    

    this->_memory->unlockVar "listeners.count"
}

this->emit(){ local event=$1; local data=$2;
    this->_memory->lockVar "listeners.count"
    local count=$(this->_memory->getVar "listeners.count")
    this->_memory->unlockVar "listeners.count"

    for i in $(seq 0 $((count-1))); do
        local e=$(this->_memory->getVar "listeners.$i.event")
        local c=$(this->_memory->getVar "listeners.$i.callback")

        if [ "$e" == "$event" ]; then
            "$c" "$data"
        fi
    done
}