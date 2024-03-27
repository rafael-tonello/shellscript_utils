#!/bin/bash
# this  file  was  written to allow a kind of Object Orientation in bash script. Basically, 
# the  functions  in  this file load a file (.sh) and replaces all ocurrences of 'this' (or
# other placeholder) with the name of an object, creating a entire 'namespace' or variables
# and  functions  that  can  be  called like we do within OO. Bash do not allow use of '.', 
# so you need to use '_' instead.

#this file is  in: https://github.com/rafael-tonello/shellscript_utils

#newF new object from a class in the [className].sh file
#className, ObjectName
new_cf()
{
    class=$1
    name=$2
    fileName=$class.sh

    new_f $fileName $name
}

#new object from a class in a [fileName].sh file
#fileName, ObjectName
new_f()
{
    fileName=$1
    name=$2
    thiskey="this"
    if [ "$3" != "" ]; then
        thiskey=$3
    fi;

    rm -f "$fileName.c.sh"
    awk "{gsub(/$thiskey/, \"$name\"); print}" $fileName > $fileName.c.sh

    awk "{gsub(/\"->\"/, \"_\"); print}" $fileName.c.sh > $fileName.c.sh

    chmod +x "$fileName.c.sh"

    source "$fileName.c.sh" new "$name"
    rm "$fileName.c.sh"
}

#className, objectName
new_c()
{
    class=$1
    name=$2
    tmp=$(echo $tmp | sed "s/this/$name/g")
    eval $tmp
}

