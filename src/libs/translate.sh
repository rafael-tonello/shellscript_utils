

this->scriptLocation=$3
declare -gA _this->translations
declare -gA _this->translationsNotFound

this->defaultLangDir="$(pwd)/lang"

#initializes the translation object. The first parameter is the file with the translations
#if destLangFile was not provided, the current system language will be assumed and the 
#folder informed in 'this->defaultLangDir' (in the current directory) will be used
this->init(){ local destLangFile="$1"

    this->getSystemLanguage >> /tmp/test.txt


    if [ "$destLangFile" == "" ]; then
        mkdir -p "$this->defaultLangDir"
        local sysLang=$(this->getSystemLanguage)
        destLangFile="$this->defaultLangDir/$sysLang"
    fi
    destLangFile_notFounds="$destLangFile"".notFound"

    new_f "$this->scriptLocation""/../utils/strutils.sh" _this->strUtils "" 0
    this->cutChar="="
    

    _this->destLangFile="$(realpath "$destLangFile")"
    _this->notFoundsFile="$(realpath "$destLangFile_notFounds")"
    

    _this->loadTranslationFile "$destLangFile"
    _this->loadTranslationsNotFoundFile "$_this->notFoundsFile"


}

this->getSystemLanguage(){
    local sysLang=$(locale | grep LANG | cut -d= -f2 | cut -d. -f1)
    echo $sysLang
}

_this->fixName(){
    _this->strUtils->getOnly_2 "$1"
    echo "$_r"
}

_this->loadTranslationFile(){ local fname=$1
    if [[ ! -f "$fname" ]]; then
        return 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        #key=$(echo $line | cut -d"$this->cutChar" -f1)
    
        key=$(_this->strUtils->cut "$line" "$this->cutChar" 1)
        key=$(_this->fixName "$key")
        
        value=$(_this->strUtils->cut "$line" "$this->cutChar" 2)
    
        if [ "$key" == "charsep" ]; then
            this->cutChar=$value
        elif [ "$key" != "" ]; then
            _this->translations[$key]=$value
        fi
    done < "$fname"

    return 0
}

_this->loadTranslationsNotFoundFile(){ local fname=$1
    if [[ ! -f "$fname" ]]; then
        return 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        key=$(_this->strUtils->cut "$line" "$this->cutChar" 1)
        key=$(_this->fixName "$key")

        #value=$(_this->strUtils->cut "$line" "$this->cutChar" 2)
        value="no value"

        if [ "$key" != "" ]; then
            _this->translationsNotFound[$key]=$value
        fi
    done < "$fname"

    return 0
}

#translates a text. If the text is not found, it is saved to the notFounds file and the original text is returned
#the text (and the translation) can have placeholders (%%). The placeholders are replaced by the arguments passed 
#to the function (after the text)
this->t(){ local text="$1"

    key=$(_this->fixName "$text")
    
    local tmp=$text
    

    local found=${_this->translations[$key]}
    if [ "$found" != ""  ]; then
        tmp=${_this->translations[$key]}
    else
        _this->registerUnsavedTranslations "$text"
    fi
       
    tmp="\"$tmp\""
    shift
    for args; do 
        tmp="$tmp \"$args\""
    done  

    eval "_this->strUtils->replaceSeq_2 \"%%\" $tmp";


    #print using tr to remove possible \r from lines
    printf "$_r" | tr -d '\r'
    #echo $testVar | tr -d '\r'
}

this->tAll(){ local text="$@"
    this->t "$text"
    return $?
}

_this->registerUnsavedTranslations(){ local text=$1
    key=$(_this->fixName "$text")

    local found=${_this->translationsNotFound[$key]}
    if [ "$found" == ""  ]; then
        #FIX: TODO: this set will not work sometimes because the this->t can be called in a subshell
        _this->translationsNotFound[$key]="$text"
        #save to notfounds file
        echo "$text=" >> "$_this->notFoundsFile"
    fi
#
}
