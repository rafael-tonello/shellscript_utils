this->init(){ local fileName=$1
    _this->logfile=$fileName
}

#line, logLevel, isError, colorbegin, colorend
this->log(){ local line=$1; local level=$2; local isError=$3
    printf "$line" >> $_this->logfile
}

