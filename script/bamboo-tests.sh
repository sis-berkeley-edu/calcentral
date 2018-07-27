#!/bin/bash
# Script to install necessary dependencies and then run unit tests, for use on Bamboo CI

# set up environment
export RAILS_ENV=${RAILS_ENV:="test"}
export DISPLAY=":99"
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
./script/front-end-build.sh

# set up Xvfb for headless browser testing
if [ ! -f /tmp/.X99-lock ];
then
    Xvfb :99 -screen 0 1440x900x16 &
fi

# run the tests
if [ "$2" == "uitest" ]; then
  # run UI tests if we've been given a second arg
  echo "Running UI tests with RAILS_ENV=$RAILS_ENV"
  export UI_TEST=true
  bundle exec rake spec:xml
elif [ $RAILS_ENV == "test" ]; then
  echo "Running tests with fixtures"
  bundle exec rake assets:clean spec:xml
fi
