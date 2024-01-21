_this_logname=""
_this_logToTerminal=1
_this_logfile=""
_this_alowedloglevels=""


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

#logname, [log_levels_def_$INFO], [log to terminal, 1_or_0_def_1], [logfile]
this_init(){
    _this_logname=$1
    _this_alowedloglevels=$2
    _this_logToTerminal=$3
    _this_logfile=$4

    if [ "$_this_logToTerminal" == "" ]; then
        _this_logToTerminal=1
    fi

    if [ "$_this_alowedloglevels" == "" ]; then
        _this_alowedloglevels=$INFO
    fi

    return 0
}

#level, text, [is_an_err_default 0]
this_log(){
    level=$1
    data=$2
    isError=$3

    if [ "$_this_alowedloglevels" -gt "$level" ]; then
        return 0
    fi
    
    header=$(_this_lineHeader $level $_this_logname)
    headerSize=${#header}
    data=$(_this_identData "$data" $headerSize)
    line=$header$data
    if [ "$_this_logToTerminal" == "1" ]; then
        _this_write_color_begin $level
        if [ "$isError" ==  "" ]; then
            >&2 printf "$line\n"
        else
            printf "$line\n"
        fi

        _this_write_color_end
    fi

    if [ "$_this_logfile" != "" ]; then
        printf "$line\n" >> $_this_logfile
    fi
}

#level
_this_write_color_begin()
{
    eval "if [ \"\$LVLCOLOR_$level\" != \"\" ]; then printf \$LVLCOLOR_$level; fi"
    return 0
}

_this_write_color_end()
{
    printf '\033[0m'
    return 0
}


#text
this_trace(){
    this_log $TRACE "$1"
    return 0
}

#text
this_debug(){
    this_log $DEBUG "$1"
    return 0
}

#text
this_info(){
    this_log $INFO "$1"
    return 0
}

#text
this_warning(){
    this_log $WARNING "$1"
    return 0
}

#text
this_error(){
    this_log $ERROR "$1" 1
    return 0
}

#text
this_critical(){
    this_log $CRITICAL $1 1
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