#!/bin/bash

#test the new.sh file

this->scriptLocation=$3
this->init(){ testsObject=$1;
    "$testsObject"->registerTest "new.sh: import_webfile showuld make a remote file available for 'new' instances" "this->testWebImport"
}

this->finalize(){
    :;
}

this->testWebImport(){
    mkdir -p "/tmp/testWebImport"
    this->_writeShClassFile "/tmp/testWebImport/testWebImport.sh"
    this->_startPython3Server "/tmp/testWebImport" 8000 >> /dev/null

    import_webFile "http://localhost:8000/testWebImport.sh" 2>/tmp/testWebImport/error.cerr
    if [ "$?" != "0" ]; then
        _error=$(cat /tmp/testWebImport/error.cerr)
        if [ "$_error" == "" ]; then
            _error="import_webFile did not return 0 (unknown error)"
        fi

        _error="import_webFile error: $_error"
        return 1
    fi
    
    context=self; new "testWebImport" twi

    if [ "$twi->testProperty" != "testPropertyValue" ]; then
        _error="testProperty was not set correctly"
        return 1
    fi

    local testeMethodValue=$(twi->testMethod)
    if [ "$testeMethodValue" != "testMethod" ]; then
        _error="testMethod did not return the expected value"
        return 1
    fi

    this->_killPython3Server

    return 0
}

this->_writeShClassFile(){ local destFile="$1"
    echo "#!/bin/bash" > "$destFile"
    echo "self->init(){ self->testProperty=\"testPropertyValue\"; }" >> "$destFile"
    echo "self->finalize(){ :; }" >> "$destFile"
    echo "self->testMethod(){ echo \"testMethod\"; }" >> "$destFile"

    scan_folder_for_classes $(dirname "$destFile")
    return 0;
}

this->_startPython3Server(){ local folder="$1"; local port="$2"
    python3 -m http.server $port --directory "$folder" 2>/dev/null &
    sleep 1
    return 0
}

this->_killPython3Server(){
    pkill -f "python3 -m http.server"
    return 0
}