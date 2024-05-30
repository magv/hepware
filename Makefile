CC=cc
CXX=c++
FC=gfortran

all: phony
	@echo "This is HEPWARE. Type '${MAKE} <software>.done' or '${MAKE} all.done'."

ALL=\
	cln \
	fermat \
	feynson \
	fire6 \
	firefly \
	flint \
	forcer \
	form \
	fuchsia \
	ginac \
	gmp \
	googlebenchmark \
	hypothread \
	jemalloc \
	kira \
	mpfr \
	nauty \
	qgraf \
	ratnormal \
	ratracer \
	yaml-cpp \
	zlib

all.done: $(addsuffix .done,${ALL}) phony

clean: phony
	rm -rf bin/ build/ include/ lib/ share/ *.done

phony:;

DIR=${CURDIR}
DEP_CFLAGS=-I${DIR}/include -O3 -g -fno-omit-frame-pointer -fdata-sections -ffunction-sections ${CFLAGS}
DEP_FFLAGS=-I${DIR}/include -O3 ${FFLAGS}
DEP_LDFLAGS=-L${DIR}/lib -Wl,--gc-sections ${LDFLAGS}

MAKEOVERRIDES=

build/.dir:
	mkdir -p bin build include lib share
	date >$@

## Jemalloc

build/jemalloc.tar.bz2: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/jemalloc/jemalloc/releases/download/5.3.0/jemalloc-5.3.0.tar.bz2" \
		|| rm -f $@

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

## Kira

build/kira.tar.bz2: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://gitlab.com/kira-pyred/kira/-/archive/master/kira-master.tar.bz2" \
		|| rm -f $@

kira.done: build/kira.tar.bz2 firefly.done fermat.done flint.done ginac.done jemalloc.done yaml-cpp.done zlib.done
	rm -rf build/kira-*/
	cd build && tar xf kira.tar.bz2
	cd build/kira-*/ && autoreconf -i
	cd build/kira-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
			PKG_CONFIG_PATH="${DIR}/nopkgconf" \
			GINAC_CFLAGS="-I." GINAC_LIBS="-lginac" \
			CLN_CFLAGS="-I." CLN_LIBS="-lcln" \
			YAML_CPP_CFLAGS="-I." YAML_CPP_LIBS="-lyaml-cpp" \
			ZLIB_CFLAGS="-I." ZLIB_LIBS="-lz" \
			FIREFLY_CFLAGS="-I." FIREFLY_LIBS="-ljemalloc -lfirefly -lflint -lmpfr" \
		./configure \
			--prefix="${DIR}" --libdir="${DIR}/lib" \
			--includedir="${DIR}/include" --bindir="${DIR}/bin" \
			--enable-firefly=yes
	+${MAKE} -C build/kira-*/
	+${MAKE} -C build/kira-*/ install
	date >$@

## GMP

build/gmp.tar.xz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz" \
		|| rm -f $@

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

## MPFR

build/mpfr.tar.xz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://www.mpfr.org/mpfr-4.2.1/mpfr-4.2.1.tar.xz" \
		|| rm -f $@

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

## Flint

build/flint.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://flintlib.org/flint-3.1.2.tar.gz" \
		|| rm -f $@

flint.done: build/flint.tar.gz gmp.done mpfr.done
	rm -rf build/flint-*/
	cd build && tar xf flint.tar.gz
	cd build/flint-*/ && \
		./configure \
			--prefix="${DIR}" --libdir="${DIR}/lib" \
			--enable-static --disable-shared \
			--enable-arch=no \
			--with-gmp="${DIR}" --with-mpfr="${DIR}" \
			CC="${CC}" CXX="${CXX}" \
			CFLAGS="${DEP_CFLAGS} -g -pedantic -std=c11 -O3 -Werror=implicit-function-declaration" \
			LDFLAGS="${DEP_LDFLAGS}"
	+${MAKE} -C build/flint-*/
	+${MAKE} -C build/flint-*/ install
	date >$@

## Forcer

build/forcer.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/benruijl/forcer/archive/refs/heads/master.tar.gz" \
		|| rm -f $@

