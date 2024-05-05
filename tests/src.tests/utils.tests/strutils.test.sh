#!/bin/bash

#test the sharedmemory.sh file

this->scriptLocation=$3
this->init(){ testsObject=$1;
    "$testsObject"->registerTest "getOnly should return only valid chars" "this->testGetOnly"
    "$testsObject"->registerTest "getOnly_2 should return only valid chars" "this->getOnly_2"
    "$testsObject"->registerTest "replace should replace all ocurrences of a string" "this->testReplace"
    "$testsObject"->registerTest "replace_2 should replace all ocurrences of a string" "this->replace_2"
    "$testsObject"->registerTest "cut should return the first part of a string" "this->cut"
    "$testsObject"->registerTest "cut_2 should return the first part of a string" "this->cut_2"
}

this->finalize(){
    :;
}


#!/bin/bash
if [ "$1" != "new" ]; then >&2 echo "This must be included through the 'new_f' function in the file 'new.sh' (of shellscript_utils)"; exit 1; fi

#getOnly(source, [validChars])
#   for a given 'source' a new string will be generate with only letters of 'source' that are in 'validChars'.
#   if 'validChars was not provided, an internal string will be used ("abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPQRSTUVXYWZ0123456789_")'
this->testGetOnly(){
    new "strutils" su
    local result=$(su->getOnly "abc123" "123")
    if [ "$result" != "123" ]; then
        _error="getOnly did not return the expected result"
        return 1
    fi
    return 0
}

this->getOnly_2(){
    new "strutils" su
    su->getOnly_2 "def45678" "456"
    result=$_r
    if [ "$result" != "456" ]; then
        _error="getOnly did not return the expected result"
        return 1
    fi
    return 0
}

#replaces all ocureneces of 'every' in 'in' with  each one remain function arguments
#example: replace "%%" "the key is %% and key is %%" "key" "value" -> "the key is key and key is value
this->testReplace(){ 
    new "strutils" su
    local result=$(su->replace "%%" "the key is %% and key is %%" "key" "value")
    if [ "$result" != "the key is key and key is value" ]; then
        _error="replace did not return the expected result"
        return 1
    fi
    return 0
}

#use echo instead _r
this->replace_2(){
    new "strutils" su
    su->replace_2 "%%" "the key is %% and key is %%" "key" "value"
    result=$_r
    if [ "$result" != "the key is key and key is value" ]; then
        _error="replace did not return the expected result"
        return 1
    fi
    return 0
}


this->cut(){ 
    #local source=$1; local separator=$2; local p1_p2=$3
    new "strutils" su
    local result=$(su->cut "key=value" "=" 1)
    if [ "$result" != "key" ]; then
        _error="cut did not return the expected result"
        return 1
    fi
}

#use echo instead _r
this->cut_2(){
    new "strutils" su
    su->cut_2 "key=value" "=" 1
    result=$_r
    if [ "$result" != "key" ]; then
        _error="cut did not return the expected result"
        return 1
    fi
    return 0
}
