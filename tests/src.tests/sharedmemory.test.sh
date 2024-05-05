#!/bin/bash

#test the sharedmemory.sh file

this->scriptLocation=$3
this->init(){ testsObject=$1;
    new_f $this->scriptLocation"/../../src/sharedmemory.sh" this->memory "" 1 $("$testsObject"->getNamespace)
    #you can use the object passe by parameters or instantiate a new instance (in this case, 
    #the namespace should be the same as the one used in the tests.sh file)
    #new_f $this->scriptLocation"/../../../tests.sh" this->tests "" 1 "tests"
    
    "$testsObject"->registerTest "Testing setVar" "this->testSetVar"
    "$testsObject"->registerTest "Testing getVar" "this->testGetVar"
    "$testsObject"->registerTest "Testing lock/unlock vars" "this->testLockUnLock"
    "$testsObject"->registerTest "waitForValue" "this->testWaitForValue 0.5"
    "$testsObject"->registerTest "Testing waitForValue should fail if wait timeout is reached" "_anfn(){
        this->testWaitForValue 1.2
        local retCode=\$?
        #check if errorCode == 0

        if [ "\$retCode" -eq \"0\" ]; then
            _error=\"function 'waitForValue' returned 0 (sucess) when it should not\"
            return 0
        fi
        _expected=\"timeout reached\"
        _returned=\"\$_error\"
        
        if [ "\$retCode" -eq \"0\" ]; then
            return 1
        fi
        _error=\"\"
        return 0
        
    }; _anfn"
}

this->finalize(){
    :;
}

this->testSetVar(){
    new "sharedmemory" memory "" 1 "tests_testGetVar"
    memory->setVar "testvar" "testValue"

    #check if file [memory->sharedMemoryDir]/[testvar] exists and has the value "testValue"
    if [ ! -f "$memory->sharedMemoryDir/testvar" ]; then
        _error="file testvar was not created"
        memory->finalize 1
        return 1
    fi
    memory->finalize 1

    return 0
}

this->testGetVar(){
    new "sharedmemory" memory "" 1 "tests_testGetVar"
    #create a file [memory->sharedMemoryDir]/[testgetvar] with the value "rightValue"
    echo "rightValue" > "$memory->sharedMemoryDir/testgetvar"

    #check if the value returned by getVar is "rightValue"
    if [ "$(memory->getVar "testgetvar")" != "rightValue" ]; then
        _error="getVar did not return the right value"
        memory->finalize 1
        return 1
    fi

    memory->finalize 1
    return 0
}

this->testLockUnLock(){
    new "sharedmemory" memory "" 1 "tests_testLockUnLock"
    memory->lockVar "testvar"
    #check if the file [memory->sharedMemoryDir]/[testvar] exists
    if [ ! -f "$memory->sharedMemoryDir/testvar.lock" ]; then
        _error="lockVar did not lock the file"
        memory->finalize 1
        return 1
    fi

    memory->unlockVar "testvar"

    #check if the file [memory->sharedMemoryDir]/[testvar] does not exists
    if [ -f "$memory->sharedMemoryDir/testvar.lock" ]; then
        _error="lockVar did not unlock the file"
        memory->finalize 1
        return 1
    fi

    memory->finalize 1
    return 0
}


#this test will set the value of a variable int the background (with 0.5 seconds delay) and will check if the value is the expected one. 
#The time should be checked to be less than 5 seconds and bigger than 0 seconds
#the total time is stored in the _r variable by the memory->waitForValue function
this->testWaitForValue(){ local sleepTime=$1;
    new "sharedmemory" memory "" 1 "tests_testWaitForValue"
    echo "wrongValue" > "$memory->sharedMemoryDir/testwaitforvalue"

    (
        sleep $sleepTime
        #create a file [memory->sharedMemoryDir]/[testwaitforvalue] with the value "rightValue"
        (echo "rightValue" > "$memory->sharedMemoryDir/testwaitforvalue") 2>/dev/null
    ) &

    #check if the value returned by waitForValue is "rightValue"
    memory->waitForValue "testwaitforvalue" "rightValue" 1
    if [ "$?" -ne "0" ]; then
        _error="timeout reached"
        memory->finalize 1
        return 1
    fi
    #check if bc command is installed
    if [ ! -x "$(command -v bc)" ]; then
        _error="bc command is not installed"
        memory->finalize 1
        return 1
    fi


    #check if time is bigger than 0 and less than 1 seconds
    local sleepTimeMs=$(echo $( echo "scale=0; $sleepTime * 1000" | bc) | cut -d. -f1)
    if [ "$_r->ms" -lt "$sleepTimeMs" ] || [ "$_r->ms" -gt "2000" ]; then
        _error="waitForValue did not return in the right time"
        memory->finalize 1
        return 1
    fi

    memory->finalize 1
    return 0
    
}
