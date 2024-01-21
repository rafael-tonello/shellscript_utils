#!/bin/bash
source "./libs/new.sh"

main(){
    new_f "./libs/logger/logger.sh" loggerObj
    loggerObj_init "./libs/logger/" $trace  1 "./testTmpFiles/tests.log"
    loggerObj_newNLog main log

    log_intercept "ping www.google.com.br -c 5"
    log_intercept "ping www.google.cam.br -c 5"

    log_debug "initializing SSH Manager instance"
    new_f "./libs/SSHManager.sh" test
    test_init "localhost" "user" "ssss"
    if [ "$?" != "0" ]; then
        log_error "Error starting the ssh library↩\n↪$_r\n"
        return
    fi;

    #test move remote files
    log_debug "testing the file moving resource"
    echo "lol" > ./testTmpFiles/tomove.txt
    loc=$(pwd)
    test_moveRemote "$loc/testTmpFiles/tomove.txt" "$loc/testTmpFiles/moved.txt"

    #test upload folders
    log_debug "testing folder upload resource"
    rm -rf "$loc/testTmpFiles/uploadHere"
    test_uploadFolder "$loc/testTmpFiles/toUpload" "$loc/testTmpFiles/uploadHere"
};main
