#!/bin/bash
#a library for make tests for your bash projects. You need to specify a sharedMemory name to be used as a namespace for the tests
#
#test functions can use _error (to return error messages)

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
    new_f "$this->scriptLocation/sharedmemory.sh" this->vars "" 1 "$namespace"
}

#no code yet
this->finalize(){ :; }

this->cleanAndPrepare(){
    this->vars->setVar "__tests.count" 0
}

#set the test name, result code and a optional message. This tests are stored in a list in the shared memory to be recovered later
this->setTestResult(){ local testName=$1; local result=$2; local message=$3;
    local count=$(this->vars->getVarC "__tests.count")
    this->vars->setVar "__tests.$count.name" "$testName"
    this->vars->setVar "__tests.$count.result" "$result"
    this->vars->setVar "__tests.$count.message" "$message"
    this->vars->setVar "__tests.count" $((count+1))
}

#register a test to be runned by the runTests function
this->registerTest(){ local testName=$1; local testFunction=$2;
    local count=$(this->vars->getVarC "__tests.count")
    this->vars->setVar "__tests.$count.name" "$testName"
    this->vars->setVar "__tests.$count.testFunction" "$testFunction"
    this->vars->setVar "__tests.count" $((count+1))
}

#run all tests registered by the registerTest function. For each test, the result is 
#registered by the setTestResult function. Returns the error count
this->runTests(){
    local count=$(this->vars->getVarC "__tests.count")
    local errorCount=0
    for i in $(seq 0 $((count-1))); do
        local testName=$(this->vars->getVarC "__tests.$i.name")
        local testFunction=$(this->vars->getVarC "__tests.$i.testFunction")

        _error=""
        _r=""

        printf "Running test: $testName... "
        $testFunction
        errorCode=$?

        if [ $errorCode -eq 0 ]; then
            printf "Sucess"
            #check for _r
            #if [ ! -z "$_r" ]; then
            #    printf ": $_r"
            #fi
            printf "\n"
        else
            printf "Failed"
            #check for error message
            if [ ! -z "$_error" ]; then
                printf ": $_error"
            fi
            printf "\n"
            errorCount=$((errorCount+1))
        fi

        this->setTestResult "$testName" "$errorCode" "$_error"
    done
    return $errorCount
}

#a function to show the test results
this->showTestResults(){
    local count=$(this->vars->getVarC "__tests.count")
    for i in $(seq 0 $((count-1))); do
        local testName=$(this->vars->getVarC "__tests.$i.name")
        local result=$(this->vars->getVarC "__tests.$i.result")
        local message=$(this->vars->getVarC "__tests.$i.message")

        echo "Test: $testName"
        echo "Result: $result"
        echo "Message: $message"
        echo ""
    done
}


