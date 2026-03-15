root_dir="/home/b08902062"
$root_dir/crosvm-opt-startup run --disable-sandbox \
             --mem $((8192*3)) \
             --cpus 8 \
             -s "crosvm_socket" \
             -p "root=/dev/vda rw swiotlb=force" \
             --rwroot $root_dir/crosvm-1.img,o_direct=true \
             --fdt-position "start" \
             --net tap-name=crosvm_tap,vhost-net \
             --protected-vm-without-firmware \
             $root_dir/Images/Image_vfio_swiotlb
rm crosvm_socket
