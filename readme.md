This repo contains the scripts, the configs, and the patches related to start-up optimization.

- `artifact-evaluation.md`
The detailed documentation for artifact evaluation.

- `patches/`
    The base commit is contained in all patches. Simply apply them to QEMU/crosvm/Linux kernel.
    - crosvm
        For reference, this is my command for building crosvm:
        ```sh
        cargo build --no-default-features --features="audio","gpu","usb","net","gdb" --target aarch64-unknown-linux-gnu --release
        ```

- `scripts/`
Contains VM launch and benchmarking scripts.

Run `start-time.exp` to launch a VM and measure the start-up time.

- `kernel-configs/`
The configs for compiling kernel are listed here.
