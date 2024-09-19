#!/bin/bash

# semaphore class

this->init(){ local _maxItems_="$1";
    local sharedmemory_namespace_name="locker/$RANDOM$RANDOM"
    new sharedmemory "this->mem" "$sharedmemory_namespace_name"
    this->_maxItems="$_maxItems_"

    this->mem->runLocked "__f(){
        this->mem->set \"currentCount\" \"0\";
        this->mem->set \"totalDecreasings\" \"0\";
    }; __f";
    #this->mem->set \"totalIncreasings\" \"0\";


}

#increment the internal semaphore counter
this->take(){ local _amount_="$1"
    if [ "$_amount_" == "" ]; then
        _amount_=1
    fi

    this->mem->runLocked "__f(){
        local currentCount=\$(this->mem->get \"currentCount\" 0)
        currentCount=\$((currentCount + $_amount_))
        if [ \"\$this->_maxItems\" != \"\" ] && [ \"\$currentCount\" -gt \"\$(this->_maxItems)\" ]; then
            currentCount=\$this->_maxItems
        fi
        this->mem->set \"currentCount\" \"\$currentCount\"
    }; __f";
    #local totalIncreasings=\$(this->mem->get \"totalIncreasings\" 0)
    #totalIncreasings=\$((totalIncreasings + $_amount_))
    #this->mem->set \"totalIncreasings\" \"\$totalIncreasings\"
}

#decrement the internal semaphore counter
this->release(){ local _amount_="$1"
    if [ "$_amount_" == "" ]; then
        _amount_=1
    fi

    this->mem->runLocked "__f(){
        local currentCount=\$(this->mem->get \"currentCount\" 0)
        currentCount=\$((currentCount - $_amount_))
        
        if [ \"\$currentCount\" -lt \"0\" ]; then
            currentCount=0
        fi
        
        this->mem->set \"currentCount\" \"\$currentCount\"

        local totalDecreasings=\$(this->mem->get \"totalDecreasings\" 0)
        totalDecreasings=\$((totalDecreasings + $_amount_))
        this->mem->set \"totalDecreasings\" \"\$totalDecreasings\"
    }; __f";
}

#wait until the semaphore counter be decremented by the informed amount
this->wait(){ local _howMany_def_1_=$1; local _timeout_seconds_="$2"
    if [ "$_howMany_def_1_" == "" ]; then _howMany_def_1_=1; fi

    local localInitialCount=""
    this->mem->runLocked "__f(){
        initialTotalDecreasings=\$(this->mem->get \"totalDecreasings\" 0)
    }; __f"
    local minValueToExit=$((initialTotalDecreasings + _howMany_def_1_))

    local startTimestamp=$(date +%s)

    local sucess=0
    while [ "$_timeout_seconds_" == "" ] || [ $(( $(date +%s) - $startTimestamp )) -lt $_timeout_seconds_ ]; do
        this->mem->runLocked "__f(){
            local currentTotalDecreasings=\$(this->mem->get \"totalDecreasings\" 0)

            if [ \"\$currentTotalDecreasings\" -ge \"\$minValueToExit\" ]; then
                sucess=\"1\"
                return 0
            fi
        }; __f";

        if [ "$sucess" == "1" ]; then
            break;
        fi

        sleep $(echo "scale=2; ($(( RANDOM % 50)) + 50) / 1000" | bc)
    done

    if [ "$sucess" == "1" ]; then
        return 0;
    else
        _error="timeout error"
        return 1;
    fi
}

this->waitOne(){ local _timeout_seconds_="$1"
    this->wait 1 "$_timeout_seconds_"
}

this->waitAll(){ local _timeout_seconds_=$1;
    local startTimestamp=$(date +%s)
    local sucess=0;
    while [ "$_timeout_seconds_" == "" ] || [ $(( $(date +%s) - $startTimestamp )) -lt $_timeout_seconds_ ]; do
        this->mem->runLocked "__f(){
            local currentCount=\$(this->mem->get \"currentCount\" 0)
            
            if [ \"\$currentCount\" == \"0\" ]; then
                sucess=\"1\"
                return 0
            fi
        }; __f";

        if [ "$sucess" == "1" ]; then
            break;
        fi

        sleep $(echo "scale=2; ($(( RANDOM % 50)) + 50) / 1000" | bc)
    done

    if [ "$sucess" == "1" ]; then
        return 0;
    else
        _error="timeout error"
        return 1;
    fi
}

this->getCount(){
    this->mem->runLocked "__f(){
        _r=\$(this->mem->get \"currentCount\" 0)
    }; __f"
    echo $_r
}