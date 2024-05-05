#!/bin/bash

#test the sharedmemory.sh file

this->scriptLocation=$3
this->init(){ testsObject=$1;
    "$testsObject"->registerTest "should send event and it should be received by listeners" "this->testEmit"
    "$testsObject"->registerTest "another listeners should not receive the event" "this->testEmit_2"
}

this->finalize(){
    :;
}

this->testEmit(){
    new "eventbus" eb "" 1 "eventbus"

    eb->on "event" "func(){
        this->callback_data=\"\$1\"
    }; func"

    eb->on "event" "func(){
        this->callback_data_2=\"\$1\"
    }; func"
    
    eb->emit "event" "data"
    if [ "$this->callback_data" != "data" ]; then
        _error="callback did not receive the expected data"
        _expected="data"
        _returned="$this->callback_data"
        return 1
    fi
    if [ "$this->callback_data_2" != "data" ]; then
        _error="callback did not receive the expected data"
        _expected="data"
        _returned="$this->callback_data_2"
        return 1
    fi
    return 0
}

this->testEmit_2(){
    new "eventbus" eb "" 1 "eventbus"
    eb->on "event" "func(){
        this->callback_data=\"\$1\"
    }; func"

    this->callback_data_2="originalData"
    eb->on "otherEvent" "func(){
        this->callback_data_2=\"\$1\"
    }; func"
    
    eb->emit "event" "data"
    
    if [ "$this->callback_data" != "data" ]; then
        _error="callback did not receive the expected data"
        _expected="data"
        _returned="$this->callback_data"
        return 1
    fi
    if [ "$this->callback_data_2" != "originalData" ]; then
        _error="callback was changed by another event"
        _expected="data"
        _returned="$this->callback_data_2"
        return 1
    fi
    
    return 0
}