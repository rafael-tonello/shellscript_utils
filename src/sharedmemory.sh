#!/bin/bash
# _error is a global varibale used to return error messages
# _r is a global variable used to return values
#
#The name of thre shared memory (passed to init function) is used as a namespace for 
#the key-values. To share the key-values between different thread lib instances, 
#use the same name in the init function for all instances.
#
#this file is a class, and must be instantiated through the new.sh lib.

#if [ "$1" != "new" ]; then echo "sourcing"; source <(curl -s "https://raw.githubusercontent.com/rafael-tonello/shellscript_utils/main/libs/new.sh"); new_f "$0" __app__ "" 1; exit 0; fi

this->init(){ local namespace=$1;
    this->initSharedMemory $namespace
}

this->finalize(){
    #this->clearNamespace
    :;
}

this->clearNamespace(){
    rm -rf $this->sharedMemoryDir
}

#this function creates a virtual directory in the RAM to store key-values
this->initSharedMemory(){ local namespace=$1;
    this->sharedMemoryDir="/dev/shm/sharedMemory_"$namespace
    mkdir -p "$this->sharedMemoryDir"
}


this->getVar(){ local key=$1;
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    _r=$this->sharedMemoryDir/$sanitizedKey
    return 0
}

#internally calls the getVar function, but also print the value (utils to be used like 'value=$(this->getVarC key)')
this->getVarC(){ local key=$1;
    this->getVar $key
    cat $_r
    return 0
}

#a helper to getVar
this->get(){ this->getVar $1; }
this->getC(){ this->getVarC $1; }


this->lockVar(){ local key=$1;
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    touch $this->sharedMemoryDir/$sanitizedKey.lock
}

this->unlockVar(){ local key=$1;
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    rm $this->sharedMemoryDir/$sanitizedKey.lock &>/dev/null
}

this->isVarLocked(){ local key=$1;
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    if [ -f $this->sharedMemoryDir/$sanitizedKey.lock ]; then
        return 0
    else
        return 1
    fi
}

#creates a file, in the shared memory, to store the value. The file name is the key. The content is the value. The name of the file should be sanitized
this->setVar(){ local key=$1; local value=$2; local timeout=$3;
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    local start=$(date +%s)

    #define adefault time out (if it is not provided)
    if [ "$timeout" == "" ]; then
        timeout=5
    fi

    while [ $(( $(date +%s) - $start )) -lt $timeout ]; do
        if [ ! -f $this->sharedMemoryDir/$sanitizedKey.lock ]; then
            echo $value > $this->sharedMemoryDir/$sanitizedKey
            return 0
        fi
        sleep 0.25
    done
    _error="$key is locked"
    return 1
}

#a helper to setVar
this->set(){ this->setVar $1 $2 5; return $?; }

#wait for a variable to be set with a value. The timeout is in seconds
this->waitForValue(){ local key=$1; local value=$2 local timeout=$3;
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    local start=$(date +%s)
    while [ $(( $(date +%s) - $start )) -lt $timeout ]; do
        if [ -f $this->sharedMemoryDir/$sanitizedKey ]; then
            if [ "$(cat $this->sharedMemoryDir/$sanitizedKey)" == "$value" ]; then
                return 0
            fi
        fi
        
        sleep 0.25
    done
    _error="$key not set"
    return 1
}