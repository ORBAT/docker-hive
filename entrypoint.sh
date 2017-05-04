#!/bin/bash

function addProperty() {
  local path=$1
  local name=$2
  local value=$3

  local entry="<property><name>$name</name><value>${value}</value></property>"
  local escapedEntry=$(echo $entry | sed 's/\//\\\//g')
  sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path
}

function log() {
    if [[ -z "$SILENT" ]]; then
    echo $@
    fi
}

function configure() {
    local module=$1
    local envPrefix=$2

    local var
    local value

    log "Configuring $module"
    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/_/g; s/_/./g'`
        var="${envPrefix}_${c}"
        value=${!var}
        log " - Setting $name=$value"
        addProperty /opt/hive/conf/$module-site.xml $name "$value"
    done
}

configure hive HIVE_SITE_CONF

set -x
exec "$@"