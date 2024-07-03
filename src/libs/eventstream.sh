#!/bin/vash

#strem class

this->init(){
    #declare an assotiative array to store the observers
    declare -A this->observers
    this->currenId=0
}

#subscribe the stream. 
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

#stream data for all 
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