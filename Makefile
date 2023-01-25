CC=cc
CXX=c++
FC=gfortran

all: phony
	@echo "This is HEPWARE. Type '${MAKE} <software>.done' or '${MAKE} all.done'."

all.done: \
	cln.done \
	feynson.done \
	flint.done \
	form.done \
	ginac.done \
	gmp.done \
	jemalloc.done \
	mpfr.done \
	nauty.done \
	qgraf.done \
	zlib.done \
	phony

clean: phony
	rm -rf bin/ build/ include/ lib/ share/ *.done

phony:;

DIR=${CURDIR}
DEP_CFLAGS=-I${DIR}/include -O3 -fno-omit-frame-pointer -fdata-sections -ffunction-sections
DEP_FFLAGS=-I${DIR}/include -O3
DEP_LDFLAGS=-L${DIR}/lib

build/.dir:
	mkdir -p bin build include lib share
	date >$@

build/jemalloc.tar.bz2: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/jemalloc/jemalloc/releases/download/5.3.0/jemalloc-5.3.0.tar.bz2"

jemalloc.done: build/jemalloc.tar.bz2 build/.dir
	rm -rf build/jemalloc-*/
	cd build && tar xf jemalloc.tar.bz2
	cd build/jemalloc-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		./configure \
			--prefix="${DIR}" --libdir="${DIR}/lib" \
			--includedir="${DIR}/include" --bindir="${DIR}/bin" \
			--enable-static --disable-shared \
			--disable-stats --disable-libdl --disable-doc
	+${MAKE} -C build/jemalloc-*/
	+${MAKE} -C build/jemalloc-*/ install
	date >$@

build/gmp.tar.xz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz"

gmp.done: build/gmp.tar.xz
	rm -rf build/gmp-*/
	cd build && tar xf gmp.tar.xz
	cd build/gmp-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		./configure \
			--prefix="${DIR}" --libdir="${DIR}/lib" \
			--includedir="${DIR}/include" --bindir="${DIR}/bin" \
			--enable-static --disable-shared --enable-cxx
	+${MAKE} -C build/gmp-*/
	+${MAKE} -C build/gmp-*/ install
	date >$@

build/mpfr.tar.xz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://www.mpfr.org/mpfr-4.1.1/mpfr-4.1.1.tar.xz"

mpfr.done: build/mpfr.tar.xz gmp.done
	rm -rf build/mpfr-*/
	cd build && tar xf mpfr.tar.xz
	cd build/mpfr-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		./configure \
			--prefix="${DIR}" --libdir="${DIR}/lib" \
			--includedir="${DIR}/include" --bindir="${DIR}/bin" \
			--enable-static --disable-shared --enable-thread-safe
	+${MAKE} -C build/mpfr-*/
	+${MAKE} -C build/mpfr-*/ install
	date >$@

build/flint.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"http://flintlib.org/flint-2.9.0.tar.gz"

flint.done: build/flint.tar.gz gmp.done mpfr.done
	rm -rf build/flint-*/
	cd build && tar xf flint.tar.gz
	cd build/flint-*/ && \
		./configure \
			--prefix="${DIR}" --enable-static --disable-shared \
			CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS} -ansi -pedantic -Wall -O3 -funroll-loops -g"
	+${MAKE} -C build/flint-*/ QUIET_CC="" QUIET_CXX="" QUIET_AR=""
	+${MAKE} -C build/flint-*/ install
	date >$@

build/zlib.tar.xz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"http://zlib.net/zlib-1.2.13.tar.xz"

zlib.done: build/zlib.tar.xz
	rm -rf build/zlib-*/
	cd build && tar xf zlib.tar.xz
	cd build/zlib-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" \
		./configure \
			--prefix="${DIR}" --static
	+${MAKE} -C build/zlib-*/
	+${MAKE} -C build/zlib-*/ install
	date >$@

build/qgraf.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		--user anonymous --password anonymous \
		"http://qgraf.tecnico.ulisboa.pt/v3.6/qgraf-3.6.5.tgz"

