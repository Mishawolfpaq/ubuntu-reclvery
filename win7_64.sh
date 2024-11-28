#!/bin/bash
#Source - https://bitbucket.org/sakhnik/win7_64/src/master/win7_64.sh
# https://sakhnik.com/2016/11/10/win7-in-qemu.html
diskimg=win7_64.qcow2
virtimg=virtio-win.iso

vm_socket=/tmp/vm_spice.socket

launch_spice()
{
    while ! test -S $vm_socket; do
        sleep 0.05
    done

    spicy --uri="spice+unix://$vm_socket" >/tmp/spicy.log 2>&1
}

launch_spice &

qemu-system-x86_64 \
    -cpu host \
    -smp cores=2,threads=4 \
    -machine type=pc,accel=kvm \
    -rtc base=localtime,clock=host \
    -m 3072 \
    -drive file=${diskimg},index=0,media=disk,if=virtio \
    -drive file=${virtimg},index=3,media=cdrom \
    -net nic,model=virtio -net user \
    -soundhw hda \
    -vga qxl \
    -spice unix,addr=$vm_socket,disable-ticketing \
    -device virtio-serial-pci \
    -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
    -chardev spicevmc,id=spicechannel0,name=vdagent \
    -usbdevice tablet \
    -show-cursor \
    -balloon virtio \
    -monitor stdio \
    2>/tmp/win7_64.log


#    -spice port=5930,disable-ticketing \
#    -net nic,model=virtio -net bridge,br=bridge0 \