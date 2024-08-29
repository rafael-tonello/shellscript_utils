#!/bin/bash
if [ "$1" != "new" ]; then >&2 echo "This must be included through the 'new_f' function in the file 'new.sh' (of shellscript_utils)"; exit 1; fi

this->init(){ :; }

this->alphaNumericChars="abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPQRSTUVXYWZ0123456789_"

#getOnly(source, [validChars])
#   for a given 'source' a new string will be generate with only letters of 'source' that are in 'validChars'.
#   if 'validChars was not provided, an internal string will be used ("abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPQRSTUVXYWZ0123456789_")'
this->getOnly(){
    # Define the original string and the valid characters
    original_string=$1
    valid_characters=$2

    if [ "$valid_characters" == "" ]; then
        valid_characters="$this->alphaNumericChars"
    fi

    ## Initialize an empty string to store the valid characters
    #valid_string=""
#
    ## Iterate through each character in the original string
    #for ((i=0; i<${#original_string}; i++)); do
    #    # Get the character at position i
    #    char="${original_string:i:1}"
    #    
    #    # Check if the character is present in the valid characters string
    #    if [[ $valid_characters == *"$char"* ]]; then
    #        # If present, append it to the valid string
    #        valid_string+="$char"
    #    fi
    #done

    # Print the valid string
    local ret=$(echo "$original_string" | tr -cd "$valid_characters")
    echo "$ret"
    return 0
}

this->getOnly_2(){
    _r=$(this->getOnly "${@}")
}

#replace all ocurrences of 'from' in 'source' with 'to'
this->replace(){ local source="$1"; local from="$2"; local to="$3"
    local result=$(echo $source | sed "s/$from/$to/g")
    echo $result
}

this->replaceAll(){
    this->replace "${@}"
}

#use _r instead echo
this->replace_2(){
    _r=$(this->replace "${@}")
}
this->replaceAll_2(){
    this->replace_2 "${@}"
}


#replaces all ocureneces of 'every' in 'in' with  each one remain function arguments
#example: replaceSeq "the key is %% and key is %%" "%%" "key" "value" -> "the key is key and key is value
this->replaceSeq(){
    local every=$1;
    every=$(echo "$every" | sed 's/\//\\\//g')
    shift; local in=$1;
    shift; local result=$in;
    for arg; do
        local tmpArg=$(echo "$arg" | sed 's/\//\\\//g')
        result=$(echo $result | sed "s/$every/$tmpArg/");
    done;
    echo $result;
}
this->compose(){
    return this->replaceSeq "$@"
}

#use _r instead echo
this->replaceSeq_2(){
    _r=$(this->replaceSeq "$@")
}
this->compose_2(){
    return this->replaceSeq_2 "$@"
}

this->replaceEvery(){
    return this->replace "$@"
}

this->cut(){ local source=$1; local separator=$2; local p1_p2=$3
    local index=$(expr index "$source" "$separator")

    # Cortando a string com base na posição do separador
    local tmp=""
    if [ "$p1_p2" == "2" ]; then
        tmp="${source:index}"
    else
        tmp="${source:0:index-1}"
    fi
    echo $tmp
}

#use echo instead _r
this->cut_2(){
    _r=$(this->cut "${@}")
}


#returns an bash array. Note: first element is at position 1
this->split(){ local source=$1; local separator=$2
    #declare the array
    _r=()

    local count=1
    while [ true ]; do
        #find the separator
        local tmpIndex=$(expr index "$source" "$separator")

        #if not found, add the source to the array and break the loop
        if [ "$tmpIndex" == "0" ]; then
            _r[0]="$source"
            break
        fi

        #add the part of the source to the array
        tmpStr="${source:0:tmpIndex-1}"
        _r[$count]="$tmpStr"
        count=$((count+1))

        #remove the part of the source
        source="${source:tmpIndex}"
    done
}


#do not use bash arrays. Instead, uses _r->count, _r->0, _r->1, ... Note: first element is at position 0
this->split_2(){ local source=$1; local separator=$2
    local count=0
    while [ true ]; do
        #find the separator
        local tmpIndex=$(expr index "$source" "$separator")

        #if not found, add the source to the array and break the loop
        if [ "$tmpIndex" == "0" ]; then
            _r->0="$source"
            break
        fi

        #add the part of the source to the array
        tmpStr="${source:0:tmpIndex-1}"
        eval "_r->$count=\"$tmpStr\""
        count=$((count+1))

        #remove the part of the source
        source="${source:tmpIndex}"
    done
    _r->count=$count
    _r=$count
}