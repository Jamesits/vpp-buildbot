# vpp-buildbot

Experimental nightly CI building [FD.io VPP](https://fd.io/) packages. DEBs and artifacts can be acquired from the CI.

[![Build Status](https://dev.azure.com/nekomimiswitch/General/_apis/build/status/vpp-buildbot?branchName=master)](https://dev.azure.com/nekomimiswitch/General/_build/latest?definitionId=87&branchName=master)

## Status

Currently building branches:

* v19.04
* v19.08
* v20.01
* master

Currently building distros:

* Debian 10

Currently building plugins:

* sample-plugin
* netlink

## Hall of Shame

[🎵~Your build system is a hall of shame~🎵](https://www.youtube.com/watch?v=nSKp2StlS6s)

### Things that do not always work

VPP v20.01 _sometimes_ fail with the following error during a `make build-release`:

```
[987/1813] Building C object vnet/CMakeFiles/vnet.dir/arp/arp_api.c.o
FAILED: vnet/CMakeFiles/vnet.dir/arp/arp_api.c.o 
ccache /usr/lib/ccache/cc -DHAVE_FCNTL64 -DHAVE_MEMFD_CREATE -DWITH_LIBSSL=1 -Dvnet_EXPORTS -I/root/vpp/src -I. -Iinclude -Wno-address-of-packed-member -g -fPIC -Werror -Wall -march=corei7 -mtune=corei7-avx  -O2 -fstack-protector -DFORTIFY_SOURCE=2 -fno-common  -fPIC -MD -MT vnet/CMakeFiles/vnet.dir/arp/arp_api.c.o -MF vnet/CMakeFiles/vnet.dir/arp/arp_api.c.o.d -o vnet/CMakeFiles/vnet.dir/arp/arp_api.c.o   -c /root/vpp/src/vnet/arp/arp_api.c
/root/vpp/src/vnet/arp/arp_api.c:23:10: fatal error: vpp/app/version.h: No such file or directory
 #include <vpp/app/version.h>
          ^~~~~~~~~~~~~~~~~~~
compilation terminated.
ninja: build stopped: subcommand failed.
make[1]: *** [Makefile:695: vpp-build] Error 1
make[1]: Leaving directory '/root/vpp/build-root'
make: *** [Makefile:388: build-release] Error 2
```

### Make targets that do not work

* vom-pkg-deb

### vppsb plugins that do not build

 * router (code does not even compile)
 * turbotap (build system is broken)

### Branch that do not build on distro other than Ubuntu and CentOS

* v17.01 and earlier: `Makefile:169: *** "This option currently works only on Ubuntu or Centos systems".  Stop.`
* v17.10 - v19.01: `make: *** [Makefile:264: install-dep] Error 100`
