#!/bin/bash

#test the list.sh file

this->init(){ testsObject=$1;
    "$testsObject"->registerTest "List~>push: should add items in the front" "this->testPushFront"
    "$testsObject"->registerTest "List~>pushBack: should add items in the back" "this->testPushBack"
    "$testsObject"->registerTest "List~>getByIndex: gets an element using its index (do not remove)" "this->testGetByIndex"
    "$testsObject"->registerTest "List~>get: gets an element using its id (do not remove)" "this->testGet"
    "$testsObject"->registerTest "List~>putAfter: should put items after another one" "this->testPutAfter"
    "$testsObject"->registerTest "List~>putBefore: should put items before another one" "this->testPutBefore"
    "$testsObject"->registerTest "List~>update: should update the data of an items" "this->testUpdate"
    "$testsObject"->registerTest "List~>size: should return the list size" "this->size"

    "$testsObject"->registerTest "List~>getFront: should return the item at front (do not remove)" "this->getFront"
    "$testsObject"->registerTest "List~>getBack: should return the item at back (do not remove)" "this->getBack"

    "$testsObject"->registerTest "List~>remove: should remove an item(uses its id)" "this->remove"
    "$testsObject"->registerTest "List~>removeFront: should remove the first item" "this->removeFront"
    "$testsObject"->registerTest "List~>removeBack: should remove the last item" "this->removeBack"

    "$testsObject"->registerTest "List~>pop: should return and remove an item(uses its id)" "this->pop"
    "$testsObject"->registerTest "List~>popFront: should return and remove the first item" "this->popFront"
    "$testsObject"->registerTest "List~>popBack: should reurn and remove the last item" "this->popBack"

    "$testsObject"->registerTest "List~>forEach: should iterate over the list" "this->forEach"
    "$testsObject"->registerTest "List~>backForEach: should iterate over the list in reverse" "this->backForEach"
}

this->finalize(){
    :;
}


this->testPushFront(){
    new libs/list list
    list->pushFront "test data" "test data aaa" "test data bbb"
    _received=$_r
    finalize list
    if [ "$received" != "" ]; then
        _error="push failed"
        _expected=" != \"\""
        return 1
    fi

    return 0
}

this->testPushBack(){
    new libs/list list
    list->pushBack "test data" "test data aaa" "test data bbb"
    _received=$_r
    finalize list
    if [ "$received" != "" ]; then
        _error="push failed"
        _expected=" != \"\""
        return 1
    fi

    return 0
}

this->testGetByIndex(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    list->getByIndex "3"
    local dataCount="${#_r[@]}"

    if [ "$dataCount" != "1" ]; then
        _error="getByIndex failed. Get returned an invalid data count"
        _expected="1"
        _received="$dataCount"
        return 1
    fi

    local theData="${_r[1]}"
    if [ "$theData" != "44444" ]; then
        _error="getByIndex failed. Get returned an invalid data"
        _expected="44444"
        _received="$theData"
        return 1
    fi

    return 0
}

this->testGet(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r

    list->get "$id2"
    local dataCount="${#_r[@]}"

    if [ "$dataCount" != "1" ]; then
        _error="get failed. Get returned an invalid data count"
        _expected="1"
        _received="$dataCount"
        return 1
    fi

    local theData="${_r[1]}"
    if [ "$theData" != "22222" ]; then
        _error="get failed. Get returned an invalid data"
        _expected="22222"
        _received="$theData"
        return 1
    fi

    return 0
}

this->testPutAfter(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    list->putAfter "$id3" "77777"

    list->getByIndex "3"
    local dataCount="${#_r[@]}"

    local theData="${_r[1]}"
    if [ "$theData" != "77777" ]; then
        _error="putAfter failed. Get returned an invalid data"
        _expected="77777"
        _received="$theData"
        return 1
    fi

    return 0
}

this->testPutBefore(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    list->putBefore "$id3" "77777"

    list->getByIndex "2"

    local theData="${_r[1]}"
    if [ "$theData" != "77777" ]; then
        _error="putBefore failed. Get returned an invalid data"
        _expected="77777"
        _received="$theData"
        return 1
    fi

    return 0
}

this->testUpdate(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    list->update "$id3" "88888"

    list->get "$id3"

    local theData="${_r[1]}"
    if [ "$theData" != "88888" ]; then
        _error="update failed. Get returned an invalid data"
        _expected="88888"
        _received="$theData"
        return 1
    fi

    return 0
}

this->size(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    local size=$(list->size)

    if [ "$size" != "6" ]; then
        _error="The did not returned the right size"
        _expected="6"
        _received="$size"
        return 1
    fi

    return 0
}

this->getFront(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    list->getFront
    local theData="${_r[1]}"

    if [ "$theData" != "11111" ]; then
        _error="getFront returned an invalid data"
        _expected="11111"
        _received="$theData"
        return 1
    fi

    #repeat the getFront call. Result should be the same
    list->getFront
    local theData="${_r[1]}"
    if [ "$theData" != "11111" ]; then
        _error="getFront removed the first element"
        _expected="11111"
        _received="$theData"
        return 1
    fi

    local size=$(list->size)
    
    if [ "$size" != "6" ]; then
        _error="getFront removed something from the list (but first element is intact)"
        _expected="6"
        _received="$size"
        return 1
    fi

    return 0
}

