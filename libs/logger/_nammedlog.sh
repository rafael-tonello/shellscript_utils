
#logger_objec_name, logName
_this_parent=""
_this_logName=""
this_init(){
    _this_parent=$1
    _this_logName=$2
}


#level, text, [is_an_err_default 0]
this_log(){
    level=$1
    data=$2
    isError=$3

    "$_this_parent"_log "$_this_logName" "$level" "$data" "$isError"
}

#text
this_trace(){
    "$_this_parent"_trace "$_this_logName" "$1"
    return 0
}

#text
this_debug(){
    "$_this_parent"_debug "$_this_logName" "$1"
    return 0
}

#text
this_info(){
    "$_this_parent"_info "$_this_logName" "$1"
    return 0
}

#text
this_warning(){
    "$_this_parent"_warning "$_this_logName" "$1"
    return 0
}

#text
this_error(){
    "$_this_parent"_error "$_this_logName" "$1"
    return 0
}

#text
this_critical(){
    "$_this_parent"_critical "$_this_logName" "$1"
    return 0
}

#command
this_intercept()
{
    "$_this_parent"_intercept "$_this_logName" "$1"
    return $?
}