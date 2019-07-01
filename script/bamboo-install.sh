#!/bin/bash
# Script to install necessary dependencies, for use on Bamboo CI

# set up environment
export JRUBY_OPTS="-Xcompile.invokedynamic=false -J-Xmx900m -J-Djruby.compile.mode=OFF"

cd $( dirname "${BASH_SOURCE[0]}" )/..

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc
GEMSET="$1"
if [ -z "$1" ]; then
  GEMSET="calcentral"
fi
rvm gemset use $GEMSET

# get Ruby deps
bundle install --local --retry 3 || { echo "WARNING: bundle install --local failed, running bundle install"; bundle install --retry 3 || { echo "ERROR: bundle install failed"; exit 1; } }
bundle package --all || { echo "WARNING: bundle package failed"; exit 1; }
