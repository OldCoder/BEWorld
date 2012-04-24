#!/bin/sh
# buildme.sh - Builds "brick-tcl" and "beworld"
# License for Brick Engine: MIT/X-based - see "license*.txt" files
# License for BEWorld: Creative Commons - see LICENSE and source code
# Revision: 120422

#---------------------------------------------------------------------
# Determine target prefix.

WHOAMI=/usr/bin/whoami

if [ \! -x $WHOAMI ]; then
    echo Error: This script needs $WHOAMI
    exit 1
fi

if [ x"`$WHOAMI`" == xroot ]; then
    PREFIX=/opt/beworld
else
    PREFIX=$HOME/beworld
fi

#---------------------------------------------------------------------
# Check other requirements.

for name in cmake gcc sed tclConfig.sh
do
    X=`which $name 2>&1`
    if [ \! -x $X ]; then
        echo Error: This script needs $name
        exit 1
    fi
done

#---------------------------------------------------------------------
# Set up output directories.

mkdir -p $PREFIX                            || exit 1
echo PREFIX will be $PREFIX

BINDIR=$PREFIX/bin
DOCDIR=$PREFIX/doc

mkdir -p $BINDIR                            || exit 1
mkdir -p $DOCDIR                            || exit 1

rm -f $BINDIR/beworld* $BINDIR/brick*tcl    || exit 1
cp -p LICENSE $DOCDIR/                      || exit 1

#---------------------------------------------------------------------
# Build Brick Engine library.

echo Building Brick Engine library
cd engine                                   || exit 1

cmake -DCMAKE_BUILD_TYPE:STRING=RELEASE \
      -DCMAKE_INSTALL_PREFIX=$PREFIX        || exit 1
make                                        || exit 1
make install                                || exit 1
cp -p license-engine.txt $DOCDIR/           || exit 1

#---------------------------------------------------------------------
# Build "brick-tcl".

echo Building brick-tcl
cd ../bindings/tcl                          || exit 1

for x in CMakeLists.txt extra/Findbrick.cmake
do
    sed -e "s|__META_INCDIR__|$PREFIX/include|" \
        -e "s|__META_LIBDIR__|$PREFIX/lib|" \
        -i $x                               || exit 1
done

cmake -DCMAKE_BUILD_TYPE:STRING=RELEASE \
      -DCMAKE_INSTALL_PREFIX=$PREFIX        || exit 1

make                                        || exit 1
make install                                || exit 1
cp -p license-brick-tcl.txt $DOCDIR/        || exit 1
ln -s $BINDIR/brick-tcl $BINDIR/bricktcl    || exit 1

#---------------------------------------------------------------------
# Install "beworld" (Tcl script and shell wrapper).

cd ../..                                    || exit 1
cp -p beworld.tcl $BINDIR/                  || exit 1

cat > $BINDIR/beworld << END                || exit 1
#!/bin/sh

L=`libmikmod-config --prefix 2> /dev/null`
if [ \! -z "\$L" ]; then
    export LD_LIBRARY_PATH=\$L/lib:\$LD_LIBRARY_PATH
fi

export LD_LIBRARY_PATH=$PREFIX/lib:\$LD_LIBRARY_PATH
$BINDIR/brick-tcl $BINDIR/beworld.tcl
END

chmod 755  $BINDIR/beworld                  || exit 1

echo
echo Built $BINDIR/beworld
echo "To play the game run that script"
echo "If you don't hear music, you may need to install libmikmod"
echo Done
