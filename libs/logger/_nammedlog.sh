
#logger_objec_name, logName
_this_parent=""
_this_logName=""
this_init(){
    _this_parent=$1
    _this_logName=$2
}

this_finalize(){ echo; }

#level, text, [break_line_default_1], [is_an_err_default 0]
this_log(){
    level=$1
    data=$2
    breakLine=$3
    isError=$4

    "$_this_parent"_log "$_this_logName" "$level" "$data" "$breakLine" "$isError"
}

#text, [break_line_default_1]
this_trace(){
    "$_this_parent"_trace "$_this_logName" "$1"
    return 0
}

#text, [break_line_default_1]
this_debug(){
    "$_this_parent"_debug "$_this_logName" "$1" "$2"
    return 0
}

#text, [break_line_default_1]
this_info(){
    "$_this_parent"_info "$_this_logName" "$1" "$2"
    return 0
}

#text, [break_line_default_1]
this_warning(){
    "$_this_parent"_warning "$_this_logName" "$1" "$2"
    return 0
}

#text, [break_line_default_1]
this_error(){
    "$_this_parent"_error "$_this_logName" "$1" "$2"
    return 0
}

#text, [break_line_default_1]
this_critical(){
    "$_this_parent"_critical "$_this_logName" "$1" "$2"
    return 0
}

#command
this_intercept()
{
    "$_this_parent"_intercept "$_this_logName" "$1"
    return $?
}