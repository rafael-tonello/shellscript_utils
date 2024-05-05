#!/bin/bash

#test the threads.sh file

if [ "$1" != "new" ]; then source ../new.sh; new_f "$0" __app__ "" 1; exit 0; fi


this->scriptLocation=$3
this->init(){
    new_f $this->scriptLocation"/../../../threads.sh" this->threads "" 1 "tests"
    new_f $this->scriptLocation"/../../../sharedmemory.sh" this->memory "" 1 "tests"
    new_f $this->scriptLocation"/../../../tests.sh" this->tests "" 1 "tests"
    
    this->tests->registerTest "Testing run thread1" "this->testRunThread" 
    this->tests->registerTest "Testing run thread2" "this->testRunThread" 
    this->tests->registerTest "Testing run thread3" "this->testRunThread" 
    this->tests->registerTest "Testing run thread4" "this->testRunThread" 
    this->tests->registerTest "Testing run thread5" "this->testRunThread" 
    this->tests->registerTest "Testing run thread6" "this->testRunThread" 
    this->tests->registerTest "Testing run thread7" "this->testRunThread" 
    this->tests->registerTest "Testing run thread8" "this->testRunThread" 
    this->tests->registerTest "Testing run thread9" "this->testRunThread" 
    this->tests->registerTest "Testing run thread10" "this->testRunThread" 
    this->tests->registerTest "Testing run thread11" "this->testRunThread" 
    this->tests->registerTest "Testing run thread12" "this->testRunThread" 
    this->tests->registerTest "Testing run thread13" "this->testRunThread" 
    this->tests->registerTest "Testing run thread14" "this->testRunThread" 
    this->tests->registerTest "Testing run thread15" "this->testRunThread" 
    this->tests->registerTest "Testing run thread16" "this->testRunThread" 
    this->tests->registerTest "Testing run thread17" "this->testRunThread" 
    this->tests->registerTest "Testing run thread18" "this->testRunThread" 
    this->tests->registerTest "Testing run thread19" "this->testRunThread" 
    this->tests->registerTest "Testing run thread20" "this->testRunThread" 
    this->tests->registerTest "Testing run thread21" "this->testRunThread" 
    this->tests->registerTest "Testing run thread22" "this->testRunThread" 
    this->tests->registerTest "Testing run thread23" "this->testRunThread" 
    this->tests->registerTest "Testing run thread24" "this->testRunThread" 
    this->tests->registerTest "Testing run thread25" "this->testRunThread" 

    
}

this->testRunThread(){
    
    this->threads->runThread "_this->thread1Func"
    local threadPid=$_r
    this->threads->waitThread_byPid $threadPid    
    if [ "$?" -ne "0" ]; then
        _error="thread1Func did not finish in time"
        return 1
    fi

    #get random error code (0 or 1)
    local errorCode=$((RANDOM % 2))
    if [ "$errorCode" -ne "0" ]; then
        _error="random error"
        return 1
    fi

    return 0
}

_this->thread1Func(){
    this->memory->set "thread1Func.done" "1"
}