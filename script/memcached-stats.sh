#!/bin/bash
# Script to summarize memcached usage and effectiveness.

# Make sure the normal shell environment is in place.
source "$HOME/.bash_profile"

DT=$(date +"%Y-%m-%d")

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG="$PWD/log/memcached_stats_$DT.log"
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=${RAILS_ENV:-production}
export LOGGER_STDOUT=only
export LOGGER_LEVEL=INFO
export JRUBY_OPTS="--dev"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT

cd deploy

bundle exec rake memcached:get_stats | $LOGIT
