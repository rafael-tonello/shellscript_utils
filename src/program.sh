#!/bin/bash

#program.sh

#variables that can be used to identify if the program and scheduler are loaded
PROGRAM="program"
SCHEDULER="scheduler"

program_init(){ local shellscriptUtilsPath=$1; local autoScanCurrentFolder=$2;
    #loads the shell script utils system
    local newShPath="$shellscriptUtilsPath""/new.sh"
    source "$newShPath"
    scan_folder_for_classes "$shellscriptUtilsPath"
    
    if [ "$autoScanCurrentFolder" == "1" ]; then
        scan_folder_for_classes "$(pwd)"
    fi



    #scheduler
        new "list" "scheduler_oneShotTasks" "" 1
        new "list" "scheduler_periodicTasks" "" 1
        new "list" "scheduler_delayedTasks" "" 1

        scheduler_run(){ local callback=$1
            scheduler_oneShotTasks_pushBack "$callback"
        }

        scheduler_runDelayed(){ local callback=$1; local delay_seconds=$2
            #convert seconds to miliseconds (delay_seconds can have decimal values)
            local miliseconds=$(echo "$delay_seconds * 1000" | bc)

            #remove any decimal value
            miliseconds=$(echo $miliseconds | awk '{print int($1)}')

            local initialTimeStamp=$(date +%s%3N)
            scheduler_delayedTasks_pushBack "$callback" "$miliseconds" "$initialTimeStamp"
        }

        scheduler_runPeriodically(){ local callback=$1; local interval_seconds=$2
            #convert seconds to miliseconds (interval_seconds can have decimal values)
            local miliseconds=$(echo "$interval_seconds * 1000" | bc)

            #remove any decimal value
            miliseconds=$(echo $miliseconds | awk '{print int($1)}')

            local initialTimeStamp=$(date +%s%3N)
            scheduler_periodicTasks_pushBack "$callback" "$miliseconds" "$initialTimeStamp"
        }

        
        scheduler_work(){
            scheduler_periodicTasks_forEach "__f(){
                local elementId=\"\$1\"
                local callback=\"\$2\"
                local taskTime=\"\$3\"
                local initialTimeStamp=\"\$4\"

                local currentTimeStamp=$(date +%s%3N)
                local elapsedTime=\$(( \$currentTimeStamp - \$initialTimeStamp ))
                if [ \$elapsedTime -ge \$taskTime ]; then
                    eval \"\$callback\"
                    scheduler_periodicTasks_update \"\$elementId\" \"\$callback\" \"\$taskTime\" \"\$currentTimeStamp\"
                fi

            }; __f" 1

            scheduler_delayedTasks_forEach "__f(){
                local elementId=\"\$1\"
                local callback=\"\$2\"
                local taskTime=\"\$3\"
                local initialTimeStamp=\"\$4\"

                local currentTimeStamp=$(date +%s%3N)
                local elapsedTime=\$(( \$currentTimeStamp - \$initialTimeStamp ))
                if [ \$elapsedTime -ge \$taskTime ]; then
                    eval \"\$callback\"
                    scheduler_delayedTasks_remove \"\$elementId\"
                fi
            
            }; __f" 1

            scheduler_oneShotTasks_forEach "__f(){
                local elementId=\"\$1\"
                local callback=\"\$2\"

                eval \"\$callback\"

                scheduler_oneShotTasks_remove \"\$elementId\"
            }; __f" 1
        }

        scheduler_workLoop(){ local _taskCheckInterval_=$1
            if [ "$_taskCheckInterval_" == "" ]; then
                _taskCheckInterval_=0.5
            fi

            while [ true ]; do
                scheduler_work
                sleep $_taskCheckInterval_
            done
        }

    #scheduler


}