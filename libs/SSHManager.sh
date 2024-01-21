

this_host="";
this_username="";
this_password="";
this_useSudo="";

#remote_host, username, pasword, use_sudo_0or1
this_init() { 
    this_host=$1;
    this_username=$2;
    this_password=$3;

    if [ "$4" == "1" ]; then
        this_useSudo="sudo ";
    fi

    _this_testConnection
    if [ "$?" != "0" ]; then
        _r="Error: ssh connetion cannot be made to the destination"
        return 1
    fi

    return 0;
}

_this_testConnection(){
    this_runCmd "echo"
    return $?
}

#cmd
this_runCmd(){ 
    sshpass -p ${this_password} /usr/bin/ssh $this_username@$this_host "$this_useSudo $1";

    return $?
}

#remote_origin, remote_destination
this_moveRemote(){ 
    origin=$1
    dest=$2
    #sshpass -p ${this_password} /usr/bin/ssh $this_username@$this_host "$this_useSudo mv '$1' '$2'.bak";
    this_runCmd "mv '$origin' '$dest'"
}

#remote_origin, remote_destination
this_uploadFolder(){
    origin=$1
    dest=$2
    sshpass -p ${this_password} /usr/bin/scp -r "$origin" $this_username@$this_host:"'$dest'/"
}

#remote_origin, remote_destination
this_uploadFile(){
    origin=$1
    dest=$2
    this_runCmd "mkdir -p '$dest'"
    sshpass -p ${this_password} /usr/bin/scp "$origin" $this_username@$this_host:"'$dest'"
}
