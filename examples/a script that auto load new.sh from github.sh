if [ "$1" != "new" ]; then 
    echo sourcing new.sh from github
    source <(curl -s "https://raw.githubusercontent.com/rafael-tonello/shellscript_utils/main/src/new.sh") "" "" 
    new_f "$0" __app__ "" 1 $@
    exit 0; 
fi


this->init(){
    echo "script called with arguments: " "$@"
}