#!/bin/bash
# this  file  was  written to allow a kind of Object Orientation in bash script. Basically, 
# the  functions  in  this file load a file (.sh) and replaces all ocurrences of 'this' (or
# other placeholder) with the name of an object, creating a entire 'namespace' or variables
# and  functions  that  can  be  called like we do within OO. Bash do not allow use of '.', 
# so you need to use '_' instead.

#this file is in: https://github.com/rafael-tonello/shellscript_utils

#the script will be loaded with threse arguments:
#   $1: 'new' string
#   $2: the name of the object
#   $3: the directory where the script is running (run path)

#this file is sourced in another scripts and a parameter (root project dir) can be passed. If 
#this is passed, call _scan_folder_for_classes with this path). If the project_dir is no informed,
#the function 'new', if called, will make a recursive search in the current directory (at moment 
#when 'new' is called) for .sh files
#the scan code is at end of the file
project_dir=$1

#new object from a class in a [fileName].sh file
#fileName, ObjectName, [this_self_string], [auto_call_init], [auto_call_init_arguments ...]
new_f()
{
	local currDir=$(pwd)
    local fileName="$1"
    local name="$2"
    local auto_call_init=$4
    local thiskey="this"


    if [ "$3" != "" ]; then
        thiskey=$3
    fi;

    if [ "$fileName" == "http"* ]; then
        #check if curl is present
        if ! command -v curl &> /dev/null; then
            rm -f /tmp/__new_f_downloaded.sh 2>/dev/null
            curl -s $fileName > /tmp/__new_f_downloaded.sh
            fileName=/tmp/__new_f_downloaded.sh
        #else, looks for xwget
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

    

    rm -f "$fileName.c.sh" 2>/dev/null

    cp "$fileName" "$fileName.c.sh"
    #replace
    sed -i "s/->/_/g" "$fileName.c.sh" 2>/dev/null
    sed -i "s/$thiskey\_/$name\_/g" "$fileName.c.sh" 2>/dev/null


    #awk '{
    #    while (match($0, /[.][^ ]/)) {
    #        # Replace the dot with underscore
    #        $0 = substr($0, 1, RSTART-1) "_" substr($0, RSTART+1)
    #    }
    #    print
    #}' "$fileName.c.sh" > "$fileName.c.sh2"
#
    #rm "$fileName.c.sh" 2>/dev/null
    #mv "$fileName.c.sh2" "$fileName.c.sh"

    chmod +x "$fileName.c.sh"

    if [[ "$fileName" == "/"* ]]; then
        scriptDir="$(dirname $fileName)"
    else
        scriptDir="$(dirname "$currDir/$fileName")"
    fi
    
    #create a variable with the name of the object. The value is the filename of the object
    eval "$name=\$scriptDir\$fileName"
    eval "$name""_name=\"$name\""

    #(__new_f_tmp(){
    #    sleep 0.25
    #    cd "$ret" 2>/dev/null
    #    rm "$fileName.c.sh" 2>/dev/null
    #}; __new_f_tmp &)

    source "$fileName.c.sh" new "$name" "$scriptDir"
    rm "$fileName.c.sh" 2>/dev/null

    if [ "$auto_call_init" == "1" ]; then
        shift
        shift
        shift
        shift
        eval "$name""_init \"\$@\""
        return $?
    fi
    return 0

}

#new object from a class in a [fileName].sh file
#fileName, ObjectName, [this_self_string], [auto_call_init], [auto_call_init_arguments]
newsh_scanned=0
declare -Ag newsh_classes
new () { local className=$1;
    if [ "$newsh_scanned" == "0" ]; then
        scan_folder_for_classes
    fi

    #add '.sh' to the end of the class name (if not present)
    if [[ "$className" != *".sh" ]]; then
        className="$className.sh"
    fi

    #scrolls all newsh_classes to find the class
    local foundFile=""
    for i in "${newsh_classes[@]}"; do
        #check if $className is at end of the current item
        if [[ "$i" == *"$className" ]]; then
            foundFile=$i
            break
        fi
    done

    #if not found, remove one parent folder name of className and try again
    if [ "$foundFile" == "" ]; then
        >&2 echo "Class $1 not found"
        return 1
    fi

    shift

    #for over the arguments and call the new_f function

    new_f "$foundFile" "$@"
    return $?
}

