ip link set enp129s0f1np1 down
modprobe vfio-pci
# sudo bash /tmp2/b08902062/vfio-pci-bind/vfio-pci-bind.sh 8086:1583 81:00.1
sudo bash /tmp2/b08902062/vfio-pci-bind/vfio-pci-bind.sh 14e4:165f c1:00.0
