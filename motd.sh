#!/bin/bash

clear

#
# Test whether bash supports arrays.
# (Support for arrays was only added recently.)
#
whotest[0]='test' || (echo 'Failure: arrays not supported in your version of bash. Must be at least version 4 to have associative arrays.' && exit 2)

#############################################################################
#                                SETTINGS                                   #
# Comment with a # messages you don't want displayed                        #
# Change order of items in array to change order of displayed messages      #
#############################################################################

settings=(
    #LOGOSMALL
    LOGOBIG
    SYSTEM
    DATE
    UPTIME
    MEMORY
    DISKS
    LOADAVERAGE
    PROCESSES
    IP
    # Please be aware UPDATES command may take a few seconds to run
    # If you don't like waiting, just comment it out
    UPDATES
    WEATHER
    CPUTEMP
    GPUTEMP
    SSHLOGINS
    LASTLOGIN
    MESSAGES
)

# Accuweather location codes: https://github.com/SixBytesUnder/custom-motd/blob/master/accuweather_location_codes.txt
weatherCode="EUR|UK|UK001|LONDON|"

# Show temperatures in "C" for Celsius or "F" for Fahrenheit
degrees=C

# Colour reference
#    Colour    Value
#    black       0
#    red         1
#    green       2
#    yellow      3
#    blue        4
#    magenta     5
#    cyan        6
#    white       7
declare -A colour=(
    [header]=$(tput setaf 6)
    [neutral]=$(tput setaf 2)
    [info]=$(tput setaf 4)
    [warning]=$(tput setaf 1)
    [reset]=$(tput sgr0)
)


#############################################################################
#                                                                           #
# DO NOT TOUCH ANYTHING BELOW THIS POINT, UNLESS YOU KNOW WHAT YOU'RE DOING #
#                                                                           #
#############################################################################

# Expects two arguments:
# $1 is the header
# $2 is the message
function displayMessage {
    if [ -z "$1" ]; then
        echo "${colour[neutral]}$2"
    else
        while read line; do
            echo "${colour[header]}$1 ${colour[neutral]}$line";
        done <<< "$2"
    fi
}

function metrics {
    case "$1" in
    #'LOGOSMALL')
        #logo="${colour[neutral]}
        #\\\ // ${colour[warning]}
        # ◖ ● ◗
        #◖ ● ● ◗ ${colour[neutral]}Raspberry Pi${colour[warning]}
        # ◖ ● ◗
        #   •
        #"
        #displayMessage '' "$logo"
        #;;
    'LOGOBIG')
        logo="${colour[neutral]}
        ${colour[neutral]}                                                                                

dP   dP   dP          dP .8888b  88888888b       dP                   
88   88   88          88 88   '' 88              88                   
88  .8P  .8P .d8888b. 88 88aaa  a88aaaa    .d888b88 .d8888b. .d8888b. 
88  d8'  d8' 88'   88 88 88      88        88'   88 88'   88 88ooood8 
88.d8P8.d8P  88.  .88 88 88      88        88.  .88 88.  .88 88.  ... 
8888' Y88'    88888P  dP dP      88888888P  88888P8  8888P88  88888P' 
                                                         .88          
                                                     d8888P"

        displayMessage '' "$logo"
        ;;
    'SYSTEM')
        displayMessage 'System.............:' "$(uname -snrmo)"
        ;;
    'DATE')
        displayMessage 'Date...............:' "$(date +"%A, %e %B %Y, %r")"
        ;;
    'UPTIME')
        let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
        let sec=$((${upSeconds}%60))
        let min=$((${upSeconds}/60%60))
        let hour=$((${upSeconds}/3600%24))
        let day=$((${upSeconds}/86400))
        displayMessage 'Uptime.............:' "$(printf "%d days, %02dh %02dm %02ds" "$day" "$hour" "$min" "$sec")"
        ;;
    'MEMORY')
        displayMessage 'Memory.............:' "$(cat /proc/meminfo | grep MemFree | awk {'print $2'})kB (Free) / $(cat /proc/meminfo | grep MemTotal | awk {'print $2'})kB (Total)"
        ;;
    'DISKS')
        displayMessage 'Disk...............:' "$(df -hT -x tmpfs -x vfat | grep "^/dev/" | awk '{print $1" - "$5" (Free) / "$3" (Total)"}')"
        ;;
    'LOADAVERAGE')
        read one five fifteen rest < /proc/loadavg
        displayMessage 'Load average.......:' "${one}, ${five}, ${fifteen} (1, 5, 15 min)"
        ;;
    'PROCESSES')
        displayMessage 'Running processes..:' "$(ps ax | wc -l | tr -d " ")"
        ;;
    'IP')
        lip=$(ip addr show cni0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
        eip=$(wget -q -O - http://icanhazip.com/ | tail)
        if [ "$lip" ]; then
            localIP="local: ${lip}"
        else
            localIP=""
        fi
        if [ "$eip" ]; then
            if [ "$lip" ]; then
                externalIP=", external: ${eip}"
            else
                externalIP="external: ${eip}"
            fi
        else
            externalIP=""
        fi
        displayMessage 'IP addresses.......:' "${localIP}${externalIP}"
        ;;
    'UPDATES')
        displayMessage 'Available updates..:' "$(apt-get -s dist-upgrade | tail -n 1 | cut -d' ' -f 10) packets can be updated"
        ;;
    'SSHLOGINS')
        displayMessage 'SSH logins.........:' "Currently $(who -q | cut -c "9-11" | sed "1 d") user(s) logged in."
        ;;
    'LASTLOGIN')
        displayMessage 'Last login.........:' "$(last -2 -a -F | awk 'NR==2 {print $1,"on",$3,$4,$5,$6,$7,"from " $15}')"
        ;;
        # default, do nothing
    esac
}


for K in "${!settings[@]}";
do
    metrics "${settings[$K]}"
done

echo "${colour[reset]}"
