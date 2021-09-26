#!/bin/bash

set -e
set -x

. "$(dirname $0)/../cmkfm-0/eapi-functions.bash"

cd "$(dirname $0)"

bash "$(dirname $0)/../build-package.sh" && echo PASSED || die FAILED
