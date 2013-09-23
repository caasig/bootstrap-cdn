#!/usr/bin/env bash
####

# Usage
####
function usage() {
echo "
Usage ./scripts/deploy.sh /path/to/config.sh

   Example:
   $ ./scripts/deploy.sh ./_deploy.sh

   Note: Default config is './_deploy.sh'.

Via make:

   make deploy # uses './_deploy.sh'
"
exit 1;
}

# Debug
####
test "$DEBUG" && set -x
set -e

config="`dirname $0`/../_deploy.conf"
if test "$1"; then
  config=$1
fi

source $config

# Ensure configuration.
####

# Defaults
test "$ssh_flags" || ssh_flags=""
test "$branch"    || branch=`git rev-parse --abbrev-ref HEAD`

# Required
test "$hostname"   || usage
test "$username"   || usage
test "$location"   || usage
test "$repository" || usage

####

ssh $ssh_flags $username@$hostname bash <<EOSH
  if test -f /tmp/.deploy.lock; then
    echo 'Another deployment is in progress on this host.'
    echo ' '
    echo 'If you feel you have reached this message in error,'
    echo 'log on to the target host and remove:'
    echo ' '
    echo ' /tmp/.deploy.lock'
    exit 1
  else
    touch /tmp/.deploy.lock
    test -d $location || git clone $repository $location
    cd $location
    git checkout $branch
    git pull
    make clean setup || exit 1
    make restart || make start
    rm /tmp/.ypu.deploy.lock
  fi
EOSH

# vim: ft=sh:
