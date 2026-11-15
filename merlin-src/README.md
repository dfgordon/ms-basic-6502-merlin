# Merlin Sources

## Structure of the Sources

The file `MSB6502.S` is the heart of the package in all cases.

However, in order to handle the Applesoft case as gracefully as possible, while working around
various defects in the toolchain, the sources have been split as follows.

Everything is controlled by settings in `switchbox.s`. See comments therein for more.

To actually assemble these sources see `scripts`.

## KIM, OSI, and Primitive Commodore

This is a single source with two includes

    * MSB6502.S
      - switchbox.s
      - msb.zp.s

## Commodore PET

This is a single source with three includes

    * MSB6502.S
      - switchbox.s
      - msb.zp.s
      - pet1tail.s

## Apple II Primitive BASIC

This is a single source with two includes

    * MSB6502.S
      - switchbox.s
      - msb.zp.apple.s

## Applesoft

In this case run the assembler on `link_apple.S`.

The linker modules correspond to the original Microsoft code,
Apple extensions, and the Apple F8 ROM.

    * MSB6502.S
      - switchbox.s
      - msb.zp.apple.ext.s
      - apple.ext.head.s
    * apple.extensions.s
      - apple.prim.head.s
      - apple.ext.head.s
    * apple.f8rom.s
      - apple.ext.head.s
