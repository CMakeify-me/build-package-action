#!/bin/bash

set -e
[[ ${VERBOSE:-0} > 2 ]] && set -x

. "$(dirname $0)/cmkfm-0/eapi-functions.bash"

if [[ -d debian ]]; then
    . "$(dirname $0)/build-deb.sh"

elif [[ -d SPECS ]]; then
    die 'RPM package builder not implemented yet'

fi
