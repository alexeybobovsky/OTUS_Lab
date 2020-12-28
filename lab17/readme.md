# Лабораторная работа №17. Настройка бэкапов на примере **borgbackup**.

[img1]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab17/img/scr1.PNG "" 
[img2]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab17/img/scr2.PNG "" 

## Задание: Настраиваем бэкапы

* Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client

* Настроить удаленный бекап каталога /etc c сервера client при помощи **borgbackup**. Резервные копии должны соответствовать следующим критериям:

- Директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB.
- Репозиторий дле резервных копий должен быть зашифрован ключом или паролем - на ваше усмотрение
- Имя бекапа должно содержать информацию о времени снятия бекапа
- Глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех. Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов
- Резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации.
- Написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на ваше усмотрение.
- Настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов

* Запустите стенд на 30 минут. Убедитесь что резервные копии снимаются. Остановите бекап, удалите (или переместите) директорию /etc и восстановите ее из бекапа. Для сдачи домашнего задания ожидаем настроенные стенд, логи процесса бэкапа и описание процесса восстановления. 

## Решение

* В репозиторий **GitHUB** добавлен [Vagrant файл](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab17/Vagrantfile),  который  разворачивает требуемый стенд из 2 виртуалок посредством шелл скриптов 
для **client**  ([client.sh](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab17/client.sh)) и для и **backup_server** ([server.sh](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab17/server.sh)).
Также добавлен скрипт для запуска задания резервного копирования  ([backup.sh](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab17/backup.sh)).

### Описание действий для автонастройки сервера резервного копирования 

* В провижне стартует внешний скрипт **server.sh**, выполняющий следующие действия:

Производится установка **lvm** для настройки и монтирования диска с резервными копиями и **wget** для дальнейшего скачавания **borgbackup**. Сразу создаётся раздел для РК, который монтируется в ```/var/backup``` и прописывется в ```/etc/fstab``` для автомоунта после рестарта хоста.

```
yum install lvm2 wget -y
pvcreate /dev/sdb
vgcreate vg_backup /dev/sdb 
lvcreate -n lv_backup -l +100%FREE /dev/vg_backup
mkfs.xfs /dev/vg_backup/lv_backup
mkdir /var/backup
mount /dev/vg_backup/lv_backup /var/backup
echo "`blkid | grep backup: | awk '{print $2}'` /var/backup ext4 defaults 0 0" >> /etc/fstab
```

Производится установка  **borgbackup** посредством скачивания бинарника с официального репозитория продукта и добавляются права на запуск

```
wget https://github.com/borgbackup/borg/releases/download/1.1.14/borg-linux64 -O /usr/local/bin/borg
chmod +x /usr/local/bin/borg
```

Создаётся УЗ **borg** дла работы с резервным копированием. Сразу прописывается заранее сгенерированный ключ для беспарольного запуска процессов **borgbackup** с удалённого клиентского хоста. Настраиваются соответствующие права владельца для УЗ **borg** на папку с ключами и резервными копиями.

```
useradd -m borg
mkdir ~borg/.ssh
echo 'command="/usr/local/bin/borg serve" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMlPjlLVSPtIWIq0DyAfnVNX3tqeIEv85nw9fP+pbgokNqHprxUXXnNLx2WEGKX2rtVUPF9tsMc+03Ts8C2jRioSoHNZh9ZYESlzKoBTKSNXgcRU4VsFmwx7vgIIpOVdziqeIpqHk8dNSxa/JarClXjKDIkMqlNRnIgVxH4FIAO7SJXlRzKM15Ys2l0mrlk508bYGzFwvbgrxRHNNYgzMjgX/0drdXKj4cerurBGKucA4TgrzFD9KKFO77Vn4D6xIUWoLYtbjoZcgWphoimzRNHtbpBHQ43yI70IAun50JR0/llaDLJ6rsv1iQ0dIW+F34VVNqTJJHhbzhbSHrgrqL vagrant@client.otus.edu' > ~borg/.ssh/authorized_keys
chown -R borg:borg ~borg/.ssh
chown -R borg:borg /var/backup/
```

### Описание действий для автонастройки клиентской машины РК.

* В провижне стартует внешний скрипт **client.sh**, выполняющий следующие действия:

