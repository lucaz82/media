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
```
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
```
    volumes:
      - './data:/data'
```

### Install MergeFS
Update Repository Cache <br/>
`apt update -y`

Install with <br/>
`apt install -y mergerfs`

Reboot <br/>
`reboot`

Create new folders with recommended settings using disks which are defined beforehand (see above)
```
# MergerFS to show all systems 1 disk at all times no matter what lies below it || https://github.com/trapexit/mergerfs
# Movies
/mnt/movies-disk1:/mnt/movies-disk2 /data/movies mergerfs defaults,nonempty,allow_other,category.create=mfs,use_ino,cache.files=auto-full,moveonenospc=true,dropcacheonclose=true 0 0
# Series
/mnt/series-disk1 /data/series mergerfs defaults,nonempty,allow_other,category.create=mfs,use_ino,cache.files=auto-full,moveonenospc=true,dropcacheonclose=true 0 0
```

### Disks
use same commands as before to determine disks with ids and place it in `/etc/fstab`

for our usecase we assume the folder `/data` was created and is accessible

```
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
in the ubuntu vm use `parted`

see below for examples:
```
parted

(parted) print
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 53,7GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name  Flags
 1      1049kB  2097kB  1049kB                     bios_grub
 2      2097kB  50,0MB  47,9MB  ext4

(parted) resizepart
Partition number? 2
Warning: Partition /dev/sda2 is being used. Are you sure you want to continue?
Yes/No? Yes
End?  [50,0MB]? 50GB
(parted) print
Model: QEMU QEMU HARDDISK (scsi)
Disk /dev/sda: 53,7GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name  Flags
 1      1049kB  2097kB  1049kB                     bios_grub
 2      2097kB  50,0GB  50,0GB  ext4

(parted)

Information: You may need to update /etc/fstab.
```

then extend it finally <br/>
`resize2fs /dev/sda2`

<br/>
<br/>

[Jump to parent file](Readme.md)