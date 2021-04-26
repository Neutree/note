#!/bin/bash
#
# backup script for raspberry Pi, backup on PC in recommend
# usage:
#       1. Cleanup your unuseful files in system
#       2. Reboot to check system can normally boot
#       3. Shutdown and remove TF card from Pi, and put it in a card reader
#       4. Plug your card reader into a PC's USB port
#       5. PC's OS should be ubuntu(recommend)/dedian/arch/manjaro
#       6. Edit the TODO section below, find your device by `sudo lsblk` command
#       7. Execute script, the script will automatically install software and print size,
#          ensure your PC have enough place
#       8. wait and see if error occurrs, if error occurrs,
#          see error carefully and maybe you can change config to resolve it
#
#       9. If error occurred, you can manually umount virual device by
#          `df -h` to see mount info, then `sudo umount dir`
#          `sudo blkid`, then `sudo kpartx -d /dev/loopx && sudo losetup -d /dev/loopx`
# recover:
#        1. Burn image to TF card by `sudo dd if=backup.img of=/dev/sdx status=progress bs=1MiB`
#                                    or other tools like etcher, win32diskimager etc.
#        2. Expand filesystem
#               way1: boot system on Pi and switch to console by `ctrl+alt+F1`, 
#                     login and execute `sudo raspi-config`, in `advanced config` select `expand filesystem`, `reboot`, all things done
#               way2: use gparted GUI tool to expand filesystem              
# author: neucrack (neucrack.com)
# update: 2021-04-26 optimize backup
#


set -o errexit
######################################################
################## TODO: settings#####################
src_boot_device=/dev/sde1         #/dev/mmcblk0p1
src_root_device=/dev/sde2         #/dev/root
src_boot_device_blkid=/dev/sde1   #/dev/mmcblk0p1
src_root_device_blkid=/dev/sde2   #/dev/mmcblk0p2

root_backup_size=1.3              # root backup size, 1 means the same as used size
os_arch_manjaro=0                 # for system Arch or Manjaro, else ubuntu/debian
backup_on_pi=0                 # 1: backup on pi(maybe not well supported), 0: backuo on PC (recommend)
# !!!!!if back on PI, it's better to use rsync
copy_use_rsync=0               # 1: use rsync to copy files, 0: use dump command to copy files
# !!!!!if back on PI, you should umount all your disk devices like USB disk or add exclude here
# rsync_exlude='--exclude relative_path1 --exclude relative_path2'
rsync_exlude='--exclude home/pi/data/raid'
######################################################


green="\e[32;1m"
yellow="\e[33;1m"
red="\e[31;1m"
purple="\e[35;1m"
normal="\e[0m"

# check
if [ "${backup_on_pi}x" == "1x" ]; then
  echo "====================="
  echo -e "${green}backup on pi${normal}"
  echo "====================="
  root_uid=`sudo cat /etc/passwd | grep root|awk -F : '{print $3}'`
  root_gid=`sudo cat /etc/passwd | grep root|awk -F : '{print $4}'`
  if [ "${root_uid}x" != "${root_gid}x" ]; then
    echo "root user(uid:${root_uid}, gid:${root_gid}) must belong to root group, change by sudo usermod -g root root"
    exit 1
  fi
else
  echo "====================="
  echo -e "${green}backup on PC${normal}"
  echo "====================="
fi

echo -e "${green} \ninstall software\n ${normal}"
if [ "${os_arch_manjaro}x" == "1x" ]; then
  echo "-- install by pacman"
  sudo pacman -S dosfstools parted multipath-tools bc
else
  sudo apt-get install -y dosfstools dump parted kpartx bc
fi
echo -e "${green} \ninstall software complete\n ${normal}"

