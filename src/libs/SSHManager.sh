#!/bin/bash
if [ "$1" != "new" ]; then >&2 echo "This must be included through the 'new_f' function in the file 'https://github.com/rafael-tonello/shellscript_utils/blob/main/libs/new.sh'"; exit 1; fi

#remote_host, username, pasword, use_sudo_0or1

dirname=$3
autoinit=0; new "utils/strutils.sh" this->strUtils
autoinit=0; new "utils/utils.sh" this->utils

this->init() { 
    this->host=$1
    this->username=$2
    this->password=$3

    if [ "$4" == "1" ]; then
        this->useSudo="sudo";
    fi

    _this->testConnection
    if [ "$?" != "0" ]; then
        this->utils->derivateError "$_error" "Error: ssh connetion cannot be made to the destination"
        return 1
    fi

    return 0;
}

_this->testConnection(){
    _error=""
    ping -c 1 $this->host > /dev/null 2>/dev/null
    local ping_result=$?
    if [ "$ping_result" != "0" ]; then
        _error="The destination host ($this->host) is unreachable"

        return $ping_result
    else
        this->runCmd "echo"
        local echo_result=$?
        if [ "$echo_result" != "0" ]; then
            this->utils->derivateError "$_error" "Error running a test command on remote host ($this->host)"
            return $echo_result
        fi;
    fi
    return 0
}

#cmd
this->runCmd(){
    _error=""
    #echo "Running: sshpass -p \"$this->password\" /usr/bin/ssh $this->username@$this->host \"$this->useSudo $1\""
    rm /tmp/runCmdResult >/dev/null 2> /dev/null
    (sshpass -p "$this->password" /usr/bin/ssh $this->username@$this->host "$this->useSudo $1") > /tmp/runCmdResult 2> /tmp/runCmdResult
    local _retCode=$?
    _r=$(cat /tmp/runCmdResult)
    this->strUtils->getOnly_2 "$_r" "abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPQRSTUVXYWZ0123456789_=> " #removes some line returns and other strange chars from ssh output
    #_r=$_r
    if [ "$_retCode" != "0" ]; then
        #_error=$_r
        this->utils->derivateError "$_error" "$_r"
        if [[ $_error == *"Permission denied"* ]]; then
            this->utils->derivateError "$_error" "username or password may be wrong or another authentication error may have occurred"
        fi
        _r=""
    fi

    return $_retCode
}

#remote_origin, remote_destination
this->moveRemote(){ 
    local origin=$1
    local dest=$2
    #sshpass -p ${this->password} /usr/bin/ssh $this->username@$this->host "$this->useSudo mv '$1' '$2'.bak";
    this->runCmd "mv '$origin' '$dest'"
    return $?
}

#remote_origin, remote_destination
this->uploadFolder(){
    local origin=$1
    local dest=$2
    sshpass -p $this->password /usr/bin/scp -r "$origin" $this->username@$this->host:"$dest"
    return $?
}

#remote_origin, remote_destination
this->uploadFile(){
    local origin=$1
    local dest=$2
    this->runCmd "mkdir -p '$dest'"
    sshpass -p $this->password /usr/bin/scp "$origin" $this->username@$this->host:"'$dest'"
    return $?
}

#originstring, destinationstring, #progresscallback. This function runs with subshell and uses 'script' instead sshpass
this->transferFileWithProgress(){
    local origin="$1"
    local dest="$2"
    local callback="$3"

    this->runCmd "mkdir -p '$dest'"

    local progressFile="/tmp/$RANDOM$(date +%s)"
    local doneFile="/tmp/$RANDOM$(date +%s)"

    echo "" > $doneFile

    (__f(){
        local lastScpData=""
        local scpdata=""
        while [ true ]; do
            scpdata=$(tail -n1 $progressFile)
            
            scpdata=$(echo -n "$scpdata" | grep -o '[^ ]*%')
            scpdata=$(echo -n "$scpdata" | sed 's/%//')

            scpdata=$(echo $scpdata | sed 's/\r//')
            scpdata=$(echo $scpdata | sed 's/.*[[:space:]]\([^[:space:]]*\)/\1/')
            
            if [ "$lastScpData" != "$scpdata" ]; then
                eval "$callback \"$scpdata\""
            fi;

            lastScpData=$scpdata
            sleep 0.25

            local doneState=$(cat $doneFile)
            if [ "$doneState" == "stop" ]; then
                eval "$callback \"100\""
                echo "stopped" > $doneFile
                break
            fi

            scpdata=""
        done
    }; __f &)

    { sleep 2; echo $this->password; } | script -q /dev/null -c "/usr/bin/scp \"$originstring\" \"$destinationstring\"" > $progressFile
    local retCode=$?
    
    echo "stop"> $doneFile
    while [ true ]; do
        local doneState=$(cat $doneFile)
        if [ "$doneState" == "stopped" ]; then
            break;
        fi
        sleep 0.25
    done

    return $retCod
}


this->uploadFileWithProgress(){
    this->transferFileWithProgress "$1" "$this->username@$this->host:\"$2\"" "$3"
    return $?
}

#_this_get_onlye(source, [valid_chars])
_this_get_only(){
    # Define the original string and the valid characters
    original_string=$1
    valid_characters=$2

    if [ "$valid_characters" == "" ]; then
        valid_characters="abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPQRSTUVXYWZ0123456789_"
    fi

    # Initialize an empty string to store the valid characters
    valid_string=""

    # Iterate through each character in the original string
    for ((i=0; i<${#original_string}; i++)); do
        # Get the character at position i
        char="${original_string:i:1}"
        
        # Check if the character is present in the valid characters string
        if [[ $valid_characters == *"$char"* ]]; then
            # If present, append it to the valid string
            valid_string+="$char"
        fi
    done

    # Print the valid string
    _r=$valid_string
    return 0
}

this->downloadFile(){
    local origin=$1
    local dest=$2
    sshpass -p $this->password /usr/bin/scp $this->username@$this->host:"$origin" "$dest"
    return $?
}

this->downloadFolder(){
    local origin=$1
    local dest=$2
    sshpass -p $this->password /usr/bin/scp -r $this->username@$this->host:"$origin" "$dest"
    return $?
}

this->downloadFileWithProgress(){
    this->transferFileWithProgress "$this->username@$this->host:\"$1\"" "$2" "$3"
    return $?
}