#!/bin/sh
######################################################
################## TODO: settings#####################
src_root_device=/dev/sdc2 #/dev/root
src_boot_device=/dev/sdc1 #/dev/mmcblk0p1
######################################################


echo '\ninstall software\n'
sudo apt-get install -y dosfstools dump parted kpartx
echo '\ninstall software complete\n'

used_size=`df -P | grep $src_root_device | awk '{print $3}'`
boot_size=`df -P | grep $src_boot_device | awk '{print $2}'`
count=`echo "$used_size*1.1+$boot_size+2"|bc|awk '{printf("%.0f",$1)}'`
echo boot size:$boot_size,used_size:$used_size,block count: $count
echo $(($boot_size/1024+1))
sudo dd if=/dev/zero of=backup.img bs=1k count=$count
sudo parted backup.img --script -- mklabel msdos
sudo parted backup.img --script -- mkpart primary fat32 1M $(($boot_size/1024+1))M #(nByte/512)s
sudo parted backup.img --script -- mkpart primary ext4 $(($boot_size/1024+1))M -1

loopdevice=`sudo losetup --show -f backup.img`
echo $loopdevice
device=`sudo kpartx -va $loopdevice`
device=`echo $device | sed -E 's/.*(loop[0-9])p.*/\1/g' | head -1`
device="/dev/mapper/${device}"
boot_device="${device}p1"
root_device="${device}p2"
sleep 2
sudo mkfs.vfat $boot_device
sudo mkfs.ext4 $root_device
sudo mkdir -p /media/img_to
sudo mkdir /media/img_src
sudo mount -t vfat $boot_device /media/img_to
sudo mount -t vfat $src_boot_device /media/img_src
sudo cp -rfp /media/img_src/* /media/img_to
sudo umount /media/img_to
sudo umount /media/img_src

sudo chattr +d backup.img #exclude img file from backup

sudo mount -t ext4 $root_device /media/img_to
sudo mount -t ext4 $src_root_device /media/img_src
cd /media/img_to
sudo dump -0af - /media/img_src | sudo restore -rf -
cd
sudo umount /media/img_to
sudo umount /media/img_src
sudo kpartx -d $loopdevice
sudo losetup -d $loopdevice
sudo rm /media/img_to /media/img_src -rf

