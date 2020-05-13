#!/bin/bash
set -Eeuo pipefail
set -x

export DEBIAN_FRONTEND=noninteractive
MAKE_ARGS="UNATTENDED=y V=${MAKE_VERBOSE} PLATFORM=${MAKE_PLATFORM} TAG=${MAKE_TAG} -j"
declare -a VPPSB_PLUGINS_LINK=(
	"netlink"
	"router"
	"turbotap"
)
declare -a VPP_PLUGINS_INSTALL=(
    "sample-plugin"
    "netlink"
    "router"
    "turbotap"
)

apt-get update -y
apt-get install -y git build-essential sudo python3

git config --global core.autocrlf input
git clone --recursive "${GIT_VPP_URL}" "vpp"
git clone --recursive "${GIT_VPPSB_URL}" "vppsb"

cd vpp
git checkout "${VPP_BRANCH}"

for PLUGIN in "${VPPSB_PLUGINS_LINK[@]}"; do
    # link necessary files in
    ln -sf "../vppsb/${PLUGIN}"
    ln -sf "../../../vppsb/${PLUGIN}/${PLUGIN}.mk" "build-data/packages/"
done

make ${MAKE_ARGS} install-dep
make ${MAKE_ARGS} bootstrap # only needed on old versions (vpp <08.10)
make ${MAKE_ARGS} install-ext-deps # (vpp >=08.10)
make ${MAKE_ARGS} build-release

# build debs
make ${MAKE_ARGS} pkg-deb
make ${MAKE_ARGS} vom-pkg-deb || true # known to fail

# get rte_* headers for turbotap plugin
apt-get install -y libdpdk-dev
export LIBRARY_PATH=$LIBRARY_PATH:/usr/include/dpdk:/usr/include/x86_64-linux-gnu/dpdk:$(pwd)/src

# fix headers for router plugin
# never mind, it is going to fail anyway
cp -n src/vnet/ip-neighbor/ip6_neighbor.h src/vnet/ip/
cp -n src/vnet/arp/arp.h src/vnet/ethernet/
cp -n src/plugins/dpdk/device/*.h src/vnet/devices/dpdk/

for PLUGIN in "${VPP_PLUGINS_INSTALL[@]}"; do
    pushd build-root/
    # build the plugin (let them fail)
    make ${MAKE_ARGS} ${PLUGIN}-install || echo "WARNING: ${PLUGIN} build failed!"
    # install its headers so other plugins can link to it
    export LIBRARY_PATH=$LIBRARY_PATH:$(pwd)/install-${MAKE_TAG}-native/${PLUGIN}/include
    popd
done

# archive artifacts
# note that if $MAKE_TAG is empty, the directory is build-native and install-native
pushd build-root/
for DIRECTORY in "build-${MAKE_TAG}-native" "install-${MAKE_TAG}-native"; do
    tar -czf "${DIRECTORY}".tar.gz "${DIRECTORY}"
done
popd
