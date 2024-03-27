


#remote_host, username, pasword, use_sudo_0or1
this_init() { 
    this_host=$1
    this_username=$2
    this_password=$3

    if [ "$4" == "1" ]; then
        this_useSudo="sudo";
    fi

    _this_testConnection
    if [ "$?" != "0" ]; then
        _r="Error: ssh connetion cannot be made to the destination -> $_r"
        echo $_r
        return 1
    fi

    return 0;
}

_this_testConnection(){
    ping -c 1 $this_host > /dev/null 2>/dev/null
    local ping_result=$?
    if [ "$ping_result" != "0" ]; then
        _r="The destination host is unreachable"

        return $ping_result
    else
        this_runCmd "echo"
        local echo_result=$?
        if [ "$echo_result" != "0" ]; then
            _r="Error running a test command on remote host"
            return $echo_result
        fi;
    fi
    return 0
}

#cmd
this_runCmd(){
    #echo "Running: sshpass -p \"$this_password\" /usr/bin/ssh $this_username@$this_host \"$this_useSudo $1\""
    sshpass -p "$this_password" /usr/bin/ssh $this_username@$this_host "$this_useSudo $1"

    return $?
}

#remote_origin, remote_destination
this_moveRemote(){ 
    local origin=$1
    local dest=$2
    #sshpass -p ${this_password} /usr/bin/ssh $this_username@$this_host "$this_useSudo mv '$1' '$2'.bak";
    this_runCmd "mv '$origin' '$dest'"
    return $?
}

#remote_origin, remote_destination
this_uploadFolder(){
    local origin=$1
    local dest=$2
    sshpass -p $this_password /usr/bin/scp -r "$origin" $this_username@$this_host:"$dest"
    return $?
}

#remote_origin, remote_destination
this_uploadFile(){
    local origin=$1
    local dest=$2
    this_runCmd "mkdir -p '$dest'"
    sshpass -p $this_password /usr/bin/scp "$origin" $this_username@$this_host:"'$dest'"
    return $?
}
