#!/bin/bash
# This script starts libra cli with two account

# set ulimit
ulimit -n 10000

LIBRADIR="$HOME/libra"

BASEDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
LOGS_DIR="$BASEDIR/custom_logs"

# remove custom modules
if [ -d "$LOGS_DIR" ]; then
    rm -rf $LOGS_DIR
fi

mkdir -p $LOGS_DIR

# cd to libra directory and run the test command
cd $LIBRADIR

# with logs
#RUST_BACKTRACE=1 cargo run -p libra-swarm -- -s -l -c $LOGS_DIR

# without logs
RUST_BACKTRACE=1 cargo run -p libra-swarm -- -s -l

#account list
#account create
#account create
# account mint 0 100
#dev compile 0 /Users/pariweshsubedi/Desktop/UiS/4thsem/project/modules/tests/course.mvir module
#dev publish 0 <path>
#dev compile 1 /Users/pariweshsubedi/Desktop/UiS/4thsem/project/scripts/course/register-course.mvir script
#dev execute 1 <path>
#query txn_acc_seq 1 0 true 
