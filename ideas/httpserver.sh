#!/bin/bash

# this is cript spaw a webserver and talk to it, allowing the data transfer between it and shelscripts

this->init(){ local serverPort=$1
    this->serverPort=serverPort
    this->toServerFile="/tmp/toServerFile"
    this->fromServerFile="/tmp/fromServerFile"
    this->running=1
    declare -A this->routes
}

this->beginListen(){
    # start the webserver
    python -m SimpleHTTPServer this->serverPort &

    #data comming from server comes through the file 'this->fromServerFile'
    #monitores the file for changes. Each server command occupes a line in the file. Monitores the files while '$this->running' is 1
    while [ $this->running -eq 1 ]; do
        #check if the file has changed
        if [ -f $this->fromServerFile ]; then
            #scroll through the file
            while read line; do
                #parse the command and execute it
                _this->parseCommand $line
            done < $this->fromServerFile
        else
            #wait for the file to be created
            sleep 0.1
        fi
    done

    return 0
}

#register a webroute. Web routes can have variables names in the url. The variable name is the name of the variable between '{}'. The callback function will receive the variables as parameters
this->route(){ local method=$1; local route=$2; local callback=$3
    #route is saved internally
    this->routes["$method:$route"]=$callback
}

_this->parseCommand(){ local data=$1
    #data format is "type:data". Obs, data can contain ':'
    cmdType=$(echo $data | cut -d':' -f1)
    cmdData=$(echo $data | cut -d':' -f2-)

    #check form command type ('request', 'msgBus', 'internalError')
    case $cmdType in
        'request')
            _this->request $cmdData
            ;;
        'msgBus')
            _this->msgBus $cmdData
            ;;
        'internalError')
            _this->internalError $cmdData
            ;;
        *)
            echo "Error: unknown command type '$cmdType'"
            ;;
    esac
    #parse the command and execute it
    return 0
}

_this->request(){ local data=$1
    #data format is "method:url"
    method=$(echo $data | cut -d':' -f1)
    url=$(echo $data | cut -d':' -f2)
    body=$(echo $data | cut -d':' -f3-)

    #check for compatible routes
    for route in "${!this->routes[@]}"; do
        routeMethod=$(echo $route | cut -d':' -f1)
        routeUrl=$(echo $route | cut -d':' -f2)

        #check if the route is compatible
        if [ $routeMethod == $method ] && [ $routeUrl == $url ]; then
            #call the route callback
            ${this->routes["$route"]} $body
            return 0
        fi
    done

    return 0
}

#for a route resource/methos/{var1}/{var2} and a url resource/methos/val1/val2, this function will return the values of the variables in the url
_this->parseUrlVars(){ local url=$1; local urlReceiveFromServer=$2
    #check if the url has variables
    if [[ $url == *'{'* ]]; then
        #get the variables from the url
        urlVars=$(echo $url | grep -oP '{\K[^}]+' | tr '\n' ' ')
        urlVars=($urlVars)

        #get the values of the variables
        urlVarsValues=()
        for var in "${urlVars[@]}"; do
            #get the value of the variable
            varValue=$(echo $urlReceiveFromServer | grep -oP "$var:\K[^ ]+" | tr '\n' ' ')
            urlVarsValues+=($varValue)
        done
    else
        urlVarsValues=()
    fi

    #add the 'get vars' (variables in the url, like ?var3=val3&var4=val4) to the urlVarsValues
    urlVarsValues+=($(echo $urlReceiveFromServer | grep -oP '\?\K[^ ]+' | tr '\n' ' '))

    return 0

}

_this->msgBus(){ local data=$1
    #data format is "msg"
    msg=$data

    #send the message to the server
    echo "msg:$msg" >> $this->toServerFile

    return 0
}

_this->internalError(){ local data=$1
    #data format is "msg"
    msg=$data

    #send the message to the server
    echo "internalError:$msg" >> $this->toServerFile

    return 0
}