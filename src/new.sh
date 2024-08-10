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

ctx=""
context=""
autoinit=""
#new object from a class in a [fileName].sh file
#arguments:
#   normal args:
#       fileName: the filename with the class implmentation
#       ObjectName: the name of the new object
#       [init arguments ...]: arguments to be passed to the init function of the object
#   named args (global variables):
#       ctx: the context/reference of the object (this, self, etc). The default value is 'this'
#       autoinit: if 1, call the init function of the object after create it. The default vlue is 1
new_f()
{
	local currDir=$(pwd)
    local fileName="$1"
    local name="$2"
    local thiskey="this"

    if [ "$ctx" != "" ]; then
        thiskey="$ctx"
    elif [ "$context" != "" ]; then
        thiskey="$context"
    fi;

    local auto_call_init=$autoinit
    if [ "$auto_call_init" == "" ]; then
        auto_call_init="1"
    fi

    #prepare named args (global variables) for the next calls {
        ctx=""
        context=""
        autoinit=""
    #}

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
    eval "$name=\"\$scriptDir\$fileName\""
    eval "$name""_name=\"\$name\""
    eval "$name""_fileName=\"\$fileName\""
    eval "$name""_file=\"\$scriptDir\$fileName\""


    #(__new_f_tmp(){
    #    sleep 0.25
    #    cd "$ret" 2>/dev/null
    #    rm "$fileName.c.sh" 2>/dev/null
    #}; __new_f_tmp &)

    source "$fileName.c.sh" new "$name" "$scriptDir"
    if [ "$?" != "0" ]; then
        dump_stack
    fi

    #check if 'DEBUG' is set to 1
    if [ "$DEBUG" != "1" ]; then
        rm "$fileName.c.sh" 2>/dev/null
    fi


    if [ "$auto_call_init" == "1" ]; then
        shift
        shift
        eval "$name""_init \"\$@\""
        return $?
    fi
    return 0

}

#new object from a class in a [fileName].sh file
#new object from a class in a [fileName].sh file
#arguments:
#   normal args:
#       className: the name of the class (filename without extension). It can contains part of the path. Path are used as namespace
#       ObjectName: the name of the new object
#       [init arguments ...]: arguments to be passed to the init function of the object
#   named args (global variables):
#       ctx: the context/reference of the object (this, self, etc). The default value is 'this'
#       autoinit: if 1, call the init function of the object after create it. The default vlue is 1
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

inherit_f(){ local parentClassFile=$1; local childObjectName=$2; lcoal _this_key_=$3

    new_f "$parentClassFile" "$childObjectName" "$_this_key_" 0

    #get the parent class name (filename without extension and directory)
    local parentClassName=$(basename "$parentClassFile")
    parentClassName="${parentClassName%.*}"

    _replaceMethodObjectName "$childObjectName" "$childObjectName""_""$parentClassName"
    
}

inherit(){ local parentClassName=$1; local childObjectName=$2; local _this_key_=$3

    autoinit=0; new "$parentClassName" "$childObjectName" "$_this_key_"

    local parentFuncs=$(compgen -A function | grep "^$childObjectName""_")

    _replaceMethodObjectName "$childObjectName" "$childObjectName""_""$parentClassName"

}

_replaceMethodObjectName(){ local objectName=$1; local newObjectName=$2
    
    local parentFuncs=$(compgen -A function | grep "^$objectName""_")

    #copy all functions from new object to 'childObjectName_base' object
    for i in $parentFuncs; do
        #get the original function code and create a new function
        local funcCode=$(declare -f $i)

        #replace '$childObjectName' in the function name by "$childObjectName""_base" (replace only the first ocurrence)
        #funcCode=$(echo "$funcCode" | sed "s/$objectName""_/$newObjectName""_/")
        funcCode=$(echo "$funcCode" | sed "0,/$objectName""_/{s//$newObjectName""_/}")

        #create the new function
        eval "$funcCode"
    done

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


#import a repository to your project. After the import, you can call new with the repository class names
import_git(){ local gitUrl=$1; local _global_=$2; local _commit_=$3
    local cacheFolder="$project_dir/.shellscript_utils/newshgitrepos"
    

    if [ "$_commit_" == "" ]; then
        _commit_="HEAD"

    fi
    
    if [ "$_global_" == "1" ]; then
        cacheFolder="$HOME/.shellscript_utils/newshgitrepos"
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


#import a files from the internet. After the import, you can do a 'new' in the imported file
import_webFile(){ local fileUrl=$1; local _global_=$2;
    #get urlBase after ://
    local protoFileName=$(echo $fileUrl | sed 's/.*:\/\///')

    #get the directory name
    #local protoFileFolder=$(dirname $urlBase)

    local cacheFolder="$project_dir/.shellscript_utils/webfiles/"

    if [ "$_global_" == "1" ]; then
        cacheFolder="$HOME/.shellscript_utils/webfiles/"
    fi

    local filename=$cacheFolder$protoFileName
    local folder=$(dirname $filename)

    if [ ! -d "$folder" ]; then
        mkdir -p "$folder"
    fi

    #try download the file
    if ! command -v curl &> /dev/null; then
        curl -s "$fileUrl" > "$filename"".tmp"
    elif ! command -v wget &> /dev/null; then
        wget -q "$fileUrl" -O "$filename"".tmp"
    else
        >&2 echo "You need to have 'curl' or 'wget' installed to download the file"
        return 1
    fi

    #check if command was executed with sucess
    if [ "$?" != "0" ]; then
        >&2 echo "Error downloading file"
        return 1
    fi

    #if downloaded with sucess, replace the original file (if exists) withe the .tmp file
    if [ -f "$filename" ]; then
        rm -f "$filename" 2>/dev/null
    fi
    mv "$filename"".tmp" "$filename"

    return 0

    scan_folder_for_classes "$folder"
}

displaysObjecMemory(){
    objectName="$1"
    #get all variables started with '$objectName
    local objVars=$(compgen -A variable | grep "^$objectName")


    for i in $objVars; do
        eval "echo \"$i: \$$i\""
    done
}

showObjectMemory(){
    displaysObjecMemory "$@"
}

dump_stack(){ #found here: https://stackoverflow.com/questions/685435/trace-of-executed-programs-called-by-a-bash-script
    local i=0
    local line_no
    local function_name
    local file_name
    while caller $i ;do ((i++)) ;done | while read line_no function_name file_name;do echo -e "\t$file_name:$line_no\t$function_name" ;done >&2
}