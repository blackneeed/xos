#!/bin/bash

if [ "$1" = "build" ]; then
    mkdir -p build
    nasm -f bin stage1.asm -o build/stage1
    nasm -f bin stage2.asm -o build/stage2
    cat build/stage1 build/stage2 > build/main
elif [ "$1" = "run" ]; then
    qemu-system-i386 -drive format=raw,file=build/main -boot c -d guest_errors,cpu_reset,int -enable-kvm -no-shutdown -no-reboot
else
    echo "Invalid command \"$1\""
fi
