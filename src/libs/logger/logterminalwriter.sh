#new "logger" "this->logManager"
#new "logterminalwriter" "this->logTerminalWriter"
#this->logManager->addWriter this->logTerminalWriter

this->init(){
    :;
}

#line, logLevel, isError, colorbegin, colorend
this->log(){ local line=$1; local level=$2; local isError=$3
    #cat not implemented error to stderr
    
    _this->write_color_begin $level
    if [ "$isError" ==  "1" ]; then
        >&2 printf "$line"
    else
        printf "$line" 2>/dev/shm/printferrooutput
        if [ "$printferr" != "" ]; then
            echo "printf error, redirecting to echo:  $lblText"
        fi
    fi
    _this->write_color_end
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