root_dir="/home/b08902062"
$root_dir/crosvm-startup run --disable-sandbox \
             --mem $((8192)) \
             --cpus 8 \
             -s "crosvm_socket" \
             -p "root=/dev/vda rw swiotlb=force" \
             --rwroot $root_dir/crosvm-1.img,o_direct=true \
             --fdt-position "start" \
             --swiotlb 64 \
             --vfio /sys/bus/pci/devices/0002:01:00.0,guest-address=00:09.0,iommu=off \
             $root_dir/Images/Image_vfio_swiotlb
rm crosvm_socket
