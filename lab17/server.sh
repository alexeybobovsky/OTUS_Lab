#!/bin/bash
echo -e "\n***********************************************************************"
echo -e "***********Provision script on "$(hostname)
echo -e "***********************************************************************\n\n"
yum install lvm2 wget -y
pvcreate /dev/sdb
vgcreate vg_backup /dev/sdb 
lvcreate -n lv_backup -l +100%FREE /dev/vg_backup
mkfs.xfs /dev/vg_backup/lv_backup
mkdir /var/backup
mount /dev/vg_backup/lv_backup /var/backup
echo "`blkid | grep backup: | awk '{print $2}'` /var/backup ext4 defaults 0 0" >> /etc/fstab
wget https://github.com/borgbackup/borg/releases/download/1.1.14/borg-linux64 -O /usr/local/bin/borg
chmod +x /usr/local/bin/borg
useradd -m borg
mkdir ~borg/.ssh
echo 'command="/usr/local/bin/borg serve" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMlPjlLVSPtIWIq0DyAfnVNX3tqeIEv85nw9fP+pbgokNqHprxUXXnNLx2WEGKX2rtVUPF9tsMc+03Ts8C2jRioSoHNZh9ZYESlzKoBTKSNXgcRU4VsFmwx7vgIIpOVdziqeIpqHk8dNSxa/JarClXjKDIkMqlNRnIgVxH4FIAO7SJXlRzKM15Ys2l0mrlk508bYGzFwvbgrxRHNNYgzMjgX/0drdXKj4cerurBGKucA4TgrzFD9KKFO77Vn4D6xIUWoLYtbjoZcgWphoimzRNHtbpBHQ43yI70IAun50JR0/llaDLJ6rsv1iQ0dIW+F34VVNqTJJHhbzhbSHrgrqL vagrant@client.otus.edu' > ~borg/.ssh/authorized_keys
chown -R borg:borg ~borg/.ssh
chown -R borg:borg /var/backup/