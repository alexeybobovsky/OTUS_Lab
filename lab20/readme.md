# Лабораторная работа №20. Фильтрация трафика **firewalld**.

[scheme]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab20/img/scheme.png "" 
[img1]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab20/img/scr1.PNG "" 
[img2]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab20/img/scr2.PNG "" 

## Задание: Настраиваем iptables/firewalld

1) реализовать **knocking port**:  **centralRouter** может попасть на ssh **inetrRouter** через knock скрипт
2) добавить **inetRouter2**, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост
3) запустить nginx на **centralServer**
4) пробросить 80й порт на **inetRouter2** 8080
5) дефолт в инет оставить через **inetRouter**

## Решение

* Для наглядности, согласно задания, строится схема сетевого взаимодействия узлов стенда.

![схема сети][scheme]

* В репозиторий **GitHUB** добавлен [Vagrant файл](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab20/Vagrantfile),  который  разворачивает требуемый стенд из 4 виртуалок.

### Описание действий для автонастройки стенда на каждой из станций 

* В **Vagrantfile** для каждой станции на интерфейсах выставляются адреса согласно схемы. Посредством ***inline shell*** скриптов производится автоматическая настройка каждого хоста:

#### **inetRouter**. 

* В **firewalld** настраивается зона ***internal*** для **knocking** и  зона ***public*** с маршрутом для проброса внутренних пакетов в интернет.

```
sysctl net.ipv4.conf.all.forwarding=1
systemctl enable firewalld && systemctl start firewalld
firewall-cmd --permanent --zone=public --remove-interface=eth1
firewall-cmd --permanent --zone=internal --add-interface=eth1
firewall-cmd --permanent --zone=public --add-masquerade && firewall-cmd --reload
firewall-cmd --permanent --zone=internal --remove-service=ssh && firewall-cmd --reload
ip r add 192.168.0.0/22	via 192.168.255.2 dev eth1
```

* Создаётся пользователь для входа в **inetRouter** по **ssh**.

```
useradd -m netadm
mkdir ~netadm/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMlPjlLVSPtIWIq0DyAfnVNX3tqeIEv85nw9fP+pbgokNqHprxUXXnNLx2WEGKX2rtVUPF9tsMc+03Ts8C2jRioSoHNZh9ZYESlzKoBTKSNXgcRU4VsFmwx7vgIIpOVdziqeIpqHk8dNSxa/JarClXjKDIkMqlNRnIgVxH4FIAO7SJXlRzKM15Ys2l0mrlk508bYGzFwvbgrxRHNNYgzMjgX/0drdXKj4cerurBGKucA4TgrzFD9KKFO77Vn4D6xIUWoLYtbjoZcgWphoimzRNHtbpBHQ43yI70IAun50JR0/llaDLJ6rsv1iQ0dIW+F34VVNqTJJHhbzhbSHrgrqL netadm@centralRouter' > /home/netadm/.ssh/authorized_keys
chown -R netadm:netadm /home/netadm/.ssh			
```
* Установка и настройка серверной части **knocking**.

```
yum install libpcap -y
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7Server/x86_64/knock-server-0.7-1.el7.nux.x86_64.rpm
echo -e '[options]\nUseSyslog\nlogfile = /var/log/knockd.log\n[OpenSSH]\nSequence = 1101,2202,3303\nSeq_timeout = 15\nTcpflags = syn\nCommand = /bin/firewall-cmd --zone=internal --add-rich-rule="rule family="ipv4" source address="%IP%" service name="ssh" accept"\n\n[CloseSSH]\nSequence = 6606,5505,4404\nSeq_timeout = 15\nTcpflags = syn\nCommand = /bin/firewall-cmd --zone=internal --remove-rich-rule="rule family="ipv4" source address="%IP%" service name="ssh" accept"' > /etc/knockd.conf
echo -e 'OPTIONS="-i eth1"' >> /etc/sysconfig/knockd
systemctl start knockd && systemctl enable knockd
```
#### **centralRouter**. 

* Настраивается маршрут для  для проброса внутренних пакетов в интернет.

```
sysctl net.ipv4.conf.all.forwarding=1
echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
echo "GATEWAY=192.168.255.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
ip r add default 		via 192.168.255.1 	dev eth1
systemctl restart network
```

* Добавляются ключи для подключения пользователей по **ssh**.

