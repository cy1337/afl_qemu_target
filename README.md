# Intro to AFL QEMU

This repo contains supporting files for a tutorial on AFL QEMU.

`simple_target_server` implements an HTTP service on port 8080 which processes example data from `post_data.bin`.

The goal is to use `afl-fuzz -Q` (qemu mode) to identify a memory corruption bug in the function parsing that data.
