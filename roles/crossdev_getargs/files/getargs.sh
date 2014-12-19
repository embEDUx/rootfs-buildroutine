#! /bin/bash
A="sys-devel/binutils" ; B=`equery l $A` ; BINUTILS_VER=`echo $B | cut -d- -f3-`
A=`/usr/bin/gcc-config -c` ; B=`echo $A | cut -d- -f5` ; GCC_VER=`equery l sys-devel/gcc | grep $B | cut -d- -f3-`
KERNEL_VER=`uname -r | sed s/-gentoo//`
A="sys-libs/glibc" ; B=`equery l $A` ; LIBC_VER=`echo $B | cut -d- -f3-`
echo "--b =$BINUTILS_VER --g =$GCC_VER --k =$KERNEL_VER --l =$LIBC_VER -t `uname -m`"
