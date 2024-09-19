#!/bin/bash
# _error is a global varibale used to return error messages
# _r is a global variable used to return values
#
#The name of thre shared memory (passed to init function) is used as a namespace for 
#the key-values. To share the key-values between different thread lib instances, 
#use the same name in the init function for all instances.
#
#this file is a class, and must be instantiated through the new.sh lib.

#if [ "$1" != "new" ]; then echo "sourcing"; source <(curl -s "https://raw.githubusercontent.com/rafael-tonello/shellscript_utils/main/libs/new.sh"); new_f "$0" __app__; exit 0; fi

#initializes thes shared memory. The first parameter is the namespace. The second parameter (optional) is the 
#directory where the shared memory will be stored. If the _storageDirectory_ is not provided, the shared memory will be stored in /dev/shm
this->init(){ local namespace="$1"; local _storageDirectory_="$2"
    if [ "$_storageDirectory_" == "" ]; then
        _storageDirectory_="/dev/shm"
    fi

    this->_storageDirectory="$_storageDirectory_"

    this->_initSharedMemory "$namespace"
}

this->finalize(){ local _clearNamespace_=$1
    if [ "$_clearNamespace_" == "1" ]; then
        this->_clearNamespace
    fi
}

this->_clearNamespace(){
    rm -rf $this->sharedMemoryDir
}

#this function creates a virtual directory in the RAM to store key-values
this->_initSharedMemory(){ local namespace="$1";
    this->sharedMemoryDir="$this->_storageDirectory""/shu/sharedMemory/$namespace"
    mkdir -p "$this->sharedMemoryDir"
}


this->getVar(){ local key="$1"; _default_value_="$2"
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    #check if $key begins with $globaldbg (globaldbg should be not empty)

    local v=$(cat "$this->sharedMemoryDir/$sanitizedKey" 2>/dev/null)
    if [ "$v" == "" ]; then
        _r="$_default_value_"
    else
        _r="$v"
    fi
    echo "$_r";
    return 0
}

#internally calls the getVar function, but the value is not printed. It is stored in the global variable _r
this->getVar2(){ local key="$1";
    _r=$(this->getVar "$key")
    return 0
}

#a helper to getVar
this->get(){ this->getVar "$@"; }
this->get2(){ this->getVar2 "$@"; }


this->lockVar(){ local key="$1"; local timeout="$2";
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    local start=$(date +%s)

    #define adefault time out (if it is not provided)
    if [ "$timeout" == "" ]; then
        timeout=5
    fi

    while [ $(( $(date +%s) - $start )) -lt $timeout ]; do
        mkdir $this->sharedMemoryDir/$sanitizedKey.lock >> /dev/null 2>&1
        if [ "$?" == "0" ]; then
            return 0
        fi
        sleep $(echo "scale=2; ($(( RANDOM % 50)) + 100) / 1000" | bc)
    done
    _error="$key is locked"
    return 1
}
this->lock(){ this->lockVar "$@"; return $?; }

this->unlockVar(){ local key="$1";
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    rm -rf "$this->sharedMemoryDir/$sanitizedKey.lock" &>/dev/null
}

this->unlock(){ this->unlockVar "$@"; }

this->isVarLocked(){ local key="$1";
    local sanitizedKey=$(echo $key | sed 's/[^a-zA-Z0-9]/_/g')
    if [ -f "$this->sharedMemoryDir/$sanitizedKey.lock" ]; then
        return 0
    else
        return 1
    fi
}

#creates a file, in the shared memory, to store the value. The file name is the key. The content is the value. The name of the file should be sanitized
this->setVar(){ local key="$1"; local value="$2"
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
this->set(){ this->setVar "$1" "$2"; return $?; }

#wait for a variable to be set with a value. The timeout is in seconds
#this function returns 0 if the value is setted and 1 if the timeout is reached
#this function uses _r as aditional return values:
#   _r is the time in seconds
#   _r->s is the time in seconds
#   _r->ms is the time in miliseconds
this->waitForValue(){ local key="$1"; local value="$2" local timeout="$3";
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

this->listVars(){
    local index=0;
    #scroll over the files in the shared memory directory
    for file in $this->sharedMemoryDir/*; do
        #get the file name
        eval "_r->$index=\$(basename $file)"
        index=$((index+1))
    done

    _r->count=$index
    _r->size=$index
    _r->length=$index
    _r=$index
}

this->listVars_2(){
    #just list the files
    ls -1 "$this->sharedMemoryDir"
}

#runs a callback inf a locked context. If another 'runLocked' is called with the same lock group name, 
#it will wait until the first 'runLocked' finishes. If you do not provide a lock group name, a default
#lock group name is used
this->runLocked(){ local callback="$1"; local _customLockGroupName_="$2"
    if [ "$_customLockGroupName_" == "" ]; then
        _customLockGroupName_="runLockedDefaultLocker"
    fi
    this->lock "$_customLockGroupName_"

    eval "$callback"

    this->unlock "$_customLockGroupName_"
}


#runs a callback in a locked context. The callback is executed in background (subshell) and will
#receive a 'unlocker function' to be evaluated when it finishes its work.
this->runLockedAsync(){ local callback="$1"; local _customLockGroupName_="$2"
    if [ "$_customLockGroupName_" == "" ]; then
        _customLockGroupName_="runLockedDefaultLocker"
    fi
    this->lock "$_customLockGroupName_"
    
    (eval "$callback __f(){
        this->unlock \"$_customLockGroupName_\"
    }; __f") &
}
