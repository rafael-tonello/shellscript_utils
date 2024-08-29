if [ "$1" != "new" ]; then
    source ../src/new.sh "$(pwd)"
    scan_folder_for_classes ".."
    scan_folder_for_classes "."
    new_f "$0" __app__
    exit $?
fi

this->init(){
    new "libs/tests" this->tests "tests_namespace"
    this->tests->cleanAndPrepare

    autoinit=0; new "utils" this->utils
    
    echo "initializing tests"
    new "new.tests.sh" this->newShTests "this->tests"
    new "sharedmemory.test.sh" this->memoryTests "this->tests"
    new "thread.test.sh" this->threadTests "this->tests"
    new "strutils.test.sh" this->utilsTests "this->tests"
    new "translate.test.sh" this->translateTests "this->tests"
    new "eventbus.test.sh" this->eventbusTests "this->tests"
    new "queue.test.sh" this->queueTests "this->tests"


    this->utils->printHorizontalLine " [ running tests ] " "=" 2>/dev/null
    this->tests->runTests 1
    errorCount=$?

    echo ""
    this->utils->printHorizontalLine " [ tests results ] " "=" 2>/dev/null
    #this->tests->showTestResults
    this->tests->showSumarizedTestResults

    this->memoryTests->finalize
    this->threadTests->finalize
    this->utilsTests->finalize
    this->translateTests->finalize
    this->eventbusTests->finalize
    this->queueTests->finalize
    this->tests->finalize
    return $errorCount
}
 



interceptCommandStdout(){ local command=$1; local lambda=$2
    local output=$(eval $command)
    local error=$?
    if [ $error -ne 0 ]; then
        echo "Error running command: $command"
        return 1
    fi

    echo "$output" | while read line; do
        $lambda "$line"
    done
}

#run 'command' and intercept its stdout in real time
interceptCommandStdout(){ local command=$1; local lambda=$2
    eval "$command" | while read line; do
        eval "$lambda \"\$line\""
    done
}