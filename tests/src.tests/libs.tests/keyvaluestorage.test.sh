#!/bin/bash

#test the keyvaluestorage.sh file

this->scriptLocation=$3
this->init(){ testsObject=$1;
    "$testsObject"->registerTest "keyvaluestorage: should fail if invalid dbMode is informed" "this->testInit"
    "$testsObject"->registerTest "keyvaluestorage: should fail if the path for db is not informed" "this->testInit2"
    "$testsObject"->registerTest "keyvaluestorage: should should create db folder" "this->testInit3"
    "$testsObject"->registerTest "keyvaluestorage: should should download pkv" "this->testInit4"

    "$testsObject"->registerTest "keyvaluestorage: shoud set data to a file" "this->testSetFile"
    "$testsObject"->registerTest "keyvaluestorage: shoud get data from a file" "this->testGetFile"
    "$testsObject"->registerTest "keyvaluestorage: shoud delete the data form a file" "this->testDeleteFile"

    "$testsObject"->registerTest "keyvaluestorage: shoud set data to a prefix tree" "this->testSetPkv"
    "$testsObject"->registerTest "keyvaluestorage: shoud get data from a prefix tree" "this->testGetPkv"
    "$testsObject"->registerTest "keyvaluestorage: shoud delete the data form a prefix tree" "this->testDeletePkv"
}

this->finalize(){
    (
        sleep 0.5
        rm -rf ./tmp >/dev/null 2>&1
    ) &
}

this->testInit(){
    new "keyvaluestorage.sh" kvs "/tmp/test1.db" "invalid_db_mode"
    local retCode=$?
    if [ "$retCode" -eq 0 ]; then
        _expected="<retCode != 0 and _error != \"\" >"
        _returned="retCode == $retCode and _error == \"$_error\""
        _returned="\"$_error\""
        return 1
    fi

    kvs->finalize
}

this->testInit2(){
    new "keyvaluestorage.sh" kvs "" "$SKVS_USE_FOLDER"
    local retCode=$?
    if [ "$retCode" -eq 0 ]; then
        _expected="<retCode != 0 and _error != \"\" >"
        _returned="retCode == $retCode and _error == \"$_error\""
        _error="Keyvaluestorage~>init did not fail when path for db was not informed"
        return 1
    fi

    kvs->finalize
}

this->testInit3(){
    new "keyvaluestorage" kvs "./tmp/tmpDbs/testInit3.db" "$SKVS_USE_FOLDER"
    if [ "$?" -ne 0 ]; then
        _error="Error initing keyvaluestorage (configured to use a folder as database): $_error"
        return 1
    fi

    if [ ! -d "./tmp/tmpDbs/testInit3.db" ]; then
        _error="Folder to be used as database (./tmp/tmpDbs/testInit3.db) was not created"
    fi
    return 0
}

this->testInit4(){
    rm -rf $HOME/.local/bin/pkv
    rm -rf /tmp/pkv

    new "keyvaluestorage" kvs "./tmp/tmpDbs/testInit4.db" "$SKVS_USE_PKV"
    destroy "kvs"
    if [ "$?" -ne 0 ]; then
        _error="Error initing keyvaluestorage (configured to use a folder as database): $_error"
        return 1
    fi
    sleep 1 #time to pkv have enough time to load and create the database file

    if [ ! -f "./tmp/tmpDbs/testInit4.db" ]; then
        _error="Prefix tree (./tmp/tmpDbs/testInit4.db) was not created"
        return 1
    fi
    return 0
}

this->testSetFile(){
    new "keyvaluestorage.sh" kvs "./tmp/tmpDbs/db1" "$SKVS_USE_FOLDER"
    kvs->set "thekey" "the value"
    kvs->finalize

    if [ -f "./tmp/tmpDbs/db1/thekey" ]; then
        if [ "$(cat ./tmp/tmpDbs/db1/thekey)" == "the value" ]; then
            return 0
        else
            _error="File content is not the expected"
            _expected="the value"
            _returned="$(cat ./tmp/tmpDbs/db1/thekey)"
            return 1
        fi
    else
        _error="File was not created"
        return 1
    fi

    _error="Unknown error"
    return 1
}

this->testGetFile(){
    new "keyvaluestorage.sh" kvs "./tmp/tmpDbs/db2" "$SKVS_USE_FOLDER"
    echo "the value 2" > ./tmp/tmpDbs/db2/thekey
    local value=$(kvs->get "thekey" "default value")
    kvs->finalize

    if [ "$value" == "the value 2" ]; then
        return 0
    else
        _error="Returned value is not the expected"
        _expected="the value 2"
        _returned="$value"
        return 1
    fi

    _error="Unknown error"
    return 1
}

this->testDeleteFile(){
    new "keyvaluestorage.sh" kvs "./tmp/tmpDbs/db3" "$SKVS_USE_FOLDER"
    kvs->set "thekey" "the value 3"
    kvs->delete "thekey"
    local value=$(kvs->get "thekey" "default value")
    kvs->finalize
    
    if [ ! -f "./tmp/tmpDbs/db3/thekey" ]; then
        if [ "$value" == "default value" ]; then
            return 0
        else
            _error="File was deleted but the value was not deleted"
            _expected="default value"
            _returned="$value"
            return 1
        fi
    else
        _error="File was not deleted"
        return 1
    fi

    _error="Unknown error"
    return 1

}

this->testSetPkv(){
    new "keyvaluestorage.sh" kvs2 "$(pwd)/tmp/tmpDbs/db4.db" "$SKVS_USE_PKV"
    kvs2->set "thekey" "the value"
    local pkvPath=$kvs2->_pkvPath
    destroy kvs2

    #use pkv to check the data in the prefixtree file
    if [ ! -f "$pkvPath" ]; then
        _error="Pkv command was not found"
        return 1
    fi
    _returned=$("$pkvPath" get thekey -f:$(pwd)/tmp/tmpDbs/db4.db)
    
    if [ "$_returned" == "the value" ]; then
        return 0
    else
        _error="File content is not the expected"
        _expected="the value"
        return 1
    fi

    _error="Unknown error"
    return 1
}

this->testGetPkv(){
    new "keyvaluestorage.sh" kvs3 "$(pwd)/tmp/tmpDbs/db5.db" "$SKVS_USE_PKV"
    kvs3->set "thekey" "the value 5"
    local value=$(kvs3->get "thekey" "default value")
    destroy kvs3

    if [ "$value" == "the value 5" ]; then
        return 0
    else
        _error="Returned value is not the expected"
        _expected="the value 5"
        _returned="$value"
        return 1
    fi

    _error="Unknown error"
    return 1
}

this->testDeletePkv(){
    new "keyvaluestorage.sh" kvs4 "$(pwd)/tmp/tmpDbs/db6.db" "$SKVS_USE_PKV"
    kvs4->set "thekey" "the value 6"
    kvs4->delete "thekey"

    local value=$(kvs4->get "thekey" "default value")
    destroy kvs4
    if [ "$value" == "default value" ]; then
        return 0
    else
        _error="Returned value is not the expected"
        _expected="default value"
        _returned="$value"
        return 1
    fi
}
