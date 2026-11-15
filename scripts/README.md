# Scripts for Building and Testing

## Building All

Just run `build-all.ps1`. If you have the PowerShell extension in VS Code you can use the run button in the editor.

This will produce several `.out` files in the build directory.

The script produces the effect of an out-of-source build, as well as automatically setting conditional assembly flags.

It does this by moving and modifying files, because Merlin 32 does not support these actions directly.

## Building One

To build a specific case only, you have to do it manually.  The steps are as follows.

1. Edit `switchbox.s` to select the coarse grained options
2. *If* you want fine grained control, edit the flags in `MSB6502.S`
    - failure is quite possible in this case
3. Run the assembler on the appropriate source file
    - For most cases the source file is simply `MSB6502.S`
    - For Applesoft *with extensions* use `link_apple.S`
    - Move build products to `build` 

## Testing

For testing there are separate scripts for testing one case and testing all cases:

* `test-one.ps1` tests one case given a few inputs
* `test-all.ps1` tests several cases

See comments in the `test` directory for more.