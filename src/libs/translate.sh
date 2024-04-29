

this->scriptLocation=$3
declare -gA _this->translations
declare -gA _this->translationsNotFound

#initializes the translation object. The first parameter is the file with the translations
this->init(){ local destLangFile=$1
    new_f "$this->scriptLocation""/../utils/strutils.sh" _this->strUtils
    this->cutChar="="
    
    _this->destLangFile="$destLangFile"
    _this->notFoundsFile="$destLangFile"".notFound"
    

    _this->loadTranslationFile "$destLangFile"
    _this->loadTranslationsNotFoundFile "$_this->notFoundsFile"


}

_this->fixName(){
    _this->strUtils->getOnly "$1"
    echo "$_r"
}

_this->loadTranslationFile(){ local fname=$1
    if [[ ! -f "$fname" ]]; then
        return 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        #key=$(echo $line | cut -d"$this->cutChar" -f1)
    
        key=$(_this->strUtils->cut_2 "$line" "$this->cutChar" 1)
        key=$(_this->fixName "$key")
        
        value=$(_this->strUtils->cut_2 "$line" "$this->cutChar" 2)
    
        if [ "$key" == "charsep" ]; then
            this->cutChar=$value
        else
            #value=$(echo $line | cut -d"$this->cutChar" -f2-)
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
        key=$(_this->strUtils->cut_2 "$line" "$this->cutChar" 1)
        key=$(_this->fixName "$key")

        #value=$(_this->strUtils->cut_2 "$line" "$this->cutChar" 2)
        value="no value"

        _this->translationsNotFound[$key]=$value
    done < "$fname"

    return 0
}

#translates a text. If the text is not found, it is saved to the notFounds file and the original text is returned
this->t(){ local text=$1
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

    eval "_this->strUtils->replace \"%%\" $tmp";
    printf "$_r"
}

_this->registerUnsavedTranslations(){ local text=$1
    key=$(_this->fixName "$text")

    local found=${_this->translationsNotFound[$key]}
    if [ "$found" == ""  ]; then
        _this->translationsNotFound[$key]="$text"

        #save to notfounds file
        echo "$text=" >> "$_this->notFoundsFile"
    fi
#
}
