# vpp-buildbot

Experimental nightly CI building [FD.io VPP](https://fd.io/) packages. DEBs and artifacts can be acquired from the CI. CI failure is usual. 

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

[🎵\~Your build system is a hall of shame\~🎵](https://www.youtube.com/watch?v=nSKp2StlS6s)

VPP is a software engineering disaster. Here's why.

### Things that do not work

#### Documentation

The documentation is outdated, unmaintained and not consistent. The mailing list is not helpful either. 

#### Make targets that do not work

**vom-pkg-deb**: build system is broken

```
@@@@ Installing vom @@@@
[0/1] Install the project...
-- Install configuration: ""
-- Set runtime path of "/root/vpp/build-root/install-vpp-native/vom/lib/libvom.so.20.09" to "/root/vpp/build-root/install-vpp-native/vom/lib"
ninja: error: unknown target 'package'
make[1]: *** [/root/vpp/build-data/packages/vom.mk:44: vom-package-deb] Error 1
make[1]: Leaving directory '/root/vpp/build-root'
make: *** [Makefile:608: vom-pkg-deb] Error 2
```

#### `vppsb` plugins that do not build

**router**: code does not even compile

```
/root/vpp/build-data/../router/router/tap_inject_netlink.c:19:10: fatal error: vnet/ip/ip6_neighbor.h: No such file or directory
 #include <vnet/ip/ip6_neighbor.h>                                
          ^~~~~~~~~~~~~~~~~~~~~~~~                
compilation terminated.            
make[1]: *** [Makefile:493: router/tap_inject_netlink.lo] Error 1
make[1]: *** Waiting for unfinished jobs....
/root/vpp/build-data/../router/router/tap_inject_node.c: In function ‘tap_inject_tap_send_buffer’:
/root/vpp/build-data/../router/router/tap_inject_node.c:45:13: warning: implicit declaration of function ‘writev’; did you mean ‘write’? [-Wimplicit-function-declaration]
   n_bytes = writev (fd, &iov, 1);
             ^~~~~~
             write
/root/vpp/build-data/../router/router/tap_inject_node.c: In function ‘tap_rx’:
/root/vpp/build-data/../router/router/tap_inject_node.c:181:29: error: ‘VLIB_BUFFER_DATA_SIZE’ undeclared (first use in this function); did you mean ‘VLIB_BUFFER_PRE_DATA_SIZE’?
 #define MTU_BUFFERS ((MTU + VLIB_BUFFER_DATA_SIZE - 1) / VLIB_BUFFER_DATA_SIZE)
                             ^~~~~~~~~~~~~~~~~~~~~
/root/vpp/build-data/../router/router/tap_inject_node.c:189:20: note: in expansion of macro ‘MTU_BUFFERS’
   struct iovec iov[MTU_BUFFERS];
                    ^~~~~~~~~~~
/root/vpp/build-data/../router/router/tap_inject_node.c:181:29: note: each undeclared identifier is reported only once for each function it appears in
 #define MTU_BUFFERS ((MTU + VLIB_BUFFER_DATA_SIZE - 1) / VLIB_BUFFER_DATA_SIZE)
                             ^~~~~~~~~~~~~~~~~~~~~
/root/vpp/build-data/../router/router/tap_inject_node.c:189:20: note: in expansion of macro ‘MTU_BUFFERS’
   struct iovec iov[MTU_BUFFERS];
                    ^~~~~~~~~~~
/root/vpp/build-data/../router/router/tap_inject_node.c:205:13: warning: implicit declaration of function ‘vlib_buffer_alloc_from_free_list’; did you mean ‘vlib_buffer_alloc_from_pool’? [-Wimplicit-function-declaration]
       len = vlib_buffer_alloc_from_free_list (vm,
             ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             vlib_buffer_alloc_from_pool
/root/vpp/build-data/../router/router/tap_inject_node.c:207:21: error: ‘VLIB_BUFFER_DEFAULT_FREE_LIST_INDEX’ undeclared (first use in this function); did you mean ‘VLIB_BUFFER_DEFAULT_DATA_SIZE’?
                     VLIB_BUFFER_DEFAULT_FREE_LIST_INDEX);
                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                     VLIB_BUFFER_DEFAULT_DATA_SIZE
/root/vpp/build-data/../router/router/tap_inject_node.c:231:13: warning: implicit declaration of function ‘readv’; did you mean ‘read’? [-Wimplicit-function-declaration]
   n_bytes = readv (fd, iov, MTU_BUFFERS);
             ^~~~~
             read
/root/vpp/build-data/../router/router/tap_inject_node.c:190:7: warning: unused variable ‘bi’ [-Wunused-variable]
   u32 bi[MTU_BUFFERS];
       ^~
/root/vpp/build-data/../router/router/tap_inject_node.c:189:16: warning: unused variable ‘iov’ [-Wunused-variable]
   struct iovec iov[MTU_BUFFERS];
                ^~~
make[1]: *** [Makefile:493: router/tap_inject_node.lo] Error 1
make[1]: Leaving directory '/root/vpp/build-root/build-vpp-native/router'
make: *** [Makefile:695: router-build] Error 2
```

**turbotap**: build system is broken

```
@@@@ Arch for platform 'vpp' is native @@@@
@@@@ Finding source for vppinfra @@@@
@@@@ Package vppinfra not found with path /root/vpp/build-root/.. @@@@
make: *** [Makefile:777: vppinfra-find-source] Error 1
make: *** Waiting for unfinished jobs....
@@@@ Arch for platform 'vpp' is native @@@@
@@@@ Finding source for dpdk @@@@
@@@@ Package dpdk not found with path /root/vpp/build-root/.. @@@@
make: *** [Makefile:777: dpdk-find-source] Error 1
```

### Things that do not always work

`vppsb` is not release tagged along with `vpp` and only has a `master` branch. So basically you'd expect anything in `vppsb` to break at any time. Plus there is no one really maintaining `vppsb`, although it is used everywhere in the docs, demos and quickstarts. 

VPP v20.01 _sometimes_ fail with the following error during a `make -j build-release`:

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

(If no `-j`, it will always fail.)

### Distro Lock-in

The build system is massively f***ed up with loads of hardcoded things and assumptions about the system. There is no reproducible build procedure available either. The [doc](https://wiki.fd.io/view/VPP/Build,_install,_and_test_images) is pretty outdated and doesn't work. 

Branches that do not build on distros other than Ubuntu and CentOS:

* v17.01 and earlier: `Makefile:169: *** "This option currently works only on Ubuntu or Centos systems".  Stop.`
* v17.10 - v19.01: `make: *** [Makefile:264: install-dep] Error 100`
