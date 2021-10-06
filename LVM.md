**LVM**

  * Med fdisk lav 4 partitioner på 5GB, 10GB, 15GB, 20GB 
  * Sæt partitionstype til 0x8E

```bash
pvcreate /dev/sda{5,6,7,8}
vgcreate datavg /dev/sda{5,8}
vgcreate homesvg /dev/sda{6,7}
lvcreate --size 20G  --name datalv datavg
lvcreate --size 20G  --name homeslv homesvg

mkfs /dev/datavg/datalv
mkdir /data
mount /dev/datavg/datalv /data
```

  * Kopierer mange og nogle større filer over på /data

```bash
lvcreate --size 4G --snapshot --name datasnap /dev/datavg/datalv
mkdir /snapshot
mount /dev/datavg/datasnap /snapshot
```

  * leg med snapshot

```bash
lvremove /dev/datavg/snap
lvremove /dev/datavg/datalv
```
