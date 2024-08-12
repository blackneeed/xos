#!/bin/bash

if [ "$1" = "build" ]; then
    mkdir -p build
    nasm -f bin main.asm -o build/main
elif [ "$1" = "run" ]; then
    qemu-system-i386 -drive format=raw,file=build/main -boot c -d guest_errors,cpu_reset,int -enable-kvm -no-shutdown -no-reboot
else
    echo "Invalid command \"$1\""
fi
