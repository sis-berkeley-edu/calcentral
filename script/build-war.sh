#!/bin/bash
# Script to build and migrate a new version of a shared deployment of CalCentral.
# This is meant for running on Bamboo.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=${RAILS_ENV:-production}
export LOGGER_STDOUT=only

# Disable optimizations for faster startup
export JRUBY_OPTS="-J-Xmx900m -Xcompile.invokedynamic=false -J-Djruby.compile.mode=OFF"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Updating and rebuilding CalCentral..." | $LOGIT

GEMSET="$1"
if [ -z "$1" ]; then
  GEMSET="calcentral"
fi
rvm gemset use $GEMSET

# Load all dependencies.
echo "`date`: bundle install..." | $LOGIT
bundle install --deployment --local || { echo "ERROR: bundle install failed" ; exit 1 ; }

# Ensure that front-end static assets (HTML, JS, etc.) are in place and fingerprinted.
echo "`date`: Rebuilding static assets with npm..." | $LOGIT
./script/front-end-build.sh || { echo "ERROR: front-end build failed" ; exit 1 ; }

# The rails-admin gem requires that we also run the older Rails assets:precompile.
echo "`date`: Rebuilding static assets with rake..." | $LOGIT
bundle exec rake assets:precompile || { echo "ERROR: asset compilation failed" ; exit 1 ; }
bundle exec rake fix_assets || { echo "ERROR: asset fix failed" ; exit 1 ; }

# Stamp version number
git log --pretty=format:'%H' -n 1 > versions/git.txt || { echo "ERROR: git log command failed" ; exit 1 ; }

# copy Oracle jar into ./lib
echo "`date`: Getting external driver files..." | $LOGIT
./script/install-jars.sh 2>&1 | $LOGIT

# build the WAR
echo "`date`: Building calcentral.war..." | $LOGIT
warble || { echo "ERROR: warble failed" ; exit 1 ; }