#recursive scan .sh files
scan_folder_for_classes(){ local dir=$1; local subfoldersMaxDeep=$2; local canScanThisFolder=$3
    if [ "$dir" == "" ]; then
        dir=$(pwd)
    fi

    if [ "$subfoldersMaxDeep" == "" ]; then
        subfoldersMaxDeep=1000000
    fi

    if [ "$canScanThisFolder" == "" ]; then
        canScanThisFolder="__f(){ echo 1; }; __f"
    fi

    _scan_classes "$dir" $subfoldersMaxDeep "$canScanThisFolder" 0
    newsh_scanned=1
}

_scan_classes_count=0
_scan_classes(){ local dir=$1; local subfoldersMaxDeep=$2; local canScanThisFolder=$3; local _deep=$4
    #check if _deep is greater than subfoldersMaxDeep
    if [ "$subfoldersMaxDeep" != "" ] && [ "$_deep" -gt "$subfoldersMaxDeep" ]; then
        return
    fi

    #run lambda "canScanThisFolder" to check if can scan this folder
    local canScan=$(eval "$canScanThisFolder \"\$dir\"")
    if [ "$canScan" == "0" ]; then
        return
    fi


    if [[ "$dir" != "/"* ]]; then
        local dir="$(pwd)/$dir"
    fi

    for file in "$dir"/*.sh; do
        #add to the list of classes
        file=$(realpath "$file")
        if [ -f "$file" ]; then
            newsh_classes[$_scan_classes_count]="$file"
            _scan_classes_count=$(( _scan_classes_count + 1 ))
        fi
    done

    #recursive call with child folders
    for d in "$dir"/*; do
        if [ -d "$d" ]; then
            _scan_classes "$d" $subfoldersMaxDeep "$canScanThisFolder" $(( _deep + 1 ))
        fi
    done
}

fixname(){ $source; local valid_characters=$2
    if [ "$valid_characters" == "" ]; then
        valid_characters="abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPQRSTUVXYWZ0123456789_"
    fi

    echo $1 | tr -cd "$valid_characters"
}

if [ "$project_dir" != "" ]; then
    shift
    scan_folder_for_classes "$project_dir" $@
else
    #do not scan for classes, but define project_dir as $(pwd), because proejct_dir is needed to cache git repositories
    project_dir=$(pwd)
fi


import_git(){ local gitUrl=$1; local _portable_=$2; local _commit_=$3
    local cacheFolder="$project_dir/.newshgitrepos"
    

    if [ "$_commit_" == "" ]; then
        _commit_="HEAD"

    fi
    
    if [ "$_portable_" == "1" ]; then
        cacheFolder="$HOME/.newshgitrepos"
    fi

    if [ ! -d "$cacheFolder" ]; then
        mkdir -p "$cacheFolder"
    fi

    local gitFolder="$cacheFolder/$(fixname $gitUrl)"

    #clone only the last commit if _commit_ is 'HEAD'
        _commit_=$(git ls-remote $gitUrl HEAD | cut -f 1)
    if [ ! -d "$gitFolder" ]; then
        if [ "$_commit_" == "HEAD" ]; then
            git clone --depth 1 $gitUrl $gitFolder
        else
            git clone $gitUrl $gitFolder
            git checkout $_commit_
        fi
    else
        local returnFolder=$(pwd)
        cd $gitFolder
        git pull
        cd $returnFolder
    fi

    scan_folder_for_classes "$gitFolder"
    return 0
}

