if [ "$1" != "new" ]; then
    source ../src/new.sh "$(pwd)/../src"
    new_f "$0" __app__ "" 1
    exit $?
fi

this->init(){
    new "tests" this->tests "" 1 "tests_namespace"
    new "utils" this->utils
    
    echo "initializing tests"
    new_f "./src.tests/sharedmemory.test.sh" this->memoryTests "" 1 "this->tests"
    new_f "./src.tests/thread.test.sh" this->threadTests "" 1 "this->tests"
    new_f "./src.tests/utils.tests/strutils.test.sh" this->utilsTests "" 1 "this->tests"
    new_f "./src.tests/libs.tests/translate.test.sh" this->translateTests "" 1 "this->tests"


    this->utils->printHorizontalLine " [ running tests ] " "=" 2>/dev/null
    this->tests->runTests
    errorCount=$?

    echo ""
    this->utils->printHorizontalLine " [ tests results ] " "=" 2>/dev/null
    echo ""
    this->tests->showTestResults

    this->threadTests->finalize
    this->memoryTests->finalize
    this->tests->finalize
    return $errorCount
}
