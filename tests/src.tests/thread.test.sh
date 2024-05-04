#!/bin/bash

#test the threads.sh file

this->scriptLocation=$3
this->init(){ testsObject=$1;
    new_f $this->scriptLocation"/../../src/threads.sh" this->threads "" 1 $("$testsObject"->getNamespace)
    new_f $this->scriptLocation"/../../src/sharedmemory.sh" this->memory "" 1 $("$testsObject"->getNamespace)
    #you can use the object passe by parameters or instantiate a new instance (in this case, 
    #the namespace should be the same as the one used in the tests.sh file)
    #new_f $this->scriptLocation"/../../../tests.sh" this->tests "" 1 "tests"
    
    "$testsObject"->registerTest "Testing run thread1" "this->testRunThread"
    "$testsObject"->registerTest "Testing setVar and getVar (multi thread)" "this->testSetAndGet"
    

    
}

this->finalize(){
    this->threads->finalize
}

this->testRunThread(){
    this->threads->runThread "func(){ 
        sleep 0.5
        this->memory->set \"thread1Func.done\" \"1\";
    }; func"
    local threadPid=$_r
    this->threads->waitThread_byPid $threadPid    
    if [ "$?" -ne "0" ]; then
        _error="thread1Func did not finish in time"
        return 1
    fi

    return 0
}

this->testSetAndGet(){
    result=0
    this->threads->runThread "func(){ 
        this->threads->lock "mutex"
        this->threads->setVar thread1Func.v1 \"1\"
        sleep 0.5
        this->threads->setVar thread1Func.v2 \"2\"
        this->threads->unlock "mutex"
        return 0
    }; func"
    local thread1Pid=$_r

    this->threads->runThread "func(){
        this->threads->lock "mutex" 
        v1=\$(this->threads->getVar thread1Func.v1)
        v2=\$(this->threads->getVar thread1Func.v2)
        
        if [ \"\$v1\" != \"1\" ]; then
            local err=\"v1 (which should be set by the first thread) was not setted or setted with wrong value)\"
            this->threads->setVar thread2Func.err \"\$err\"
            #echo \"     \$err\"
            result=1
            return 1
        fi

        if [ \"\$v2\" != \"2\" ]; then
            local err=\"v2 (which should be set by the first thread) was not setted or setted with wrong value)\"
            this->threads->setVar thread2Func.err \"\$err\"
            #echo \"     \$err\"
            result=1
            return 1
        fi
    }; func"
    local thread2Pid=$_r

    this->threads->waitThread_byPid $thread1Pid
    if [ "$?" -ne "0" ]; then
        _error="first thread did not finish in time"
        return 1
    fi

    this->threads->waitThread_byPid $thread2Pid 60
    if [ "$?" -ne "0" ]; then
        _error="second thread did not finish in time"
        return 1
    fi

    t1Result=$(this->threads->getExitCode_byPid $thread1Pid)
    if [ "$t1Result" -ne "0" ]; then
        _error="first thread returned an error: $(this->threads->getVar thread1Func.err)"
        return 1
    fi

    t2Result=$(this->threads->getExitCode_byPid $thread2Pid)
    if [ "$t2Result" -ne "0" ]; then
        _error="second thread returned an error: $(this->threads->getVar thread2Func.err)"
        return 1
    fi

    return 0
}
