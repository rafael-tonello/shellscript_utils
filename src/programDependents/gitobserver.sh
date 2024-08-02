#!/bin/bash

#git observer

#init the class. Receive as an argument the repo url and the path to the git repository
#project name is used as an unique id to create folders
this->init(){ 
    #arguments
    local projectName="$1"; 
    local repoUrl="$2"; 
    local _gitRepoPath_="$3"; 
    local _shm_namespace_="$4"; 
    local _shm_directory="$5"; 
    local _aditionalGitCloneArgs_="$6"
    local _logLibObject_="$7"
    
    
    this->projectName="$projectName"
    this->repoUrl="$repoUrl"
    this->gitRepoPath="$_gitRepoPath_"
    this->additionalGitCloneArgs="$_aditionalGitCloneArgs_"
    this->logManager="$_logLibObject_"

    "$this->logManager""->newNLog" "gitobserver" "this->log"
    #CREATE A CUSTOM LOG LEVEL FOR COMMAND INTERCEPTION
    createLogLevel "COMMAND_TRACE" 25 '\033[0;34m'

    new "eventstream.sh" "this->onCommit" "" 1
    new "eventstream.sh" "this->onTag" "" 1

    new "strutils.sh" strutils
    if [ -z "$this->gitRepoPath" ]; then
        this->gitRepoPath="$(pwd)/.gitobserver_data/repo_workdir_"$(strutils->getOnly "$this->projectName" $strutils->alphaNumericChars)
    fi

    #shared memory (used as a key-value db){
        if [ -z "$_shm_namespace_" ]; then
            _shm_namespace_="gitobserver_$(strutils->getOnly \"$this->repoUrl\" $strutils->alphaNumericChars)"
        fi

        if [ -z "$_shm_directory" ]; then
            _shm_directory="$(pwd)/.gitobserver_data"
        fi
        new "sharedmemory" "this->db" "" 1 "$_shm_namespace_" "$_shm_directory"
    #}

    #schedule the periodical checking of the repository{
        #check if 'PROGRAM' is defined
        if [ ! -z "$PROGRAM" ]; then
            #add a periodic task to the scheduler
            this->log->info "Adding periodic task to the scheduler to check for new commits in the repository '$this->repoUrl' every 5 seconds"
            scheduler->runPeriodically "this->work" 5
        else
            this->log->warning "The scheduler (from program.sh) is not loaded. You must call the 'work' or 'workLoop' function by yourself to make the GitObserver work"
        fi
    #}
}

#this function make all the class work
this->work(){
    #clone the repositore if the folder does not exist
    this->log->info "checking folder $this->gitRepoPath/git"
    if [ ! -d "$this->gitRepoPath/.git" ]; then
        this->log->interceptCommandStdout "$COMMAND_TRACE" "git clone $this->additionalGitCloneArgs \"$this->repoUrl\" \"$this->gitRepoPath\""

        cd "$this->gitRepoPath"
        this->log->interceptCommandStdout "$COMMAND_TRACE" "git submodule init"
        this->log->interceptCommandStdout "$COMMAND_TRACE" "git submodule update --init --depth=1"
    fi

    cd "$this->gitRepoPath"

    this->log->interceptCommandStdout  "$COMMAND_TRACE" "git fetch --all"

    _this->checkCommitsAndTags
}

#this function is a loop that make the work function run every 5 seconds
this->workLoop(){ local _time_=$1
    if [ -z "$_time_" ]; then
        _time_=5
    fi

    while [ true ]; do
        this->work
        sleep $_time_
    done
}

_this->checkCommitsAndTags(){
    #get the last found commit from database
    local lastCommit=$(this->db->getVar lastCommit)

    #list all the commits before the 'lastCommit'
    if [ -z "$lastCommit" ]; then
        this->log->warning "The repository was just cloned. Only the last commit will be sent to the observers" #the commit is sent to observer after the 'for' over the commits

        local commits=$(git log --all --pretty=format:"%H" --reverse)
    else
        local commits=$(git log --all --pretty=format:"%H" --reverse $lastCommit..HEAD)
    fi

    #scroll all new commits (after #lastCommit)
    for commit in $commits; do
        #get the commit message
        local commitMessage=$(git log -1 --pretty=format:"%s" $commit)
        #get the commit author
        local commitAuthor=$(git log -1 --pretty=format:"%an" $commit)
        #get the commit date
        local commitDate=$(git log -1 --pretty=format:"%ad" $commit)

        #get the commit tag
        local commitTag=$(git tag --points-at $commit)
        
        #do not call onCommit if the commit is empty. It signs that the repository was just cloned and it my have a lot of commits
        if [ "$lastCommit" != "" ]; then
            #if the commit has a tag, emit the this->onTag event
            if [ ! -z "$commitTag" ]; then
                this->onTag->emit "$commitTag" "$commit" "$commitMessage" "$commitAuthor" "$commitDate"
            fi
            #emit the this->onCommit event
            this->onCommit->emit "$commit" "$commitMessage" "$commitAuthor" "$commitDate"
        fi
    done

    #in case of the repsotiory was just cloned, just the lastCommit is sent to the observers
    if [ -z "$lastCommit" ]; then
        this->onCommit->emit "$commit" "$commitMessage" "$commitAuthor" "$commitDate"
    fi

    #update the last commit found in the database
    this->db->setVar lastCommit $commit
}
