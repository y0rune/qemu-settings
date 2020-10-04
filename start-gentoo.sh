#!/bin/bash
function start(){
exec qemu-system-x86_64 -enable-kvm \
        -cpu host \
        -drive file=Gentoo-VM.img,if=virtio \
        -netdev user,id=vmnic,hostname=Gentoo-VM \
        -device virtio-rng-pci \
        -m 512M \
        -smp 2 \
        -monitor stdio \
        -name "Gentoo VM" \
        -boot d \
        -device e1000,netdev=network0,mac=52:55:00:d1:55:01 \
        -netdev tap,id=network0,ifname=tap0,script=no,downscript=no \
        -cdrom install-amd64-minimal-20201001T120249Z.iso
}


sudo ip link add br0 type bridge
#sudo ip addr flush dev eth0
sudo ip tuntap add dev tap0 mode tap user $(whoami)
sudo ip link set tap0 master br0
sudo ip link set dev br0 up
sudo ip link set dev tap0 up
sudo ip link set eth0 master br0

start &
sleep 2
vncviewer 127.0.0.1:5900 &

for j in $(jobs -p)
    do
        echo $j
        wait "$j"
    done

pkill -9 qemu
