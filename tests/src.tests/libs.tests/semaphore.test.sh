#!/bin/bash

this->init(){ testsObject=$1;
    "$testsObject"->registerTest "semaphore~>init: should create the semaphore with counter = 0" "this->testInit"
    "$testsObject"->registerTest "semaphore~>take: should incrment counter by 1" "this->testTake"
    "$testsObject"->registerTest "semaphore~>take: should incrment counter by 1 more than one time" "this->testTake2"
    "$testsObject"->registerTest "semaphore~>take 'n': should increment counter by 'n'" "this->testTakeN"
    "$testsObject"->registerTest "semaphore~>release: should decrease counter by 1" "this->testRelease"
    "$testsObject"->registerTest "semaphore~>release 'n': should decrease counter by 'n'" "this->testReleaseN"
    "$testsObject"->registerTest "semaphore~>wait: should wait one decreasing to return" "this->testWait"
    "$testsObject"->registerTest "semaphore~>waitOne: should wait one descresing to return" "this->testWaitOne"
    "$testsObject"->registerTest "semaphore~>wait 'n': should wait 'n' decreasings to return" "this->testWaitN"
    "$testsObject"->registerTest "semaphore~>waitAll: should wait internal counter be 0 to return" "this->testWaitAll"
    "$testsObject"->registerTest "semaphore~>wait: should return timeout error" "this->testWaitTimeout"
    "$testsObject"->registerTest "semaphore~>waitOne: should return timeout error" "this->testWaitOneTimeout"
    "$testsObject"->registerTest "semaphore~>wait 'n': should return timeout error" "this->testWaitNTimeout"
    "$testsObject"->registerTest "semaphore~>waitAll: should return timeout error" "this->testWaitAllTimeout"


}

this->finalize(){
    :;
}

this->testInit(){
    new semaphore sem1
    local count=$(sem1->getCount "currentCount")
    if [ "$count" != "0" ]; then
        _error="Semaphore was not initialized with counter = 0"
        _expected="0"
        _returned="$count"
        return 1
    fi

    return 0
}

this->testTake(){
    new semaphore sem
    sem->take
    local count=$(sem->getCount)
    if [ "$count" != "1" ]; then
        _error="Semaphore counter was not incremented by 1"
        _expected="1"
        _returned="$count"
        return 1
    fi

    return 0
}

this->testTake2(){
    new semaphore sem
    sem->take
    sem->take
    local count=$(sem->getCount)
    if [ "$count" != "2" ]; then
        _error="Semaphore counter was not incremented by 1 the two times"
        _expected="2"
        _returned="$count"
        return 1
    fi

    return 0
}

this->testTakeN(){
    new semaphore sem
    sem->take 10
    local count=$(sem->getCount "currentCount")
    if [ "$count" != "10" ]; then
        _error="Semaphore counter was not incremented by 10"
        _expected="10"
        _returned="$count"
        return 1
    fi

    return 0
}

this->testRelease(){
    new semaphore sem
    sem->take
    sem->take 2
    sem->release
    local count=$(sem->getCount)
    if [ "$count" != "2" ]; then
        _error="Semaphore counter was not incremented and decremented correctly"
        _expected="2"
        _returned="$count"
        return 1
    fi

    return 0
}

this->testReleaseN(){
    new semaphore sem
    sem->take
    sem->take 4
    sem->take 5
    sem->release
    sem->release 2
    sem->release 2
    local count=$(sem->getCount)
    if [ "$count" != "5" ]; then
        _error="Semaphore counter was not incremented and decremented correctly"
        _expected="5"
        _returned="$count"
        return 1
    fi

    return 0
}

this->testWait(){
    new semaphore sem
    sem->take 2
    (
        sleep 0.25
        sem->release
        sleep 0.25
        sem->take 2
        sleep 0.25
        sem->release
    ) &
    sem->wait 2
    local count=$(sem->getCount)
    if [ "$count" != "2" ]; then
        _error="Semaphore counter was not incremented and decremented correctly"
        _expected="2"
        _returned="$count"
        return 1
    fi

    return 0
}

this->testWaitOne(){
    new semaphore sem
    sem->take 5

    (
        sleep 0.25
        sem->release
        sleep 0.5
        sem->release 4
    ) &

    sem->wait 1
    local count=$(sem->getCount)
    sleep 0.5
    if [ "$count" != "4" ]; then
        _error="Semaphore counter was not incremented and decremented correctly"
        _expected="4"
        _returned="$count"
        return 1
    fi

    return 0
}

this->testWaitN(){
    new semaphore sem
    sem->take 5
    (
        sleep 0.2
        sem->release 2
        sleep 0.4
        sem->release 3
    ) &

    (
        sleep 0.2
        sem->release
    ) &

    sem->wait 3
    local count=$(sem->getCount)
    sleep 0.5
    if [ "$count" != "2" ]; then
        _error="Semaphore counter was not incremented and decremented correctly"
        _expected="2"
        _returned="$count"
        return 1
    fi

    return 0
}

this->testWaitAll(){
    new semaphore sem
    sem->take 5
    (
        sleep 0.2
        sem->release 2
        sleep 0.2
        sem->release 2
    ) &
    (
        sleep 0.25
        sem->release
    ) &
    sem->waitAll
    local count=$(sem->getCount)
    if [ "$count" != "0" ]; then
        _error="Semaphore counter was not incremented and decremented correctly"
        _expected="0"
        _returned="$count"
        return 1
    fi

    return 0
}

this->testWaitTimeout(){
    new semaphore sem
    sem->take 5
    
    (
        sleep 0.2
        sem->release 2
        
    ) &

    sem->wait 3 1
    local retCode=$?
    if [ "$retCode" == "0" ]; then
        _error="Semaphore counter does not have exited with error"
        _expected="exitcode == 1"
        _returned="exitcode == $retCode"
        return 1
    fi

    return 0
}

this->testWaitOneTimeout(){
    new semaphore sem
    sem->take 5
    (
        sleep 1
        sem->release 2
        
    ) &

    sem->waitOne 1
    local retCode=$?
    if [ "$retCode" == "0" ]; then
        _error="Semaphore counter does not have exited with error"
        _expected="exitcode == 1"
        _returned="exitcode == $retCode"
        return 1
    fi

    return 0
}

this->testWaitNTimeout(){
    new semaphore sem
    sem->take 5
    (
        sleep 0.2
        sem->release 1
        sleep 0.8
        sem->release 2
        
    ) &

    sem->wait 2 1
    local retCode=$?
    if [ "$retCode" == "0" ]; then
        _error="Semaphore counter does not have exited with error"
        _expected="exitcode == 1"
        _returned="exitcode == $retCode"
        return 1
    fi

    return 0
}

this->testWaitAllTimeout(){
    new semaphore sem
    sem->take 5
    (
        sleep 0.2
        sem->release 1
        sleep 0.8
        sem->release 2
        
    ) &

    sem->waitAll 1
    local retCode=$?
    if [ "$retCode" == "0" ]; then
        _error="Semaphore counter does not have exited with error"
        _expected="exitcode == 1"
        _returned="exitcode == $retCode"
        return 1
    fi

    return 0
}
