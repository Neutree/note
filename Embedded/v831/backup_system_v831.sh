#/bin/bash

set -e

########################
device=/dev/sdd
img_name=maixos_maixii.img
sector_size=512
########################

out_dir=out
mkdir -p $out_dir

p1_start=`sudo fdisk -l $device |grep ${device}1 |awk '{print $2}'`
p1_end=`sudo fdisk -l $device |grep ${device}1 |awk '{print $3}'`

p2_start=`sudo fdisk -l $device |grep ${device}2 |awk '{print $2}'`
p2_end=`sudo fdisk -l $device |grep ${device}2 |awk '{print $3}'`

p3_start=`sudo fdisk -l $device |grep ${device}3 |awk '{print $2}'`
p3_end=`sudo fdisk -l $device |grep ${device}3 |awk '{print $3}'`

p4_start=`sudo fdisk -l $device |grep ${device}4 |awk '{print $2}'`
p4_end=`sudo fdisk -l $device |grep ${device}4 |awk '{print $3}'`

p5_start=`sudo fdisk -l $device |grep ${device}5 |awk '{print $2}'`
p5_end=`sudo fdisk -l $device |grep ${device}5 |awk '{print $3}'`

p6_start=`sudo fdisk -l $device |grep ${device}6 |awk '{print $2}'`
# p6_end=`sudo fdisk -l $device |grep ${device}7 |awk '{print $3}'`

total_M=$((${p6_start} * $sector_size / 1024 / 1024 +  10))

echo "-- total size: $total_M MiB"
echo "-- now generate img, wait ..."

sudo dd if=/dev/zero of=$out_dir/$img_name bs=1M count=$total_M status=progress
ls -al $out_dir

echo "-- now part img"
sudo parted $out_dir/$img_name --script -- mklabel gpt
sudo parted $out_dir/$img_name --script -- mkpart env ${p1_start}s ${p1_end}s
sudo parted $out_dir/$img_name --script -- mkpart boot fat32 ${p2_start}s ${p2_end}s
sudo parted $out_dir/$img_name --script -- mkpart cfg fat32 ${p3_start}s ${p3_end}s
sudo parted $out_dir/$img_name --script -- mkpart rootfs fat32 ${p4_start}s ${p4_end}s
sudo parted $out_dir/$img_name --script -- mkpart swap fat32 ${p5_start}s ${p5_end}s
sudo parted $out_dir/$img_name --script -- mkpart disk ext4 ${p6_start}s -1

echo "-- copy"
sudo dd if=${device}1 of=$out_dir/temp.bin
sudo python3 copy_bin.py --seek $(($p1_start * $sector_size)) --size $((($p1_end + 1 - $p1_start) * $sector_size)) $out_dir/temp.bin $out_dir/$img_name
sudo dd if=${device}2 of=$out_dir/temp.bin
sudo python3 copy_bin.py --seek $(($p2_start * $sector_size)) --size $((($p2_end + 1 - $p2_start) * $sector_size)) $out_dir/temp.bin $out_dir/$img_name
rm -rf $out_dir/temp.bin


echo "-- create loop device"
loop_device=`sudo losetup --show -f $out_dir/$img_name`
loop_device_mapper=`sudo kpartx -va $loop_device`
if [ "${loop_device_mapper}x" == "x" ]; then
    echo "==== error when map loop device ${loop_device}==="
    sudo kpartx -d ${loop_device} && sudo losetup -d ${loop_device}
    exit 1
fi
loop_device_name=`echo $loop_device_mapper | sed -E 's/.*(loop[0-9].*)p.*/\1/g' | head -1`
echo "-- loop device: $loop_device, mapper: ${loop_device_mapper}, name:$loop_device_name"

echo "-- format"
sudo mkfs.vfat /dev/mapper/${loop_device_name}p3
sudo mkfs.ext4 /dev/mapper/${loop_device_name}p4
sudo mkswap /dev/mapper/${loop_device_name}p5


echo "-- mount"
mkdir -p $out_dir/cfg_src
mkdir -p $out_dir/root_src
mkdir -p $out_dir/cfg
mkdir -p $out_dir/root
sudo mount -t vfat /dev/mapper/${loop_device_name}p3 $out_dir/cfg
sudo mount -t ext4 /dev/mapper/${loop_device_name}p4 $out_dir/root
sudo mount ${device}3 $out_dir/cfg_src
sudo mount ${device}4 $out_dir/root_src

echo "-- copy cfg part"
if [ "`ls -A $out_dir/cfg_src/`" = "" ]; then
    echo "-- cfg is empty, no file to copy, skip"
else
    sudo cp -rfp $out_dir/cfg_src/* $out_dir/cfg
fi

echo "-- copy root"
cwd=`pwd`
cd $out_dir/root
sudo dump -0auf - ../root_src | sudo restore -rf -
cd -

sync
sleep 3

echo "-- umount"
sudo umount $out_dir/cfg_src
sudo umount $out_dir/root_src
sudo umount $out_dir/cfg
sudo umount $out_dir/root

echo "-- delete loop device $loop_device"
sudo kpartx -d $loop_device
sudo losetup -d $loop_device


echo "====================="
echo -e "${green}\nbackup complete\n${normal}"
echo "====================="


