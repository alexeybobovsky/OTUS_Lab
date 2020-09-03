# Лабораторная работа №5.  Размещаем свой RPM в своем репозитории
 


## Описание работы

* В репозиторий **GitHUB** добавлен [Vagrant файл](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab5/Vagrantfile),  который подключает 2 заранее отредактированных файла: спека для кастомной сборки **nginx** ([nginx.spec](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab5/nginx.spec))
и конфиг web сервера  **nginx** ([default.conf](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab5/default.conf)).  Затем запускает скрипт для провиженнинга   
([rpmbngnx.sh](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab5/rpmbngnx.sh)), который уже и выполняет все необходимые операции:

```
sudo su && cd /root
```
Выполняется последовательно вход под суперпользователем и смена текущей директории на домашнюю рута
```
yum install  redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc -y
```
Устанавливаются в авторежиме (без вопросов) все необходимые для стенда пакеты (перечислены в методичке) + **gcc**, который не был указан, по сборка без него не идёт
```
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
```
скачивается SRPM пакет **nginx** и разворачивается в текущий каталог 
```
wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz
```
скачиваются и разворачиваются в текущий каталог исходники  **openSSL** последней версии

```
yum-builddep rpmbuild/SPECS/nginx.spec -y
```
устанавливаются требуемые пакеты для сборки **nginx** из спеки
```
mv /root/rpmbuild/SPECS/nginx.spec /root/rpmbuild/SPECS/nginx.spec."$(date +%d-%m-%Y.%H.%M)" && cp /home/vagrant/nginx.spec /root/rpmbuild/SPECS/nginx.spec
```
дефолтная спека переименовывется и на её место копируется изменённая - с добавленным **openSSL** в т.ч. с указанием локального расположения его исходников 
*(Скорее всего логичнее было бы поменять местами эту комманду с предыдущей)*
```
rpmbuild -bb rpmbuild/SPECS/nginx.spec
```
Старт сборки RPM пакета

```
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
systemctl start nginx
```
Установка   кастомного **nginx** из полученного  RPM пакета и его запуск

```
mkdir /usr/share/nginx/html/repo
cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
```
Создание внутри публичной веб папки директории для локального репозитория и копирование туда кастомного  **nginx** RPM пакета и скачивание туда же с  соответствующего web сервера RPM пакета ПО **percona**
```
createrepo /usr/share/nginx/html/repo/
```
Инициализация локального репозитория в созданной ранее папке
```
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf."$(date +%d-%m-%Y.%H.%M)" && cp /home/vagrant/default.conf /etc/nginx/conf.d/default.conf
nginx -s reload
```
переименование дефолтной кофигурации вебсервера **nginx** и  на её место копируется изменённая, с указанием автоиндексации вложенных каталогов. Затем перегрузка конфигурации **nginx**

```
if [ -f /etc/yum.repos.d/otus.repo ]; then echo "file exist"; else echo -e "[otus]\nname=otus-linux\nbaseurl=http://localhost/repo\ngpgcheck=0\nenabled=1\n" >  /etc/yum.repos.d/otus.repo; fi
```
создание файла-описания нового локального репозитория с предварительной проверкой на существование (*избыточно, но привычка - конструкция взята из моих рабочих шаблонов*)
```
yum install percona-release -y
```
установка стороннего приложения percona из RPM пакета, расположенного в локальном репозитории

## Результат работы 
  В резальтате получаем требуемый стенд 
```
1) создан свой RPM (nginx с последней openssl)
2) создан свой репо с размещённым там своим RPM

```