forcer.done: build/forcer.tar.gz form.done
	rm -rf build/forcer-*/
	cd build && tar xf forcer.tar.gz
	rm -rf "${DIR}/share/forcer"
	cd build && mv forcer-*/ "${DIR}/share/forcer"
	date >$@
	@echo "HEPWARE: You can find Forcer at ${DIR}/share/forcer"

## Yaml-cpp

build/yaml-cpp.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/jbeder/yaml-cpp/archive/refs/tags/yaml-cpp-0.7.0.tar.gz" \
		|| rm -f $@

yaml-cpp.done: build/yaml-cpp.tar.gz
	rm -rf build/yaml-cpp-*/
	cd build && tar xf yaml-cpp.tar.gz
	cd build/yaml-cpp-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		cmake . \
			-DCMAKE_INSTALL_PREFIX="${DIR}" \
			-DCMAKE_INSTALL_LIBDIR="lib" \
			-DYAML_BUILD_SHARED_LIBS=OFF \
			-DYAML_CPP_BUILD_CONTRIB=OFF \
			-DYAML_CPP_BUILD_TESTS=OFF \
			-DYAML_CPP_BUILD_TOOLS=OFF
	+${MAKE} -C build/yaml-cpp-*/ VERBOSE=1
	+${MAKE} -C build/yaml-cpp-*/ install
	date >$@

## zlib

build/zlib.tar.xz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"http://zlib.net/fossils/zlib-1.3.1.tar.gz" \
		|| rm -f $@

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

## Fuchsia

build/fuchsia.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/magv/fuchsia.cpp/archive/refs/heads/master.tar.gz" \
		|| rm -f $@

fuchsia.done: build/fuchsia.tar.gz ginac.done
	rm -rf build/fuchsia.cpp-*/
	cd build && tar xf fuchsia.tar.gz
	+env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		${MAKE} -C build/fuchsia.cpp-*/
	cd build/fuchsia.cpp-*/ && cp -a build/fuchsia "${DIR}/bin/"
	+${MAKE} -C build/fuchsia.cpp-*/ clean
	date >$@

## Ratnormal

build/ratnormal.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/magv/ratnormal/archive/refs/heads/master.tar.gz" \
		|| rm -f $@

ratnormal.done: build/ratnormal.tar.gz ginac.done flint.done
	rm -rf build/ratnormal-*/
	cd build && tar xf ratnormal.tar.gz
	+env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		${MAKE} -C build/ratnormal-*/
	cd build/ratnormal-*/ && cp -a ratnormal "${DIR}/bin/"
	date >$@

## Ratracer

build/ratracer.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/magv/ratracer/archive/refs/heads/master.tar.gz" \
		|| rm -f $@

ratracer.done: build/ratracer.tar.gz ginac.done flint.done gmp.done jemalloc.done mpfr.done zlib.done
	rm -rf build/ratracer-*/
	cd build && tar xf ratracer.tar.gz
	+${MAKE} -C build/ratracer-*/ build/.dir
	cd build/ratracer-*/build/ && touch \
		mpfr.tar.xz mpfr.done \
		gmp.tar.xz gmp.done \
		flint.tar.gz flint.done \
		jemalloc.tar.bz2 jemalloc.done \
		zlib.tar.xz zlib.done
	+env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		${MAKE} -C build/ratracer-*/ ratracer
	cd build/ratracer-*/ && cp -a tools/* ratracer "${DIR}/bin/"
	date >$@

## Hypothread

build/hypothread.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/magv/hypothread/archive/refs/heads/master.tar.gz" \
		|| rm -f $@

hypothread.done: build/hypothread.tar.gz
	rm -rf build/hypothread-*/
	cd build && tar xf hypothread.tar.gz
	+env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		${MAKE} -C build/hypothread-*/
	cd build/hypothread-*/ && cp -a hypothread "${DIR}/bin/"
	cd build/hypothread-*/ && make clean
	date >$@

## QGRAF

build/qgraf.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		--user anonymous --password anonymous \
		"http://qgraf.tecnico.ulisboa.pt/links/qgraf-3.6.7.tgz" \
		|| rm -f $@

qgraf.done: build/qgraf.tar.gz
	rm -rf build/qgraf/
	mkdir -p build/qgraf bin
	cd build/qgraf && tar xf ../qgraf.tar.gz
	cd build/qgraf && ${FC} ${DEP_FFLAGS} -o qgraf qgraf-*.f08
	mv build/qgraf/qgraf bin/
	date >$@

