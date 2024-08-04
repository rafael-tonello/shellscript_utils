#!/bin/bash
# example of use
#       #create the log manager
#       new "logger" "this->logManager"
#
#       #create a log file writer
#       new "logterminalwriter" "this->logTerminalWriter"
#
#       #add the writer to the log manger
#       this->logManager->addWriter this->logTerminalWriter


if [ "$1" != "new" ]; then >&2 echo "This must be included through the 'new_f' function in the file 'https://github.com/rafael-tonello/shellscript_utils/blob/main/libs/new.sh'"; exit 1; fi

_this->logToTerminal=1
_this->logfile=""
_this->alowedloglevels=""
_this->scriptDirectory="$3"

#name, levelNumber, [ascii_scape_color]
createLogLevel()
{
    local name=$1
    local levelNumber=$2
    local color=$3
    eval "$name=$levelNumber"
    eval "${name,,}=$levelNumber"
    eval "${name^^}=$levelNumber"
    eval "LVLSTR_$levelNumber=$name"
    eval "LVLCOLOR_$levelNumber='$color'"

    return 0
}

createLogLevel "TRACE" 10 '\033[0;35m'
createLogLevel "DEBUG" 20 '\033[0;35m'
createLogLevel "INFO" 30
createLogLevel "WARNING" 40 '\033[0;33m'
createLogLevel "ERROR" 50 '\033[0;31m'
createLogLevel "CRITICAL" 60 '\033[0;31m'


#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

#declare an array of strings


#[log_levels_def_$INFO], [ident_data_default_1]
this->init(){ local alowedloglevels=$1; local identData=$2; local useMiliseconds=$3
    #declare -A _this->writers

    _this->alowedloglevels=$alowedloglevels
    _this->identData=$identData
    _this->useMiliseconds=$useMiliseconds

    if [ "$_this->logToTerminal" == "" ]; then
        _this->logToTerminal=1
    fi

    if [ "$_this->alowedloglevels" == "" ]; then
        _this->alowedloglevels=$INFO
    fi

    if [ "$_this->identData" == "" ]; then
        _this->identData=1
    fi

    shift; shift; shift;
    for writer in "$@"; do
        this->addWriter "$writer"
    done

    return 0
}

#add a wirter driver to the logger.
#
this->addWriter(){ local writer=$1
    local currentSize=${#_this->writers[@]}
    _this->writers[$currentSize]="$writer"
    return 0
}

this->finalize(){ echo; }

#name, level, text, [break_line_default_1], [is_an_err_default 0]
_this->lastBreakLine="\n"
this->log(){
    name=$1
    local level=$2
    data=$3
    breakLine=$4
    isError=$5

    if [ "$breakLine" == "" ] || [ "$breakLine" == "1" ] || [ "$breakLine" == "true" ]; then
        breakLine="\n"
    elif [ "$breakLine" == "0" ] || [ "$breakLine" == "false" ]; then
        breakLine=""
    fi

    if [ "$_this->alowedloglevels" -gt "$level" ]; then
        return 0
    fi
    
    header=""
    if [ "$_this->lastBreakLine" == "\n" ]; then
        header=$(_this->lineHeader $level $name)
        headerSize=${#header}
    fi

    _this->lastBreakLine=$breakLine
    
    if [ "$_this->identData" == "1" ]; then
        data=$(_this->makeDataIdentation $headerSize "$data")
    fi
        
    line=$header$data$breakLine

    #scrolls over the writers
    for writer in "${_this->writers[@]}"; do
        "$writer"_log "$line" "$level" "$isError"
    done

}

#level
_this->write_color_begin()
{
    level=$1
    eval "if [ \"\$LVLCOLOR_$level\" != \"\" ]; then printf \$LVLCOLOR_$level; fi"
    return 0
}

_this->write_color_end()
{
    printf '\033[0m'
    return 0
}

#run 'command' and intercept its stdout and stderr in real time
this->interceptCommandStdout(){ local logSessionName=$1; local level=$2; local command=$3; local _identifyErrors_=$4
    eval "$command" 2>&1 | while read line; do
        #check if is error (line contains the word 'error' or 'exception' or 'fail' or 'fatal' or 'critical', case insensitive)
        if [ "$_identifyErrors_" == "1" ]; then
            #check if one of the error tokens is in the line
            local errorTokens="error|ERROR|Error|exception|Exception|EXCEPTION|fail|Fail|FAIL|fatal|Fatal|FATAL|critical|Critical|CRITICAL"
            local errorTokenIsPresent=0
            #scrolls over the error tokens
            for token in $(echo $errorTokens | tr "|" "\n"); do
                #check if the line contains the token
                if [[ "$line" == *"$token"* ]]; then
                    errorTokenIsPresent=1
                    break
                fi
            done

            if [ "$errorTokenIsPresent" == "1" ]; then
                this->log "$logSessionName" "$ERROR" "$line" 1 1
            else
                this->log "$logSessionName" $level "$line"
            fi
        else
            this->log "$logSessionName" $level "$line"
        fi
    done
}

#name, text, [break_line_default_1]
this->trace(){
    this->log "$1" $TRACE "$2" $3
    return 0
}

#name, text, [break_line_default_1]
this->debug(){
    this->log "$1" $DEBUG "$2" $3
    return 0
}

#name, text, [break_line_default_1]
this->info(){
    this->log "$1" $INFO "$2" $3
    return 0
}

#name, text, [break_line_default_1]
this->warning(){
    this->log "$1" $WARNING "$2" $3
    return 0
}

#name, text, [break_line_default_1]
this->error(){
    this->log "$1" $ERROR "$2" $3 1
    return 0
}

#name, text, [break_line_default_1]
this->critical(){
    this->log "$1" $CRITICAL "$2" $3 1
    return 0
}

#level, #logname
_this->lineHeader(){
    level=$1
    name=$2
    if [ "$_this->useMiliseconds" == "1" ]; then
        echo "[$(date +"%Y-%m-%d %H:%m:%S.%3N%z")][$(_this->level_to_string $level)][$name] ";
    else
        echo "[$(date +"%Y-%m-%d %H:%m:%S%z")][$(_this->level_to_string $level)][$name] ";
    fi
    return 0
}

#data, identationSize
_this->makeDataIdentation(){
    local mdi_size="$1"
    local mdi_data="$2"

    if [ "$mdi_size" == "" ]; then
        mdi_size=0
    fi
    
    #generate a string with 10 characters of '-'
    #identation=$(printf '%*s' "$mdi_size" | tr ' ' "-")

    local identation=$(printf "%${mdi_size}s")

    #replace all linebreaks by "\n" + identation
    #mdi_data=$(echo "$mdi_data" | sed -r "s/[^/]*/$identation/g")
    mdi_data=$(echo "$mdi_data" | sed ':a;N;$!ba;s/\n/oOoOo/g')
    mdi_data=$(echo "$mdi_data" | sed "s/oOoOo/\n$identation/g")
    
    
    #remove first identation (only from first line)
    #mdi_data=$(echo "$mdi_data" | sed "s/^$identation//")


    echo "$mdi_data"
}

#level
_this->level_to_string(){
    eval "echo \$LVLSTR_$1"
    return 0
}

#logName, object_name

this->newNLog(){
    log_name=$1
    object_name=$2
    new_f "$_this->scriptDirectory"/_nammedlog.sh "$object_name"

    #eval "\"$object_name\"_init \"$log_name\""
    "$object_name"_init $this->name "$log_name"

    return 0
}
