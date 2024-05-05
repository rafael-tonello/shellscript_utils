#!/bin/bash
if [ "$1" != "new" ]; then >&2 echo "This must be included through the 'new_f' function in the file 'new.sh' (of shellscript_utils)"; exit 1; fi

this->makeupPrint(){ local message=$1; local color=$2; local bold=$3; local underline=$4;
    local colorCode=""
    local underlineCode=""
    local boldCode=""

    if [ "$color" == "red" ]; then
        colorCode="\033[0;31m"
    elif [ "$color" == "green" ]; then
        colorCode="\033[0;32m"
    elif [ "$color" == "orange" ]; then
        colorCode="\033[0;33m"
    elif [ "$color" == "yellow" ]; then
        colorCode="\033[0;33m"
    elif [ "$color" == "blue" ]; then
        colorCode="\033[0;34m"
    elif [ "$color" == "purple" ]; then
        colorCode="\033[0;35m"
    elif [ "$color" == "cyan" ]; then
        colorCode="\033[0;36m"
    elif [ "$color" == "lightred" ]; then
        colorCode="\033[1;31m"
    elif [ "$color" == "lightgreen" ]; then
        colorCode="\033[1;32m"
    elif [ "$color" == "lightblue" ]; then
        colorCode="\033[1;34m"
    elif [ "$color" == "lightpurple" ]; then
        colorCode="\033[1;35m"
    elif [ "$color" == "lightcyan" ]; then
        colorCode="\033[1;36m"
    elif [ "$color" == "white" ]; then
        colorCode="\033[0;37m"
    elif [ "$color" == "grey" ]; then
        colorCode="\033[1;30m"
    elif [ "$color" == "lightgrey" ]; then
        colorCode="\033[0;37m"
    elif [ "$color" == "darkgrey" ]; then
        colorCode="\033[1;30m"
    elif [ "$color" == "black" ]; then
        colorCode="\033[0;30m"
    else #default color
        colorCode="\033[0m"
    fi


    #check if underline is true or 1

    if [ "$underline" == "true" ] || [ "$underline" == "1" ]; then
        underlineCode="\033[4m"
    fi

    if [ "$bold" == "true" ] || [ "$bold" == "1" ]; then
        #tput bold
        #tput sgr0
        boldCode="\033[1m"
    fi

    #echo -e "$colorCode$underlineCode$boldCode$message\033[0m"
    printf "$colorCode$underlineCode$boldCode$message\033[0m"
}

this->printHorizontalLine(){ local centralText=$1; local optionalChar=$2;
    if [ -z "$centralText" ]; then
        centralText=""
    fi

    if [ -z "$optionalChar" ]; then
        optionalChar="-"
    fi

    local terminalWidth=$(tput cols)
    
    if [ "$terminalWidth" == "" ]; then
        terminalWidth=80
    fi

    local optionalCharLength=${#optionalChar}

    local optionalCharString=""
    for i in $(seq 1 $terminalWidth); do
        optionalCharString="$optionalCharString$optionalChar"
    done

    #cut possible excess of chars
    lineText=${optionalCharString:0:$terminalWidth}

    local centralTextSize=${#centralText}
    local lineTextSize=${#lineText}
    local halfTextSize=$(( lineTextSize / 2 ))
    local halfOfCentralText=$(( centralTextSize / 2 ))


    #get the lineText between chars 0 and (halfTextSize - halfOfCentralText)
    local lineText1=${lineText:0:$(( halfTextSize - halfOfCentralText ))}

    #get the line between chars (halfTextSize + halfOfCentralText) and the end
    local lineText2=${lineText:0:$(( terminalWidth - halfTextSize - halfOfCentralText ))}

    local finalText="$lineText1$centralText$lineText2"
    #cut possible excess of chars
    finalText=${finalText:0:$terminalWidth}

    echo "$finalText"
}