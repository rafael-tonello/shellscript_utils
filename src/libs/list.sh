#!/bin/bash

#this is a multi puRpose list and queue class. You can insert element in any 
#position, remove any element, get any element, iterate over the list and more.
#this list is a chain of elements. Each element has 'data' fields and two
#pointers: 'next' and 'prev', that respectively points to the next and previous
#elements.

##if [ "$1" != "new" ]; then 
##    echo "sourcing new.sh"
##    source "/media/veracrypt/projects/rafinha_tonello/shellscript_utils/src/new.sh"
##    echo "starting app"
##    new_f "$0" test
##    exit 0; 
##fi


#list.sh
this->init(){
    this->idCount=0
    this->firstId=""
    this->lastId=""

    this->currentCount=0
}

this->pushBack(){
    this->putAfter "$this->lastId" "$@"
    return $?
}

this->back(){
    this->get "$this->lastId"
}

this->getBack(){
    return $this->back
}

this->removeBack(){
    this->remove "$this->lastId"
}

this->popBack(){
    this->getBack
    this->removeBack
}

this->pushFront(){
    this->putBefore "$this->firstId" "$@"
}

this->front(){
    this->get "$this->firstId"
}

this->getFront(){
    return $this->front
}

this->removeFront(){
    this->remove "$this->firstId"
}

#remove an element from the list and return its data (call 'get' and 'remove' in sequence). You should provide the elementId
#argument id: the id of the element
#result _r: _r will hold the element value
#result _error: _error will recieve an error description if some one happes
this->popFront(){
    this->getFront
    this->removeFront
}

#insert an element after another element in the list
#argument previousElementId: the id of the previous element (the new element will be put after this one)
#argument newElementData: the data of the new element
#result _r: _r will receive the id of the new element
#result _error: _error will store a error message if something goes wrong 
this->putAfter(){ local previousElementId=$1;
    #create the new element
    local newElement="this->el_""$this->idCount"
    local nextElementId=""


    #eval "$newElement""->data=\"\$2\""


    local tmpCount=0
    shift
    for i in "$@"; do
        eval "$newElement""->data_$tmpCount=\"$i\""
        tmpCount=$(( tmpCount+1 ))
    done
    eval "$newElement""->dataCount=$tmpCount"


    #get the next and the previous elements
    if [ "$previousElementId" != "" ]; then
        eval "nextElementId=\"\$$previousElementId""->next\""
    else
        nextElementId=$this->firstId
    fi

    #here we have the tree elementIds: previousElementId, newElement and nextElementId


    #update the previousElement next pointer
    if [ "$previousElementId" != "" ]; then
        eval "$previousElementId""->next=\"$newElement\""
    else
        this->firstId="$newElement"
    fi

    #update the nextElement prev pointer
    if [ "$nextElementId" != "" ]; then
        eval "$nextElementId""->prev=\"$newElement\""
    else
        this->lastId="$newElement"
    fi

    #update the new element pointers
    eval "$newElement""->prev=\"\$previousElementId\""
    eval "$newElement""->next=\"\$nextElementId\""
    _r="$newElement"
    _error=""

    this->idCount=$(( this->idCount+1 ))
    this->currentCount=$(( this->currentCount+1 ))
    return 0
}
pushAfter(){
    this->putAfter "$@"
}

#insert an element before another element in the list
#argument nextElementId: the id of the next element (the new element will be put before this one)
#argument newElementData: the data of the new element
#result _r: _r will receive the id of the new element
#result _error: _error will store a error message if something goes wrong 
this->putBefore(){ local nextElementId="$1"; local newElementData="$2"
    
    #uses putAfter
    eval "previousElement=\"\$$nextElementId""->prev\""

    #if [ "$previousElement" == "" ]; then
    #    previousElement=$this->firstId
    #fi

    shift
    this->putAfter "$previousElement" "$@"
    return $?
}
pushBefore(){
    this->putBefore "$@"
}

