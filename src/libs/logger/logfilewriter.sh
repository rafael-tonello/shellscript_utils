this->init(){ local fileName="$1"; local _maxFileSize_="$2";
    _this->logfile="$fileName"
    if [ -z "$_maxFileSize_" ]; then
        _maxFileSize_=1000000
    fi

    this->maxFileSize=$_maxFileSize_
    #compact log file if it is too big
    this->checkAndCompactFile "$_this->logfile" $this->maxFileSize

    this->currentAddedLines=0
}

#line, logLevel, isError, colorbegin, colorend
this->log(){ local line=$1; local level=$2; local isError=$3
    printf "$line" >> "$_this->logfile"
    this->currentAddedLines=$(( this->currentAddedLines + 1 ))
    if [ $this->currentAddedLines -gt 100 ]; then
        this->checkAndCompactFile "$_this->logfile" $this->maxFileSize
        this->currentAddedLines=0
    fi
}

#check if the file is too big and compact it
this->checkAndCompactFile(){ local file=$1; local maxFileSize=$2
    if [ -f "$file" ]; then
        local fileSize=$(stat -c %s "$file")
        if [ $fileSize -gt $maxFileSize ]; then
            #use date to get a unique name (format year-month-day-hour-minute-second)
            local compressedFileName="$file.$(date +%Y-%m-%d-%H-%M-%S)"

            #get file extension
            local extension="${file##*.}"
            
            #move current file to a temporary file
            local tmpFile="$compressedFileName"."$extension"
            mv "$file" "$tmpFile"

            #launch a background process to compress the file
            (
                #check if 7zip is installed
                if [ -x "$(command -v 7z)" ]; then
                    7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "$compressedFileName".7z "$tmpFile".7z
                else
                    #create a tar.gz file (if tar is present)
                    if [ -x "$(command -v tar)" ]; then
                        tar -czf "$compressedFileName".tar.gz "$tmpFile".tar.gz
                    else
                        #if 7zip is not installed, use gzip
                        gzip "$tmpFile".gz
                    fi
                fi

                #remove the temporary file
                rm "$tmpFile"
            ) &
            
        fi
    fi
}

