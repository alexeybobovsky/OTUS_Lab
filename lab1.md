# Лабораторная работа №1.  Обновление ядра в базовой системе 

## Настройка окружения и софта

* Лабораторные выполняются на ноутбуке в Windows 10 (8Гб ОЗУ)
* Установлены актуальные версии Oracle VirtualBox, HashiCorp Vagrant, HashiCorp Packer, GitBash
* В процессе работы была создана новая УЗ  https://app.vagrantup.com/fmeat  в Vagrant cloud и задействована имеющаяся УЗ в GitHUB https://github.com/alexeybobovsky/
* Для доступа к репозиторию GitHUB был сгенерён и добавлен SSL ключ

## Ход выполнения и возникшие проблемы

* Первоначально в Vagrant была сконфигурирована виртуалка с убунтой и уже внутри неё снова развернут вагрант и пэкер, чтобы все работы провести в единой среде Linux. Но внутренняя виртуалка не запустилась, т.к. на этом уровне не доступна виртуализация. После этого все было проделано на Windows

* Во время попыток билда была ошибка при выполнении скрипта **vagrant.ks** добавлениия УЗ vagrant в sudoers: 
```
# Add vagrant to sudoers
cat > /etc/sudoers.d/vagrant << EOF_sudoers_vagrant
vagrant        ALL=(ALL)       NOPASSWD: ALL
EOF_sudoers_vagrant 
``` 
После замены на этот код
``` 
# Add vagrant to sudoers
echo -e "vagrant        ALL=(ALL)       NOPASSWD: ALL\n" | sudo tee --append /etc/sudoers.d/vagrant 
``` 
процесс запустился.

* Во время билда "подвис" модем (я работаю удалённо за городом) и часть пакетов не закачалась, однако виртуалка с этого локального билда  стартовала - сперва с ошибкой авторизации ssh, но при запуске с имеющегося **Vagrantfile** работало без сбоев. Но при проверке у преподавателя возникла аналогичная ошибка ssh авторизации, после чего билд был собран заново.

## Результат работы

* В репозиторий Vagrant cloud добавлен билд с обновлённым ядром версии **5.8.0-1.el7.elrepo.x86_64** по адресу https://app.vagrantup.com/fmeat/boxes/centos-7-555
* В репозиторий GitHUB добавлено описание лабораторной работы, оформленной в разметке **Markdown** по адресу https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab1.md
* В репозиторий GitHUB добавлен **Vagrantfile**, созданный  командой `vagrant init centos-7-555` при проверке образа в локальном хранилище по адресу https://github.com/alexeybobovsky/OTUS_Lab/blob/master/Vagrantfile 


 


