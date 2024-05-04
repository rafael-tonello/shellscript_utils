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
    _this->initSharedMemory $namespace
}

this->finalize(){ local clearNamespace=$1
    if [ "$clearNamespace" == "1" ]; then
        _this->clearNamespace
    fi
}

_this->clearNamespace(){
    rm -rf $this->sharedMemoryDir
}

#this function creates a virtual directory in the RAM to store key-values
_this->initSharedMemory(){ local namespace=$1;
    this->sharedMemoryDir="/dev/shm/sharedMemory_"$namespace
    mkdir -p "$this->sharedMemoryDir"
}


this->getVar(){ local key=$1;
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    #check if $key begins with $globaldbg (globaldbg should be not empty)
    
    cat "$this->sharedMemoryDir/$sanitizedKey" 2>/dev/null
    return 0
}

#internally calls the getVar function, but the value is not printed. It is stored in the global variable _r
this->getVar2(){ local key=$1;
    _r=$(this->getVar "$key")
    return 0
}

#a helper to getVar
this->get(){ this->getVar $1; }
this->get2(){ this->getVar2 $1; }


this->lockVar(){ local key=$1; local timeout=$2;
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    local start=$(date +%s)

    #define adefault time out (if it is not provided)
    if [ "$timeout" == "" ]; then
        timeout=5
    fi

    while [ $(( $(date +%s) - $start )) -lt $timeout ]; do
        if [ ! -f "$this->sharedMemoryDir/$sanitizedKey.lock" ]; then
            touch "$this->sharedMemoryDir/$sanitizedKey.lock"
            return 0
        fi
        sleep 0.25
    done
    _error="$key is locked"
    return 1
}
this->lock(){ this->lockVar $1 $2; return $?; }

this->unlockVar(){ local key=$1;
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    rm "$this->sharedMemoryDir/$sanitizedKey.lock" &>/dev/null
}

this->unlock(){ this->unlockVar $1; }

this->isVarLocked(){ local key=$1;
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    if [ -f "$this->sharedMemoryDir/$sanitizedKey.lock" ]; then
        return 0
    else
        return 1
    fi
}

#creates a file, in the shared memory, to store the value. The file name is the key. The content is the value. The name of the file should be sanitized
this->setVar(){ local key=$1; local value=$2
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    
    #echo -e $value > "$this->sharedMemoryDir/$sanitizedKey"
    #printf "%s" $value > "$this->sharedMemoryDir/$sanitizedKey"

#do not ident these lines
    cat << EOF > "$this->sharedMemoryDir/$sanitizedKey"
$value
EOF

    return 0
}

#a helper to setVar
this->set(){ this->setVar $1 $2 5; return $?; }

#wait for a variable to be set with a value. The timeout is in seconds
#this function returns 0 if the value is setted and 1 if the timeout is reached
#this function uses _r as aditional return values:
#   _r is the time in seconds
#   _r->s is the time in seconds
#   _r->ms is the time in miliseconds
this->waitForValue(){ local key=$1; local value=$2 local timeout=$3;
    #convert timeout to miliseconds
    timeout=$(( $timeout * 1000 ))
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    local start=$(date +%s%3N)
    while [ $(( $(date +%s%3N) - $start )) -lt $timeout ]; do
        if [ -f $this->sharedMemoryDir/$sanitizedKey ]; then
            if [ "$(cat $this->sharedMemoryDir/$sanitizedKey)" == "$value" ]; then
                #save the elasped time in the _r variable
                local tmp1=$(date +%s%3N)
                _r->ms=$(( tmp1 - start ))
                _r->s=$(echo "scale=5; $_r->ms/1000" | bc )
                _r=$_r->s
                return 0
            fi
        fi
        
        sleep 0.25
    done
    local tmp1=$(date +%s%3N)
    _r->ms=$(( tmp1 - start ))
    _r->s=$(echo "scale=5; $_r->ms/1000" | bc )
    _r=$_r->s
    _error="$key not set"
    return 1
}