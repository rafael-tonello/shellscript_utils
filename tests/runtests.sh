if [ "$1" != "new" ]; then
    source ../src/new.sh "../src"
    new_f "$0" __app__ "" 1
    exit $?
fi

this->init(){
    new "tests" this->tests "" 1 "tests_namespace"
    new "utils" this->utils "" 0
    
    echo "initializing tests"
    new_f "./src.tests/sharedmemory.test.sh" this->memoryTests "" 1 "this->tests"
    new_f "./src.tests/thread.test.sh" this->threadTests "" 1 "this->tests"
    new_f "./src.tests/utils.tests/strutils.test.sh" this->utilsTests "" 1 "this->tests"
    new_f "./src.tests/libs.tests/translate.test.sh" this->translateTests "" 1 "this->tests"
    new_f "./src.tests/libs.tests/eventbus.test.sh" this->eventbusTests "" 1 "this->tests"
    new_f "./src.tests/queue.test.sh" this->queueTests "" 1 "this->tests"


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