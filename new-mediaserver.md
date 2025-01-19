# Mediaserver 2025

## overview

**TLDR: KISS**

- OS: Ubuntu 24.04, install via ISO on USB Stick
- IP: dhcp, via netplan

---
### software raid


| raw size in gb | type | manufacterer | purchased |
| -------------- | ---- | ------------ | --------- |
| 256            | SSD  | samsung      | ??/????   |
| 512            | SSD  | intel        | ??/????   |

![configure md0 on install](<img/md0.jpg>)

---
### directories

| dir     | subdir      | type | function                                            |
| ------- | ----------- | ---- | --------------------------------------------------- |
| /docker |             | ssd  | contains all compose files and configs or databases |
|         | config/     | "-"  | container configs                                   |
|         | compose.yml | "-"  | stack information                                   |
| /data   |             | ssd  | folder to hold fstab mounts                         |
|         | movies/     | hdd  | mounted from `/etc/fstab`                           |
|         | series/     | hdd  | mounted from `/etc/fstab`                           |
|         | usenet/     | hdd  | mounted from `/etc/fstab`                           |
|         | anime       | -    | symlink to `/data/series/anime/`                    |
|         | plex-cache/ | ssd  | volume bind from docker container for caching       |
|         | music/      | ssd  | mounted from /etc/fstab                             |


## config

### change login options

we are root so after installing we do

- `su root`
- change root password
  - `passwd`

optional

- allow password login as root
- `nano /etc/sshd/sshd_config`
- `permitrootlogin yes`
- `service ssh restart`

optional

- generade an openssh key via
  - `ssh-keygen -b 4096`swapoff -a
- copy pub key to
  - `/root/.ssh/authorized_keys`

others
- disable swap
  - `swapoff -a`
  - comment it in `/etc/fstab`
- my custom [aliases](aliases.md)
- disable modt-news
  - `nano /etc/default/motd-news`

---
### copy before migration

- copy
  - authorized_keys
  - mediahost /docker
  - minecraft-docker /docker
  - /etc/fstab
  - boot loader options

---
### install tools

- `apt-install`
  - `mergerfs joe mc progress iotop nmon`

---
### install docker

https://docs.docker.com/engine/install/ubuntu/

---
### TODO: install remote luks

<https://www.cyberciti.biz/security/how-to-unlock-luks-using-dropbear-ssh-keys-remotely-in-linux/>

- view current disks
  - `lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT`
- install dropbear-initramfs
  - `apt update -y && apt upgrade -y`
  - `apt install dropbear-initramfs`
- paste previosly generated keys to (like ssh)
  - `/etc/dropbear/initramfs/authorized_keys`
- edit config file
  - `nano /etc/dropbear/initramfs/dropbear.conf`
- set parameters
  - `DROPBEAR_OPTIONS="-I 0 -j -k -p 2222 -s -c cryptroot-unlock"`
    - <https://linux.die.net/man/8/dropbear>
- update initram
  - `update-initramfs -u`


## fstab

<details><summary>old</summary>

```bash
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sda2 during curtin installation
/dev/disk/by-uuid/566a8c55-0ed1-4f4f-8013-65d046e57f39 / ext4 defaults 0 1
/swap.img       none    swap    sw      0       0

# SERIES HDD PASSTHROUGH (4TB Seagate 07/2024)
UUID=5c34014d-50f6-4070-b1c4-673c8d86791e /mnt/series-disk1 auto nosuid,nodev,nofail,x-gvfs-show 0 0

# MOVIES HDD PASSTROUGH (1TB Seagate ??/????)
UUID=0b77fe0a-e6c3-49a1-bca3-b30ed7039a08 /mnt/movies-disk1 auto nosuid,nodev,nofail,x-gvfs-show 0 0

# MOVIES HDD PASSTROUGH (1TB Hitachi ??/????)
UUID=13318462-ba16-40b2-9a7b-fc54da4f33c7 /mnt/movies-disk2 auto nosuid,nodev,nofail,x-gvfs-show 0 0

# USENET SSD RAID10 ZFS from Host
UUID=afb11cdf-d080-4c87-a420-387f7acee893 /data/usenet auto nosuid,nodev,nofail,x-gvfs-show 0 0

# MergerFS to show all systems 1 disk at all times no matter what lies below it || https://github.com/trapexit/mergerfs
# Movies
/mnt/movies-disk1:/mnt/movies-disk2 /data/movies mergerfs defaults,nonempty,allow_other,category.create=mfs,use_ino,cache.files=auto-full,moveonenospc=true,dropcacheonclose=true 0 0
# Series
/mnt/series-disk1 /data/series mergerfs defaults,nonempty,allow_other,category.create=mfs,use_ino,cache.files=auto-full,moveonenospc=true,dropcacheonclose=true 0 0
```

