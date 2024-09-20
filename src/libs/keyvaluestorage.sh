#!/bin/bash

#usage examples
#   new kvdb
#   kvdb->set key value
#   kvdb->get key

SKVS_DEFAULT_BIN_LOCATION="$HOME/.local/bin"
SKVS_PKV_TMP_FOLDER="/tmp/pkv"

#PKV=Prefixtree key value - A program that store key-values in a prefix tree file
#SKVS=Simple key value store
SKVS_AUTO=0
SKVS_USE_FOLDER=1
SKVS_USE_PKV=2
this->init(){ local dbPath="$1"; local storageType="$2"
    if [ "$_allowInstalations_" == "" ]; then _allowInstalations_=1; fi


    if [ "$storageType" == "" ]; then
        storageType=$SKVS_AUTO
    fi

    this->storageType="$storageType"

    if [ "$dbPath" == "" ]; then
        _error="db path not informed"
        return 1
    fi

    if [ "$storageType" == "$SKVS_USE_FOLDER" ]; then
        this->storageType="$SKVS_USE_FOLDER"
    elif [ "$storageType" == "$SKVS_USE_PKV" ]; then
        this->_tryInitPkv $_allowInstalations_
        if [ "$?" -ne 0 ]; then
            _error="error initializing pkv: $_error"
            return 1
        fi
        this->storageType="$SKVS_USE_PKV"
    elif [ "$storageType" == "$SKVS_AUTO" ]; then
        this->_tryInitPkv $_allowInstalations_
        if [ "$?" -eq 0 ]; then
            this->storageType="$SKVS_USE_PKV"
        else
            this->storageType="$SKVS_USE_FOLDER"
        fi
    else
        _error="invalid storage type"
        return 1
    fi

    this->_dbPath="$dbPath"
    this->_initDb
    if [ "$?" -ne 0 ]; then
        _error="error initializing db: $_error"
        return 1
    fi

    return 0
}

this->finalize(){
    if [ "$this->storageType" == "$SKVS_USE_PKV" ]; then
        #kill the pkv process
        kill $this->_pkvPid
    fi
}
this->destroy(){ this->finalize "$@"; }

this->_tryInitPkv(){
    this->_pkvPath=$(this->_tryFindPkv)
    if [ "$?" -eq 0 ]; then
        this->using="pkv"
        return 0
    else
        #this->_pkvPath=$(this->_tryCompileAndIntallPkv $_allowInstalations_)
        this->_pkvPath=$(this->_tryDownloadPkv)
        if [ "$?" -eq 0 ]; then
            this->using="pkv"
            return 0
        fi
    fi

    return 1
}

#clone the pkv repositoy and try to compile it
this->_tryDownloadPkv(){ local allowInstalations=1;
    local currentFolder=$(pwd)

    mkdir -p $SKVS_PKV_TMP_FOLDER > /dev/null 2>&1
    wget https://github.com/rafael-tonello/PrefixTreeStorage/releases/download/v1.0.0/PrefixTreeStorage-v1.0.0.tar.gz -O "$SKVS_PKV_TMP_FOLDER/pkv.tar.gz" > /dev/null 2>&1
    #extract pkv
    tar -xzf "$SKVS_PKV_TMP_FOLDER/pkv.tar.gz" -C "$SKVS_PKV_TMP_FOLDER"

    mkdir -p $SKVS_DEFAULT_BIN_LOCATION > /dev/null 2>&1
    cp "$SKVS_PKV_TMP_FOLDER/PrefixTreeStorage-v1.0.0/command/pkv" $SKVS_DEFAULT_BIN_LOCATION/

    echo "$SKVS_DEFAULT_BIN_LOCATION/pkv"
    cd "$currentFolder"
    return 0
}

#looking in the system by pkv binary
this->_tryFindPkv(){
    local pkvPath=$(which pkv)
    if [ "$pkvPath" != "" ]; then
        echo "$pkvPath"
        return 0
    fi
        
    #look for a previous compilation
    if [ -f "$SKVS_DEFAULT_BIN_LOCATION/pkv" ]; then
        echo "$SKVS_DEFAULT_BIN_LOCATION/pkv"
        return 0
    elif [ -f "$SKVS_PKV_TMP_FOLDER/PrefixTreeStorage-v1.0.0/command/pkv" ]; then
        echo "$SKVS_PKV_TMP_FOLDER/PrefixTreeStorage-v1.0.0/command/pkv"
        return 0
    fi

    _error="error locating pkv binary"
    return 1
}

this->_initDb(){
    if [ "$this->storageType" == "$SKVS_USE_FOLDER" ]; then
        mkdir -p "$this->_dbPath"
    elif [ "$this->storageType" == "$SKVS_USE_PKV" ]; then
        this->_checkAndStartPKVInServerMode
    else 
        _error="invalid storage type"
        return 1
    fi
}

this->_checkAndStartPKVInServerMode(){
    #check if pkv is running
    if [ "$this->_pkvHttPort" != "" ]; then
        return 0
        #run curl and get httpCode
        #local httpCode=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$this->pkvHttpPort")
        #echo "returned httpCode: $httpCode"
        #if [ "$httpCode" == "204" ]; then
        #    return 0
        #fi
    fi


    local pkvPath=$(this->_tryFindPkv)
    if [ "$?" -ne 0 ]; then
        _error="error locating pkv binary"
        return 1
    fi

    #create a random port for pkv http server
    this->_pkvHttPort=$(( ( RANDOM % 1000 )  + 50000 ))
    #get current process pid
    local pid=$$

    #starts the pkv in server mode. The current process pid is passed to the pkv and it will be used to kill the pkv process when the script ends
    local pkvStartupCommand="$this->_pkvPath -H $this->_pkvHttPort -f:$this->_dbPath -d $pid > /dev/null 2>&1" >/dev/null 2>&1
    
    #run $pkvStartupCommand in background and get the pid of the process
    eval "$pkvStartupCommand" &
    sleep 1
    this->_pkvPid=$!
    

    return 0
}

this->set(){ local key="$1"; local value="$2";
    if [ "$this->storageType" == "$SKVS_USE_PKV" ]; then
        #$this->_pkvPath set "$key" "$value"
        #make an http post request
        this->_checkAndStartPKVInServerMode
        curl -sS -X POST -d "$value" "http://localhost:$this->_pkvHttPort/$key"
    else
        echo "$value" > "$this->_dbPath/$key"
    fi
}

#return via _r variable. Use this->get2 to get the value via echo
this->get_r(){ local key="$1"; local _defaultValue_="$2";
    local v=""
    if [ "$this->storageType" == "$SKVS_USE_PKV" ]; then
        #v=$($this->_pkvPath get "$key")
        this->_checkAndStartPKVInServerMode
        v=$(curl -sS "http://localhost:$this->_pkvHttPort/$key")
    else
        if [ -f "$this->_dbPath/$key" ]; then
            v=$(cat "$this->_dbPath/$key")
        fi
    fi

    if [ "$v" == "" ]; then
        _r="$_defaultValue_"
    else
        _r="$v"
    fi
}

#return 'get_r' via echo
this->get(){
    echo "$(this->get_r "$@"; echo "$_r")"
}

this->delete(){ local key="$1";
    if [ "$this->storageType" == "$SKVS_USE_PKV" ]; then
        #$this->_pkvPath remove "$key"
        #make an http delete request
        this->_checkAndStartPKVInServerMode
        curl -sS -X DELETE "http://localhost:$this->_pkvHttPort/$key" > /dev/null 2>&1
    else
        rm -f "$this->_dbPath/$key"
    fi
}
this->remove(){ this->delete "$1"; }
