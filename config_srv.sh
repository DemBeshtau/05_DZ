#!/bin/bash

sudo -i
yum install -y http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

yum install -y epel-release kernel-devel wget
rm -f /lib/modules/`uname -r`/build
ln -s /usr/src/kernels/* /lib/modules/`uname -r`/build
yum-config-manager --disable zfs
yum-config-manager --enable zfs-kmod
yum install -y zfs
modprobe zfs
sudo echo "zfs" >> /etc/modules-load.d/zfs.conf
