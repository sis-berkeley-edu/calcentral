#!/bin/bash
# Script to build and migrate a new version of a shared deployment of CalCentral.
# This is meant for running on Bamboo.

main() {
  # Set working directory to project root
  cd $( dirname ${BASH_SOURCE[0]} )/..

  LOG=`date +"log/start-stop_%Y-%m-%d.log"`
  LOGIT="tee -a $LOG"
  export RAILS_ENV=${RAILS_ENV:-production}
  export LOGGER_STDOUT=only
  export JRUBY_OPTS="-Xcompile.invokedynamic=false -J-Xmx900m -J-Djruby.compile.mode=OFF"

  initRuby
  bundleGems
  buildFrontEnd
  compileAssets
  getJar
  gitVersion
  buildWarfile
}

initRuby() {
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
  source .rvmrc

  GEMSET="$1"
  if [ -z "$1" ]; then
    GEMSET="calcentral"
  fi
  rvm gemset use $GEMSET
}

bundleGems() {
  echo "`date`: bundle install..." | $LOGIT
  bundle install --deployment --local || { echo "ERROR: bundle install failed"; exit 1; }
}

buildFrontEnd() {
  echo "`date`: Rebuilding static assets with npm..." | $LOGIT
  ./script/front-end-build.sh || { echo "ERROR: front-end build failed" ; exit 1 ; }
}

compileAssets() {
  echo "`date`: Rebuilding static assets with rake..." | $LOGIT
  bundle exec rake assets:precompile || { echo "ERROR: asset compilation failed" ; exit 1 ; }
  bundle exec rake fix_assets || { echo "ERROR: asset fix failed" ; exit 1 ; }
}

# copy Oracle jar into ./lib
getJar() {
  echo "`date`: Getting external driver files..." | $LOGIT
  ./script/install-jars.sh 2>&1 | $LOGIT
}

gitVersion() {
  git log --pretty=format:'%H' -n 1 > versions/git.txt || { echo "ERROR: git log command failed" ; exit 1 ; }
}

buildWarfile() {
  echo "`date`: Building calcentral.war..." | $LOGIT
  bundle exec warble
}

main
