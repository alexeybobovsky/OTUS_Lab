# Лабораторная работа №16. Настройка централизованного сервера для сбора логов

[img1]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab16/img/scr1.PNG "" 
[img2]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab16/img/scr2.PNG "" 
[img3]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab16/img/scr3.PNG "" 

## Задание: настроить центральный сервер для сбора логов

* в вагранте поднимаем 2 машины web (**log-client**) и log (**log-server**)
* на web поднимаем **NGINX**
* на log настраиваем центральный лог сервер посредством **Rsyslog**
* настраиваем аудит следящий за изменением конфигов **NGINX**

* все критичные логи с web должны собираться и локально и удаленно
* все логи с **NGINX** должны уходить на удаленный сервер (локально только критичные)
* логи аудита должны также уходить на удаленную систему

## Решение

* В репозиторий **GitHUB** добавлен [Vagrant файл](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab16/Vagrantfile),  который  разворачивает требуемый стенд из 2 виртуалок посредством шелл скриптов 
для web (log-client)  ([client.sh](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab16/client.sh)) и для и log (log-server) ([server.sh](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab16/server.sh))

### Описание действий для авто настройки сервера логов 

####В провижне стартует внешний скрипт **server.sh**, выполняющий следующие действия:

Производится установка **Rsyslog** и **policycoreutils-python** для открытия портов в **SELinux**

```
yum install -y rsyslog policycoreutils-python 
```

Производится открытие 514 порта для протоколов **tcp** и **udp** в **SELinux** для приёма логов **Rsyslog** 

```
semanage port -m -t syslogd_port_t -p tcp 514
semanage port -m -t syslogd_port_t -p udp 514
```

Конфигурирование конфига **Rsyslog** 
* в 1 строке указываются  порты для прослушивания; 
* во 2 строке добавляются шаблоны для обработке входящих событий - распределение по папкам с наименованием как у машины-источника и в соответствующий сервису файл. Также создаётся отдельный шаблон для обработки событий аудита (```facility = local6```).
* выполняется старт и добавление в автозапуск службы **Rsyslog** 

```
sed -i 's/#$ModLoad imtcp/$ModLoad imtcp/; s/#$InputTCPServerRun 514/$InputTCPServerRun 514/; s/#$ModLoad imudp/$ModLoad imudp/; s/#$UDPServerRun 514/$UDPServerRun 514/' /etc/rsyslog.conf
echo -e "\n\$template HostAudit, \"/var/log/rsyslog/%HOSTNAME%/audit.log\"\nlocal6.* ?HostAudit\n\$template RemoteLogs,\"/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log\"\n*.* ?RemoteLogs\n& ~\n" >> /etc/rsyslog.conf
systemctl start rsyslog && systemctl enable rsyslog
```

####Далее в провижне стартует inline shell скрипт, который добавляет  в политики безопасности  **SELinux** изменения, разрешающие службе **Rsyslog** доступ к журналу аудита. 

```
semodule -i /home/vagrant/my-rsyslogd.pp
semodule -i /home/vagrant/my-inimfile.pp
systemctl restart rsyslog 
```

*Файлы политики были сгенерены заранее, но можно было также добавить их генерацию во внешний скрипт, что потребовало бы иммитации активности для появления событий и регистрации ошибок доступа для для последующей генерации политик посредством команд:*

```
sealert -a /var/log/audit/audit.log
ausearch -c 'rsyslogd' --raw | audit2allow -M my-rsyslogd
ausearch -c 'in:imfile' --raw | audit2allow -M my-inimfile
semodule -i my-rsyslogd.pp
semodule -i my-inimfile.pp
```	

### Описание действий для авто настройки клиентской машины логов **log-client** (машины web)

####В провижне стартует внешний скрипт **client.sh**, выполняющий следующие действия:

Производится установка **Rsyslog** и веб сервера **NGINX** совместно с необходимым репозиторием **epel-release**

```
yum install epel-release -y && yum install -y nginx rsyslog 
```

Производится изменение конфига **NGINX** для настройки удалённого и локального сбора событий, согласно заданию. Далее старт и добавление в автозапуск службы **NGINX**

```
sed -i 's#error_log /var/log/nginx/error.log;#error_log /var/log/nginx/error.log warn;\nerror_log syslog:server=192.168.50.10;#; s#access_log  /var/log/nginx/access.log  main;#access_log  syslog:server=192.168.50.10 combined;#' /etc/nginx/nginx.conf
systemctl start nginx && systemctl enable nginx 
```	

Воплняется добавление в аудит событий слежки за каталогом с конфигаруциями **NGINX** (все измениения внутри рекурсивно) **/etc/nginx/** и рестарт службы **auditd**

```	
echo "-w /etc/nginx/ -p wa -k NGNX_conf" > /etc/audit/rules.d/ngnx.rules && service auditd restart
```	

Настройка отправки кртитичных событий на централизованный сервер **Rsyslog** 

```
echo -e "*.crit @@192.168.50.10:514\n*.err @@192.168.50.10:514\n" > /etc/rsyslog.d/crit.conf 
```

Настройка отправки событий из журнала аудита  на централизованный сервер. Старт и добавление в автозапуск службы **Rsyslog**.
 
```
echo -e "\$ModLoad imfile\n\$InputFileName /var/log/audit/audit.log\n\$InputFileTag tag_audit_log:\n\$InputFileStateFile audit_log\n\$InputFileSeverity info\n\$InputFileFacility local6\n\$InputRunFileMonitor\n\n*.*   @@192.168.50.10:514\n" > /etc/rsyslog.d/audit.conf 
systemctl enable rsyslog && systemctl start rsyslog
```

####Далее в провижне аналогично серверу стартует inline shell скрипт, который добавляет  в политики безопасности  **SELinux** изменения, разрешающие службе **Rsyslog** доступ к журналу аудита. 

```
semodule -i /home/vagrant/my-rsyslogd.pp
semodule -i /home/vagrant/my-inimfile.pp
systemctl restart rsyslog 
```

## Проверка работы стенда

* На сервере сбора логов имеется каталог журналов событий с клиентской машины. Производится обращение к несуществующей странице веб сервера **NGINX** на клиентской машине - в соответствующем журнале появляются характерные записи.

![Проверка наличия журналов на сервере и NGINX][img1]

* На клиенте выполняется изменение внутри отслеживаемого каталога конфигураций **NGINX**

![Изменение конфигурации NGINX][img2]

* На сервере в соответствующем журнале появляются характерные записи.

![Фиксация событий изменения конфигурации NGINX][img3]