#!/bin/bash

set -e
[[ ${VERBOSE:-0} > 1 ]] && set -x

if [[ ! -d debian ]]; then
    die 'The `debian/` directory not found in the repository root'
fi

# BEGIN Prepare
echo '::group::Prepare'

declare -r PN=$(head -n1 debian/changelog | sed 's,\([^ ]\+\).*,\1,')
declare -r PV=$(head -n1 debian/changelog | sed 's,^[^(]\+(\([0-9]\+\(\.[0-9]\+\)*\(-rc[0-9]\)\?\).*,\1,')

if [[ -e ./package.cmkfme-0 ]]; then
    . ./package.cmkfme-0
else
    die 'The repository must have the `package.cmkfme-0` script'
fi

mkdir $(v1_option) -p build

cd build

echo '::endgroup::'
# END Prepare

# BEGIN Downloading the release tarball
echo '::group::Downloading the release tarball'

if [[ -n ${DOWNLOAD} ]]; then
    wget -T 30 ${DOWNLOAD}
else
    die 'The `package.cmkfme-0` script must export the `DOWNLOAD` variable set to the URL of the package tarball'
fi

echo '::endgroup::'
# END Downloading the release tarball

# BEGIN Unpack
echo '::group::Unpacking the tarball'

mkdir $(v1_option) -p "${PN}_${PV}"

cd "${PN}_${PV}"

# TODO Support for non-tar archives (?)
tar -xf ../${DOWNLOAD##*/} --strip-components=1

cp $(v1_option) --reflink=auto -r ../../debian .

echo '::endgroup::'
# END Unpack

# BEGIN Pre-installing build dependencies
echo '::group::Pre-installing build dependencies'

apt-get update

mk-build-deps -i -r -t 'apt-get -y'

echo '::endgroup::'
# END Pre-installing build dependencies

# BEGIN Building packages
echo '::group::Building packages'

DEB_BUILD_OPTIONS="parallel=$(nproc) ${DEB_BUILD_OPTIONS} nocheck" dpkg-buildpackage -b -nc -uc

echo '::endgroup::'
# END Building packages

# BEGIN Signing packages
echo '::group::Signing packages'

if [[ ${#GPG_PRIVATE_KEY} > 0 ]]; then
    [[ ${VERBOSE:-0} > 1 ]] && set +x
    echo -e "${GPG_PRIVATE_KEY}" | gpg $(v_option) --import --batch --no-tty
    [[ ${VERBOSE:-0} > 1 ]] && set -x
    dpkg-sig $(v1_option) --sign cmkfm -- ../*.deb
fi

echo '::endgroup::'
# END Signing packages