this->getBack(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    list->getBack
    local theData="${_r[1]}"

    if [ "$theData" != "66666" ]; then
        _error="getBack returned an invalid data"
        _expected="66666"
        _received="$theData"
        return 1
    fi

    #repeat the getBack call. Result should be the same
    list->getBack
    local theData="${_r[1]}"
    if [ "$theData" != "66666" ]; then
        _error="getBack removed the last element"
        _expected="66666"
        _received="$theData"
        return 1
    fi

    local size=$(list->size)

    if [ "$size" != "6" ]; then
        _error="getBack removed something from the list (but last element is intact)"
        _expected="6"
        _received="$size"
        return 1
    fi

    return 0
}

this->remove(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    list->remove "$id3"

    list->size >/dev/null
    local size="$_r"

    if [ "$size" != "5" ]; then
        _error="remove failed. The size is invalid"
        _expected="5"
        _received="$size"
        return 1
    fi

    list->get "$id3"
    local redCode=$?
    
    if [ "$retCode" == "0" ]; then
        _error="remove failed. Get does not return an error after the remove"
        _expected="retcode != 0"
        _received="retcode ==$retCode"
        return 1
    fi

    return 0
}

this->removeFront(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    list->removeFront

    list->size > /dev/null
    local size="$_r"

    if [ "$size" != "5" ]; then
        _error="removeFront failed. The size is invalid"
        _expected="5"
        _received="$size"
        return 1
    fi

    list->getFront
    local theData="${_r[1]}"
    
    if [ "$theData" != "22222" ]; then
        _error="removeFront failed. The data is invalid"
        _expected="22222"
        _received="$theData"
        return 1
    fi

    return 0
}

this->removeBack(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    list->removeBack

    list->size >/dev/null
    local size="$_r"

    if [ "$size" != "5" ]; then
        _error="removeBack failed. The size is invalid"
        _expected="5"
        _received="$size"
        return 1
    fi

    list->getBack
    local theData="${_r[1]}"
    
    if [ "$theData" != "55555" ]; then
        _error="removeBack failed. The data is invalid"
        _expected="55555"
        _received="$theData"
        return 1
    fi

    return 0
}

this->pop(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    list->pop "$id3"
    local theData="${_r[1]}"

    list->size >/dev/null
    local size="$_r"

    if [ "$size" != "5" ]; then
        _error="The new size is invalid"
        _expected="5"
        _received="$size"
        return 1
    fi
    
    if [ "$theData" != "33333" ]; then
        _error="Data was not returned correctly"
        _expected="33333"
        _received="$theData"
        return 1
    fi


    list->get "$id3"
    local retCode=$?
    local dataCount="$_r"
    
    if [ "retCode" == "0" ]; then
        _error="Element was not removed"
        _expected="function exit code != 0"
        _received="$retCode"
        return 1
    fi

    if [ "$_error" == "" ]; then
        _error="get operations does not return an error"
        return 1
    fi

    return 0
}

this->popFront(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    list->popFront
    local theData="${_r[1]}"

    list->size >/dev/null
    local size="$_r"

    if [ "$size" != "5" ]; then
        _error="The new size is invalid"
        _expected="5"
        _received="$size"
        return 1
    fi
    
    if [ "$theData" != "11111" ]; then
        _error="Data was not returned correctly"
        _expected="11111"
        _received="$theData"
        return 1
    fi

    list->get "$id1"
    local retCode=$?
    
    if [ "$recCode" == "0" ]; then
        _error="Element was not removed"
        _expected="retCode != 0"
        return 1
    fi

    if [ "$_error" == "" ]; then
        _error="get operations does not return an error"
        return 1
    fi

    return 0
}

this->popBack(){
    new libs/list list
    list->pushBack "11111"
    local id1=$_r
    list->pushBack "22222"
    local id2=$_r
    list->pushBack "33333"
    local id3=$_r
    list->pushBack "44444"
    local id4=$_r
    list->pushBack "55555"
    local id5=$_r
    list->pushBack "66666"
    local id6=$_r

    list->popBack
    local theData="${_r[1]}"

    list->size >/dev/null
    local size="$_r"

    if [ "$size" != "5" ]; then
        _error="The new size is invalid"
        _expected="5"
        _received="$size"
        return 1
    fi
    
    if [ "$theData" != "66666" ]; then
        _error="Data was not returned correctly"
        _expected="66666"
        _received="$theData"
        return 1
    fi

    list->get "$id6"
    local retCode=$?
    
    if [ "$recCode" == "0" ]; then
        _error="Element was not removed"
        _expected="retCode != 0"
        return 1
    fi

    if [ "$_error" == "" ]; then
        _error="get operations does not return an error"
        return 1
    fi

    return 0
}

this->forEach(){
    #insert elements and check if they are iterated in the right order
    new libs/list list
    list->pushBack "1"
    list->pushBack "2"
    list->pushBack "3"
    list->pushBack "4"
    list->pushBack "5"

    local tmp=""
    list->forEach "__f(){
        tmp=\"\$tmp \$1\"
    }; __f"

    if [ "$tmp" != " 1 2 3 4 5" ]; then
        _error="forEach failed"
        _expected="1 2 3 4 5"
        _received="$tmp"
        return 1
    fi
    
}

this->backForEach(){
    #insert elements and check if they are iterated in the right order
    new libs/list list
    list->pushBack "1"
    list->pushBack "2"
    list->pushBack "3"
    list->pushBack "4"
    list->pushBack "5"

    local tmp=""
    list->backForEach "__f(){
        tmp=\"\$tmp \$1\"
    }; __f"

    if [ "$tmp" != " 5 4 3 2 1" ]; then
        _error="backForEach failed"
        _expected="5 4 3 2 1"
        _received="$tmp"
        return 1
    fi
}
