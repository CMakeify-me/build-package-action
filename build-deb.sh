#!/bin/bash

set -e
set -x

function die()
{
    local -r message="$1"
    echo "ERROR: ${message}" 1>&2
    exit 1
}

if [[ ! -d debian ]]; then
    die 'The `debian/` directory not found in the repository root'
fi

# BEGIN Downloading the release tarball
echo '::group::Downloading the release tarball'

declare -r PN=$(head -n1 debian/changelog | sed 's,\([^ ]\+\).*,\1,')
declare -r PV=$(head -n1 debian/changelog | sed 's,^[^(]\+(\([0-9]\+\(\.[0-9]\+\)*\(-rc[0-9]\)\?\).*,\1,')

if [[ -e ./package.cmkfme-0 ]]; then
    . ./package.cmkfme-0
else
    die 'The repository must have the `package.cmkfme-0` script'
fi

mkdir -pv build

cd build

if [[ -n ${DOWNLOAD} ]]; then
    wget -T 30 ${DOWNLOAD}
else
    die 'The `package.cmkfme-0` script must export the `DOWNLOAD` variable set to the URL of the package tarball'
fi

echo '::endgroup::'
# END Downloading the release tarball

# BEGIN Unpack
echo '::group::Unpacking the tarball'

mkdir -pv "${PN}_${PV}"

cd "${PN}_${PV}"

# TODO Support for non-tar archives (?)
tar -xf ../${DOWNLOAD##*/} --strip-components=1

cp --reflink=auto -vr ../../debian .

echo '::endgroup::'
# END Unpack

# BEGIN Prepare
echo '::group::Prepare'

if [[ $(type -t src_prepare) == 'function' ]]; then
    src_prepare
fi

echo '::endgroup::'
# END Prepare

# BEGIN Pre-installing build dependencies
echo '::group::Pre-installing build dependencies'

apt-get update

mk-build-deps -i -r -t 'apt-get -y'

echo '::endgroup::'
# END Pre-installing build dependencies

# BEGIN Building packages
echo '::group::Building packages'

DEB_BUILD_OPTIONS="parallel=$(nproc) nocheck" dpkg-buildpackage -b -nc -uc

echo '::endgroup::'
# END Building packages

# BEGIN Signing packages
echo '::group::Signing packages'

if [[ ${#GPG_PRIVATE_KEY} > 0 ]]; then
    set +x
    echo -e "${GPG_PRIVATE_KEY}" | gpg --import --batch --no-tty
    set -x
    dpkg-sig --sign cmkfm -- ../*.deb
fi

echo '::endgroup::'
# END Signing packages