echo -e "before backup, it's better to clean your temp files and not useful files, and carefully, not detele useful data!!!"
if [ "${os_arch_manjaro}x" != "1x" ]; then
  if [ "${backup_on_pi}x" == "1x" ]; then
    echo -e "${gren} \nclean apt cache\n${normal}"
    sudo apt-get autoremove -yq --purge
    sudo apt-get clean
    sudo rm -rf /var/lib/apt/lists/*
    sudo rm -rf /tmp/*
  fi
fi

if [ "${backup_on_pi}x" != "1x" ]; then
  echo -e "${green} mount ${normal}"
  sudo mkdir -p /media/backup_src_boot
  sudo mkdir -p /media/backup_src_root
  if df -P | grep $src_boot_device_blkid ; then
    echo "already mounted"
  else
    sudo mount $src_boot_device_blkid /media/backup_src_boot
    sudo mount $src_root_device_blkid /media/backup_src_root
  fi
  echo -e "${green} mount ok ${normal}"
fi

echo -e "${green}create image now\n ${normal}"
used_size=`df -P | grep $src_root_device | awk '{print $3}'`
boot_size=`df -P | grep $src_boot_device | awk '{print $2}'`
if [ "x${used_size}" != "x" ] && [ "x${boot_size}" != "x" ];then
        count=`echo "${used_size}*${root_backup_size}/1024+${boot_size}/1024+2"|bc|awk '{printf("%.0f",$1)}'`
else
        echo "device $src_root_device or $src_boot_device not exist in `df -P`,mount first"
        exit 0;
fi
echo -e "${green}boot size:$(($boot_size/1024+1))MiB, root used_size:$(($used_size/1024)) MiB, will backup as: $count MiB ${normal}"
echo -e "${purple}If your mem > used_size, it's a faster way to backup in tempfs directory~~~${normal}"
echo -e "${yellow}continue? yes or no${normal}"


read x
case "$x" in 
   y|yes ) echo "#########";;
   n|no  ) exit 1;;
   * ) echo "Only answer yes or no!"
esac

echo -e "${green} now generate empty img, it may take a while, wait please ... ${normal}"
sudo dd if=/dev/zero of=backup.img bs=1M count=$count status=progress

echo -e "${green} now part img ${normal}"
bootstart=`sudo fdisk -l | grep $src_boot_device_blkid | awk '{print $2}'`
bootend=`sudo fdisk -l | grep $src_boot_device_blkid | awk '{print $3}'`
rootstart=`sudo fdisk -l | grep $src_root_device_blkid | awk '{print $2}'`
echo "boot addr: $bootstart - $bootend, root addr: $rootstart >>> end"
sudo parted backup.img --script -- mklabel msdos
sudo parted backup.img --script -- mkpart primary fat32 ${bootstart}K ${bootend}K
sudo parted backup.img --script -- mkpart primary ext4 ${rootstart}K -1

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
sleep 5
sudo mkfs.vfat $boot_device
sudo mkfs.ext4 $root_device
sudo mkdir -p /media/img_to_boot
sudo mkdir -p /media/img_to_root
sudo mkdir -p /media/img_src_boot
sudo mkdir -p /media/img_src_root
mount_path=`df -h|grep ${src_boot_device}|awk '{print $6}'`
if [ "x${mount_path}" == "x" ];then
  sudo mount -t vfat $src_boot_device /media/img_src_boot
  mount_path=/media/img_src_boot
fi
sudo mount -t vfat $boot_device /media/img_to_boot
echo -e "${green}copy /boot(${mount_path} to /media/img_to_boot)${normal}"
sudo cp -rfp ${mount_path}/* /media/img_to_boot
sync


#################################

mount_path=`df -h|grep ${src_root_device}|awk '{print $6}'`
echo root mount path: $mount_path
if [ "x${mount_path}" == "x" ];then
  sudo mount -t ext4 $src_root_device /media/img_src_root
  mount_path=/media/img_src_root
fi
sudo mount -t ext4 $root_device /media/img_to_root

echo -e "${green}copy /${normal}"
if [[ "${copy_use_rsync}x" == "1x" ]]; then
  if [ "${backup_on_pi}x" == "1x" ]; then
    curr_dir=`pwd`
    backup_img_exclude="--exclude '${curr_dir}/backup.img'"
    backup_img_exclude=`echo ${backup_img_exclude} | sed -e "s/\///"`
  else
    backup_img_exclude=""
  fi
  if [ -f /etc/dphys-swapfile ]; then
    SWAPFILE=`cat /etc/dphys-swapfile | grep ^CONF_SWAPFILE | cut -f 2 -d=`
    if [ "$SWAPFILE" = "" ]; then
      SWAPFILE=/var/swap
    fi
    EXCLUDE_SWAPFILE="--exclude $SWAPFILE"
  fi
  sudo rsync --force -rltWDEgop --delete --stats --progress \
    $EXCLUDE_SWAPFILE \
    --exclude '.gvfs' \
    --exclude 'media/' \
    --exclude 'mnt/' \
    --exclude 'tmp/' \
    --exclude 'lost\+found/' \
    --exclude 'var/lib/apt/lists/' \
    $rsync_exlude \
    $backup_img_exclude \
    ${mount_path}/* /media/img_to_root
else
  if [ "${backup_on_pi}x" == "1x" ]; then
    # exclude backup.img from backup
    sudo chattr +d backup.img #exclude img file from backup(support in ext* file system)
  fi
  cd /media/img_to_root
  tmp_inode=`stat ${mount_path}/tmp --printf "%i"`
  lost_found_inode=`stat ${mount_path}/lost\+found/ --printf "%i"`
  media_inode=`stat ${mount_path}/media --printf "%i"`
  mnt_inode=`stat ${mount_path}/mnt --printf "%i"`
  apt_inode=`stat ${mount_path}/var/lib/apt/lists --printf "%i"`
  sudo dump -e ${tmp_inode},${lost_found_inode},${media_inode},${mnt_inode},${apt_inode} -0auf - ${mount_path} | sudo restore -rf -
fi

sync


echo -e "${green}update partUUID${normal}"
uuid_boot_src=`sudo blkid -o export ${src_boot_device_blkid} | grep PARTUUID`
uuid_boot_dst=`sudo blkid -o export ${boot_device} | grep PARTUUID`
uuid_root_src=`sudo blkid -o export ${src_root_device_blkid} | grep PARTUUID`
uuid_root_dst=`sudo blkid -o export ${root_device} | grep PARTUUID`
echo -e "${green}old boot partUUID: $uuid_boot_src , new: $uuid_boot_dst ${normal}"
echo -e "${green}old root partUUID: $uuid_root_src , new: $uuid_root_dst ${normal}"
sudo sed -i "s/$uuid_root_src/$uuid_root_dst/g" /media/img_to_boot/cmdline.txt
sudo sed -i "s/$uuid_root_src/$uuid_root_dst/g" /media/img_to_root/etc/fstab
sudo sed -i "s/$uuid_boot_src/$uuid_boot_dst/g" /media/img_to_root/etc/fstab
echo -e "${green}update partUUID complete${normal}"

# create temp dirs
sudo mkdir -p /media/img_to_root/tmp
sudo mkdir -p /media/img_to_root/media
sudo mkdir -p /media/img_to_root/mnt
sudo mkdir -p /media/img_to_root/tmp
sudo chmod 777 /media/img_to_root/tmp
sudo mkdir -p /media/img_to_root/var/lib/apt/lists

sync

sleep 5
cd
echo "loopdevice: $loopdevice"
echo -e "${green}umount /media/img_to_boot${normal}"
sudo umount /media/img_to_boot
echo -e "${green}umount /media/img_to_root${normal}"
sudo umount /media/img_to_root

sudo kpartx -d $loopdevice
sudo losetup -d $loopdevice
sudo rm /media/img_to_root /media/img_to_boot /media/img_src_root /media/img_src_boot -rf

if [ "${backup_on_pi}x" != "1x" ]; then
  echo -e "${green} umount ${normal}"
  sudo umount /media/backup_src_boot
  sudo umount /media/backup_src_root
  echo -e "${green} umount ok ${normal}"
fi

echo "====================="
echo -e "${green}\nbackup complete\n${normal}"
echo "====================="