```
echo -e "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAzJT45S1Uj7SFiKtA8gH51TV97aniBL/OZ8PXz/qW4KJDah6a\n8VF15zS8dlhBil9q7VVDxfbbDHPtN07PAto0YqEqBzWYfWWBEpcyqAUykjV4HEVO\nFbBZsMe74CCKTlXc4qniKah5P HTUsWvyWqwpV4ygyJDKpTUZyIFcR+BSADu0iV5U\ncyjNeWLNpdJq5ZOdPG2BsxcL24K8URzTWIMzI4F/9Ha3Vyo+HHq7qwRirnAOE4K8\nxQ/SihTu+1Z+A+sSFFqC2LW46GXIFqYaIps0TR7W6QR0ON8iO9CALp+dCUdP5ZWg\nyyeq7L9YkNHSFvhd+FVTakySR4W84W0h64K6iwIDAQABAoIBAEUfRGUy hrKzPLbr\nndrm3gGyvCST1KDkKZoXqpBDy7yENqDhTFqiumJvCAo4UZSuHpOnzmlRubsgZBLe\n1sTQ8wgsCeY7rpUXuZ+NZHkuoGKUHEv5AqQDXJqFMa5NcE19Z09SNO78VFIf60ky\n/sSyDJnfEugRO9bL9TUwt/w1B5+58ZIkHNncBCItI94PLFv/4Qza3UUZifpOq3P8\nyGqDVXJqEWsc6UxypplvZ ScRBLJ2o029k/L3y53SQ2jO/nkcUGpizNkzVOJBAMes\ndgQuZQx6MqwRI3TZWDjJUcS8jaX+rJgfy0wGW6Iw2abn9GrztDam7aRa62Iu8fm9\n245xiKkCgYEA9CtNgB/x2KX6MyYlzxIaWfBG2hzUJs2YnhoUt22duJLXhQ1fs6au\nBjkgiNzJIFj6HAW83PoDpet9wYKm7EZJOCj4oIncff6z8/RJVs8r dCLEkzf9yRJa\nk6fGBbGY4T2R0OYMUVKBuSmD9or5F/Tlg6FJE0ea0KYSnuWPJX3pVp8CgYEA1n6g\nMzs8/cuLN5/5z0V/y11PD0Sy+tZj3EMfOhDX3DDflG78+UqtgNOp8ODR54yyQ1kP\nmokAVC+4SUlxKJoSiEcSZd/nsTZHBpdTCyjuyFotsbdu4wmbAgzZcOFfujScmRUm\nvwcNPHn2g7oCcqDIf T64rsLzDqCOP9yhcrUasJUCgYBGM+kdjJHBo78zU6WNSvwu\nncoRTjalTXmzA3avYqH1fqrew4Cfq63fdi9nimt9lHec9P1fX7cKzpGiwMjzqCXH\nMuiBaAHwa/obi0JG5lvtEU4JshCS7mcCizuBSZXWNRimwm4KN7m6njgl+8Ew5SXU\nWdwj4fOeSBGUhBZLRk9/qwKBgQC0rrn4LgB0sg817jaa2SqL frBoZjB2iD5afthB\nK4sKWskb2lqTDMsW6DYRSPDIooZPoSg5vwpd4EzWv1zpHNBbp7Lhyjj72IMAFFzJ\n29M5Rm2TdLed3KuMkJJiOhdPXZ5EfcLDzAbkWMDFudzx/mqkxj8ASAxC2BC7zvjZ\nDaHL+QKBgG8dl3dYfMtD9+wVj80fZXvDsXYtVFCMT9oVHKAAhqDt4i/GbL9A5mlo\njkJJ4QTnLLSmO IjSBUuSDab0vBLrynZ8xlyJaotP4n5hl3Qki96kQno5UXcyu2Kq\n3uZgvo9tEQKueypM2Fu7fCb0pnPhPSQF427jZnWrUJPcFUyYrvvY\n-----END RSA PRIVATE KEY-----" > ~vagrant/.ssh/id_rsa
cp /home/vagrant/.ssh/id_rsa /root/.ssh/ &&  chmod 400 /root/.ssh/id_rsa && chown vagrant:vagrant /home/vagrant/.ssh/id_rsa && chmod 400 /home/vagrant/.ssh/id_rsa
```

* Установка **nmap** и настройка  клиентского **knocking** скрипта для соединения с сервером заранее настроенным пользователем.

```
sudo yum -y install epel-release && sudo yum -y install nmap
echo -e '#!/bin/bash\nfor x in 1101 2202 3303; do nmap -Pn --host_timeout 201 --max-retries 0 -p $x 192.168.255.1 && sleep 1; done && ssh netadm@192.168.255.1' > /home/vagrant/netssh.sh && chmod +x /home/vagrant/netssh.sh
```

#### **inetRouter2**. 

* В **firewalld** настраивается зона ***public*** для проброса 80 порта извне до 8080 порта внутреннего веб сервера. 

```
sysctl net.ipv4.conf.all.forwarding=1
ip r add 192.168.0.0/24	via 192.168.255.6 dev eth1
systemctl enable firewalld && systemctl start firewalld
firewall-cmd --zone=public --add-masquerade --permanent
firewall-cmd --zone=public --add-forward-port=port=80:proto=tcp:toport=8080:toaddr=192.168.0.2 --permanent
firewall-cmd --reload
```

#### **centralServer**. 

* Устанавливается **nginx** на порту 8080 и прописывается дефолтный маршрут через **centralRouter** 

```
ip r add default 		via 192.168.0.1 	dev eth1
systemctl restart network
yum -y install epel-release
yum -y install nginx
sed -i 's#80 default_server#8080 default_server#' /etc/nginx/nginx.conf
systemctl enable nginx
systemctl start nginx
```

## Проверка работы стенда

* С **centralRouter** осуществляется безуспешная попытка подключения напряму по **ssh** к **inetRouter**. Затем запускается скрипт подключения по **knocking** и устанавливается соединение.

![проверка соединения по ssh посредством knocking][img1]

* С **centralRouter** осуществляется опрос **inetRouter2** по 80 порту и **centralServer** по 8080. В обоих случаях отображается идентичный ответ от **nginx**, слушающем порт 8080 на хосте **centralServer**.

![проверка проброса портов][img2]
