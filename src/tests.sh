#!/bin/bash
#a library for make tests for your bash projects. You need to specify a sharedMemory name to be used as a namespace for the tests
#
#test functions can use _error (to return error messages)
#test functions can use _message (to return a free message, for help purposes)
#test functions can use _expected (to inform a expected value, for help purposes)
#test functions can use _returned (to return a returned value, for help purposes)

#Examples
#   Basic example
#       new_f "tests.sh" __tests__ "" 1 "myTests"
#       __tests__->registerTest "test1" "echo 1"
#       __tests__->registerTest "test2" "echo 2"
#       __tests__->runTests
#       __tests__->showTestResults

#   Calling directly the function setTestResult to set a test results. In this case, you do not need to
#   register the test before (but you need to run the test by yourself).
#       new_f "tests.sh" __tests__ "" 1 "myTests"
#       __tests__->setTestResult "test1" 0 "test1 passed"
#       __tests__->setTestResult "test2" 1 "test2 failed"
#       __tests__->showTestResults

this->scriptLocation=$3
this->init(){ local namespace=$1;
    this->_namespace=$namespace
    new_f "$this->scriptLocation/sharedmemory.sh" this->vars "" 1 "$namespace"
    new_f "$this->scriptLocation/utils/utils.sh" this->utils
    
    local initialCount=$(this->vars->getVar "__tests.count")

    if [ "$initialCount" == "" ]; then
        this->vars->setVar "__tests.count" 0
    fi
}

#no code yet
this->finalize(){
    this->vars->finalize 1
}

this->cleanAndPrepare(){
    this->vars->setVar "__tests.count" 0
}

#set the test name, result code and a optional message. This tests are stored in a list in the shared memory to be recovered later
this->setTestResult(){ local testName=$1; local resultCode=$2; local errorMessage=$3; expected=$4; returned=$5; local message=$6;
    local index=-1

    local fixedName=$(this->_fixName "$testName")
    index=$(this->vars->getVar "__tests.$fixedName.index")

    if [ "$index" == "" ]; then
        #register a new test, but withtout testFunction
        index=$(this->vars->getVar "__tests.count")
        this->vars->setVar "__tests.count" $((index+1))
        this->vars->setVar "__tests.$index.testFunction" ":;"

        this->vars->setVar "__tests.$fixedName.index" $index
    fi


    this->vars->setVar "__tests.$index.name" "$testName"
    this->vars->setVar "__tests.$index.resultCode" "$resultCode"
    this->vars->setVar "__tests.$index.message" "$message"
    this->vars->setVar "__tests.$index.expected" "$expected"
    this->vars->setVar "__tests.$index.returned" "$returned"
    this->vars->setVar "__tests.$index.errorMessage" "$errorMessage"
}

#register a test to be runned by the runTests function
this->registerTest(){ local testName=$1; local testFunction=$2;
    local count=$(this->vars->getVar "__tests.count")
    
    this->vars->setVar "__tests.$count.name" "$testName"
    this->vars->setVar "__tests.$count.testFunction" "$testFunction"
    this->vars->setVar "__tests.count" $((count+1))

    local fixedName=$(this->_fixName "$testName")
    this->vars->setVar "__tests.$fixedName.index" $count
}

#run all tests registered by the registerTest function. For each test, the result is 
#registered by the setTestResult function. Returns the error count
this->runTests(){
    local count=$(this->vars->getVar "__tests.count")
    local errorCount=0
    for i in $(seq 0 $((count-1))); do
        local testName=$(this->vars->getVar "__tests.$i.name")
        local testFunction=$(this->vars->getVar "__tests.$i.testFunction")

        _error=""
        _r=""
        _expected=""
        _returned=""
        _message=""

        local currTestNumber=$((i+1))
        printf "Running test ($currTestNumber/$count): $(this->utils->makeupPrint "$testName" "" 1)... "
        eval "$testFunction"
        errorCode=$?

        if [ $errorCode -eq 0 ]; then
            this->utils->makeupPrint "Sucess" "lightgreen"
            #check for _r
            #if [ ! -z "$_r" ]; then
            #    printf ": $_r"
            #fi
            printf "\n"
        else
            this->utils->makeupPrint "Failed" "lightred"
            #check for error message
            if [ -z "$_error" ]; then
                _error="Unknown error"
            fi
            this->utils->makeupPrint ": $_error" "red"
            printf "\n"
            errorCount=$((errorCount+1))
        fi

        this->setTestResult "$testName" "$errorCode" "$_error" "$_expected" "$_returned" "$_message"

        #echo ""
    done
    return $errorCount
}

this->getRegisteredTestsCount(){
    local count=$(this->vars->getVar "__tests.count")
    echo $count
}

this->getNamespace(){
    echo $this->_namespace
}

#a function to show the test results
this->showTestResults(){
    local count=$(this->vars->getVar "__tests.count")
    for i in $(seq 0 $((count-1))); do
        local testName=$(this->vars->getVar "__tests.$i.name")
        local resultCode=$(this->vars->getVar "__tests.$i.resultCode")
        local message=$(this->vars->getVar "__tests.$i.message")
        local expected=$(this->vars->getVar "__tests.$i.expected")
        local returned=$(this->vars->getVar "__tests.$i.returned")
        local errorMessage=$(this->vars->getVar "__tests.$i.errorMessage")

        printf "[ Test: $testName ]\n"

        if [ ! -z "$message" ]; then
            printf "  Message: $message\n"
        fi

        if [ "$resultCode" -eq "0" ]; then
            this->utils->makeupPrint "  Sucess\n" "lightgreen"
        else
            this->utils->makeupPrint "  Failed\n" "lightred"
        fi

        if [ ! -z "$expected" ]; then
            printf "  Expected: $expected\n"
        fi

        if [ ! -z "$returned" ]; then
            printf "  Returned: $returned\n"
        fi

        if [ ! -z "$errorMessage" ]; then
            printf "  Error: "
            this->utils->makeupPrint "$errorMessage\n" "red"
        fi
        
        echo ""
    done

    this->showSumarizedTestResults
}

this->showSumarizedTestResults(){
    local count=$(this->vars->getVar "__tests.count")
    local errorCount=0
    for i in $(seq 0 $((count-1))); do
        local testName=$(this->vars->getVar "__tests.$i.name")
        local resultCode=$(this->vars->getVar "__tests.$i.resultCode")
        local message=$(this->vars->getVar "__tests.$i.message")

        if [ "$resultCode" -ne "0" ]; then
            errorCount=$((errorCount+1))
        fi
    done

    echo "Total tests: $count"
    echo "Sucess count: $((count-errorCount))"
    echo "Error count: $errorCount"
}

this->_fixName(){ local name=$1;
    echo $(echo $name | sed 's/[^a-zA-Z0-9]/_/g')
}


