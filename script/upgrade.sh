#!/bin/bash

######################################################
#
# Upgrade CalCentral: get code, build, db migration, and restart.
#
######################################################

cd $( dirname "${BASH_SOURCE[0]}" )/..

./script/init.d/calcentral maint

./script/update-build.sh || { echo "ERROR: update-build failed"; exit 1; }

exit 0
