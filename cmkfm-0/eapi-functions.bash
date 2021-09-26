#!/usr/bin/env bash
#
# cmkfm-0 EAPI functions
#

function v_option()
{
    local -r vrb_cnt=$(( ${VERBOSE} - 1 ))
    [[ ${VERBOSE} > 1 ]] && echo "-$(eval printf 'v%.0s' {1..${vrb_cnt}})"
}

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
        "$(dirname $0)/cmkfmlibs/${module}.cmkfmlib" \
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
export -f v_option
export -f die
export -f require