## FORM

build/form.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/vermaseren/form/releases/download/v4.3.1/form-4.3.1.tar.gz" \
		|| rm -f $@

form.done: build/form.tar.gz gmp.done zlib.done
	rm -rf build/form-*/
	cd build && tar xf form.tar.gz
	cd build/form-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		./configure \
			--prefix="${DIR}" --libdir="${DIR}/lib" \
			--includedir="${DIR}/include" --bindir="${DIR}/bin" \
			--with-zlib="${DIR}" --with-gmp="${DIR}" \
			--enable-scalar=yes \
			--enable-threaded=yes \
			--enable-debug=yes \
			--enable-parform=no \
			--enable-static-link=no \
			--enable-native=no
	+${MAKE} -C build/form-*/
	+${MAKE} -C build/form-*/ install
	date >$@

## CLN

build/cln.tar.bz2: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/gudrunhe/secdec/raw/ffa14e1c686ebb29e21f69e49d991e7000a6b6c6/pySecDecContrib/cln-1.3.6.tar.bz2" \
		|| rm -f $@

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

## Google Benchmark

build/benchmark.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/google/benchmark/archive/refs/tags/v1.7.1.tar.gz" || \
		rm -f "$@"

build/googletest.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/google/googletest/archive/refs/tags/release-1.12.1.tar.gz" || \
		rm -f "$@"

googlebenchmark.done: build/benchmark.tar.gz build/googletest.tar.gz
	rm -rf build/benchmark-*/
	cd build && tar xf benchmark.tar.gz
	cd build/benchmark-*/ && \
		tar xf ../googletest.tar.gz && \
		mv googletest-release-* googletest && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		cmake . \
			-DCMAKE_INSTALL_PREFIX="${DIR}" \
			-DCMAKE_INSTALL_LIBDIR="lib" \
			-DCMAKE_BUILD_TYPE=Release \
			-DBENCHMARK_INSTALL_DOCS=OFF \
			-DBENCHMARK_ENABLE_GTEST_TESTS=OFF \
			-DBENCHMARK_ENABLE_TESTING=OFF
	+${MAKE} -C build/benchmark-*/ VERBOSE=1
	+${MAKE} -C build/benchmark-*/ install
	date >$@

## GiNaC

build/ginac.tar.bz2: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://www.ginac.de/ginac-1.8.7.tar.bz2" \
		|| rm -f $@

ginac.done: build/ginac.tar.bz2 cln.done
	rm -rf build/ginac-*/
	cd build && tar xf ginac.tar.bz2
	cd build/ginac-*/ && sed -i.bak 's/readline/NOreadline/g' configure
	cd build/ginac-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
			PKG_CONFIG=false CLN_CFLAGS="-I${DIR}/include" CLN_LIBS="-L${DIR}/lib -lcln" \
		./configure \
			--prefix="${DIR}" --libdir="${DIR}/lib" \
			--includedir="${DIR}/include" --bindir="${DIR}/bin" \
			--enable-shared=no --enable-static=yes --with-pic \
			--enable-excompiler=no --disable-rpath
	+${MAKE} -C build/ginac-*/
	+${MAKE} -C build/ginac-*/ install
	date >$@

## Nauty and Traces

build/nauty.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://pallini.di.uniroma1.it/nauty2_8_6.tar.gz" \
		|| rm -f $@

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
	mkdir -p "${DIR}/include/nauty/"
	cd build/nauty*/ && cp -a *.h "${DIR}/include/nauty/"
	date >$@

## Fermat

build/ferl6.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://home.bway.net/lewis/fermat64/ferl6.tar.gz" \
		|| rm -f $@

fermat.done: build/ferl6.tar.gz
	rm -rf build/ferl6*/
	cd build && tar vxf ferl6.tar.gz
	rm -rf share/ferl6*/
	mv build/ferl6 share/
	ln -sf "../share/ferl6/fer64" "${DIR}/bin/fer64"
	date >$@

## Feynson

build/feynson.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/magv/feynson/archive/refs/heads/master.tar.gz" \
		|| rm -f $@

feynson.done: build/feynson.tar.gz ginac.done nauty.done
	rm -rf build/feynson-*/
	cd build && tar xf feynson.tar.gz
	+env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		${MAKE} -C build/feynson-*/
	cd build/feynson-*/ && cp -a feynson "${DIR}/bin/"
	date >$@

