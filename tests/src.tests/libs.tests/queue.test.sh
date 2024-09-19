#!/bin/bash

#test the sharedmemory.sh file

this->scriptLocation=$3
this->init(){ testsObject=$1;
    "$testsObject"->registerTest "queue: should put data in the front (and get it)" "this->testPushFront"
    "$testsObject"->registerTest "queue: should put data in the back (and get it)" "this->testPushBack"
    "$testsObject"->registerTest "queue: should get data from the front" "this->testPopFront"
    "$testsObject"->registerTest "queue: should get data from the back" "this->testPopBack"
    "$testsObject"->registerTest "queue: should get data from the front only one time" "this->testPopFront_2"
    "$testsObject"->registerTest "queue: should get data from the back only one time" "this->testPopBack_2"
    "$testsObject"->registerTest "queue: should store several data up front " "this->testPushFront_2"
    "$testsObject"->registerTest "queue: should store several data up back " "this->testPushBack_2"

}

this->finalize(){
    :;
}

this->testPushFront(){
    new "queue" q "queue"
    q->pushFront "data"
    local data=$(q->popFront)
    if [ "$data" != "data" ]; then
        _error="data was not put in the front"
        _expected="data"
        _returned="$data"
        return 1
    fi
    return 0
}

this->testPushBack(){
    new "queue" q "queue"
    q->pushBack "data"
    local data=$(q->popBack)
    if [ "$data" != "data" ]; then
        _error="data was not put in the back"
        _expected="data"
        _returned="$data"
        return 1
    fi
    return 0
}

this->testPopFront(){
    new "queue" q "queue"
    q->pushFront "data"
    local data=$(q->popFront)
    if [ "$data" != "data" ]; then
        _error="data was not put in the front"
        _expected="data"
        _returned="$data"
        return 1
    fi
    return 0
}

this->testPopBack(){
    new "queue" q "queue"
    q->pushBack "data"
    local data=$(q->popBack)
    if [ "$data" != "data" ]; then
        _error="data was not put in the back"
        _expected="data"
        _returned="$data"
        return 1
    fi
    return 0
}

this->testPopFront_2(){
    new "queue" q "queue"
    q->pushFront "data"
    local data=$(q->popFront)
    if [ "$data" != "data" ]; then
        _error="data was not put in the front"
        _expected="data"
        _returned="$data"
        return 1
    fi
    data=$(q->popFront)
    if [ "$data" != "" ]; then
        _error="data was not removed from the front"
        _expected=""
        _returned="$data"
        return 1
    fi
    return 0
}

this->testPopBack_2(){
    new "queue" q "queue"
    q->pushBack "data"
    local data=$(q->popBack)
    if [ "$data" != "data" ]; then
        _error="data was not put in the back"
        _expected="data"
        _returned="$data"
        return 1
    fi
    data=$(q->popBack)
    if [ "$data" != "" ]; then
        _error="data was not removed from the back"
        _expected=""
        _returned="$data"
        return 1
    fi
    return 0
}

this->testPushFront_2(){
    new "queue" q "queue"
    q->pushFront "data"
    q->pushFront "data2"
    q->pushFront "data3"
    local data=$(q->popFront)
    if [ "$data" != "data3" ]; then
        _error="data was not put in the front"
        _expected="data3"
        _returned="$data"
        return 1
    fi
    data=$(q->popFront)
    if [ "$data" != "data2" ]; then
        _error="data was not put in the front"
        _expected="data2"
        _returned="$data"
        return 1
    fi
    data=$(q->popFront)
    if [ "$data" != "data" ]; then
        _error="data was not put in the front"
        _expected="data"
        _returned="$data"
        return 1
    fi
    return 0
}

this->testPushBack_2(){
    new "queue" q "queue"
    q->pushBack "data"
    q->pushBack "data2"
    q->pushBack "data3"
    local data=$(q->popBack)
    if [ "$data" != "data3" ]; then
        _error="data was not put in the back"
        _expected="data3"
        _returned="$data"
        return 1
    fi
    data=$(q->popBack)
    if [ "$data" != "data2" ]; then
        _error="data was not put in the back"
        _expected="data2"
        _returned="$data"
        return 1
    fi
    data=$(q->popBack)
    if [ "$data" != "data" ]; then
        _error="data was not put in the back"
        _expected="data"
        _returned="$data"
        return 1
    fi
    return 0
}