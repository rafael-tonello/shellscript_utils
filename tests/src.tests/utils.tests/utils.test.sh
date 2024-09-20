#!/bin/bash

#test the sharedmemory.sh file

this->scriptLocation=$3

this->init(){ testsObject=$1;
    "$testsObject"->registerTest "utils: interceptCommandStdout should invoke lambda for stdout lines" "this->testInterceptCommandStdout"
    "$testsObject"->registerTest "utils: runCommandAndGetOutput should return a command stdout" "this->testRunCommandAndGetOutput"
    "$testsObject"->registerTest "utils: copyVars should copy all variables" "this->testCopyVars"
    "$testsObject"->registerTest "utils: copyFunctions should copy all functions" "this->testCopyFunctions"
    "$testsObject"->registerTest "utils: cloneObject should copy all functions and variables" "this->testCloneObject"

    
    #this->derivateError(){ local existingError="$1"; local newError="$2"
    #this->derivateError2(){ local newError="$1"; local existingError="$2"
    #this->getArgV(){ local varName="$1"; 
}

this->finalize(){
    :;
}


this->testInterceptCommandStdout(){
    new "utils/utils.sh" utils
    rm /tmp/aa.txt >> /dev/null 2>&1
    _expected="text1text2text3"
    rm /tmp/testInterceptCommandStdout.txt >/dev/null 2>&1
    utils->interceptCommandStdout "echo 'text1'; echo 'text2'; echo 'text3'" "__f(){
        echo -n \"\$1\" >> /tmp/testInterceptCommandStdout.txt
    }; __f"

    _returned=$(cat /tmp/testInterceptCommandStdout.txt)
    rm /tmp/aa.txt >> /dev/null 2>&1

    if [ "$_returned" != "$_expected" ]; then
        _error="interceptCommandStdout did not invoke the lambda for each line"
        return 1
    fi

    return 0
}

this->testRunCommandAndGetOutput(){
    new "utils/utils.sh" utils
    _expected="text1text2text3"
    utils->runCommandAndGetOutput "__f(){ echo -n 'text1'; echo -n 'text2'; echo -n 'text3'; }; __f"
    _returned="$_r"
    if [ "$_returned" != "$_expected" ]; then
        _error="runCommandAndGetOutput did not return the expected output"
        return 1
    fi

    return 0
}

this->testCopyVars(){
    new "utils/utils.sh" utils

    #create a temporary class file
    local destFile="/tmp/testCopyVars.sh"
    echo "#!/bin/bash" > "$destFile"
    echo "self->init(){ self->testProperty=\"testPropertyValue\"; }" >> "$destFile"
    echo "self->testProperty2=\"testPropertyValue2\"" >> "$destFile"
    echo "self->finalize(){ :; }" >> "$destFile"
    echo "self->testMethod(){ echo \"testMethod\"; }" >> "$destFile"

    context=self; new_f "$destFile" "tmpObject"

    #copy the variables
    utils->copyVars "tmpObject" "tmpObject2"

    rm "$destFile" > /dev/null 2>&1

    #check if the variables were copied
    if [ "$tmpObject2->testProperty" != "testPropertyValue" ]; then
        _error="copyVars did not copy the variables"
        return 1
    fi

    if [ "$tmpObject2->testProperty2" != "testPropertyValue2" ]; then
        _error="copyVars did not copy the variables"
        return 1
    fi

    return 0
}

this->testCopyFunctions(){
    new "utils/utils.sh" utils

    #create a temporary class file
    local destFile="/tmp/testCopyFunctions.sh"
    echo "#!/bin/bash" > "$destFile"
    echo "self->init(){ self->testProperty=\"testPropertyValue\"; }" >> "$destFile"
    echo "self->testProperty2=\"testPropertyValue2\"" >> "$destFile"
    echo "self->finalize(){ :; }" >> "$destFile"
    echo "self->testMethod(){ echo \"testMethod\"; }" >> "$destFile"
    echo "self->testMethod2(){ echo \"testMethod2\"; }" >> "$destFile"

    context=self; new_f "$destFile" "tmpObject"

    #copy the functions
    utils->copyFunctions "tmpObject" "tmpObject2"

    rm "$destFile" > /dev/null 2>&1

    #check if the functions were copied
    local tmp=$(tmpObject2->testMethod)
    if [ "$tmp" != "testMethod" ]; then
        _error="copyFunctions did not copy the functions"
        return 1
    fi

    local tmp=$(tmpObject2->testMethod2)
    if [ "$tmp" != "testMethod2" ]; then
        _error="copyFunctions did not copy the functions"
        return 1
    fi

    return 0
}

this->testCloneObject(){
    new "utils/utils.sh" utils

    #create a temporary class file
    local destFile="/tmp/testCloneObject.sh"
    echo "#!/bin/bash" > "$destFile"
    echo "self->init(){ self->testProperty=\"testPropertyValue\"; }" >> "$destFile"
    echo "self->testProperty2=\"testPropertyValue2\"" >> "$destFile"
    echo "self->finalize(){ :; }" >> "$destFile"
    echo "self->testMethod(){ echo \"testMethod\"; }" >> "$destFile"
    echo "self->testMethod2(){ echo \"testMethod2\"; }" >> "$destFile"

    context=self; new_f "$destFile" "tmpObject"

    #copy the functions
    utils->cloneObject "tmpObject" "tmpObject2"

    rm "$destFile" > /dev/null 2>&1

    #check if the functions were copied
    local tmp=$(tmpObject2->testMethod)
    if [ "$tmp" != "testMethod" ]; then
        _error="cloneObject did not copy the functions"
        return 1
    fi

    local tmp=$(tmpObject2->testMethod2)
    if [ "$tmp" != "testMethod2" ]; then
        _error="cloneObject did not copy the functions"
        return 1
    fi

    #check if the variables were copied
    if [ "$tmpObject2->testProperty" != "testPropertyValue" ]; then
        _error="cloneObject did not copy the variables"
        return 1
    fi

    if [ "$tmpObject2->testProperty2" != "testPropertyValue2" ]; then
        _error="cloneObject did not copy the variables"
        return 1
    fi

    return 0
}