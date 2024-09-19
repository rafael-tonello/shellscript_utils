#!/bin/bash

#test the list.sh file

this->init(){ testsObject=$1;
    "$testsObject"->registerTest "List~>push: should add items in the front" "this->testPush"
    "$testsObject"->registerTest "List~>pushBack: should add items in the back" "this->testPushBack"
    "$testsObject"->registerTest "List~>putAfter: should put items after another one" "this->testPutAfter"
    "$testsObject"->registerTest "List~>putBefore: should put items before another one" "this->testPutBefore"
    "$testsObject"->registerTest "List~>update: should update the data of an items" "this->update"
    "$testsObject"->registerTest "List~>size: should return the list size" "this->size"

    "$testsObject"->registerTest "List~>get: gets an element using its id (do not remove)" "this->get"
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



}

this->finalize(){

}


this->testPush(){
    _error="not implemented"
    return 1
    :;
}

this->testPushBack(){
    _error="not implemented"
    return 1
    :;
}

this->testPutAfter(){
    _error="not implemented"
    return 1
    :;
}

this->testPutBefore(){
    _error="not implemented"
    return 1
    :;
}

this->update(){
    _error="not implemented"
    return 1
    :;
}

this->size(){
    _error="not implemented"
    return 1
    :;
}

this->get(){
    _error="not implemented"
    return 1
    :;
}

this->getFront(){
    _error="not implemented"
    return 1
    :;
}

this->getBack(){
    _error="not implemented"
    return 1
    :;
}

this->remove(){
    _error="not implemented"
    return 1
    :;
}

this->removeFront(){
    _error="not implemented"
    return 1
    :;
}

this->removeBack(){
    _error="not implemented"
    return 1
    :;
}

this->pop(){
    _error="not implemented"
    return 1
    :;
}

this->popFront(){
    _error="not implemented"
    return 1
    :;
}

this->popBack(){
    _error="not implemented"
    return 1
    :;
}

this->forEach(){
    _error="not implemented"
    return 1
    :;
}

this->backForEach(){
    _error="not implemented"
    return 1
    :;
}
