echo 0 > /sys/module/kvm/parameters/halt_poll_ns
echo always > /sys/kernel/mm/transparent_hugepage/enabled
echo always > /sys/kernel/mm/transparent_hugepage/shmem_enabled
echo always > /sys/kernel/mm/transparent_hugepage/defrag
