#!/bin/bash
function start(){
exec qemu-system-x86_64 -enable-kvm \
        -cpu host \
        -drive file=Gentoo-VM.img,if=virtio \
        -netdev user,id=vmnic,hostname=Gentoo-VM \
        -device virtio-rng-pci \
        -m 10240M \
        -smp 8 \
        -monitor stdio \
        -name "Gentoo VM" \
        -boot d \
        -device e1000-82545em,netdev=network0,mac=52:55:00:d1:55:01 \
        -netdev tap,id=network0,ifname=tap0,script=no,downscript=no \
        -cdrom install-amd64-minimal-20201001T120249Z.iso
}

sudo ip link add br0 type bridge
sudo ip tuntap add dev tap0 mode tap user $(whoami)
sudo ip link set tap0 master br0
sudo ip link set dev br0 up
sudo ip link set dev tap0 up
sudo ip link set eth0 master br0
sudo sysctl -w net.ipv4.ip_forward=1
sudo ip route add 192.168.0.220 dev br0

sleep 5

start

sleep 5

sudo ip route del 192.168.0.220 dev br0
sudo sysctl -w net.ipv4.ip_forward=0
sudo ip link set eth0
sudo ip link set dev tap0 down
sudo ip link set dev br0 down
sudo ip link del tap0
sudo ip link del br0
