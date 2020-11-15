# Лабораторная работа №14. Docker

[img1]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab14/img/scr1.PNG "" 
[img2]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab14/img/scr21.PNG "" 
[img3]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab14/img/scr3.PNG "" 

## Задача 1. Создание образа nginx

1. Определите разницу между контейнером и образом

* Основное различие между образом и контейнером — в доступном для записи верхнем слое. Чтобы создать контейнер, движок Docker берет образ, добавляет доступный для записи верхний слой и инициализирует различные параметры (сетевые порты, имя контейнера, идентификатор и лимиты ресурсов). Все операции на запись внутри контейнера сохраняются в этом верхнем слое и когда контейнер удаляется, верхний слой, который был доступен для записи, также удаляется, в то время как нижние слоя остаются неизменными.

2. Можно ли в контейнере собрать ядро?

* ОС контейнера существует в виде образа и не является полноценной ОС, как система хоста. В образе есть только файловая система и бинарные файлы, а в полноценной ОС, помимо этого, есть ещё и ядро. Поэтому собрать ядро ОС в контейнере нельзя.

3. Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx) Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.

* Содержимое ```Dockerfile``` приведено ниже:

```
FROM nginx:alpine
RUN apk update && apk upgrade
COPY index.html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/
EXPOSE 8080
ENTRYPOINT ["nginx", "-g", "daemon off;"]
```

В образе меняются конфиг файл ```nginx.conf```, дефолтная веб страница сервера ```index.html``` и указывается порт 8080

* Выполняется логин в свой реп докер хаба и далее сборка образа

```
docker login
docker build -t fmeat/ngnx:latest /home/vagrant/lab/
```

* Затем производится запуск контейнера и проверка результата работы

![запуск контейнера и проверка кастомного nginx][img1]

* выполняется заливка образа в реп докерхаба

```
docker push fmeat/ngnx:latest
```

* После этого образа доступен по [ссылке](https://hub.docker.com/repository/docker/fmeat/ngnx) или напрямую развёртывается в системе посредством указателя ```fmeat/ngnx:latest```

## Задача 2. (* Задание со звездочкой *) Создайте кастомные образы nginx и php, объедините их в docker-compose.После запуска nginx должен показывать php info. Все собранные образы должны быть в docker hub.

* На файловой системе создаётся структура согласно изображения 

![структура приложений][img2]

* Для сборки кастомного PHP-FPM (используется при работе на веб серверах NGINX) в ```Dockerfile``` указывается специфичная таймзона ```Asia/Irkutsk``` и устанавливаются несколько доп модулей 

```
FROM php:7.0-fpm
ENV TIMEZONE Asia/Irkutsk
RUN apt-get update && apt-get install -y \
curl \
wget \
git \
libfreetype6-dev \
libjpeg62-turbo-dev \
libxslt-dev \
libicu-dev \
libmcrypt-dev
EXPOSE 9000
CMD ["php-fpm"]
```

* Для сборки кастомного NGINX в ```Dockerfile``` меняется его конфиг на заранее подготовленный

```
FROM nginx:alpine
COPY default.conf /etc/nginx/conf.d
EXPOSE 80 443
ENTRYPOINT ["nginx", "-g", "daemon off;"]
```

* Оба образа собираются и заливаются в реп докерхаба

```
docker build -t fmeat/webnginx:latest /home/vagrant/cmps/nginx/
docker build -t fmeat/webphp:latest /home/vagrant/cmps/php/

docker push fmeat/webphp:latest
docker push fmeat/webnginx:latest
```

* В ```docker-compose.yml``` описываются два контейнера в одном сетевом окружении. Также осуществлён проброс папок для журналов и с файлами проекта с хоста в конейнеры. В частности содержимое индексфайла содержит только функцию ```phpinfo()```

```
version: '3.7'
services:
    nginx:
        image: fmeat/webnginx:latest
        container_name: nginx
        ports:
            - "80:80"
            - "443:443"
        volumes:
            - ./nginx/Logs:/var/log/nginx/
        links:
            - php
        networks:
            - website
    php:
        image: fmeat/webphp:latest
        container_name: php-fpm
        ports:
            - "9000:9000"
        volumes:
            - ./nginx/www:/var/www
        networks:
            - website
networks:
    website:
        name: website
``` 

* Поднимаем сборку и проверяем результат

![запуск и проверка][img3]
