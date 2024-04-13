#!/bin/bash
# this  file  was  written to allow a kind of Object Orientation in bash script. Basically, 
# the  functions  in  this file load a file (.sh) and replaces all ocurrences of 'this' (or
# other placeholder) with the name of an object, creating a entire 'namespace' or variables
# and  functions  that  can  be  called like we do within OO. Bash do not allow use of '.', 
# so you need to use '_' instead.

#this file is in: https://github.com/rafael-tonello/shellscript_utils

#new object from a class in a [fileName].sh file
#fileName, ObjectName, [this_self_string], [auto_call_init], [auto_call_init_arguments]
new_f()
{
	currDir=$(pwd)
    fileName=$1
    name=$2
    auto_call_init=$4
    auto_call_init_arguments=$5
    thiskey="this"


    if [ "$fileName" == "http"* ]; then
        #check if curl is present
        if ! command -v curl &> /dev/null; then
            rm -f /tmp/__new_f_downloaded.sh 2>/dev/null
            curl -s $fileName > /tmp/__new_f_downloaded.sh
            fileName=/tmp/__new_f_downloaded.sh
        #else, looks for wget
        elif ! command -v wget &> /dev/null; then
            rm -f /tmp/__new_f_downloaded.sh 2>/dev/null
            wget -q $fileName -O /tmp/__new_f_downloaded.sh
            fileName=/tmp/__new_f_downloaded.sh
        else
            >&2 echo "You need to have 'curl' or 'wget' installed to download the file"
            return 1
        fi
    fi

    ret=$(pwd)

    if [ "$3" != "" ]; then
        thiskey=$3
    fi;

    rm -f "$fileName.c.sh" 2>/dev/null
    rm -f "$fileName.c.sh2" 2>/dev/null
    
    awk "{gsub(/$thiskey/, \"$name\"); print}" "$fileName" > "$fileName.c.sh2"
    awk "{gsub(/"\-\>"/, \"_\"); print}" "$fileName.c.sh2" > "$fileName.c.sh"

    chmod +x "$fileName.c.sh"

    (__new_f_tmp(){
        sleep 1
        cd "$ret"
        rm "$fileName.c.sh2" 2>/dev/null
        rm "$fileName.c.sh" 2>/dev/null
    }; __new_f_tmp &)

    if [[ "$fileName" == "/"* ]]; then
        scriptDir="$(dirname $fileName)"
    else
        scriptDir="$(dirname "$currDir/$fileName")"
    fi

    source "$fileName.c.sh" new "$name" "$scriptDir"
    if [ "$auto_call_init" == "1" ]; then
        eval "$name""_init '$auto_call_init_arguments'"
    fi

}

