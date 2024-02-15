_this_logToTerminal=1
_this_logfile=""
_this_alowedloglevels=""
_this_scriptDirectory=""

#name, levelNumber, [ascii_scape_color]
createLogLevel()
{
    name=$1
    levelNumber=$2
    color=$3
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

#loggerLibDirectory, [log_levels_def_$INFO], [log to terminal, 1_or_0_def_1], [logfile], [ident_data_default_1]
this_init(){
    _this_scriptDirectory=$1
    _this_alowedloglevels=$2
    _this_logToTerminal=$3
    _this_logfile=$4
    _this_identData=$5

    if [ "$_this_logToTerminal" == "" ]; then
        _this_logToTerminal=1
    fi

    if [ "$_this_alowedloglevels" == "" ]; then
        _this_alowedloglevels=$INFO
    fi

    if [ "$_this_identData" == "" ]; then
        _this_identData=1
    fi

    return 0
}

this_finalize(){ echo; }

#name, level, text, [break_line_default_1], [is_an_err_default 0]
_this_lastBreakLine="\n"
this_log(){
    name=$1
    level=$2
    data=$3
    breakLine=$4
    isError=$5

    if [ "$breakLine" == "" ] || [ "$breakLine" == "1" ] || [ "$breakLine" == "true" ]; then
        breakLine="\n"
    elif [ "$breakLine" == "0" ] || [ "$breakLine" == "false" ]; then
        breakLine=""
    fi


    if [ "$_this_alowedloglevels" -gt "$level" ]; then
        return 0
    fi
    
    header=""
    if [ "$_this_lastBreakLine" == "\n" ]; then
        header=$(_this_lineHeader $level $name)
        headerSize=${#header}
    fi

    _this_lastBreakLine=$breakLine
    
    if [ "$_this_identData" == "1" ]; then
        data=$(_this_identData "$data" $headerSize)
    fi
        
    line=$header$data$breakLine
    if [ "$_this_logToTerminal" == "1" ]; then
        _this_write_color_begin $level
        if [ "$isError" ==  "1" ]; then
            >&2 printf "$line"
        else
            printf "$line"
        fi

        _this_write_color_end
    fi

    if [ "$_this_logfile" != "" ]; then
        printf "$line" >> $_this_logfile
    fi
}

#level
_this_write_color_begin()
{
    level=$1
    eval "if [ \"\$LVLCOLOR_$level\" != \"\" ]; then printf \$LVLCOLOR_$level; fi"
    return 0
}

_this_write_color_end()
{
    printf '\033[0m'
    return 0
}


#name, text, [break_line_default_1]
this_trace(){
    this_log "$1" $TRACE "$2" $3
    return 0
}

#name, text, [break_line_default_1]
this_debug(){
    this_log "$1" $DEBUG "$2" $3
    return 0
}

#name, text, [break_line_default_1]
this_info(){
    this_log "$1" $INFO "$2" $3
    return 0
}

#name, text, [break_line_default_1]
this_warning(){
    this_log "$1" $WARNING "$2" $3
    return 0
}

#name, text, [break_line_default_1]
this_error(){
    this_log "$1" $ERROR "$2" $3 1
    return 0
}

#name, text, [break_line_default_1]
this_critical(){
    this_log "$1" $CRITICAL "$2" $3 1
    return 0
}

#level, #logname
_this_lineHeader(){
    level=$1
    name=$2
    echo "[$(date +"%Y-%m-%d %H:%m:%S%z")][$(_this_level_to_string $level)][$name] ";
    return 0
}

#data, identationSize
_this_identData(){
    data=$1
    size=$2

    ident="\n"
    for ((i=1; i<=size; i++)); do
        ident+=" "
    done

    result=$(echo "$data" | sed 's/\\n/pppppp/g')
    result=$(echo "$result" | sed "s/pppppp/$ident/g")

    echo "$result"
}

#level
_this_level_to_string(){
    eval "echo \$LVLSTR_$1"
    return 0
}

#logName, object_name
this_newNLog(){
    log_name=$1
    object_name=$2
    new_f "$_this_scriptDirectory"/_nammedlog.sh "$object_name"

    #eval "\"$object_name\"_init \"$log_name\""
    "$object_name"_init this "$log_name"

    return 0
}

#logName, command
this_intercept()
{
    logName=$1
    command=$2
    file="/tmp/__intercept__tmp__"$RANDOM"__"
    fileErr="/tmp/__intercept__tmp__"$RANDOM"__"
    $command > $file 2> $fileErr
    result=$?
    stdout=$(cat "$file")
    stderr=$(cat "$fileErr")

    if [ "$stdout" != "" ]; then
        this_info "$logName" "$stdout"
    fi;

    if [ "$stderr" != "" ]; then
        this_error "$logName" "$stderr"
    fi;

    rm -f $file
    rm -f $fileErr

    return $result
}