#!/bin/bash

# This script defines a queue of any thing (strings)
#a simple FIFO queue that uses shared memory to store the elements. The use of shared memory allows the queue to be used by different 
#threads (terminal spawns) and data persistence between app executions.

this->scriptLocation=$3

this->init(){ local queuename="$1"; local _memoryNamespace_="$2"; local _memoryStorageDirectory_="$3";
    if [ -z "$queuename" ]; then
        echo "Error: queue name is required"
        return 1
    fi

    this->_queueName="$queuename"

    if [ "$_memoryNamespace_" != "" ]; then
        _memoryNamespace_="$queuename"
    fi

    new_f "$this->scriptLocation/""sharedmemory.sh" "this->memory" "$_memoryNamespace_" "$_memoryStorageDirectory_"

    this->memory->setVar "$this->_queueName".lastIndex 0
    this->memory->setVar "$this->_queueName".firstIndex 0
}

this->finalize() { local _clearNamespace_=$1;
    this->this->memory->finalize "$_clearNamespace_"
}

# This function adds an element to the queue
this->pushFront() {
    local element=$1
    local firstIndex=$(this->memory->getVar "$this->_queueName".firstIndex)
    this->memory->setVar "$this->_queueName".element.$((firstIndex - 1)) "$element"
    this->memory->setVar "$this->_queueName".firstIndex $((firstIndex - 1))
}

this->pushBack() {
    local element=$1
    local lastIndex=$(this->memory->getVar "$this->_queueName".lastIndex)
    this->memory->setVar "$this->_queueName".element.$lastIndex "$element"
    this->memory->setVar "$this->_queueName".lastIndex $((lastIndex + 1))
}

this->popFront() {
    local firstIndex=$(this->memory->getVar "$this->_queueName".firstIndex)
    local lastIndex=$(this->memory->getVar "$this->_queueName".lastIndex)
    if [ $firstIndex -ge $lastIndex ]; then
        return 1
    fi
    local element=$(this->memory->getVar "$this->_queueName".element.$firstIndex)
    #set the poped element as ""
    this->memory->setVar "$this->_queueName".element.$firstIndex ""
    this->memory->setVar "$this->_queueName".firstIndex $((firstIndex + 1))
    echo $element
}

this->popBack() {
    local firstIndex=$(this->memory->getVar "$this->_queueName".firstIndex)
    local lastIndex=$(this->memory->getVar "$this->_queueName".lastIndex)
    if [ $firstIndex -ge $lastIndex ]; then
        return 1
    fi
    local element=$(this->memory->getVar "$this->_queueName".element."$(( lastIndex - 1 ))")

    #set the poped element as ""
    this->memory->setVar "$this->_queueName".element.$((lastIndex - 1)) ""
    this->memory->setVar "$this->_queueName".lastIndex $((lastIndex - 1))
    echo $element
}

this->popIndex() {
    local index=$1
    local firstIndex=$(this->memory->getVar "$this->_queueName".firstIndex)
    local lastIndex=$(this->memory->getVar "$this->_queueName".lastIndex)
    if [ $index -lt $firstIndex ] || [ $index -ge $lastIndex ]; then
        return 1
    fi
    local element=$(this->memory->getVar "$this->_queueName".element.$index)
    this->memory->setVar "$this->_queueName".element.$index ""
    echo $element
}

#function to check if queue contains anything
this->isEmpty() {
    local firstIndex=$(this->memory->getVar "$this->_queueName".firstIndex)
    local lastIndex=$(this->memory->getVar "$this->_queueName".lastIndex)
    if [ $firstIndex -ge $lastIndex ]; then
        return 0
    fi
    return 1
}
