#!/bin/bash

as exit.s -o exit.o     # Assemble
ld exit.o -o exit       # Link
chmod +x exit
./exit
echo $?