## FIRE6

build/fire6.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://bitbucket.org/feynmanIntegrals/fire/get/master.tar.gz" \
		|| rm -f $@

fire6.done: build/fire6.tar.gz
	rm -rf build/feynmanIntegrals-fire-*/
	cd build && tar xf fire6.tar.gz
	cd build/feynmanIntegrals-fire-*/FIRE6 && \
		./configure --enable_zlib --enable_snappy --enable_lthreads --enable_tcmalloc --enable_zstd
	+${MAKE} -C build/feynmanIntegrals-fire-*/FIRE6 dep
	+${MAKE} -C build/feynmanIntegrals-fire-*/FIRE6
	rm -rf share/fire6/
	mv build/feynmanIntegrals-fire-*/FIRE6 share/fire6
	date >$@
	@echo "HEPWARE: You can find FIRE6 at ${DIR}/share/fire6"

## FireFly

build/firefly.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://gitlab.com/firefly-library/firefly/-/archive/master/firefly-master.tar.bz2" \
		|| rm -f $@

firefly.done: build/firefly.tar.gz flint.done zlib.done
	rm -rf build/firefly-*/
	cd build && tar xf firefly.tar.gz
	sed -i.bak \
		-e '/ff_insert/d' \
		-e 's/FireFly_static FireFly_shared/FireFly_static/' \
		-e '/FireFly_shared/d' \
		-e '/example/d' \
		build/firefly-*/CMakeLists.txt
	cd build/firefly-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" CXXFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" \
		cmake . \
			-DCMAKE_INSTALL_PREFIX="${DIR}" -DCMAKE_INSTALL_LIBDIR="lib" \
			-DWITH_FLINT=true \
			-DFLINT_INCLUDE_DIR="${DIR}/include" -DFLINT_LIBRARY="xxx" \
			-DGMP_INCLUDE_DIRS="${DIR}/include" -DGMP_LIBRARIES="xxx" \
			-DZLIB_INCLUDE_DIR="${DIR}/include" -DZLIB_LIBRARY="xxx"
	+${MAKE} -C build/firefly-*/ VERBOSE=1
	+${MAKE} -C build/firefly-*/ install
	date >$@

## Zstd

build/zstd.tar.gz: build/.dir
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/facebook/zstd/releases/download/v1.5.6/zstd-1.5.6.tar.gz" \
		|| rm -f $@

zstd.done: build/zstd.tar.gz zlib.done
	rm -rf build/zstd-*/
	cd build && tar xf zstd.tar.gz
	@# build libzstd.a, libastd_zlibwrapper.a, and zstd
	+${MAKE} -C build/zstd-*/lib/ CFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" VERBOSE=1 libzstd.a-release-nomt 
	+${MAKE} -C build/zstd-*/programs/ CFLAGS="${DEP_CFLAGS}" LDFLAGS="${DEP_LDFLAGS}" VERBOSE=1 HAVE_ZLIB=no HAVE_LZMA=no HAVE_LZ4=no zstd-nomt
	+${MAKE} -C build/zstd-*/zlibWrapper/ CFLAGS="${DEP_CFLAGS} -DZWRAP_USE_ZSTD=1" LDFLAGS="${DEP_LDFLAGS}" VERBOSE=1 zstd_zlibwrapper.o gzclose.o gzlib.o gzread.o gzwrite.o
	cd build/zstd-*/zlibWrapper/ && ${AR} rcs libzstd_zlibwrapper.a zstd_zlibwrapper.o gzclose.o gzlib.o gzread.o gzwrite.o
	@# install libzstd.a, libastd_zlibwrapper.a, zstd*.h, and zstd
	+${MAKE} -C build/zstd-*/lib/ PREFIX="${DIR}" VERBOSE=1 install-static install-includes
	+${MAKE} -C build/zstd-*/programs/ PREFIX="${DIR}" VERBOSE=1 install
	cd build/zstd-*/zlibWrapper/ && cp -a libzstd_zlibwrapper.a "${DIR}/lib/"
	cd build/zstd-*/zlibWrapper/ && cp -a zstd_zlibwrapper.h "${DIR}/include/"
	date >$@
