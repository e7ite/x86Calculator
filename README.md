[![Build status](https://ci.appveyor.com/api/projects/status/cra5k9fv8u8k5sba?svg=true)](https://ci.appveyor.com/project/e7ite/x86calculator)

# x86Calculator

A NASM Linux program whose purpose was for me to practice my x86 knowledge and x87 FPU understanding. All it does is clear screen, print out the
available options, and allows the user to pick a desired calculation until they quit the program. This program can take an
optional command line argument as an initial value for the calculator to use.

## Usage
`./calc.out <VALUE>`

## Image Preview
![](/preview.png)

## Issues
Currently does not check if the user specified a number via command line argument.
