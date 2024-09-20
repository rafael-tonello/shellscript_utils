if [ "$1" != "new" ]; then 
    source <(curl -s https://raw.githubusercontent.com/rafael-tonello/shellscript_utils/main/src/new.sh) "" > /dev/null
    sourceFile="$0"
    new_f "$sourceFile" __app__ "$@"
    exit $?
fi


this->init(){
    echo "init called"
}