# HEPWARE

Software commonly used in High-Energy Physics is specialized,
and finding up-to-date versions of it in the packages of any
given OS is almost impossible. Most of it needs to be compiled
by hand. Because compiling by hand also involves compiling the
dependencies too, the process is tedious and error-prone.

This is where *hepware* comes in: we package instructions to
install various libraries and tools. E.g. to install [FORM] along
with all of its dependencies, get *hepware* and simply type:

    make form.done -jN

... where `N` is the number of threads the build process is
allowed to use in parallel (set this to the number of cores the
build machine has).

To install all the packages *hepware* has, run:

    make all.done -jN

## Where is the software placed?

Into the subdirectories. Binaries go into `bin/`, include files
into `include/`, libraries into `lib/`. Software that can not
be properly installed into these directories is placed into
subdirectories of `shared/`.

To use the installed programs you'll probably want to add the
`bin/` subdirectory to your `PATH`, for example using

    export PATH=/path/to/hepware/bin:$PATH

Similarly, to use the libraries you'll need to add
`-I/path/to/hepware/include` flag to your C compiler options and
`-L/path/to/hepware/lib` flag to your linker options. How to do
this depends on the software you are trying to compile.

## What is required?

* A Linux system with recent C (GCC or Clang), C++ (GCC or Clang),
  and Fortran (GFortran) compilers, the newer the better.

* The standard set of standard GNU development tools (i.e. `make`,
  `sed`, etc).

* [CMake].

* Autotools.

MacOS, FreeBSD, and other operating systems might or might not
work.

[cmake]: https://cmake.org/

## Available software

* [CLN] (`cln.done`).
* [Fermat] (`fermat.done`).
* [Feynson] (`feynson.done`).
* [FIRE6] (`fire6.done`).
* [FireFly] (`firefly.done`).
* [FLINT] (`flint.done`).
* [Forcer] (`forcer.done`).
* [FORM] (`form.done`).
* [Fuchsia] (`fuchsia.done`).
* [GiNaC] (`ginac.done`).
* [GMP] (`gmp.done`).
* [Google Benchmark] (`googlebenchmark.done`).
* [Hypothread] (`hypothread.done`).
* [Jemalloc] (`jemalloc.done`).
* [Kira] (`kira.done`).
* [MPFR] (`mpfr.done`).
* [Nauty and Traces] (`nauty.done`).
* [QGraf] (`qgraf.done`).
* [Ratnormal] (`ratnormal.done`).
* [Ratracer] (`ratracer.done`).
* [Yaml-cpp] (`yaml-cpp.done`).
* [zlib] (`zlib.done`).

[cln]: https://www.ginac.de/CLN/
[fermat]: http://home.bway.net/lewis
[feynson]: https://github.com/magv/feynson
[fire6]: https://bitbucket.org/feynmanIntegrals/fire/
[firefly]: https://gitlab.com/firefly-library/firefly
[flint]: https://flintlib.org/
[forcer]: https://github.com/benruijl/forcer
[form]: https://github.com/vermaseren/form
[fuchsia]: https://github.com/magv/fuchsia.cpp
[ginac]: https://www.ginac.de/
[gmp]: https://gmplib.org/
[google benchmark]: https://github.com/google/benchmark
[hypothread]: https://github.com/magv/hypothread
[jemalloc]: http://jemalloc.net/
[kira]: https://gitlab.com/kira-pyred/kira
[mpfr]: https://www.mpfr.org/
[nauty and traces]: https://pallini.di.uniroma1.it/
[qgraf]: http://cfif.ist.utl.pt/~paulo/qgraf.html
[ratnormal]: https://github.com/magv/ratnormal
[ratracer]: https://github.com/magv/ratracer
[yaml-cpp]: https://github.com/jbeder/yaml-cpp
[zlib]: https://www.zlib.net/
