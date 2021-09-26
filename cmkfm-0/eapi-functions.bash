#!/usr/bin/env bash
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
    local -r module=$1

    if [[ -z ${module} ]]; then
        die 'Missed the module name parameter for `require`'
    fi

    # Try to locate the module and source it
    local -r paths=( \
        "${GITHUB_WORKSPACE}/${module}.cmkfmlib" \
        "$(dirname $0)/${module}.cmkfmlib" \
      )
    local location
    for location in "${paths[@]}"; do
        if [[ -e ${location} ]]; then
            . ${location}
            return
        fi
    done

    die "Can't find the '${module}' requested"
}

# The module exports
export -f die
export -f require
