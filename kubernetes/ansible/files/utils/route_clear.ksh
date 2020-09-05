#!/bin/ksh

function DATE
{
    echo `date +%Y-%m-%d_%H:%M:%S%Z`
}

function note
{
    if type log > /dev/null 2>&1; then
        log "NOTE: `DATE` $*"
    else
        print "NOTE: `DATE` $*"
    fi
}

function run_cmd
{
    echo "Run command: <$*>" >> $LOG_FILE
    eval $*
    if [ $? -ne 0 ]
    then
        exit 1
    fi
}

SCRIPT_NAME=${0##*/} # base name
LOG_FILE=/var/tmp/${SCRIPT_NAME}.log
> $LOG_FILE

if [ $# -ge 2 ]; then
    echo "Usage: `basename $0`"
    exit 1
fi

note "Clear k8s network plugin route info"

for cidr in `ip route list | grep bird | grep unreachable | awk ' { print $2 } '`; do
    note "Delete route $cidr"
    run_cmd ip route del $cidr
done

for cidr in `ip route list | egrep '(bird|flannel|cni)' | awk ' { print $1 } '`; do
    note "Delete route $cidr"
    run_cmd ip route del $cidr
done