Производится установка  **wget** и далее установка **borgbackup** посредством скачивания бинарника с официального репозитория продукта и добавление прав на его запуск

```
yum install wget -y
wget https://github.com/borgbackup/borg/releases/download/1.1.14/borg-linux64 -O /usr/local/bin/borg
chmod +x /usr/local/bin/borg
```

Производится настройка беспарольного входа для УЗ, из под которых планируется выполнение операций с РК. Так как в задании указан системный каталог ```/etc```, ко многим вложенным ресурсам которого требуется доступ супрпользователя, то 
доступ попутно настраивается и для УЗ **root** (чего на проде делать не стоит): в домашний каталог кладётся файл с зарание сгенерированным приватным ключом, устанавливаются соответствующие права на него и попутно прописывается ключ
сервера к которому будет выполнятся подключение по **SSH** в соответствующих файлах ```~/.ssh/known_hosts``` для избежания интерактивного запроса о добавлении удалённого хоста в доверенные при первом обращении к нему. 

```
echo -e "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAzJT45S1Uj7SFiKtA8gH51TV97aniBL/OZ8PXz/qW4KJDah6a\n8VF15zS8dlhBil9q7VVDxfbbDHPtN07PAto0YqEqBzWYfWWBEpcyqAUykjV4HEVO\nFbBZsMe74CCKTlXc4qniKah5PHTUsWvyWqwpV4ygyJDKpTUZyIFcR+BSADu0iV5U\ncyjNeWLNpdJq5ZOdPG2BsxcL24K8URzTWIMzI4F/9Ha3Vyo+HHq7qwRirnAOE4K8\nxQ/SihTu+1Z+A+sSFFqC2LW46GXIFqYaIps0TR7W6QR0ON8iO9CALp+dCUdP5ZWg\nyyeq7L9YkNHSFvhd+FVTakySR4W84W0h64K6iwIDAQABAoIBAEUfRGUyhrKzPLbr\nndrm3gGyvCST1KDkKZoXqpBDy7yENqDhTFqiumJvCAo4UZSuHpOnzmlRubsgZBLe\n1sTQ8wgsCeY7rpUXuZ+NZHkuoGKUHEv5AqQDXJqFMa5NcE19Z09SNO78VFIf60ky\n/sSyDJnfEugRO9bL9TUwt/w1B5+58ZIkHNncBCItI94PLFv/4Qza3UUZifpOq3P8\nyGqDVXJqEWsc6UxypplvZScRBLJ2o029k/L3y53SQ2jO/nkcUGpizNkzVOJBAMes\ndgQuZQx6MqwRI3TZWDjJUcS8jaX+rJgfy0wGW6Iw2abn9GrztDam7aRa62Iu8fm9\n245xiKkCgYEA9CtNgB/x2KX6MyYlzxIaWfBG2hzUJs2YnhoUt22duJLXhQ1fs6au\nBjkgiNzJIFj6HAW83PoDpet9wYKm7EZJOCj4oIncff6z8/RJVs8rdCLEkzf9yRJa\nk6fGBbGY4T2R0OYMUVKBuSmD9or5F/Tlg6FJE0ea0KYSnuWPJX3pVp8CgYEA1n6g\nMzs8/cuLN5/5z0V/y11PD0Sy+tZj3EMfOhDX3DDflG78+UqtgNOp8ODR54yyQ1kP\nmokAVC+4SUlxKJoSiEcSZd/nsTZHBpdTCyjuyFotsbdu4wmbAgzZcOFfujScmRUm\nvwcNPHn2g7oCcqDIfT64rsLzDqCOP9yhcrUasJUCgYBGM+kdjJHBo78zU6WNSvwu\nncoRTjalTXmzA3avYqH1fqrew4Cfq63fdi9nimt9lHec9P1fX7cKzpGiwMjzqCXH\nMuiBaAHwa/obi0JG5lvtEU4JshCS7mcCizuBSZXWNRimwm4KN7m6njgl+8Ew5SXU\nWdwj4fOeSBGUhBZLRk9/qwKBgQC0rrn4LgB0sg817jaa2SqLfrBoZjB2iD5afthB\nK4sKWskb2lqTDMsW6DYRSPDIooZPoSg5vwpd4EzWv1zpHNBbp7Lhyjj72IMAFFzJ\n29M5Rm2TdLed3KuMkJJiOhdPXZ5EfcLDzAbkWMDFudzx/mqkxj8ASAxC2BC7zvjZ\nDaHL+QKBgG8dl3dYfMtD9+wVj80fZXvDsXYtVFCMT9oVHKAAhqDt4i/GbL9A5mlo\njkJJ4QTnLLSmOIjSBUuSDab0vBLrynZ8xlyJaotP4n5hl3Qki96kQno5UXcyu2Kq\n3uZgvo9tEQKueypM2Fu7fCb0pnPhPSQF427jZnWrUJPcFUyYrvvY\n-----END RSA PRIVATE KEY-----" > ~vagrant/.ssh/id_rsa 
mkdir /root/.ssh && cp /home/vagrant/.ssh/id_rsa /root/.ssh/ &&  chmod 400 /root/.ssh/id_rsa && chown vagrant:vagrant /home/vagrant/.ssh/id_rsa && chmod 400 /home/vagrant/.ssh/id_rsa
ssh-keyscan -H ,192.168.11.150 > /home/vagrant/.ssh/known_hosts && ssh-keyscan -H ,192.168.11.150 > /root/.ssh/known_hosts && chown vagrant:vagrant /home/vagrant/.ssh/known_hosts
```

