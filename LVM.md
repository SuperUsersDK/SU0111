**LVM**

  * Med fdisk lav 4 partitioner på 5GB, 10GB, 15GB, 20GB 
  * Sæt partitionstype til 0x8E

```bash
pvcreate /dev/sdb{12,13,14,15}
vgcreate datavg /dev/sdb{12,15}
vgcreate homesvg /dev/sdb{13,14}
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
lvremove /dev/datavg/snapshotmed fdisk lav 4 partitioner på 5GB, 10GB, 15GB, 20GB 
sæt partitionstype til 0x8E
pvcreate /dev/sdb{12,13,14,15}
vgcreate datavg /dev/sdb{12,15}
vgcreate homesvg /dev/sdb{13,14}
lvcreate --size 20G  --name datalv datavg
lvcreate --size 20G  --name homeslv homesvg

mkfs /dev/datavg/datalv
mkdir /data
mount /dev/datavg/datalv /data
kopierer mange og nogle større filer over på /data

lvcreate --size 5G --snapshot --name datasnap /dev/datavg/datalv
mkdir /snap
mount /dev/datavg/datasnap /snap
leg med snapshot
lvremove /dev/datavg/snap
lvremove /dev/datavg/datalv

lvremove /dev/datavg/datalv
```
