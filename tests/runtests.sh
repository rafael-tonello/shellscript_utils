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
    

    echo "Finding and initializing tests"
    testersCount=0
    for i in $(find . -name "*.test.sh"); do
        #local fName=$(basename "$i")
        #new "/$fName" "this->tester_$testersCount" "this->tests"
        new_f "$i" "this->tester_$testersCount" "this->tests"
        testersCount=$(( testersCount+1 ))
    done
    #new_f "./src.tests/libs.tests/list.test.sh" "asdfads" "this->tests"

    this->utils->printHorizontalLine " [ running tests ] " "=" 2>/dev/null
    this->tests->runTests 1
    errorCount=$?

    echo ""
    this->utils->printHorizontalLine " [ tests results ] " "=" 2>/dev/null
    #this->tests->showTestResults
    this->tests->showSumarizedTestResults


    while [ $testersCount -eq -1 ]; do
        testersCount=$(( testersCount-1 ))
        eval "this->tester_$testersCount->finalize"
    done

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