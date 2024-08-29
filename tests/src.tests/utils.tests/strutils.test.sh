#!/bin/bash

#test the sharedmemory.sh file

this->scriptLocation=$3
this->init(){ testsObject=$1;
    "$testsObject"->registerTest "strutils: getOnly should return only valid chars" "this->testGetOnly"
    "$testsObject"->registerTest "strutils: getOnly_2 should return only valid chars" "this->getOnly_2"
    "$testsObject"->registerTest "strutils: replace should replace all ocurrences of a string" "this->testReplace"
    "$testsObject"->registerTest "strutils: replace_2 should replace all ocurrences of a string" "this->replace_2"
    "$testsObject"->registerTest "strutils: replaceSeq should replace all placeholds with a string" "this->testReplaceSeq"
    "$testsObject"->registerTest "strutils: replaceSeq_2 should replace all placeholders with a string" "this->testReplaceSeq_2"
    "$testsObject"->registerTest "strutils: cut should return the first part of a string" "this->cut"
    "$testsObject"->registerTest "strutils: cut_2 should return the first part of a string" "this->cut_2"
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
    autoinit=0; new "strutils" su
    local result=$(su->getOnly "abc123" "123")
    if [ "$result" != "123" ]; then
        _error="getOnly did not return the expected result"
        return 1
    fi
    return 0
}

this->getOnly_2(){
    autoinit=0; new "strutils" su
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
    autoinit=0; new "strutils" su
    local desired="normal word, replaced word, normal word, replaced word"
    
    local result=$(su->replace "normal word, %%, normal word, %%" "%%" "replaced word")

    if [ "$result" != "$desired" ]; then
        _error="replace did not return the expected result. Expected: $desired, got: $result"tashed changes
        _expected="$desired"
        _returned="$result"
        return 1
    fi
    return 0
}

#use echo instead _r
this->replace_2(){
    autoinit=0; new "strutils" su
    local desired="normal word, replaced word, normal word, replaced word"
    su->replace_2 "normal word, %%, normal word, %%" "%%" "replaced word"
    result=$_r

    if [ "$result" != "$desired" ]; then
        _error="replace_2 did not return the expected result. Expected: $desired, got: $result"
        _expected="$desired"
        _returned="$result"
        return 1
    fi
    return 0
}

this->testReplaceSeq(){ 
    autoinit=0; new "strutils" su
    local expected="the key is key and key is value"
    local result=$(su->replaceSeq "%%" "the key is %% and key is %%" "key" "value")

    if [ "$result" != "$expected" ]; then
        _error="replaceSeq did not return the expected result. Expected: $expected, got: $result"Stashed changes
        return 1
    fi
    return 0
}

this->testReplaceSeq_2(){ 
    autoinit=0; new "strutils" su
    local expected="the key is key and key is value"
    su->replaceSeq_2 "%%" "the key is %% and key is %%" "key" "value"
    result=$_r

    if [ "$result" != "$expected" ]; then
        _error="replaceSeq_2 did not return the expected result. Expected: $expected, got: $result"
        return 1
    fi
    return 0
}

this->cut(){ 
    #local source=$1; local separator=$2; local p1_p2=$3
    autoinit=0; new "strutils" su
    local result=$(su->cut "key=value" "=" 1)
    if [ "$result" != "key" ]; then
        _error="cut did not return the expected result"
        return 1
    fi
}

#use echo instead _r
this->cut_2(){
    autoinit=0; new "strutils" su
    su->cut_2 "key=value" "=" 1
    result=$_r
    if [ "$result" != "key" ]; then
        _error="cut did not return the expected result"
        return 1
    fi
    return 0
}
