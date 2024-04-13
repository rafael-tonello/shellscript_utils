#!/bin/bash
if [ "$1" != "new" ]; then >&2 echo "This must be included through the 'new_f' function in the file 'https://github.com/rafael-tonello/shellscript_utils/blob/main/libs/new.sh'"; exit 1; fi
lposui_current=""

this->init(){
    this->labelsCount=0
    this->defaultX=0
    this->defaultY=0
    this->radrawEveryTime=0

    if [ "$lposui_current" ==  "" ]; then
        this->show
    fi
}

this->finalize(){
    for i in $(seq 1 $this->labelsCount); do 
        eval "this->label"$i"_x"=""
        eval "this->label"$i"_y"="\"\""
        eval "this->label"$i"_text"="\"\""
        eval "this->label"$i"_prefix"="\"\""
        eval "this->label"$i"_sufix"="\"\""
        eval "this->label"$i"_color"="\"\""
    done
    clear

    this->setCursorXY $this->defaultX $this->defaultY
}

lposui_black='\033[0;30m'
lposui_red='\033[0;31m'
lposui_green='\033[0;32m'
lposui_orange='\033[0;33m'
lposui_blue='\033[0;34m'
lposui_purple='\033[0;35m'
lposui_cyan='\033[0;36m'
lposui_lightgray='\033[0;37m'
lposui_darkgray='\033[1;30m'
lposui_lightred='\033[1;31m'
lposui_lightgreen='\033[1;32m'
lposui_yellow='\033[1;33m'
lposui_lightblue='\033[1;34m'
lposui_lightpurple='\033[1;35m'
lposui_lightcyan='\033[1;36m'
lposui_white='\033[1;37m'

lposui_endcolor='\033[0m'

lposui_invalid="-//invalid//--"

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37




#newLabel(lblname, x, y, [text], [prefix], [sufix], [color], [password_text])
this->newLabel(){
    local lblName=$1
    local lblX=$2
    local lblY=$3
    local lblText=$4
    local lblPrefix=$5
    local lblSufix=$6
    local lblColor=$7
    local lblPasswordText=$8
    

    if [ "$lblName" == "" ]; then
        lblName="_"
    fi;
    
    if [ "$lblX" == "" ]; then
        lblX="0"
    fi;
    
    if [ "$lblY" == "" ]; then
        lblY="0"
    fi;
    
    if [ "$lblText" == "" ]; then
        lblText="$lposui_invalid"
    fi;
    
    if [ "$lblPrefix" == "" ]; then
        lblPrefix="$lposui_invalid"
    fi;
    
    if [ "$lblSufix" == "" ]; then
        lblSufix="$lposui_invalid"
    fi;
    
    if [ "$lblColor" == "" ]; then
        lblColor="$lposui_white"
    fi;
    
    if [ "$lblPasswordText" == "" ]; then
        lblPasswordText="$lposui_invalid"
    fi;
    

    this->labelsCount=$(( this->labelsCount + 1))
    eval "this->labelsNames_"$lblName=$this->labelsCount
    this->setLabel $lblName "$lblText" "$lblX" "$lblY" "$lblPrefix" "$lblSufix" "$lblColor" "$lblPasswordText"
}

#setLabel(lblname, text, x, y, [prefix], [sufix], [color])
this->setLabel()
{
    local lblName=$1
    local lblText=$2
    local lblX=$3
    local lblY=$4
    local lblPrefix=$5
    local lblSufix=$6
    local lblColor=$7
    local lblPasswordText=$8

    _this->getLabelIndex $lblName
    local lblIndex=$this->r
    if [ "$lblIndex" != "" ]; then  
        _this->setLabelUsingIndex $lblIndex "$lblX" "$lblY" "$lblText" "$lblPrefix" "$lblSufix" "$lblColor" "$lblPasswordText"
        return 0
    else
        _error="Label '$lblName' not found"
        return 1
    fi
}

#getLabelData
this->getLabelData()
{
    local lblName=$1
    _this->getLabelIndex $lblName
    local lblIndex=$this->r
    if [ "$lblIndex" != "" ]; then
        _this->getLabelDataUsingIndex $lblIndex
        return 0
    else
        _error="Label '$lblName' not found"
        return 1
    fi
}

this->setLabelText()
{
    this->setLabel $1 $2
}

this->setLabelColor()
{
    this->setLabel $1 "" "" "" "" "" $2
}

this->setDefaultCursorPos()
{
    this->defaultX=$1
    this->defaultY=$2
}

