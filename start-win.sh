#!/bin/bash

function start(){
exec qemu-system-x86_64 -enable-kvm \
        -name "Windows" \
        -cpu host \
        -m 4G \
        -smp 4,threads=4 \
        -vga qxl \
        -usb \
        -usb -device usb-tablet \
        -device e1000,netdev=network0,mac=52:55:00:d1:55:01 \
        -netdev tap,id=network0,ifname=tap0,script=no,downscript=no \
        -spice port=5900,addr=127.0.0.1,disable-ticketing \
        -chardev spicevmc,id=spicechannel0,name=vdagent \
        -device usb-tablet \
        -rtc base=localtime,clock=host \
        -drive driver=raw,file=win10.img,if=virtio \
        -cdrom virtio-win-0.1.189.iso
        # -drive file=Win10_2004_English_x64.iso,index=3,media=cdrom
    }

tunctl -u yorune -t tap0
ifconfig tap0 192.168.100.1 up
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
iptables -I FORWARD 1 -i tap0 -j ACCEPT
iptables -I FORWARD 1 -o tap0 -m state --state RELATED,ESTABLISHED -j ACCEPT

#sudo ip link add br0 type bridge
##sudo ip addr flush dev eth0
#sudo ip tuntap add dev tap0 mode tap user $(whoami)
#sudo ip link set tap0 master br0
#sudo ip link set dev br0 up
#sudo ip link set dev tap0 up
#sudo ip link set eth0 master br0

start &
sleep 2
spicy -h 127.0.0.1 -p 5900 &

for j in $(jobs -p)
    do
        wait "$j"
    done

pkill -9 qemu
