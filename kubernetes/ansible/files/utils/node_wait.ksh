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

if [ $# -lt 2 ]; then
    echo "Usage: `basename $0`: <all|master|worker> <cluster_nodes>"
    exit 1
fi

note "$0 $*"

mode=$1
node=$2

while [ 1 ]; do
    case $mode in
        all )
            c=`/bin/kubectl get nodes | grep ' Ready ' | wc -l`
            ;;
        master )
            c=`/bin/kubectl get nodes | grep ' Ready ' | grep master | wc -l`
            ;;
        worker )
            c=`/bin/kubectl get nodes | grep ' Ready ' | grep -v master | wc -l`
            ;;
        * )
            echo "Wrong cluster mode, it should be master or worker"
            exit 2
            ;;
    esac
    
    if [ $c -ge $node ]; then
        note "k8s cluster: expected $mode $node, now $c node(s) ready, completed"
        break
    fi
    note "k8s cluster: expected $mode $node, now $c node(s) ready"
    sleep 3
done
