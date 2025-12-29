#!/bin/env bash

# SeL4 Deps
sudo pacman -S --needed --noconfirm cmake ccache ninja curses ncurses libxml2 dtc uboot-tools protobuf meson

## Tools
sudo pacman -S --needed --noconfirm curl git doxygen

## Specific Providers
### Provides xxd hexdecimal utility
sudo pacman -S --needed --noconfirm vim 

### Python
sudo pacman -S --needed --noconfirm python python-pip python-protobuf

### Aarch 64 Specific
sudo pacman -S --needed --noconfirm aarch64-linux-gnu-gcc aarch64-linux-gnu-binutils aarch64-linux-gnu-gdb qemu-system-aarch64 rust-aarch64-gnu
yay -S --needed --noconfirm aarch64-none-elf-gcc

## Multilib Deps

## Python Management

### Optionally
# python -m venv .venv
# source .venv/bin/activate

pip install pyfdt pyyaml jinja2 ply lxml
