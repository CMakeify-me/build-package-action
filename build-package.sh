#!/bin/bash

set -e
set -x

function die()
{
    local -r message="$1"
    echo "ERROR: ${message}" 1>&2
    exit 1
}

if [[ -d debian ]]; then
    /bin/bash "$(dirname $0)/build-deb.sh"

elif [[ -d SPECS ]]; then
    die 'RPM package builder not implemented yet'

fi
