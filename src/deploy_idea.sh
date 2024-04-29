#!/bin/sh

_this_testQueue=()
_this_testQueueLastIndice=-1
_this_testQueueLastConsumed=-1

_this_finalized=0
_this_appName=""

_this_telegramChatId=""
_this_repositoryUrl=""

_this_logger="object that will be started in the init method"
_this_log="object that will be started in the init method"
_this_telegram="object that will be started in the init method"
_this_gh="object that will be started in the init method"


#appName
this_init(){
    _this_appName=$1
    _this_telegramChatId=$2
    _this_repositoryUrl=$3

    new_f libs/logger/logger.sh _this_logger
    _this_logger_newNLog deploy _this_log
    _this_log_info "System is initializing"

    _this_log_info "Initializing Telegram service ..."
    new_f libs/TelegramHelper _this_telegram
    tr=$(_this_telegram_init "$_this_telegramChatId")
    if [ "$?" != "0" ]; then
        _this_log_error "... error starting Telegram. ↩\n↪$tr"
    fi


    _this_log_info "Starting up Git internal service ..."
    new_f GitHelper _this_gh
    gt=$(_this_gh_init "$_this_repositoryUrl" "$HOME/.$_this_appName/ToMonitor")
    if [ "$?" == "0" ]; then
        _this_gh_onChangeBranch "*" "_this_testBranch"
        _this_gh_onChangeBranch "main" "_this_deployNewVersion"
        #gh_onChangeBranch "main" "thistmpf1(){ do things };thistmpf1"
        _this_gh_startMonitorChangesInTheBranches
    else
        _this_log_error "... error starting Telegram. ↩\n↪$gr"
    fi

    _this_log_info "Starting branch test worker ..."
    _this_startConsumeTestQueue &

    _this_log_info "\nThe systes is started!"
}

this_finalize(){
    _this_finalized=1
    _this_gh_finalize
    _this_log_finalize
    _this_logger_finalize

    unset _this_testQueue
    unset _this_testQueueLastIndice
    unset _this_testQueueLastConsumed
    unset _this_appName
    unset _this_telegramChatId
    unset _this_repositoryUrl
    unset _this_logger
    unset _this_log
    unset _this_telegram
    unset _this_gh
}

#branchename
_this_testBranch(){
    branchName=$1
    _this_testQueueLastIndice=$(( _this_testQueueLastIndice + 1 ))
    _this_testQueue[$_this_testQueueLastIndice]=$branchName
    return 0
}

_this_deployNewVersion(){
    _this_checkoutMainBranch
    _this_testBranch "main" "$HOME/.$_this_appName/Deploying" "$HOME/.$_this_appName/deploy.log"

}

_this_startConsumeTestQueue(){
    while [ "$_this_finalized" == "0"]; do
        

        if [ "$_this_testQueueLastConsumed" -lt "$_this_testQueueLastIndice" ]; then
            local tmp=$_this_testQueueLastConsumed
            _this_testQueueLastConsumed=$(( _this_testQueueLastConsumed + 1 ))
            local item=$_this_testQueue[$_this_testQueueLastConsumed]
            unset $_this_testQueue[$tmp]

            _this_runDequeuedTest "$item" "$HOME/.$_this_appName/Testing" "$HOME/.$_this_appName/tests.log"
        else
            sleep 1
        fi
    done;
}

#branchName, workFolder, logFile
_this_runDequeuedTest(){
    local branchName=$1 
    local workFolder=$2
    local logFile=$3

    _this_telegram_sendText "Testing branch '$branchName' ..."

    _this_testBranch $branchName $workFolder $logFile
    result=$?
    if [ "$result" == "0" ]
        _this_telegram_sendText "... Branch '$branchName' tested with sucess"
    else
        _this_telegram_sendText "... !!!!!! Test of '$branchName' failed !!!!!!"
    fi
    _this_telegram_sendDocument "$logFile"
    rm "$logfile"
    return $result
}

#branchName, workFolder, logFile
_this_testBranch(){
    local branchName=$1 
    local workFolder=$2
    local logFile=$3

    rm -rf "$workFolder"
    
    new_f GitHelper _this_tmpGh
    _this_tmpGh_init "$(__this_gh_getUrl)" "$workFolder"

    cd $workFolder/tests
    make all
    cd $workFolder/tests/build
    ./tests >> $logFile 2>> $logFile
    _this_tmpGh_finalize
    rm -rf "$workFolder"
    return $?
}