#returns te data array of an element
#argument id: the id of the desired element
#result _r: _r will receive the amout of data elements
#result _r_0, _r_1, _r_2, ...: each _r_i will receive the data element
#result _error: _error will store a error message if something goes wrong 
this->get(){
    _r=0
    _error=""

    if [ "$1" == "" ]; then
        _error="You must provide an element id"
        return 1
    fi

    eval "local dataCount=\$$1""->dataCount"
    _r=dataCount
    if [ "$_r" == "" ]; then
        _error="Element not found"
        return 1
    fi

    for i in $(seq 0 $(( dataCount-1 ))); do
        eval "_r_$i=\"\$$1""->data_$i\""
    done
}

#removes an element of the list
#argument id: the id of the element to be removed
#result _error: _error will store a error message if something goes wrong 
this->remove(){ local elementId=$1
    _error=""

    if [ "$1" == "" ]; then
        _error="You must provide an element id"
        return 1
    fi

    local prevElementId=""
    local nextElementId=""

    eval "prevElementId=\"\$$elementId""->prev\""
    eval "nextElementId=\"\$$elementId""->next\""

    if [ "$prevElementId" != "" ]; then
        eval "$prevElementId""->next=\"\$nextElementId\""
    else
        this->firstId="$nextElementId"
    fi

    if [ "$nextElementId" != "" ]; then
        eval "$nextElementId""->prev=\"\$prevElementId\""
    else
        this->lastId="$prevElementId"
    fi

    eval "local dataCount=\$$elementId""->dataCount"
    for i in $(seq 0 $(( dataCount-1 ))); do
        eval "unset $elementId""->data_$i"
    done

    unset $elementId
    eval "unset $elementId""->next"
    eval "unset $elementId""->prev"

    this->currentCount=$(( this->currentCount-1 ))

    _error=""
}

#remove an element from the list and return its data (call 'get' and 'remove' in sequence). You should provide the elementId
#argument id: the id of the element
#result _r: _r will hold the element value
#result _error: _error will recieve an error description if some one happes
this->pop(){
    _error=""
    _r=""

    #get the element (this->get will automatically set the _r variable with the value)
    this->get "$@"
    #if [ "$0" != "0" ]; then
    if [ "$_error" != "" ]; then
        _error="An error has ocurred when system trying to get a list element: $_error"
    fi

    #remove the element from the list
    this->remove "$@"
    if [ "$_error" != "" ]; then
        _error="An error has ocurred when system trying to delete a list element: $_error"
    fi
}

#scrolls over the list elements. A callback is called for each element and the 'data' and the 'id' fo the element is passed as arguments (respectively)
#argument callback: the callback that will be called with data and id of each element ( callback(data, id))

this->forEach(){ local this_callback="$1"; local _firstArgAsId_="$2"
    local currentElementId=$this->firstId
    local currentElementData=""
    local tmpNextElementId=""

    while [ "$currentElementId" != "" ]; do
        local argumentList=""

        #get the next element id before the callback, because the callback can remove the current element
        eval "tmpNextElementId=\"\$$currentElementId""->next\""

        eval "dataCount=\$$currentElementId""->dataCount"
        for i in $(seq 0 $(( dataCount-1 ))); do
            eval "local tmpData=\"\\\$$currentElementId""->data_$i\""
            argumentList="$argumentList \"$tmpData\""
        done

        #eval "echo \"argumentList: $argumentList\""
        if [ "$_firstArgAsId_" == "1" ]; then
            eval "$this_callback \"\$currentElementId\" $argumentList"
        else
            eval "$this_callback $argumentList"
        fi
        eval "currentElementId=\"\$tmpNextElementId\""
    done
}

