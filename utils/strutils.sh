#!/bin/bash
if [ "$1" != "new" ]; then >&2 echo "This must be included through the 'new_f' function in the file 'new.sh' (of shellscript_utils)"; exit 1; fi

#getOnly(source, [validChars])
#   for a given 'source' a new string will be generate with only letters of 'source' that are in 'validChars'.
#   if 'validChars was not provided, an internal string will be used ("abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPQRSTUVXYWZ0123456789_")'
this->getOnly(){
    # Define the original string and the valid characters
    original_string=$1
    valid_characters=$2

    if [ "$valid_characters" == "" ]; then
        valid_characters="abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPQRSTUVXYWZ0123456789_"
    fi

    # Initialize an empty string to store the valid characters
    valid_string=""

    # Iterate through each character in the original string
    for ((i=0; i<${#original_string}; i++)); do
        # Get the character at position i
        char="${original_string:i:1}"
        
        # Check if the character is present in the valid characters string
        if [[ $valid_characters == *"$char"* ]]; then
            # If present, append it to the valid string
            valid_string+="$char"
        fi
    done

    # Print the valid string
    _r=$valid_string
    return 0
}
