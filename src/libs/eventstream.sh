#!/bin/vash

#stream class
#
#!! the main difference between this file and the eventbus is that the event stream (this class) will sent data to all observers, while
# the event bus is used to observe specific events. This class is more focused to create events in your modules.
#
## Usage example:
##    file MyClass.sh
##        this->ini(){
##            new "eventstream" this->onStartWork
##            new "eventstream" this->onFinishWork
##        }
##    
##        this->work(){
##            this->onStartWork->emit "work started"
##            #do the work
##            #do the work
##            this->onFinishWork->emit "work finished"
##    
##        }
##    
##    file main.sh
##        new "MyClass" myClass
##        myClass->onStartWork->listen "echo 'work started'"
##        myClass->onFinishWork->listen "echo 'work finished'"
##    
##        myClass->work

this->init(){
    #declare an assotiative array to store the observers
    declare -A this->observers
    this->currenId=0
}

#subscribe the stream. When data is published, the callback will be called
#arguments: 
#   callback/lambda function
#return _r: returns the observation ID through the variable '_r'
this->subscribe(){ local callback="$1"
    #generate a unique ID
    this->currentId=$((this->currentId+1))
    #store the observer in the list
    this->observers[$this->currentId]="$callback"

    this->currentId=$((this->currentId+1))
    #return the observer ID
    #echo $this->currentId
    _r=$this->currentId

}

#unsubscribe the stream
#arguments:
#   observer ID
this->unsubscribe(){
    #remove the observer from the list
    this->observers[$1]=""
    unset this->observers[$1]
}

#stream data for all observers
#arguments:
#   data
this->publish(){
    #scroll over all observers and call their callbacks
    for observer in "${this->observers[@]}"; do
        eval "$observer \"\$@\""
    done
}

#some helper functions
this->listen(){
    #redirect the call to 'subscribe' function
    this->subscribe "$@"
}

this->ignore(){
    #redirect the call to 'unsubscribe' function
    this->unsubscribe "$@"
}

this->stream(){
    #redirect the call to 'publish' function
    this->publish "$@"
}

this->emit(){
    #redirect the call to 'publish' function
    this->publish "$@"
}