this->backForEach(){ local this_callback="$1"; local _firstArgAsId_="$2"
    local currentElementId=$this->lastId
    local currentElementData=""
    local tmpPrevElementId=""

    while [ "$currentElementId" != "" ]; do
        local argumentList=""

        #get the previous element id before the callback, because the callback can remove the current element
        eval "tmpPrevElementId=\"\$$currentElementId""->prev\""

        eval "dataCount=\$$currentElementId""->dataCount"
        for i in $(seq 0 $(( dataCount-1 ))); do
            eval "local tmpData=\"\\\$$currentElementId""->data_$i\""
            argumentList="$argumentList \"$tmpData\""
        done

        if [ "$_firstArgAsId_" == "1" ]; then
            eval "$this_callback \"\$currentElementId\" $argumentList"
        else
            eval "$this_callback $argumentList"
        fi

        eval "currentElementId=\"\$tmpPrevElementId\""
    done
}

this->displaysMemory(){
    displaysObjecMemory "$this->name"
}

this->size(){
    echo $this->currentCount
    _r=$this->currentCount
}

this->getByIndex(){ local index=$1
    local currentElementId=$this->firstId
    local currentIndex=0

    while [ "$currentElementId" != "" ]; do
        if [ "$currentIndex" == "$index" ]; then
            this->get "$currentElementId"
            return $?
        fi

        currentIndex=$(( currentIndex+1 ))
        eval "currentElementId=\"\$$currentElementId""->next\""
    done

    _error="Index out of bounds"
    return 1
}

#returns a new list object
this->filter(){
    echo "not implemented yet"
}

#returns a new list object
this->map(){
    echo "not implemented yet"
}

this->reduce(){
    echo "not implemented yet"
}

#updates the data of an element
#receives the element id and a variable number of arguments that will be the new data
this->update(){ local id=$1
    #erase old data
    eval "local dataCount=\$$id""->dataCount"
    for i in $(seq 0 $(( dataCount-1 ))); do
        eval "unset $id""->data_$i"
    done

    shift
    local tmpCount=0
    for i in "$@"; do
        eval "$id""->data_$tmpCount=\"$i\""
        tmpCount=$(( tmpCount + 1 ))
    done
    eval "$id""->dataCount=$tmpCount"
}

##runTests(){
##
##    echo "list loaded"
##    echo "------------------------ [ insert first element (back)] ----------------------"
##    test->pushBack "test data" "test data aaa" "test data bbb"
##    element1Id=$_r
##    echo "newElementId: $element1Id"
##    test->forEach "echo"
##
##    echo "------------------------ [ insert second element (back)] ----------------------"
##    test->pushBack "test data 2"
##    test->forEach "echo"
##
##    echo "------------------------ [ insert third element (back)] ----------------------"
##    test->pushBack "test data 3"
##    test->forEach "echo"
##
##    echo "------------------------ [ insert forth element (after first) ] ----------------------"
##    test->putAfter "$element1Id" "test data 4"
##    test->forEach "echo"
##
##    echo "------------------------ [ insert fifth element (back) ] ----------------------"
##    test->pushBack "test data 5"
##    test->forEach "echo"
##
##    echo "------------------------ [ insert element 6 (front) ] ----------------------"
##    test->pushFront "test data 6 - front"
##    test->forEach "echo"
##
##    echo "------------------------ [ insert element 7 (front) ] ----------------------"
##    test->pushFront "test data 7 - front"
##    test->forEach "echo"
##
##    echo "------------------------ [ insert element 8 (back) ] ----------------------"
##    test->pushBack "test data 8"
##    test->forEach "echo"
##
##    echo "------------------------ [ all elements ] ----------------------"
##    test->forEach "echo"
##    echo "------------------------ [ all elemnts (reverse) ] ----------------------"
##    test->backForEach "echo"
##
##    echo "------------------------ [ remove element $element1Id ] ----------------------"
##    test->remove "$element1Id"
##    test->forEach "echo"
##
##    echo "------------------------ [ remove first element] ----------------------"
##    test->remove "$this->firstId"
##    test->forEach "echo"
##
##    echo "------------------------ [ remove last element] ----------------------"
##    test->remove "$this->lastId"
##    test->forEach "echo"
##
##}