Через провижнинг в **Vagrantfile** на клинтский хост копируется заранее подговоленный файл запуска РК с настройками (разбор ниже). Ему добавляются права на запуск и создаётся задание в **cron** на запуск РК каждые 5 минут

```
chmod +x /home/vagrant/backup.sh
(crontab -l ; echo -e "*/5 * * * * /home/vagrant/backup.sh\n") | sort - | uniq - | crontab - 
```

### Описание скрипта для запуска РК.


Установка переменных для указания репозитория РК и паролем к нему. Также добавляется путь к бинарнику **borgbackup**.

```
#!/bin/sh
export BORG_REPO='borg@192.168.11.150:/var/backup/client'
export BORG_PASSPHRASE='otus'
export PATH=$PATH:/usr/local/bin
```	

Описывается функция для вывода служебной информации и попутный вывод её в системный журнал с добавлением соответствующего ключа.

```	
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2;  logger -t [BACKUP] "$*"; }
```	

Создание резервной копии с компрессией и шифрованием (ключ в переменной **$BORG_PASSPHRASE**) в удалённом репозитории ( **$BORG_REPO**) каталога ```/etc``` с указание штампа времен в названии.

```
info "Starting backup"
borg create --verbose --filter AME --list --stats --show-rc --compression lz4 --exclude-caches $BORG_REPO::'{hostname}-{now:%Y-%m-%d_%H:%M:%S}' /etc
backup_exit=$?
```

Настройка политики хранения и удаления резервных копий из репозитория - хранится 90 ежедневных копий (3 месяца) и 12 ежемесячных (1 год)
 
```
info "Pruning repository"
borg prune --list --prefix '{hostname}-' --show-rc --keep-daily 90 --keep-monthly 12
prune_exit=$?
```

Обработка результатов выполнения задания на РК и информирование
 
```
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi
exit ${global_exit}
```

## Проверка работы стенда

* Нв клиенте после отработаки провижнингов необходимо вручную выполнить процедуру создания репозитория для РК, т.к. в случае наличия шифрования **borgbackup** в интерактивном режиме запрашивает *контрольную фразу*. 
Пока репозиторий не создан - задания на РК не выполняются в журнале фиксируются ошибки. Когда реп доступен - задания выполняются без сбоев

```
borg init --encryption=repokey-blake2  borg@192.168.11.150:/var/backup/client
```

![ручное добавление репозитория][img1]


* На клиенте удаляется резервируемый ресурс и  выполняется его восстановление из резервной копии. Если удалить всё содержимое каталога ```/etc``` (как сказано в задании), то штатными средствами **borgbackup** 
восстановить содержимое уже не получится т.к. **SSH** уже  на работает штатно и тогда нужно восстанавливать архив на сервере/другом хосте и каким-то образом заливать это на клиента (к примеру посредством **nfs**). Поэтому для 
проверки штатного функционала СРК удяляется какой-то не критичный ресурс и затем успешно восстанавливается из резервной копии.

![Восстановление из резервной копии][img2]

