# vpp-buildbot

Experimental nightly CI building [FD.io VPP](https://fd.io/) packages. Artifacts can be acquired from the CI.

[![Build Status](https://dev.azure.com/nekomimiswitch/General/_apis/build/status/vpp-buildbot?branchName=master)](https://dev.azure.com/nekomimiswitch/General/_build/latest?definitionId=87&branchName=master)

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

(Sadly, router and turbotap doesn't build currently.)

Branch status:

* v17.01: `Makefile:169: *** "This option currently works only on Ubuntu or Centos systems".  Stop.`
* v17.10 - v19.01: `make: *** [Makefile:264: install-dep] Error 100`