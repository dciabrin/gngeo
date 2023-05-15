#!/bin/bash
set -eu

autoreconf -iv
./configure \
    --prefix=${MSYSTEM_PREFIX} \
    --build=${MSYSTEM_CHOST} \
    --host=${MSYSTEM_CHOST} \
    --target=${MSYSTEM_CHOST} \
    --program-prefix=ngdevkit- \
    --enable-msys2 \
    --with-glew \
    CFLAGS="-Wno-implicit-function-declaration -DGNGEORC=\\\"ngdevkit-gngeorc\\\"" \
    GL_LIBS="-L${MSYSTEM_PREFIX}/bin -lglew32 -lopengl32"
MSYS2_ARG_CONV_EXCL="-DDATA_DIRECTORY=" make pkgdatadir=${MSYSTEM_PREFIX}/share/ngdevkit-gngeo
make install pkgdatadir=${MSYSTEM_PREFIX}/share/ngdevkit-gngeo
