#!/bin/bash

######################################################
#
# Upgrade CalCentral: get code, build, db migration, and restart.
#
######################################################

cd $( dirname "${BASH_SOURCE[0]}" )/..

HOST=$(uname -n)

if [[ "${HOST}" = *-01\.ist.berkeley.edu ]]; then
  IS_NODE_ONE="yes"
fi

./script/init.d/calcentral maint

./script/update-build.sh || { echo "ERROR: update-build failed"; exit 1; }

# run migrate.sh only if we are on node 1
if [ "X${IS_NODE_ONE}" != "X" ]; then
  ./script/migrate.sh
fi

exit 0
