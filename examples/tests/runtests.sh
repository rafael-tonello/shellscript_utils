if [ "$1" != "new" ]; then source ../../new.sh; new_f "$0" __app__ "" 1; exit $?; fi


this->init(){
    this->prepare
    this->instatiateTests
    this->runTests
    ret=$?
    this->clearNamespace
    return $ret
}

this->prepare(){
    new_f "../../tests.sh" this->tests "" 1 "tests"
    this->tests->cleanAndPrepare
}

this->instatiateTests(){
    new_f "./test_files/thread.tests.sh" this->threadstests "" 1
}

this->runTests(){
    this->tests->runTests
    return $?

}

this->clearNamespace(){
    new_f "../../sharedmemory.sh" this->memory "" 1 "tests"
    this->memory->clearNamespace
}