this->setRedrawEveryTime(){
    this->radrawEveryTime=$1
}

#_this->getLabelIndex(lblName)
_this->getLabelIndex(){
    local toEvaluate="local lblIndex=\$this->labelsNames_$1"
    eval "$toEvaluate"
    eval this->r=$lblIndex
}

#setLabelUsingIndex(lblname, x, y, text, [prefix], [sufix], [color])
_this->setLabelUsingIndex(){
    local lblIndex=$1
    local lblX=$2
    local lblY=$3
    local lblText=$4
    local lblPrefix=$5
    local lblSufix=$6
    local lblColor=$7
    local lblPasswordText=$8



    if [ "$lblX" != "" ]; then
        eval "this->label"$lblIndex"_x"="$lblX"
    fi

    if [ "$lblY" != "" ]; then
        eval "this->label"$lblIndex"_y"="\"$lblY\""
    fi

    if [ "$lblText" != "" ]; then
        eval "this->label"$lblIndex"_text"="\"$lblText\""
    fi

    if [ "$lblPrefix" != "" ]; then
        eval "this->label"$lblIndex"_prefix"="\"$lblPrefix\""
    fi

    if [ "$lblSufix" != "" ]; then
        eval "this->label"$lblIndex"_sufix"="\"$lblSufix\""
    fi

    if [ "$lblColor" != "" ]; then
        eval "this->label"$lblIndex"_color"="\"$lblColor\""
    fi

    if [ "$lblPasswordText" != "" ]; then
        eval "this->label"$lblIndex"_passwordText"="\"$lblPasswordText\""
    fi

    if [ "$this->radrawEveryTime" == 0 ]; then
        _this->drawLabel $lblIndex
        this->setCursorXY $this->defaultX $this->defaultY
    else
        _this->autoRefresh
    fi

    return 0
}

#getLabelDataUsingIndex(lblname, x, y, text, [prefix], [sufix], [color])
_this->getLabelDataUsingIndex(){
    local lblIndex=$1

    eval "_r->x=\$this->label""$lblIndex""_x"
    eval "_r->y=\$this->label""$lblIndex""_y"
    eval "_r->text=\$this->label""$lblIndex""_text"
    eval "_r->prefix=\$this->label""$lblIndex""_prefix"
    eval "_r->sufix=\$this->label""$lblIndex""_sufix"
    eval "_r->color=\$this->label""$lblIndex""_color"
    eval "_r->passwordText=\$this->label""$lblIndex""_passwordText"

    return 0
}


_this->autoRefresh()
{
    if [ "$lposui_current" == "this" ]; then
        this->forceRepaint
    fi
}

this->draw(){
    #tput clear
    for i in $(seq 1 $this->labelsCount); do 
        _this->drawLabel $i
    done

    this->setCursorXY $this->defaultX $this->defaultY

}

this->show(){
    lposui_current=this
    this->forceRepaint
}

this->forceRepaint(){
    tput clear
    this->draw
}

#this->drawLabel(labelNumber)
_this->drawLabel(){
    local obj="this->label"$1

    eval local lblName=\$$obj"_name"
    eval local lblX=\$$obj"_x"
    eval local lblY=\$$obj"_y"
    eval local lblText=\$$obj"_text"
    eval local lblPrefix=\$$obj"_prefix"
    eval local lblSufix=\$$obj"_sufix"
    eval local lblColor=\$$obj"_color"
    eval local lblPasswordText=\$$obj"_passwordText"


    if [ "$lblPasswordText" == "$lposui_invalid" ]; then
        lblPasswordText=""
    fi
    
    if [ "$lblPrefix" == "$lposui_invalid" ]; then
        lblPrefix=""
    fi

    if [ "$lblSufix" == "$lposui_invalid" ]; then
        lblSufix=""
    fi

    if [ "$lblText" == "$lposui_invalid" ]; then
        lblText=""
    fi


    if [ "$lblColor" != "" ]; then 
        local lblPrefix=$lblColor$lblPrefix; 
        local lblSufix=$lblSufix$lposui_endcolor 
    fi

    #echo running _this->setCursorXY $lblX $lblY
    this->setCursorXY $lblX $lblY

    #echo runnint printf "$lblPrefix$lblText$lblSufix"
    if [ "$lblPasswordText" != "" ]; then
        printf "$lblPrefix$lblPasswordText$lblSufix"
    else
        printf "$lblPrefix$lblText$lblSufix"
    fi
}

#_this->setCursorXY(x, y)
this->setCursorXY(){
    tput cup $2 $1
}