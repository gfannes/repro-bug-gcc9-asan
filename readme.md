# Overview

This repo contains a small C++ test program that reproduces an ASAN problem observed when combining GCC 9.1 and [doctest](https://github.com/onqtam/doctest).

I tried to boil things down to the bare minimum:

* The `-fsanitize=address` is necessary
* The `-O3` is necessary
* The second `DOCTEST_SUBCASE()` is necessary
* The `Struct s;` should come before the `DOCTEST_SUBCASE()`s
* The initialization of the `data` member should have at least 3 items

When testing against GCC 8.3.0, ASAN does not complain.

# Details

* `gcc --version`

    gcc (GCC) 9.1.0
    Copyright (C) 2019 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions.  There is NO
    warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

* `uname -a`

    Linux core-design 5.1.16-1-MANJARO #1 SMP PREEMPT Thu Jul 4 20:32:22 UTC 2019 x86_64 GNU/Linux

* Compilation statement

    g++ -c test.cpp -o test.o -I doctest/doctest -fsanitize=address -O3 -save-temps

* Preprocessed file can be found [here](test.ii).

# Running the test program

When running the command `make run` on a [manjaro](https://manjaro.org), I receive following output:

    git clone https://github.com/onqtam/doctest
    Cloning into 'doctest'...
    remote: Enumerating objects: 9488, done.
    remote: Total 9488 (delta 0), reused 0 (delta 0), pack-reused 9488
    Receiving objects: 100% (9488/9488), 5.31 MiB | 7.38 MiB/s, done.
    Resolving deltas: 100% (6137/6137), done.
    g++ -c test.cpp -o test.o -I doctest/doctest -fsanitize=address -O3
    g++ test.o -o test -lasan
    ./test
    [doctest] doctest version is "2.3.3"
    [doctest] run with "--help" for options
    =================================================================
    ==30240==ERROR: AddressSanitizer: stack-use-after-scope on address 0x560922d705a0 at pc 0x7f091548dab4 bp 0x7fffe672a7b0 sp 0x7fffe6729f58
    READ of size 12 at 0x560922d705a0 thread T0
        #0 0x7f091548dab3 in __interceptor_memcpy /build/gcc/src/gcc/libsanitizer/sanitizer_common/sanitizer_common_interceptors.inc:790
        #1 0x560922d48614 in _DOCTEST_ANON_FUNC_6() (/home/geertf/tmp/gcc9/test+0x4a614)
        #2 0x560922d56fb5 in doctest::Context::run() (/home/geertf/tmp/gcc9/test+0x58fb5)
        #3 0x560922d108e0 in main (/home/geertf/tmp/gcc9/test+0x128e0)
        #4 0x7f0914f0cee2 in __libc_start_main (/usr/lib/libc.so.6+0x26ee2)
        #5 0x560922d1113d in _start (/home/geertf/tmp/gcc9/test+0x1313d)
    
    0x560922d705a0 is located 0 bytes inside of global variable 'C.482' defined in 'test.cpp:8:12' (0x560922d705a0) of size 12
    SUMMARY: AddressSanitizer: stack-use-after-scope /build/gcc/src/gcc/libsanitizer/sanitizer_common/sanitizer_common_interceptors.inc:790 in __interceptor_memcpy
    Shadow bytes around the buggy address:
      0x0ac1a45a6060: f9 f9 f9 f9 07 f9 f9 f9 f9 f9 f9 f9 00 00 02 f9
      0x0ac1a45a6070: f9 f9 f9 f9 06 f9 f9 f9 f9 f9 f9 f9 02 f9 f9 f9
      0x0ac1a45a6080: f9 f9 f9 f9 02 f9 f9 f9 f9 f9 f9 f9 00 f9 f9 f9
      0x0ac1a45a6090: f9 f9 f9 f9 06 f9 f9 f9 f9 f9 f9 f9 05 f9 f9 f9
      0x0ac1a45a60a0: f9 f9 f9 f9 04 f9 f9 f9 f9 f9 f9 f9 00 02 f9 f9
    =>0x0ac1a45a60b0: f9 f9 f9 f9[f8]f8 f9 f9 f9 f9 f9 f9 00 00 00 00
      0x0ac1a45a60c0: 07 f9 f9 f9 f9 f9 f9 f9 00 00 00 00 00 03 f9 f9
      0x0ac1a45a60d0: f9 f9 f9 f9 00 00 00 00 03 f9 f9 f9 f9 f9 f9 f9
      0x0ac1a45a60e0: 00 00 00 00 04 f9 f9 f9 f9 f9 f9 f9 00 00 00 00
      0x0ac1a45a60f0: 05 f9 f9 f9 f9 f9 f9 f9 00 00 00 00 00 f9 f9 f9
      0x0ac1a45a6100: f9 f9 f9 f9 00 00 00 00 05 f9 f9 f9 f9 f9 f9 f9
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
    ==30240==ABORTING
    make: *** [makefile:15: run] Error 1
