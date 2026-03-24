#!/bin/bash
CMDLINE=""
CMDLINE="swiotlb=force"
CONSOLE="9889"
UEFI_BIOS="/tmp2/b08902062/AMDSEV/snp-release-2025-05-29/usr/local/share/qemu/OVMF.fd"
KERNEL="snp-guest-opt"
IMAGE="/tmp2/b08902062/vm/cloud.img"
QEMU="/home/reviewer/qemu-orig/build/qemu-system-x86_64"
# QEMU="/home/reviewer/qemu-opt/build/qemu-system-x86_64"
TRACE=""
QMP="9899"
MEM="$((8192*8))"
SMP="8"
RESUME=""
NET=""
MACHINE="-enable-kvm -cpu EPYC-v4 -machine q35"
MACHINE="$MACHINE -machine memory-encryption=sev0,vmport=off"

get_cbitpos() {
	modprobe cpuid
	#
	# Get C-bit position directly from the hardware
	#   Reads of /dev/cpu/x/cpuid have to be 16 bytes in size
	#     and the seek position represents the CPUID function
	#     to read.
	#   The skip parameter of DD skips ibs-sized blocks, so
	#     can't directly go to 0x8000001f function (since it
	#     is not a multiple of 16). So just start at 0x80000000
	#     function and read 32 functions to get to 0x8000001f
	#   To get to EBX, which contains the C-bit position, skip
	#     the first 4 bytes (EAX) and then convert 4 bytes.
	#

	EBX=$(dd if=/dev/cpu/0/cpuid ibs=16 count=32 skip=134217728 | tail -c 16 | od -An -t u4 -j 4 -N 4 | sed -re 's|^ *||')
	CBITPOS=$((EBX & 0x3f))
}

get_cbitpos

SEV="-object sev-snp-guest,id=sev0,cbitpos=51,reduced-phys-bits=1"

while :
do
    case "$1" in
        --nat )
            NET="-netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp:127.0.0.1:8080-:8080"
            NET="$NET -device virtio-net-pci,netdev=net0"
            shift 1
            ;;
        -k | --kernel )
            KERNEL="$2"
            shift 2
            ;;
        -q | --qemu )
            QEMU="$2"
            shift 2
            ;;
        -c | --console )
            CONSOLE="$2"
            shift 2
            ;;
        -i | --image )
            IMAGE="$2"
            shift 2
            ;;
        -m | --mem )
            MEM="$2"
            shift 2
            ;;
        -s | --smp )
            SMP="$2"
            shift 2
            ;;
        --qmp )
            QMP="$2"
            shift 2
            ;;
        --bios-code )
            UEFI_BIOS_CODE="$2"
            shift 2
            ;;
        --bios-vars )
            UEFI_BIOS_VARS="$2"
            shift 2
            ;;
        -r | --resume )
            RESUME="-incoming tcp:0:$2"
            shift 2
            ;;
        -t | --trace )
            TRACE="--trace events=$2,file=$3"
            shift 3
            ;;
        --)
            shift
            break
            ;;
        -* | --* )
            echo "WTF"
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

echo "Mapping CTRL-C to CTRL-]"
stty intr ^]

sudo $QEMU \
    -kernel $KERNEL \
    -nographic \
    -append "console=ttyS0 nokaslr root=/dev/vda rw $CMDLINE" \
    -drive if=none,file=$IMAGE,id=vda,cache=unsafe,format=raw \
    -device virtio-blk-pci,drive=vda \
    -m $MEM \
    -smp $SMP \
    -qmp tcp:localhost:$QMP,server=on,wait=off \
    $SEV \
    $MACHINE \
    $TRACE \
    $RESUME \
	-name sev-step-vm,debug-threads=on \
    -bios ${UEFI_BIOS} \
    -device vhost-vsock-pci,guest-cid=3 \
    -device vfio-pci,host=0000:c1:00.0
    # -device vfio-pci,host=0000:81:00.1 \

stty intr ^c
