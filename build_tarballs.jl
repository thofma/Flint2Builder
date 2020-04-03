# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libflint"
version = v"0.0.0-slim-7f3560"

# Collection of sources required to build libflint
sources = [
    "https://github.com/wbhart/flint2.git" =>
    "7f3560da519bd1e279767b61090bc851c57e618e",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd flint2/
sed -i 's/ -g//' configure
sed -i 's/ -funroll-loops//' configure
sed -i 's/ -O2/ -O3/' configure
if [[ ${target} == *mingw* ]]; then     ./configure --prefix=$prefix --disable-static --enable-shared --reentrant --with-gmp=$prefix --with-mpfr=$prefix; else     ./configure --prefix=$prefix --disable-static --enable-shared --with-gmp=$prefix --with-mpfr=$prefix; fi
make -j${nproc}
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Windows(:x86_64),
    MacOS(:x86_64),
    Linux(:x86_64, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libflint", :libflint)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/GMP-v6.1.2-1/build_GMP.v6.1.2.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/MPFR-v4.0.2-1/build_MPFR.v4.0.2.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

