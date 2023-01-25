# HEPWARE

Software commonly used in High-Energy Physics is specialized,
and finding up-to-date versions of it in the packages of any
given OS is almost impossible. Most of it needs to be compiled
by hand. Because compiling by hand also involves compiling the
dependencies too, the process is tedious and error-prone.

This is where *hepware* comes in: we package instructions to
install various libraries and tools. E.g. to install [FORM] along
with all of its dependencies, get *hepware*, and simply type:

    make form.done

## Where is the software placed?

Into the subdirectories. Binaries go into `bin/`, include files
into `include/`, libraries into `lib/`.

## What is required?

A Linux system with recent C (GCC or Clang), C++ (GCC or Clang),
and Fortran (GFortran) compilers. The newer the better. MacOS,
FreeBSD, and other operating systems might or might not work.

## Available software

* [CLN] (`cln.done`).
* [Feynson] (`feynson.done`).
* [FLINT] (`flint.done`).
* [FORM] (`form.done`).
* [Fuchsia] (`fuchsia.done`).
* [GiNaC] (`ginac.done`).
* [GMP] (`gmp.done`).
* [Hypothread] (`ratnormal.done`).
* [Jemalloc] (`jemalloc.done`).
* [MPFR] (`mpfr.done`).
* [Nauty and Traces] (`nauty.done`).
* [QGraf] (`qgraf.done`).
* [Ratnormal] (`ratnormal.done`).
* [zlib] (`zlib.done`).

[cln]: https://www.ginac.de/CLN/
[feynson]: https://github.com/magv/feynson
[flint]: https://flintlib.org/
[form]: https://github.com/vermaseren/form
[fuchsia]: https://github.com/magv/fuchsia.cpp
[ginac]: https://www.ginac.de/
[gmp]: https://gmplib.org/
[hypothread]: https://github.com/magv/hypothread
[jemalloc]: http://jemalloc.net/
[mpfr]: https://www.mpfr.org/
[nauty and traces]: https://pallini.di.uniroma1.it/
[qgraf]: http://cfif.ist.utl.pt/~paulo/qgraf.html
[ratnormal]: https://github.com/magv/ratnormal
[zlib]: https://www.zlib.net/
