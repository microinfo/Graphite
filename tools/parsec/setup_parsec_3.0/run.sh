#!/bin/bash

# Copy parsec.conf into the config directory. This file was missing
# in the PARSEC 3.0 release.
echo "[PARSECCONF] Copy parsec.conf into the config/ directory"
cp setup_parsec_3.0/parsec.conf config/

# Populate the PARSEC directories with the build configuration needed
# for Graphite. The configuration is derived from gcc-hooks because
# we would like to have the option to simulate just the parallel
# portion of the benchmark. This command just creates the relevant
# files, the actual compiler and linker flags are put in later
echo "[BLDCONF] Populating PARSEC directories with graphite.bldconf"
./bin/bldconfadd -n graphite -s gcc-hooks -f

# Build the tools (yasm,cmake,libtool). These tools are built in
# advance so that they need not be built during the time of
# building & running the benchmarks.
echo "[BUILD] Building tools (yasm, cmake, libtool)"
./bin/parsecmgmt -a build -p tools -c graphite

# Apply changes to graphite.bldconf for the Graphite-specific
# compiler and linker flags
echo "[BLDCONF] Applying patches (CFLAGS, CXXFLAGS, LDFLAGS, LIBS) to graphite.bldconf"
patch -p1 < setup_parsec_3.0/graphite_bldconf.patch

# Apply changes for calling into Graphite when the hooks APIs'
# are called, __parsec_roi_begin() and __parsec_roi_end()
echo "[HOOKS] Applying graphite patches for hooks API"
patch -p1 < setup_parsec_3.0/hooks.patch

# Apply changes for spawning only as many threads as requested.
# By default, if N threads are requested, N+1 threads are spawned
# The changes are applied only to 5 benchmarks:
# blackscholes, swaptions, canneal, fluidanimate, streamcluster
echo "[THREADS] Applying thread spawn patches for blackscholes, swaptions, canneal, fluidanimate, streamcluster"
patch -p1 < setup_parsec_3.0/threads.patch

# Apply changes for opening file in read-only mode in freqmine.
# These changes are not required for running with Graphite but
# are put in for our regression tests to run. They do not affect
# the simulator performance/accuracy in any way.
echo "[FREQMINE] Applying open file mode patch for freqmine"
patch -p1 < setup_parsec_3.0/freqmine.patch

# Untar the simmedium inputs of PARSEC into benchmark-specific
# run/ directories. While running the benchmarks with the simulator,
# untaring inputs is unnecessary.
echo "[INPUTS] Untar'ing and setting up inputs in the run/ directory"
./setup_parsec_3.0/inputs.sh
