#!/bin/bash
#
# cmkfm-0 EAPI functions
#

function die()
{
    local -r message="$1"
    echo "ERROR: ${message}" 1>&2
    exit 1
}

function require()
{
    declare -r module=$1

    if [[ -z ${module} ]]; then
        die 'Missed the module name parameter for `require`'
    fi

    . "$(dirname $0)/${module}.cmkfmlib"
}