qgraf.done: build/qgraf.tar.gz
	rm -rf build/qgraf/
	mkdir -p build/qgraf bin
	cd build/qgraf && tar xf ../qgraf.tar.gz
	cd build/qgraf && ${FC} ${DEP_FFLAGS} -o qgraf qgraf-*.f08
	mv build/qgraf/qgraf bin/
	date >$@

build/form.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/vermaseren/form/releases/download/v4.3.0/form-4.3.0.tar.gz"

form.done: build/form.tar.gz gmp.done zlib.done
	rm -rf build/form-*/
	cd build && tar xf form.tar.gz
	cd build/form-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		./configure \
			--prefix="${DIR}" --libdir="${DIR}/lib" \
			--includedir="${DIR}/include" --bindir="${DIR}/bin" \
			--with-zlib="${DIR}" --with-gmp="${DIR}" \
			--enable-scalar=yes --enable-threaded=yes \
			--enable-parform=no \
			--enable-static-link=no \
			--enable-native=no
	+${MAKE} -C build/form-*/
	+${MAKE} -C build/form-*/ install
	date >$@

build/cln.tar.bz2: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://www.ginac.de/CLN/cln-1.3.6.tar.bz2"

cln.done: build/cln.tar.bz2 gmp.done
	rm -rf build/cln-*/
	cd build && tar xf cln.tar.bz2
	cd build/cln-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		./configure \
			--prefix="${DIR}" --libdir="${DIR}/lib" \
			--includedir="${DIR}/include" --bindir="${DIR}/bin" \
			--with-gmp="${DIR}" \
			--disable-rpath \
        		--with-pic \
			--enable-shared=no --enable-static=yes
	+${MAKE} -C build/cln-*/
	+${MAKE} -C build/cln-*/ install
	date >$@

build/ginac.tar.bz2: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://www.ginac.de/ginac-1.8.5.tar.bz2"

ginac.done: build/ginac.tar.bz2 cln.done
	rm -rf build/ginac-*/
	cd build && tar xf ginac.tar.bz2
	cd build/ginac-*/ sed -i.bak 's/readline/NOreadline/g' configure
	cd build/ginac-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		./configure \
			--prefix="${DIR}" --libdir="${DIR}/lib" \
			--includedir="${DIR}/include" --bindir="${DIR}/bin" \
			--enable-shared=no --enable-static=yes --with-pic --enable-excompiler=no 
			--disable-rpath \
			CLN_CFLAGS="" CLN_LIBS="-lcln"
	+${MAKE} -C build/ginac-*/
	+${MAKE} -C build/ginac-*/ install
	date >$@

build/nauty.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://pallini.di.uniroma1.it/nauty2_8_6.tar.gz"

nauty.done: build/nauty.tar.gz build/.dir
	rm -rf build/nauty*/
	cd build && tar xf nauty.tar.gz
	cd build/nauty*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		./configure \
			--prefix="${DIR}" --libdir="${DIR}/lib" \
			--includedir="${DIR}/include" --bindir="${DIR}/bin" \
			--disable-popcnt --disable-clz --enable-generic
	+${MAKE} -C build/nauty*/
	cd build/nauty*/ && cp -a dreadnaut "${DIR}/bin/"
	cd build/nauty*/ && cp -a nauty.a "${DIR}/lib/libnauty.a"
	cd build/nauty*/ && cp -a *.h "${DIR}/include/"
	date >$@

build/feynson.tar.gz: build/.dir ginac.done nauty.done
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/magv/feynson/archive/refs/heads/master.tar.gz"

feynson.done: build/feynson.tar.gz ginac.done nauty.done
	rm -rf build/feynson-*/
	cd build && tar xf feynson.tar.gz
	+env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		${MAKE} -C build/feynson-*/
	cd build/feynson-*/ && cp -a feynson "${DIR}/bin/"
	date >$@
