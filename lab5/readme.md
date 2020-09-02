# Лабораторная работа №5.  Размещаем свой RPM в своем репозитории
 


## Результат работы

* В репозиторий **GitHUB** добавлен [Vagrant файл](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab5/Vagrantfile),  который подключает 2 заранее отредактированных файла: спека для кастомной сборки **nginx** ([nginx.spec](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab5/nginx.spec))
и конфиг web сервера  **nginx** ([default.conf](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab5/default.conf)).  Затем запускает скрипт для провиженнинга   
([rpmbngnx.sh](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab5/rpmbngnx.sh)), который уже и выполняет все необходимые операции. 
  В резальтате получаем требуемый стенд 
```
1) создан свой RPM (nginx с последней openssl)
2) создан свой репо с размещённым там своим RPM

```

