# Overview

This repo contains a small C++ test program that reproduces an ASAN problem observed when combining GCC 9.1.

I tried to boil things down to the bare minimum:

* The `-fsanitize=address` is necessary
* The `-O3` is necessary
* The second invocation of `f()` is necessary
* The initialization of the `data` member should have at least 3 items

When testing against GCC 8.3.0, ASAN does not complain.

# Details

* `gcc -v`

    Using built-in specs.
    COLLECT_GCC=gcc
    COLLECT_LTO_WRAPPER=/usr/lib/gcc/x86_64-pc-linux-gnu/9.1.0/lto-wrapper
    Target: x86_64-pc-linux-gnu
    Configured with: /build/gcc/src/gcc/configure --prefix=/usr --libdir=/usr/lib --libexecdir=/usr/lib --mandir=/usr/share/man --infodir=/usr/share/info --with-bugurl=https://bugs.archlinux.org/ --enable-languages=c,c++,ada,fortran,go,lto,objc,obj-c++ --enable-shared --enable-threads=posix --with-system-zlib --with-isl --enable-__cxa_atexit --disable-libunwind-exceptions --enable-clocale=gnu --disable-libstdcxx-pch --disable-libssp --enable-gnu-unique-object --enable-linker-build-id --enable-lto --enable-plugin --enable-install-libiberty --with-linker-hash-style=gnu --enable-gnu-indirect-function --enable-multilib --disable-werror --enable-checking=release --enable-default-pie --enable-default-ssp --enable-cet=auto
    Thread model: posix
    gcc version 9.1.0 (GCC) 

* `uname -a`

    Linux core-design 5.1.16-1-MANJARO #1 SMP PREEMPT Thu Jul 4 20:32:22 UTC 2019 x86_64 GNU/Linux

* Compilation statement

    g++ -c test.cpp -o test.o -fsanitize=address -O3 -save-temps

* Preprocessed file can be found [here](test.ii).

# Running the test program

When running the command `make run` on a [manjaro](https://manjaro.org), I receive following output:

    ./test
    =================================================================
    ==995==ERROR: AddressSanitizer: stack-use-after-scope on address 0x56217d2ad060 at pc 0x7f8db03eaab4 bp 0x7ffe94c4eb70 sp 0x7ffe94c4e318
    READ of size 12 at 0x56217d2ad060 thread T0
        #0 0x7f8db03eaab3 in __interceptor_memcpy /build/gcc/src/gcc/libsanitizer/sanitizer_common/sanitizer_common_interceptors.inc:790
        #1 0x56217d2ac43b in f() (/home/geertf/tmp/repro-bug-asan-doctest/test+0x143b)
        #2 0x56217d2ac17d in main (/home/geertf/tmp/repro-bug-asan-doctest/test+0x117d)
        #3 0x7f8dafe69ee2 in __libc_start_main (/usr/lib/libc.so.6+0x26ee2)
        #4 0x56217d2ac1ed in _start (/home/geertf/tmp/repro-bug-asan-doctest/test+0x11ed)
    
    0x56217d2ad060 is located 0 bytes inside of global variable 'C.0' defined in 'test.cpp:3:8' (0x56217d2ad060) of size 12
    SUMMARY: AddressSanitizer: stack-use-after-scope /build/gcc/src/gcc/libsanitizer/sanitizer_common/sanitizer_common_interceptors.inc:790 in __interceptor_memcpy
    Shadow bytes around the buggy address:
      0x0ac4afa4d9b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      0x0ac4afa4d9c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      0x0ac4afa4d9d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      0x0ac4afa4d9e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      0x0ac4afa4d9f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    =>0x0ac4afa4da00: 00 00 00 00 00 00 00 00 00 00 00 00[f8]f8 f9 f9
      0x0ac4afa4da10: f9 f9 f9 f9 00 00 00 00 00 00 00 00 00 00 00 00
      0x0ac4afa4da20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      0x0ac4afa4da30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      0x0ac4afa4da40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
      0x0ac4afa4da50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    Shadow byte legend (one shadow byte represents 8 application bytes):
      Addressable:           00
      Partially addressable: 01 02 03 04 05 06 07 
      Heap left redzone:       fa
      Freed heap region:       fd
      Stack left redzone:      f1
      Stack mid redzone:       f2
      Stack right redzone:     f3
      Stack after return:      f5
      Stack use after scope:   f8
      Global redzone:          f9
      Global init order:       f6
      Poisoned by user:        f7
      Container overflow:      fc
      Array cookie:            ac
      Intra object redzone:    bb
      ASan internal:           fe
      Left alloca redzone:     ca
      Right alloca redzone:    cb
      Shadow gap:              cc
    ==995==ABORTING
    make: *** [makefile:11: run] Error 1
    
