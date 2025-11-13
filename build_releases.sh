#!/bin/bash

VERSION="v1.0.1"
mkdir -p releases

echo "Building for Linux x86_64..."
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-linux
cp zig-out/bin/bolt releases/bolt-linux-x86_64

echo "Building for macOS x86_64..."
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-macos
cp zig-out/bin/bolt releases/bolt-macos-x86_64

echo "Building for macOS ARM64 (Apple Silicon)..."
zig build -Doptimize=ReleaseFast -Dtarget=aarch64-macos
cp zig-out/bin/bolt releases/bolt-macos-aarch64

echo "Building for Windows x86_64..."
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-windows
cp zig-out/bin/bolt.exe releases/bolt-windows-x86_64.exe

echo "Done! Binaries are in ./releases/"
