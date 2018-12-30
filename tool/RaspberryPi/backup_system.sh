#!/bin/bash
set -o errexit
######################################################
################## TODO: settings#####################
src_root_device=/dev/sdc2 #/dev/root
src_boot_device=/dev/sdc1 #/dev/mmcblk0p1
######################################################

green="\e[32;1m"
normal="\e[0m"

echo -e "${green} \ninstall software\n ${normal}"
sudo apt-get install -y dosfstools dump parted kpartx bc
echo -e "${green} \ninstall software complete\n ${normal}"

echo -e "${green}create image now\n ${normal}"
used_size=`df -P | grep $src_root_device | awk '{print $3}'`
boot_size=`df -P | grep $src_boot_device | awk '{print $2}'`
if [ "x${used_size}" != "x" ] && [ "x${boot_size}" != "x" ];then
	count=`echo "${used_size}*1.1+${boot_size}+2"|bc|awk '{printf("%.0f",$1)}'`
else
	echo "device $src_root_device or $src_boot_device not exist,mount first"
	exit 0;
fi
echo boot size:$boot_size,used_size:$used_size,block count: $count
echo $(($boot_size/1024+1))
sudo dd if=/dev/zero of=backup.img bs=1k count=$count
sudo parted backup.img --script -- mklabel msdos
sudo parted backup.img --script -- mkpart primary fat32 1M $(($boot_size/1024+1))M #(nByte/512)s
sudo parted backup.img --script -- mkpart primary ext4 $(($boot_size/1024+1))M -1

echo -e "${green}mount loop device and copy files to image\n${normal}"
loopdevice=`sudo losetup --show -f backup.img`
echo $loopdevice
device=`sudo kpartx -va $loopdevice`
echo $device
device=`echo $device | sed -E 's/.*(loop[0-9]*)p.*/\1/g' | head -1`
# device=`echo $device |awk '{print $3}' | head -1`
echo $device
device="/dev/mapper/${device}"
boot_device="${device}p1"
root_device="${device}p2"
sleep 2
sudo mkfs.vfat $boot_device
sudo mkfs.ext4 $root_device
sudo mkdir -p /media/img_to
sudo mkdir /media/img_src
mount_path=`df -h|grep ${src_boot_device}|awk '{print $6}'`
if [ "x${mount_path}" == "x" ];then
  sudo mount -t vfat $src_boot_device /media/img_src
  mount_path=/media/img_src
fi
sudo mount -t vfat $boot_device /media/img_to
echo -e "${green}copy /boot${normal}"
sudo cp -rfp ${mount_path}/* /media/img_to
sudo umount /media/img_to

sudo chattr +d backup.img #exclude img file from backup(support in ext* file system)
echo "if 'Operation not supported while reading flags on backup.img' comes up, ignore it"

mount_path=`df -h|grep ${src_root_device}|awk '{print $6}'`
echo root mount path: $mount_path
if [ "x${mount_path}" == "x" ];then
  sudo mount -t ext4 $src_root_device /media/img_src
  mount_path=/media/img_src
fi
sudo mount -t ext4 $root_device /media/img_to

cd /media/img_to
echo -e "${green}copy /${normal}"
sudo dump -0auf - ${mount_path} | sudo restore -rf -
cd
sudo umount /media/img_to

sudo kpartx -d $loopdevice
sudo losetup -d $loopdevice
sudo rm /media/img_to /media/img_src -rf

echo -e "${green}\nbackup complete\n${normal}"
