#!/bin/bash

#git observer

#init the class. Receive as an argument the repo url and the path to the git repository
#project name is used as an unique id to create folders
this->init(){ local projectName="$1"; local repoUrl="$2"; local _gitRepoPath_="$3"; local _shm_namespace_="$4"; local _shm_directory="$5"
    this->projectName="$projectName"
    this->repoUrl="$repoUrl"
    this->gitRepoPath="$_gitRepoPath_"


    new "strutils.sh" strutils
    if [ -z "$this->gitRepoPath" ]; then

        this->gitRepoPath="$(pwd)/.gitobserver_data/repo_workdir_"$(strutils->getOnly "$this->projectName" $strutils->alphaNumericChars)
    fi


    if [ -z "$_shm_namespace_" ]; then
        _shm_namespace_="gitobserver_$(strutils->getOnly \"$this->repoUrl\" $strutils->alphaNumericChars)"
    fi

    if [ -z "$_shm_directory" ]; then
        _shm_directory="$(pwd)/.gitobserver_data"
    fi


    new "sharedmemory" "this->db" "" 1 "$_shm_namespace_" "$_shm_directory"

    new "eventstream.sh" "this->onCommit" "" 1
    new "eventstream.sh" "this->onTag" "" 1
}


#this function make all the class work
this->work(){
    #clone the repositore if the folder does not exist

    if [ ! -d "$this->gitRepoPath" ]; then
        printf "Clonign repository \n    '$this->repoUrl' in \n    $this->gitRepoPath\n"
        git clone "$this->repoUrl" "$this->gitRepoPath" > /dev/null
    fi

    #go to the git repository folder
    cd "$this->gitRepoPath"

    #the the latest commits from the repository
    git fetch --all > /dev/null

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
        
        #if the commit has a tag, emit the this->onTag event
        if [ ! -z "$commitTag" ]; then
            this->onTag->emit "$commitTag" "$commit" "$commitMessage" "$commitAuthor" "$commitDate"
        fi
        #emit the this->onCommit event
        this->onCommit->emit "$commit" "$commitMessage" "$commitAuthor" "$commitDate"
    done
    #update the last commit found in the database
    this->db->setVar lastCommit $commit
}
