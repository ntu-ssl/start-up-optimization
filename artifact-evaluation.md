Instructions for building the evaluation environment and executing the evaluation scripts are provided in this document.
The artifacts intends to demonstrate the improvement of the start-up time of CVMs with device passthrough. Other setting (e.g., VM with device passthrough, CVM/VM using virtio) is not included in this documentation.

We provide access to our R7515 server to reproduce the results of SEV-SNP. Reviewers can connect to our server using `ssh` and execute the evaluations.
To request access, please contact us and provide your ssh public key. You will then be granted access to the user `reviewer` on our server.

The kernel configs and evaluation scripts are available in `/home/reviewer/start-up-optimization`.
The host and guest kernel source code are located in `/home/reviewer/kernels`.
The QEMU source code is located in `/home/reviewer/qemu`.
All other necessary software utilities, including kernel binaries, the QEMU executable, and the VM disk image are prepared on the server.

## Building Evaluation Environment
The software environment is ready. There is no need to build any software. The following instructions are only for reference.
### Host Kernel
1. Copy the host kernel config into the directory of the host kernel source.
    ```bash
    cp /home/reviewer/start-up-optimization/kernel-configs/snp/host-config /home/reviewer/kernels/host/.config
    ```
2. Compile the host kernel.
    ```bash
    make -j$(nproc)
    ```
3. Install the host kernel.
    ```bash
    sudo make modules_install
    sudo make install
    ```
    Then reboot and select the installed kernel.
### Guest Kernel
1. Copy the guest kernel config into the directory of the guest kernel source.
    ```bash
    cp /home/reviewer/start-up-optimization/kernel-configs/snp/guest-config /home/reviewer/kernels/guest/.config
    ```
2. (Optional for optimization) Copy `snp-guest.patch` into the directory of the kernel source and apply the patch.
    ```bash
    cp /home/reviewer/start-up-optimization/patches/snp-guest.patch /home/reviewer/kernels/guest
    git apply snp-guest.patch
    ```
3. Compile the guest kernel.
    ```bash
    make -j$(nproc)
    ```
### QEMU
1. Configure the build.
    ```bash
    ./configure --target-list=x86_64-softmmu
    ```
2. (Optional for optimization) Copy the qemu patch into the directory of the QEMU source and apply the patch.
    ```bash
    cp /home/reviewer/start-up-optimization/patches/qemu.patch /home/reviewer/qemu
    git apply qemu.patch
    ```
2. Build QEMU.
    ```bash
    make -j$(nproc)
    ```

## Evaluation
### Check List
- The host kernel should be `6.11.0-rc3-snp-host-85ef1ac03941+`.
### Evaluation with Scripts
1. Change to the directory `scripts/snp` and run `sudo bash enable-passthrough.sh`.
2. By executing `sudo ./start-time.exp`, the user can launch a CVM with device passthrough and observe the start-up time.

In `start-time.exp`, ensure the VM is spawned with `spawn ./run-snp-passthrough.sh` rather than other scripts.
#### CVM w/ Device Passthrough
Modify `./run-snp-passthrough.sh`, ensure that `QEMU` points to `/home/reviewer/qemu-orig/build/qemu-system-x86_64`.
#### CVM w/ Device Passthrough & Start-up Optimization
Modify `./run-snp-passthrough.sh`, ensure that `QEMU` points to `/home/reviewer/qemu-opt/build/qemu-system-x86_64`.
### Expected Results
The reviewer should observe that the VM with start-up optimization boots faster than the baseline VM.
The `expect` script will show similar output:
```
VFIO start-up time: 6636255 microseconds
VM boot time: 11343291 microseconds
```

## Contacts
- shihwei@csie.ntu.edu.tw
- r12922072@csie.ntu.edu.tw
