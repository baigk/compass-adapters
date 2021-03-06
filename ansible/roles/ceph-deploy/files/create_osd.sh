mkdir -p /ceph/images
dd if=/dev/zero of=/ceph/images/ceph-volumes.img bs=1M seek=10240 count=0 oflag=direct
sgdisk -g --clear /ceph/images/ceph-volumes.img
vgcreate ceph-volumes $(sudo losetup --show -f /ceph/images/ceph-volumes.img)
sudo lvcreate -L9G -nceph0 ceph-volumes
mkfs.xfs -f /dev/ceph-volumes/ceph0
mkdir -p /var/local/osd
mount /dev/ceph-volumes/ceph0 /var/local/osd
