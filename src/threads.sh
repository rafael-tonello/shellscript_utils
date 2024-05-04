#!/bin/bash
#this file contains a class to make a thread like in bash. Also, it provide a 
#way to create ans get key-values to be used as global variables (os a shared memory) 
#that works acros many shell process
#
# _error is a global varibale used to return error messages
# _r is a global variable used to return values
#

#if [ "$1" != "new" ]; then echo "sourcing"; source <(curl -s "https://raw.githubusercontent.com/rafael-tonello/shellscript_utils/main/libs/new.sh"); new_f "$0" __app__ "" 1; exit 0; fi

this->scriptLocation=$3

this->init(){ local namespace=$1;
    new_f $this->scriptLocation/"sharedmemory.sh" this->memory "" 1 "$namespace"
}

this->finalize(){ local clearNamespace=$1
    if [ "$clearNamespace" == "1" ]; then
        this->memory->finalize 1
    fi
}

this->runThread(){ local threadFunction=$1;
    local randomName="_rnd_thread_name_"$(date +%s)$((RANDOM % 1000))
    local sanitizedName=$(echo $randomName | sed 's/[^a-zA-Z0-9]/_/g')
    this->runThread2 "$sanitizedName" "$threadFunction"
    return 0
}

#spaw a new shell process to run the function. The function should be a string with the function name.
#the process pid is stored in the sharedMemory var named "__threads.<name>.pid"
#returns the thread pid
this->runThread2(){ local name=$1; local threadFunction=$2;
    this->memory->setVar "__threads.$name.done" 0

    (
        eval "$threadFunction \"this\" \"$name\""
        exitCode=$?
        #set a flag to indicate that the thread has finished
        this->memory->setVar "__threads.$name.exitCode" $exitCode
        this->memory->setVar "__threads.$name.done" 1
    ) &

    local pid=$!
    this->memory->setVar "__threads.$name.pid" $pid
    this->memory->setVar "__threads.byPid.$pid" "$name"

    _r=$pid

    return 0
}

this->getExitCode_byName(){ local name=$1;
    exitCode=$(this->memory->getVar "__threads.$name.exitCode")
    echo $exitCode
    return $exitCode
}

this->getExitCode_byPid(){ local pid=$1;
    local name=$(this->memory->getVar "__threads.byPid.$pid")
    this->getExitCode_byName $name
    return $?
}

#kill a thread. The thread name is passed as the first argument
this->killThread_byName(){ local name=$1;
    local pid=$(this->memory->getVar "__threads.$name.pid")
    if [ -z "$pid" ]; then
        _error="thread $name not found"
        return 1
    fi

    kill $pid
    this->memory->setVar "__threads.$name.done" 1
    return 0
}

#kill a thread using the pid. The pid is passed as the first argument
this->killThread_byPid(){ local pid=$1;
    local name=$(this->memory->getVar "__threads.byPid.$pid")
    this->killThread_byName $name
    return $?
}

this->setVar(){ local key=$1; local value=$2;
    this->memory->setVar "$key" "$value"
    return $?
}

this->getVar(){ local key=$1;
    echo "$(this->memory->getVar "$key")"
    return $?
}

this->lock(){ local key=$1; local timeout=$2;
    this->memory->lock "$key" $timeout
    return $?
}

this->unlock(){ local key=$1;
    this->memory->unlock "$key"
    return $?
}


#wait for a thread to finish. The thread name is passed as the first argument.
#the second argument is the timeout in seconds and, if not provided, a default value of 10 seconds is used
this->waitThread_byName(){ local name=$1; local timeout=$2;
    local doneFlag=$(this->memory->getVar "__threads.$name.done")
    if [ -z "$doneFlag" ]; then
        doneFlag=0
        return 1
    fi

    #if timeout is not provided, set it with a default value
    if [ "$timeout" == "" ]; then
        timeout=10
    fi



    local start=$(date +%s)
    while [ "$doneFlag" -ne "1" ]; do
        local now=$(date +%s)
        local elapsed=$((now-start))
        if [ "$elapsed" -gt "$timeout" ]; then
            _error="timeout"
            return 1
        fi

        sleep 0.1
        doneFlag=$(this->memory->getVar "__threads.$name.done")
        if [ -z "$doneFlag" ]; then
            doneFlag=0
            return 1
        fi
    done

    return 0
}

this->waitThread_byPid(){ local pid=$1; local timeout=$2;
    local name=$(this->memory->getVar "__threads.byPid.$pid")
    this->waitThread_byName $name $timeout
    return $?
}


