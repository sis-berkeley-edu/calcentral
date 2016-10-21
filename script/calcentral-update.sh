#!/bin/bash

######################################################
#
# Run Capistrano
#
######################################################

cd $( dirname "${BASH_SOURCE[0]}" )/..

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=${RAILS_ENV:-production}
export LOGGER_STDOUT=only

# JVM args per CalCentral convention
source script/standard-calcentral-JVM-OPTS-profile

echo "------------------------------------------"
echo "$(date): Redeploying CalCentral on app nodes..."

echo "$(date): cap calcentral_dev:update..."

cap -l STDOUT calcentral_dev:update || { echo "ERROR: capistrano deploy failed" ; exit 1 ; }

exit 0
