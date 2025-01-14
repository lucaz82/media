# Configuration `mediahost` VM

vmid `101`
The VM holds two users, `root`(0) and `redacted`(1000)<br/>

I usually work with root because I'm an admin and accept the "security risks" <br/>
=> this is why there's never `sudo` before any command

The VM uses my custom [aliases](aliases.md)

## SSH

Create an SSH key in PuttyKeyGen and save it to your computer/private cloud

On the VM goto `/root/.ssh/authorized_keys` and paste the public key in, expanding the file

Setup Putty to connect to the ip and use your private key as auth

### Edit the ssh config file

`nano /etc/ssh/sshd_config` and make sure `PermitRootLogin prohibit-password` is set

## Install and Configure Docker

https://docs.docker.com/engine/install/ubuntu/

Create an folder
we are admins, so we work as root - use of other users belonging to the sudoer-group should work, too

mkdir `/docker`

create folders using this structure

```yaml
/docker/service1
  /docker/service1/config
  /docker/service1/data
  /docker/service1/db_data
  /docker/service1/docker-compose.yaml
/docker/service2
  /docker/service2/config
  /docker/service2/docker-compose.yaml
```

in the `docker-compose.yaml`you can reference those folders using relative paths like

```yaml
    volumes:
      - './data:/data'
```

## Install MergeFS

Update Repository Cache <br/>
`apt update -y`

Install with <br/>
`apt install -y mergerfs`

Reboot <br/>
`reboot`

Create new folders with recommended settings using disks which are defined beforehand (see above)

```bash
# MergerFS to show all systems 1 disk at all times no matter what lies below it || https://github.com/trapexit/mergerfs
# Movies
/mnt/movies-disk1:/mnt/movies-disk2 /data/movies mergerfs defaults,nonempty,allow_other,category.create=mfs,use_ino,cache.files=auto-full,moveonenospc=true,dropcacheonclose=true 0 0
# Series
/mnt/series-disk1 /data/series mergerfs defaults,nonempty,allow_other,category.create=mfs,use_ino,cache.files=auto-full,moveonenospc=true,dropcacheonclose=true 0 0
```

## Disks

use same commands as before to determine disks with ids and place it in `/etc/fstab`

for our usecase we assume the folder `/data` was created and is accessible

```bash
# SERIES HDD PASSTHROUGH (4TB Seagate 07/2024)
UUID=5c34014d-50f6-4070-b1c4-673c8d86791e /mnt/series-disk1 auto nosuid,nodev,nofail,x-gvfs-show 0 0

# MOVIES HDD PASSTROUGH (1TB Seagate ??/????)
UUID=0b77fe0a-e6c3-49a1-bca3-b30ed7039a08 /mnt/movies-disk1 auto nosuid,nodev,nofail,x-gvfs-show 0 0

# MOVIES HDD PASSTROUGH (1TB Hitachi ??/????)
UUID=13318462-ba16-40b2-9a7b-fc54da4f33c7 /mnt/movies-disk2 auto nosuid,nodev,nofail,x-gvfs-show 0 0

# USENET SSD RAID10 ZFS from Host
UUID=79406f2b-cfc5-43f9-a030-23733424e86d /data/usenet auto nosuid,nodev,nofail,x-gvfs-show 0 0
```

### Increase disksize

First: goto proxmox and verify the free space at the zfs pool or storage block <br/>
then increase the vm disk size under hardware -> disk action -> increase size -> increment in GB

hit apply and reboot vm <br/>

in the ubuntu vm use `cfdisk`

#### Rescan Disk devices

`echo 1>/sys/class/block/sda/device/rescan`

#### Check which partition

`lsblk`

#### Extend via CFdisk

- Select desired partition e.g. `/dev/sda2`
- Select Resize, select new size
- Select Write from the menu to save the changes to the disk partition layout
- Quit cfdisk


#### If using LVM:

Let’s review LVM’s concepts and terms:
> Physical Volume (PV) – your physical disks (/dev/sda, /dev/sdb, etc.)
> Volume Group (VG) – contains one or more physical volumes (disks). For example, ubuntu-vg = /dev/sda + /dev/sdb
> Logical Volume (LV) – is a logical volume in a volume group. For example: ubuntu-vg/root, ubuntu-vg/home, etc.

Check the available free space in your LVM volume group:

`vgdisplay`


In order to expand an LVM partition, you first need to increase the size of the PV (Physical Volume):

`pvresize /dev/sda3`

Now you may extend the logical volume. In this case, we will resize the volume using all the free space available:

`lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv`<br/>
Logical volume ubuntu-vg/ubuntu-lv successfully resized.



#### Anyways, we have to expand the file system

For ext2, ext3 and ext4, run the command below:

`resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

Check the available free space:

`df -h`

## Guest tools

<https://pve.proxmox.com/wiki/Qemu-guest-agent>

`apt-get install qemu-guest-agent` <br/>

`systemctl start qemu-guest-agent` <br/>

`systemctl enable qemu-guest-agent` <br/>


### Outpooling Plex-Cache (same works for jellyfin)

In `/docker/plex/docker-compose.yaml`
Add

```YAML
- '/data/plex-cache:/config/Library/Application Support/Plex Media Server/Cache'
```

=> we're remapping the cache from inside the container towards `/data/plex-cache`

Optional, but useful since we use plex-cache deleter

since our data foldier lies under `/docker/plex/config` we need to go to `./Library/Application Support/Plex Media Server`<br/>

`mv Cache Cache.old` <br/>

and create a symlink<br/>
`ln -s /data/plex-cache/`<br/>

`chown -R chef: plex-cache`<br/>



<br/>
<br/>

[Jump to parent file](README.md)
