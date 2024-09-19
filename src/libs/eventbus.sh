#!/bin/bash

#eventbus class. This class is used to create a simple event bus. The event bus is used to create a communication channel
#between different parts of the application. The event bus is used to emit events and to listen to events. When an event 
#is emitted, all the listeners registered with the "on" method are called. 
#
#
#!! the main difference between this class and "eventstream" is that the event bus (this class) allow you to observe 
#specific events, while the eventstream is used to stream data without observers discrimination (data is sen't to all observers).
#You can use one object of this class across multiple modules in you application, allow a communication channel between them
#
#
#
## Usage example:
## 
##     file sevice1.sh
##         this->init { 
##             this->evtBus="$1"
##
##             #register the events
##             eval "$this->evtBus""->on 'service1.start' 'this->start'"
##             eval "$this->evtBus""->on 'service1.stop' 'this->stop'"
##         }
## 
##     file service2.sh
##         this->init { 
##             this->evtBus="$1"
##
##             #register the events
##             eval "$this->evtBus""->on 'service1.start' 'this->start'"
##             eval "$this->evtBus""->on 'service1.stop' 'this->stop'"
##         }
## 
##     file servicecontrol.sh
##         new "eventbus" this->evtBus "servicecontrol"
##
##         #create the services  
##         new "service1" this->service1 "$this->evtBus"
##         new "service2" this->service2 "$this->evtBus"
##
##         #Notifi all services to start its work 
##         this->evtBus->emit "service1.start"
## 
##         ...
##         ...
##         ...
## 
##         #Notifi all services to stop its work
##         this->evtBus->emit "service1.stop"


#initializes the eventbus. The 'namespace' is used to avoid conflicts between different eventbus instances
this->init(){ local namespace=$1;
    new "sharedmemory" this->_memory "$namespace"
    this->_memory->setVar "listeners.count" 0

}

this->finalize(){
    this->_memory->finalize
}

#observates an event (a message published in the event bus). When the event is emitted, the "callback" is called
this->on(){ local event=$1; local callback=$2;
    this->_memory->lockVar "listeners.count"
    local count=$(this->_memory->getVar "listeners.count")
    this->_memory->setVar "listeners.count" $((count+1))

    this->_memory->setVar "listeners.$count.event" "$event"
    this->_memory->setVar "listeners.$count.callback" "$callback"

    this->_memory->unlockVar "listeners.count"
}

#emits an event (a messagepublished in the event bus). When the event is emitted, all the callbacks registered with the "on" method are called
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
