#!/bin/bash
if [ "$1" != "new" ]; then >&2 echo "This must be included through the 'new_f' function in the file 'https://github.com/rafael-tonello/shellscript_utils/blob/main/libs/new.sh'"; exit 1; fi

#remote_host, username, pasword, use_sudo_0or1

dirname=$3
echo "$dirname"
new_f "$dirname/../strutils.sh" this->strUtils

this->init() { 
    this->host=$1
    this->username=$2
    this->password=$3

    if [ "$4" == "1" ]; then
        this->useSudo="sudo";
    fi

    _this->testConnection
    if [ "$?" != "0" ]; then
        _r="Error: ssh connetion cannot be made to the destination ==> $_r"
        echo $_r
        return 1
    fi

    return 0;
}

_this->testConnection(){
    ping -c 1 $this->host > /dev/null 2>/dev/null
    local ping_result=$?
    if [ "$ping_result" != "0" ]; then
        _r="The destination host ($this->host) is unreachable"

        return $ping_result
    else
        this->runCmd "echo"
        local echo_result=$?
        if [ "$echo_result" != "0" ]; then
            _r="Error running a test command on remote host ($this->host) ==> $_error"
            return $echo_result
        fi;
    fi
    return 0
}

#cmd
this->runCmd(){
    #echo "Running: sshpass -p \"$this->password\" /usr/bin/ssh $this->username@$this->host \"$this->useSudo $1\""
    rm /tmp/runCmdResult >/dev/null 2> /dev/null
    (sshpass -p "$this->password" /usr/bin/ssh $this->username@$this->host "$this->useSudo $1") > /tmp/runCmdResult 2> /tmp/runCmdResult
    local _retCode=$?
    _r=$(cat /tmp/runCmdResult)
    this->strUtils->getOnly_2 "$_r" "abcdefghijklmnopqrstuvxywzABCDEFGHIJKLMNOPQRSTUVXYWZ0123456789_=> " #removes some line returns and other strange chars from ssh output
    #_r=$_r
    if [ "$_retCode" != "0" ]; then
        _error=$_r
        if [[ $_error == *"Permission denied"* ]]; then
            _error=$_r
            _error="$_error (username or password may be wrong or another authentication error may have occurred)"
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