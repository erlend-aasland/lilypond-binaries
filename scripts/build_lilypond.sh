#!/bin/sh

set -e

if [ -z "$LILYPOND_TAR" ]; then
    echo "Point LILYPOND_TAR to lilypond tarball" >&2
    exit 1
fi

. "$(dirname $0)/native_deps.sh"

LILYPOND="$ROOT/lilypond"
LILYPOND_SRC="$LILYPOND/src"
LILYPOND_BUILD="$LILYPOND/build"
LILYPOND_INSTALL="$LILYPOND/install"

echo "Extracting '$LILYPOND_TAR'..."
mkdir -p "$LILYPOND_SRC"
tar -x -f "$LILYPOND_TAR" -C "$LILYPOND_SRC" --strip-components 1

echo "Building lilypond..."
mkdir -p "$LILYPOND_BUILD"
(
    cd "$LILYPOND_BUILD"

    # Load shared srfi modules.
    export LD_LIBRARY_PATH="$GUILE_INSTALL/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    export LDFLAGS="-Wl,--export-dynamic"

    pkg_config_libdir="$CAIRO_INSTALL/lib/pkgconfig"
    pkg_config_libdir="$pkg_config_libdir:$EXPAT_INSTALL/lib/pkgconfig"
    pkg_config_libdir="$pkg_config_libdir:$LIBFFI_INSTALL/lib/pkgconfig"
    pkg_config_libdir="$pkg_config_libdir:$FONTCONFIG_INSTALL/lib/pkgconfig"
    pkg_config_libdir="$pkg_config_libdir:$FREETYPE_INSTALL/lib/pkgconfig"
    pkg_config_libdir="$pkg_config_libdir:$GLIB2_INSTALL/lib/pkgconfig"
    pkg_config_libdir="$pkg_config_libdir:$HARFBUZZ_INSTALL/lib/pkgconfig"
    pkg_config_libdir="$pkg_config_libdir:$PANGO_INSTALL/lib/pkgconfig"
    pkg_config_libdir="$pkg_config_libdir:$PIXMAN_INSTALL/lib/pkgconfig"
    pkg_config_libdir="$pkg_config_libdir:$UTIL_LINUX_INSTALL/lib/pkgconfig"

    PKG_CONFIG_LIBDIR="$pkg_config_libdir" \
    GHOSTSCRIPT="$GHOSTSCRIPT_INSTALL/bin/gs" \
    GUILE="$GUILE_INSTALL/bin/guile" GUILE_CONFIG="$GUILE_INSTALL/bin/guile-config" \
    PYTHON="$PYTHON_INSTALL/bin/python" PYTHON_CONFIG="$PYTHON_INSTALL/bin/python-config" \
    "$LILYPOND_SRC/configure" --prefix="$LILYPOND_INSTALL" --disable-documentation \
        --enable-static-gxx --enable-relocation
    $MAKE -j$PROCS
    $MAKE install
) > "$LILYPOND/build.log" 2>&1