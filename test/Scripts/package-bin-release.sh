#!/bin/bash

set -o errexit

TEMPSCM=${TEMPSCM:-${HOME}/package-temp.scm}

# The nightly builds use svn checkout instead of svn export. Thus you
# need to remove the .svn directories that are littered in the tree.
find . -name .svn -type d | xargs rm -r

# Remove the src directory, since that's not part of the binary distribution.
rm -rf src

# Remove the test directory, since that's not part of the binary distribution.
rm -rf test

# Remove the include directory from the non-Petit distributions.
if [ ! -e petit.bin ] && [ ! -e petit.bin.exe ]
then rm -rf include
fi

# Remove README-COMMON-LARCENY.txt from the non Common Larceny distributions
if [ ! -e dotnet.heap.exe ]
then rm README-COMMON-LARCENY.txt
fi

# For Petit:
if [ -e petit.bin ] || [ -e petit.bin.exe ]
#    remove the .o files
then find . -name '*.o' -type f | xargs rm
#    remove the generated .c files
     for f in `find . -name '*.c' | sed -e 's/.c$//' ` ; do 
	 if [ -e $f.sch ] ; then rm $f.c; fi; 
     done
fi

# For systems with FFI support, we want to compile certain libraries
# that use the foreign-ctools library ahead of time.
#    (Felix is not going to do this for Petit systems for v0.94
#    because it is not clear if we can safely distribute the .so files
#    that compile-file on Petit Larceny generates.  So basically we're
#    just doing it for the native distributions.)
if [ -e larceny.bin ] || [ -e larceny.bin.exe ]
then 
# The important files for the v0.94 release is
# lib/Experimental/socket.sch, lib/Experimental/unix.sch, and
# lib/Standard/file-system.sch, because Snow relies on them for
# directory listing and tcpip support.
#
# These files tend to assume that their syntax dependencies will be
# handled automagically by require, so the safest way to compile them
# is to first load the file (so that the syntactic environment will be
# extended with any necessary dependencies) and then compile the file.
cat > ${TEMPSCM} <<EOF
(for-each (lambda (f) (load f) (compile-file f)) 
          (list "lib/Experimental/socket.sch" 
                "lib/Experimental/unix.sch" 
                "lib/Standard/file-system.sch"))
EOF
    ./larceny -- ${TEMPSCM}
fi
