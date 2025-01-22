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
	zlib \
	zstd

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

VER_jemalloc=5.3.0

build/jemalloc-${VER_jemalloc}.tar.bz2: build/.dir
	rm -f build/jemalloc*.tar.bz2
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/jemalloc/jemalloc/releases/download/${VER_jemalloc}/jemalloc-${VER_jemalloc}.tar.bz2" \
		|| rm -f $@

jemalloc.done: build/jemalloc-${VER_jemalloc}.tar.bz2 build/.dir
	rm -rf build/jemalloc-*/
	cd build && tar xf jemalloc-${VER_jemalloc}.tar.bz2
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
	rm -f build/kira*.tar.bz2
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

VER_gmp=6.3.0

build/gmp-${VER_gmp}.tar.xz: build/.dir
	rm -f build/gmp*.tar.xz
	wget --no-use-server-timestamps -qO $@ \
		"https://gmplib.org/download/gmp/gmp-${VER_gmp}.tar.xz" \
		|| rm -f $@

gmp.done: build/gmp-${VER_gmp}.tar.xz
	rm -rf build/gmp-*/
	cd build && tar xf gmp-${VER_gmp}.tar.xz
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

VER_mpfr=4.2.1

build/mpfr-${VER_mpfr}.tar.xz: build/.dir
	rm -f build/mpfr*.tar.xz
	wget --no-use-server-timestamps -qO $@ \
		"https://www.mpfr.org/mpfr-${VER_mpfr}/mpfr-${VER_mpfr}.tar.xz" \
		|| rm -f $@

mpfr.done: build/mpfr-${VER_mpfr}.tar.xz gmp.done
	rm -rf build/mpfr-*/
	cd build && tar xf mpfr-${VER_mpfr}.tar.xz
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

VER_flint=2.9.0

build/flint-${VER_flint}.tar.gz: build/.dir
	rm -f build/flint*.tar.gz
	wget --no-use-server-timestamps -qO $@ \
		"https://flintlib.org/download/flint-${VER_flint}.tar.gz" \
		|| rm -f $@

flint.done: build/flint-${VER_flint}.tar.gz gmp.done mpfr.done
	rm -rf build/flint-*/
	cd build && tar xf flint-${VER_flint}.tar.gz
	cd build/flint-*/ && sed -i -e 's/^\t@/\t/' -e '/^.SILENT:/d' Makefile.in
	cd build/flint-*/ && \
		./configure \
			--prefix="${DIR}" --enable-static --disable-shared \
			CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS} -ansi -Wall -O3 -funroll-loops -g"
	+${MAKE} -C build/flint-*/ QUIET_CC="" QUIET_CXX="" QUIET_AR=""
	+${MAKE} -C build/flint-*/ install
	date >$@

## Forcer

build/forcer.tar.gz: build/.dir
	rm -f build/forcer*.tar.gz
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

VER_yaml_cpp=0.7.0

build/yaml-cpp-${VER_yaml_cpp}.tar.gz: build/.dir
	rm -f build/yaml-cpp*.tar.gz
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/jbeder/yaml-cpp/archive/refs/tags/yaml-cpp-${VER_yaml_cpp}.tar.gz" \
		|| rm -f $@

yaml-cpp.done: build/yaml-cpp-${VER_yaml_cpp}.tar.gz
	rm -rf build/yaml-cpp-*/
	cd build && tar xf yaml-cpp-${VER_yaml_cpp}.tar.gz
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

VER_zlib=1.3.1

build/zlib-${VER_zlib}.tar.xz: build/.dir
	rm -f build/zlib*.tar.xz
	wget --no-use-server-timestamps -qO $@ \
		"http://zlib.net/fossils/zlib-${VER_zlib}.tar.gz" \
		|| rm -f $@

zlib.done: build/zlib-${VER_zlib}.tar.xz
	rm -rf build/zlib-*/
	cd build && tar xf zlib-${VER_zlib}.tar.xz
	cd build/zlib-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS}" \
		./configure \
			--prefix="${DIR}" --static
	+${MAKE} -C build/zlib-*/
	+${MAKE} -C build/zlib-*/ install
	date >$@

## Fuchsia

build/fuchsia.tar.gz: build/.dir
	rm -f build/fuchsia.tar.gz
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
	rm -f build/ratnormal*.tar.gz
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
	rm -f build/ratracer*.tar.gz
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
	rm -f build/hypothread*.tar.gz
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

VER_qgraf=3.6

build/qgraf-${VER_qgraf}.tar.gz: build/.dir
	rm -f build/qgraf*.tar.gz
	wget --no-use-server-timestamps -qO $@ \
		--user anonymous --password anonymous \
		"http://qgraf.tecnico.ulisboa.pt/links/qgraf-${VER_qgraf}.tgz" \
		|| rm -f $@

qgraf.done: build/qgraf-${VER_qgraf}.tar.gz
	rm -rf build/qgraf/
	mkdir -p build/qgraf bin
	cd build/qgraf && tar xf ../qgraf-${VER_qgraf}.tar.gz
	cd build/qgraf && ${FC} ${DEP_FFLAGS} -o qgraf qgraf-*.f08
	mv build/qgraf/qgraf bin/
	date >$@

