# Testing

## Automatic Tests

Generally all that should be required is to carry out two steps:

1. Build - run the script `build-all.ps1`
2. Test - run the script `test-all.ps1`

The following sections fill in what goes on under the hood.

## Overview

The basic test strategy is:

1. Compare products of Merlin 32 with ROM images from actual machines
2. Compare products of Merlin 32 with those of DASM

The full matrix of fine grained conditional assembly switch settings is too large to test every case, so we focus only on coarse-grained settings targeted at specific vendors.  Regarding ROM images, the cases and corresponding reference files are:

1. KIM (`kim.web.ref`)
2. OSI (`osi.web.ref`)
3. Commodore PET (`pet1.web.ref`)
4. Apple II plus (`apple.web.ref`)

In these cases the reference files are taken directly from the "Uncle Bernie" (UB) tarball, but renamed.

When it comes to comparing outputs of different assemblers we can compare whatever switch settings we choose.  Here we have to distinguish between the "primitive" MSBASIC source code, as opposed to the source code used by the computer vendors. This comes about because the vendors supplied their own patches and extensions. Since the original source code for patches and extensions is not available in general, it has been either reverse engineered or derived from disassembly (see comments in `dasm-src/MSB6502-ub.asm`).  In one case there is a homebrew patch from UB.  Cases and reference files are as follows:

1. KIM (`kim.dasm.ref`)
2. KIM primitive (`kim.primitive.dasm.ref`)
3. OSI (`osi.dasm.ref`)
4. OSI primitive (`osi.primitive.dasm.ref`)
5. OSI UB fix (`osi.ubfix.dasm.ref`)
6. PET (`pet1.dasm.ref`)
7. PET primitve (`pet1.primitive.dasm.ref`)
8. Apple (`apple.dasm.ref`)
9. Apple primitive (`apple.primitive.dasm.ref`)

## Reference file format

The reference files are hex dumps. Some were created by UB, others by DFG.

*The formatting of the ASCII column need not be consistent*.

In other words, make sure to only compare the hex. That is all that matters.