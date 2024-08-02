#!/bin/bash

#if [ "$1" != "new" ]; then source <(curl -s "https://raw.githubusercontent.com/rafael-tonello/shellscript_utils/main/libs/new.sh"); new_f "$0" __app__; exit $?; fi
if [ "$1" != "new" ]; then
    source <(curl -s "https://raw.githubusercontent.com/rafael-tonello/shellscript_utils/main/libs/new.sh")
    new_f "$0" __app__
    exit $?
fi

this->init(){
    echo "init called"
}