#!/bin/bash
if [ "$1" != "new" ]; then >&2 echo "This must be included through the 'new_f' function in the file 'https://github.com/rafael-tonello/shellscript_utils/blob/main/libs/new.sh'"; exit 1; fi

#logger_objec_name, logName
_this->parent=""
_this->logName=""
this->init(){
    _this->parent=$1
    _this->logName=$2
}

this->finalize(){ echo; }

#level, text, [break_line_default_1], [is_an_err_default 0]
this->log(){
    level=$1
    data=$2
    breakLine=$3
    isError=$4

    "$_this->parent"_log "$_this->logName" "$level" "$data" "$breakLine" "$isError"
}

#text, [break_line_default_1]
this->trace(){
    "$_this->parent"_trace "$_this->logName" "$1"
    return 0
}

#text, [break_line_default_1]
this->debug(){
    "$_this->parent"_debug "$_this->logName" "$1" "$2"
    return 0
}

#text, [break_line_default_1]
this->info(){
    "$_this->parent"_info "$_this->logName" "$1" "$2"
    return 0
}

#text, [break_line_default_1]
this->warning(){
    "$_this->parent"_warning "$_this->logName" "$1" "$2"
    return 0
}

#text, [break_line_default_1]
this->error(){
    "$_this->parent"_error "$_this->logName" "$1" "$2"
    return 0
}

#text, [break_line_default_1]
this->critical(){
    "$_this->parent"_critical "$_this->logName" "$1" "$2"
    return 0
}

#command
this->intercept()
{
    "$_this->parent"_intercept "$_this->logName" "$1"
    return $?
}