</details>

---

<details><summary>new</summary>

```bash
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/vg0/lv-0 during curtin installation
# https://alexskra.com/blog/ubuntu-20-04-with-software-raid1-and-uefi/
/dev/disk/by-id/dm-uuid-LVM-HkqjQKro7jkuffVLyJ2dSVsOnzbV3cniAgQk1N9EW8x8NcqxdAixw2mbchVOZQtS / ext4 defaults 0 1
#/swap.img       none    swap    sw      0       0

# SERIES HDD (4TB Seagate 07/2024)
UUID=5c34014d-50f6-4070-b1c4-673c8d86791e /data/series auto nosuid,nodev,nofail,x-gvfs-show 0 0

# MOVIES HDD (4TB WD RED ??/????)
UUID=6f59b908-4376-4ccd-a98a-bc6e8a3abce1 /data/movies auto nosuid,nodev,nofail,x-gvfs-show 0 0

# MOVIES HDD (1TB Seagate ??/????)
#UUID=0b77fe0a-e6c3-49a1-bca3-b30ed7039a08 /mnt/movies-old-disk1 auto nosuid,nodev,nofail,x-gvfs-show 0 0

# MOVIES HDD (1TB Hitachi ??/????)
#UUID=13318462-ba16-40b2-9a7b-fc54da4f33c7 /mnt/movies-old-disk2 auto nosuid,nodev,nofail,x-gvfs-show 0 0

# MergerFS to show all systems 1 disk at all times no matter what lies below it || https://github.com/trapexit/mergerfs
# Movies
#/mnt/movies-old-disk1:/mnt/movies-old-disk2:/mnt/movies-disk1 /data/movies mergerfs defaults,nonempty,allow_other,category.create=mfs,use_ino,cache.files=auto-full,moveonenospc=true,dropcacheonclose=true 0 0
# Series
#/mnt/series-disk1 /data/series mergerfs defaults,nonempty,allow_other,category.create=mfs,use_ino,cache.files=auto-full,moveonenospc=true,dropcacheonclose=true 0 0
```

</details>


## metrics

we use node exporter + prometheus + grafana

<https://gist.github.com/jarek-przygodzki/735e15337a3502fea40beba27e193b04>

- `useradd --system --shell /bin/false node_exporter`
- 
  ```bash
  curl -fsSL https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz \
    | sudo tar -zxvf - -C /usr/local/bin --strip-components=1 node_exporter-1.8.2.linux-amd64/node_exporter \
    && chown node_exporter:node_exporter /usr/local/bin/node_exporter
  ```

- `tee /etc/systemd/system/node_exporter.service <<"EOF"`

  ```bash
  [Unit]
  Description=Node Exporter

  [Service]
  User=node_exporter
  Group=node_exporter
  EnvironmentFile=-/etc/sysconfig/node_exporter
  ExecStart=/usr/local/bin/node_exporter $OPTIONS

  [Install]
  WantedBy=multi-user.target
  EOF
  ```

- 
  ```bash
  sudo systemctl daemon-reload && \
  sudo systemctl start node_exporter && \
  sudo systemctl status node_exporter && \
  sudo systemctl enable node_exporter
  ```

- `cdd`
- `mkdir monitoring`
- `touch prometheus.yml`
- `nano compose.yml`
-
  ```yaml
  services:
    prometheus:
      container_name: prometheus
      image: prom/prometheus
      ports:
        - 9090:9090
      volumes:
        - ./prometheus.yml:/etc/prometheus/prometheus.yml
      networks:
        - monitoring
    grafana:
      container_name: grafana
      image: grafana/grafana
      ports:
        - 3000:3000
      environment:
        - GF_SECURITY_ADMIN_PASSWORD=change_me # only for first start - can be changed via ui
      networks:
        - monitoring

  networks:
    monitoring:
      name: monitoring
  ```
import dashboard by id: `14513`

## monitoring

external via uptime kuma in cloud instance

<br/>
<br/>

[Jump to parent file](README.md)