#!/bin/bash

#test the sharedmemory.sh file

this->scriptLocation=$3
this->init(){ testsObject=$1;
    "$testsObject"->registerTest "eventbus: should send event and it should be received by listeners" "this->testEmit"
    "$testsObject"->registerTest "eventbus: another listeners should not receive the event" "this->testEmit_2"
    "$testsObject"->registerTest "eventbus: should handle events with mora than only one data" "this->testEmit_3"
}

this->finalize(){
    :;
}

this->testEmit(){
    new "eventbus" eb "eventbus"

    eb->on "event" "func(){
        this->callback_data=\"\$1\"
    }; func"

    eb->on "event" "func(){
        this->callback_data_2=\"\$1\"
    }; func"
    
    eb->emit "event" "data with spaces"
    if [ "$this->callback_data" != "data with spaces" ]; then
        _error="callback did not receive the expected data"
        _expected="data"
        _returned="$this->callback_data"
        return 1
    fi
    if [ "$this->callback_data_2" != "data with spaces" ]; then
        _error="callback did not receive the expected data"
        _expected="data"
        _returned="$this->callback_data_2"
        return 1
    fi
    return 0
}

this->testEmit_2(){
    new "eventbus" eb "eventbus"
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

this->testEmit_3(){
    new "eventbus" eb "eventbus"
    eb->on "event" "func(){
        this->callback_data=\"\$1\"
        this->callback_data_2=\"\$2\"
    }; func"

    eb->emit "event" "data1 with spaces" "data2 with spaces"
    
    if [ "$this->callback_data" != "data1 with spaces" ]; then
        _error="callback did not receive the expected data"
        _expected="data1"
        _returned="$this->callback_data"
        return 1
    fi
    if [ "$this->callback_data_2" != "data2 with spaces" ]; then
        _error="callback did not receive the expected data"
        _expected="data2"
        _returned="$this->callback_data_2"
        return 1
    fi
    
    return 0
}