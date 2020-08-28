# Лабораторная работа №4.  NFS, FUSE 
 


## Результат работы

* В репозиторий **GitHUB** добавлен [Vagrant файл](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab4/Vagrantfile),  который собирает стенд для NFS из двух виртуалок и последовательно 
  запускает скрипты для провиженнинга   ([nfss_script.sh](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab4/nfss_script.sh)) и ([nfsс_script.sh](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab4/nfsс_script.sh)) соответственно. 
  В резальтате получаем требуемый стенд 
```
  - vagrant up должен поднимать 2 виртуалки: сервер и клиент 
  - на сервер должна быть расшарена директория
  - на клиента она должна автоматически монтироваться при старте (fstab)
  - в шаре должна быть папка upload с правами на запись
  - NFSv3 по UDP, включенный firewall  
```

