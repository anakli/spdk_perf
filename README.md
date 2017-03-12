Storage Performance Development Kit
===================================

Intel's Storage Performance Development Kit (SPDK) provides a set of tools
and libraries for writing high performance, scalable, user-mode storage
applications. It achieves high performance by moving all of the necessary
drivers into userspace and operating in a polled mode instead of relying on
interrupts, which avoids kernel context switches and eliminates interrupt
handling overhead.

[SPDK on 01.org](https://01.org/spdk)


Local Flash load generator based on SPDK perf app
=================================================

This fork of SPDK v16.06 provides a modified version of the nvme `perf` example application to generate load for a local Flash performance test. The original application is modified to report read and write percentile latencies. The load generator is also modified to be open-loop, so you can sweep throughput by specifying a target IOPS instead of queue depth. You can use this load generator to precondition an SSD and/or run performance tests.

If you are using [ReFlex](https://github.com/stanford-mast/reflex), a software-based system that provides remote access to Flash at the performance of local Flash, you may find this load generator useful for preconditioning your SSD and running performance tests with different read/write ratios and request sizes to derive the request cost model. 


Setup instructions for ReFlex users
====================================

Follow the instructions below if you are using [ReFlex](https://github.com/stanford-mast/reflex) and have completed setup instructions 1-5 in the Reflex README. Otherwise follow instructions for general users in the next section.

    # running an SPDK app requires installing DPDK
    # we can use source code in reflex/deps/dpdk directory
    cd PATH_TO_REFLEX/reflex/deps/dpdk
    make install T=x86_64-native-linuxapp-gcc DESTDIR=.
    cd ../../..
    
    # fetch SPDK modified app code and compile
    git clone https://github.com/anakli/spdk_perf.git
    cd spdk_perf
    make DPDK_DIR=../reflex/deps/dpdk/x86_64-native-linuxapp-gcc
    
    # SPDK hugepage setup
    sudo mkdir -p /mnt/huge
    sudo mount -t hugetlbfs nodev /mnt/huge

   
    cd examples/nvme/perf
	# modify run_perf.sh with your desired rd/wr ratio, req size, number of cores, target IOPS, etc.
    # run SPDK application to precondition SSD and/or do performance testing for cost model
    sudo ./precondition.sh precond.csv
    sudo ./run_perf.sh results.csv

    # teardown spdk app hugepage setup to get ready to run ReFlex
    sudo umount /mnt/huge
    cat /proc/meminfo | grep Huge
    # if no free hugepages, delete lingering hugepage files on other mount points for hugetlbfs
    #  $ cd /dev/hugepages
	#  $ rm -f rtemap* 
    cd PATH_TO_REFLEX/reflex


Setup instructions for general users
====================================


## Documentation

[Doxygen API documentation](http://spdk.io/spdk/doc/) is available, as
well as a [Porting Guide](PORTING.md) for porting SPDK to different frameworks
and operating systems.

Many examples are available in the `examples` directory.

## Prerequisites

To build SPDK, some dependencies must be installed.

Fedora/CentOS:

    sudo dnf install -y gcc libpciaccess-devel CUnit-devel libaio-devel
    # Additional dependencies for NVMf:
    sudo dnf install -y libibverbs-devel librdmacm-devel

Ubuntu/Debian:

    sudo apt-get install -y gcc libpciaccess-dev make libcunit1-dev libaio-dev
    # Additional dependencies for NVMf:
    sudo apt-get install -y libibverbs-dev librdmacm-dev

FreeBSD:

- gcc
- libpciaccess
- gmake
- cunit

Additionally, [DPDK](http://dpdk.org/doc/quick-start) is required.

    1) cd /path/to/spdk
    2) wget http://dpdk.org/browse/dpdk/snapshot/dpdk-16.04.tar.gz
    3) tar xfz dpdk-16.04.tar.gz

Linux:

    4) (cd dpdk-16.04 && make install T=x86_64-native-linuxapp-gcc DESTDIR=.)

FreeBSD:

    4) (cd dpdk-16.04 && gmake install T=x86_64-native-bsdapp-clang DESTDIR=.)

## Building


Once the prerequisites are installed, run 'make' within the SPDK directory
to build the SPDK libraries and examples.

    make DPDK_DIR=/path/to/dpdk

If you followed the instructions above for building DPDK:

Linux:

    make DPDK_DIR=./dpdk-16.04/x86_64-native-linuxapp-gcc

FreeBSD:

    gmake DPDK_DIR=./dpdk-16.04/x86_64-native-bsdapp-clang

## Hugepages and Device Binding

Before running an SPDK application, some hugepages must be allocated and
any NVMe and I/OAT devices must be unbound from the native kernel drivers.
SPDK includes a script to automate this process on both Linux and FreeBSD.
This script should be run as root.

    sudo scripts/setup.sh

## Examples

Example code is located in the examples directory. The examples are compiled
automatically as part of the build process. Simply call any of the examples
with no arguments to see the help output. You'll likely need to run the examples
as a privileged user (root) unless you've done additional configuration
to grant your user permission to allocate huge pages and map devices through
vfio.
