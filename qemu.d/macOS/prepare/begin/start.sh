#!/bin/bash

# debugging
set -x

# load variables we defined
source "/etc/libvirt/hooks/kvm.conf"

# stop display manager
systemctl stop lightdm.service
pulse_pid=$(pgrep -u sylvester pulseaudio)
pipewire_pid=$(pgrep -u sylvester pipewire-media)
kill $pulse_pid
kill $pipewire_pid

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind

# Unbind EFI-framebuffer
#echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# Avoid race conditions
sleep 7

# unload amd drivers
modprobe -r amdgpu

# unbind gpu
virsh nodedev-detach $VIRSH_GPU_VIDEO
virsh nodedev-detach $VIRSH_GPU_AUDIO

# load vfio
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1
