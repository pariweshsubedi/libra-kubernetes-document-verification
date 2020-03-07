#!/bin/bash
# This script is responsible to transport, compile and 
# run functional test of modules written inside modules 
# directory.

LIBRADIR="$HOME/libra"

BASEDIR=$(dirname "$0")
LIBRA_MODULES_DIR="$LIBRADIR/language/functional_tests/tests/testsuite/modules/custom_modules"
CUSTOM_MODULES_DIR="$BASEDIR/tests"

# remove custom modules
if [ -d "$LIBRA_MODULES_DIR" ]; then
    rm -rf $LIBRA_MODULES_DIR
fi

# create custom modules directory
mkdir -p $LIBRA_MODULES_DIR

#copy modules to custom_modules
scp -rp  $CUSTOM_MODULES_DIR $LIBRA_MODULES_DIR

# cd to libra directory and run the test command
cd $LIBRADIR
cargo test -p functional_tests modules/custom_modules