## FORM

VER_form=4.3.1

build/form-${VER_form}.tar.gz: build/.dir
	rm -f build/form*.tar.gz
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/vermaseren/form/releases/download/v${VER_form}/form-${VER_form}.tar.gz" \
		|| rm -f $@

form.done: build/form-${VER_form}.tar.gz gmp.done zlib.done
	rm -rf build/form-*/
	cd build && tar xf form-${VER_form}.tar.gz
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

VER_cln=1.3.7

build/cln-${VER_cln}.tar.bz2: build/.dir
	rm -f build/cln*.tar.bz2
	wget --no-use-server-timestamps -qO $@ \
		"https://www.ginac.de/CLN/cln-${VER_cln}.tar.bz2" \
		|| rm -f $@

cln.done: build/cln-${VER_cln}.tar.bz2 gmp.done
	rm -rf build/cln-*/
	cd build && tar xf cln-${VER_cln}.tar.bz2
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

VER_benchmark=1.7.1
VER_googletest=1.12.1

build/benchmark-${VER_benchmark}.tar.gz: build/.dir
	rm -f build/benchmark*.tar.gz
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/google/benchmark/archive/refs/tags/v${VER_benchmark}.tar.gz" || \
		rm -f "$@"

build/googletest-${VER_googletest}.tar.gz: build/.dir
	rm -f build/googletest*.tar.gz
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/google/googletest/archive/refs/tags/release-${VER_googletest}.tar.gz" || \
		rm -f "$@"

googlebenchmark.done: build/benchmark-${VER_benchmark}.tar.gz build/googletest-${VER_googletest}.tar.gz
	rm -rf build/benchmark-*/
	cd build && tar xf benchmark-${VER_benchmark}.tar.gz
	cd build/benchmark-*/ && \
		tar xf ../googletest-${VER_googletest}.tar.gz && \
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

VER_ginac=1.8.8

build/ginac-${VER_ginac}.tar.bz2: build/.dir
	rm -f build/ginac*.tar.bz2
	wget --no-use-server-timestamps -qO $@ \
		"https://www.ginac.de/ginac-${VER_ginac}.tar.bz2" \
		|| rm -f $@

ginac.done: build/ginac-${VER_ginac}.tar.bz2 cln.done
	rm -rf build/ginac-*/
	cd build && tar xf ginac-${VER_ginac}.tar.bz2
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

VER_nauty=2_8_8

build/nauty-${VER_nauty}.tar.gz: build/.dir
	rm -f build/nauty*.tar.gz
	wget --no-use-server-timestamps -qO $@ \
		"https://pallini.di.uniroma1.it/nauty${VER_nauty}.tar.gz" \
		|| rm -f $@

nauty.done: build/nauty-${VER_nauty}.tar.gz build/.dir
	rm -rf build/nauty*/
	cd build && tar xf nauty-${VER_nauty}.tar.gz
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
	rm -f build/ferl6.tar.gz
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
	rm -f build/feynson*.tar.gz
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
	rm -f build/fire*.tar.gz
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
	rm -f build/firefly*.tar.gz
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

VER_zstd=1.5.6

build/zstd-${VER_zstd}.tar.gz: build/.dir
	rm -f build/zstd*.tar.gz
	wget --no-use-server-timestamps -qO $@ \
		"https://github.com/facebook/zstd/releases/download/v${VER_zstd}/zstd-${VER_zstd}.tar.gz" \
		|| rm -f $@

zstd.done: build/zstd-${VER_zstd}.tar.gz zlib.done
	rm -rf build/zstd-*/
	cd build && tar xf zstd-${VER_zstd}.tar.gz
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

# LHAPDF

VER_lhapdf=6.5.4

build/lhapdf-${VER_lhapdf}.tar.gz: build/.dir
	rm -f build/lhapdf*.tar.gz
	wget --no-use-server-timestamps -qO $@ \
		"https://lhapdf.hepforge.org/downloader?f=LHAPDF-${VER_lhapdf}.tar.gz" \
		|| rm -f $@

lhapdf.done: build/lhapdf-${VER_lhapdf}.tar.gz build/.dir
	rm -rf build/LHAPDF-*/
	cd build && tar xf lhapdf-${VER_lhapdf}.tar.gz
	cd build/LHAPDF-*/ && \
		env CC="${CC}" CXX="${CXX}" CFLAGS="${DEP_CFLAGS} -fPIC" CXXFLAGS="${DEP_CFLAGS} -fPIC" LDFLAGS="${DEP_LDFLAGS}" \
		PYTHON_VERSION=3 \
		./configure \
			--prefix="${DIR}" --libdir="${DIR}/lib" \
			--includedir="${DIR}/include" --bindir="${DIR}/bin" \
			--enable-static --disable-shared --disable-doxygen --disable-python
	+${MAKE} -C build/LHAPDF-*/ V=1
	+${MAKE} -C build/LHAPDF-*/ install
	date >$@
