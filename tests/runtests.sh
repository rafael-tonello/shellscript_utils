if [ "$1" != "new" ]; then
    echo "loading new.sh"
    source ../src/new.sh "../src"
    scan_folder_for_classes ".."
    echo "new.sh loaded. Starting tests app"
    new_f "$0" __app__
    exit $?
fi

this->init(){
    new "libs/tests" this->tests "tests_namespace"
    this->tests->cleanAndPrepare

    autoinit=0; new "utils" this->utils
    
    echo "initializing tests"
    new_f "./src.tests/sharedmemory.test.sh" this->memoryTests "this->tests"
    new_f "./src.tests/thread.test.sh" this->threadTests "this->tests"
    new_f "./src.tests/utils.tests/strutils.test.sh" this->utilsTests "this->tests"
    new_f "./src.tests/libs.tests/translate.test.sh" this->translateTests "this->tests"
    new_f "./src.tests/libs.tests/eventbus.test.sh" this->eventbusTests "this->tests"
    new_f "./src.tests/queue.test.sh" this->queueTests "this->tests"


    this->utils->printHorizontalLine " [ running tests ] " "=" 2>/dev/null
    this->tests->runTests
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