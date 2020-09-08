# Лабораторная работа №6.  Загрузка Linux
[img1]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab6/img/screen_load_1_1.PNG "" 
[img2]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab6/img/screen_load_1_2.PNG "" 
[img3]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab6/img/screen_load_2_1.PNG "" 
[img4]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab6/img/screen_load_2_2.PNG "" 
[img5]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab6/img/screen_load_3_1.PNG "" 
[img6]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab6/img/screen_load_3_2.PNG "" 
[img7]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab6/img/screen_dracut.PNG "" 


## Порядок работы

### Попасть в систему без пароля несколькими способами
#### Способ 1: `init=/bin/sh`
* При старте гостевой ОС в GUI окне VirtualBox во время отображения меню выбора загрузочного ядра, нажать кнопку **e** *(edit)* и в появившемся окне с конфигурациеq загрузки в конце строки начинающейся с `linux16` добавить `init=/bin/sh` и удалить `console=tty0 console=ttyS0,115200n8` 

![Правка конфига Способ 1][img1]

* Нажать **сtrl-x** для загрузки в систему. Рутовая файловая система при этом монтируется в режиме **Read-Only**. Чтобы  перемонтировать ее в режим **Read-Write** выполняется команда `mount -o remount,rw /`. После этого  можно убедиться записав данные в любой файл или прочитав вывод команды: `mount | grep Otus` *(вместо **ro** - **rw**)*

![Перемонтирование в rw и результат][img2]

#### Способ 2: `rd.break` (прерывание загрузки)
* После рестарта гостевой аналогично провалиться в конфигурацию загрузки и  добавить  в конце строки начинающейся с `linux16` - `rd.break`

![Правка конфига Способ 2][img3]

* После Нажатия **сtrl-x** система загружается в **emergency mode**. Корневая файловая система смонтирована в режиме **Read-Only** и видна как **/sysroot**. Чтобы получить к ней доступ нужно ее перемонтировать с правами для записи и сделать временным корнем. Далее проводится смена пароля. 

![Перемонтирование в rw и смена пароля][img4]

#### Способ 3: `rw init=/sysroot/bin/sh`
* После рестарта гостевой аналогично провалиться в конфигурацию загрузки и  заменить  `ro` на  `rw init=/sysroot/bin/sh`

![Правка конфига Способ 3][img5]

* После Нажатия **сtrl-x** система загружается в **emergency mode**. Корневая файловая система смонтирована в режиме **Read-Write** и видна как **/sysroot**. Нужно сделать её  временным корнем. Далее проводится смена пароля. 

![смена пароля][img6]

### Установить систему с LVM, после чего переименовать VG. Добавить модуль в initrd
* Протокол работы приведён в  [файле typescript.txt](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab6/typescript.txt) 
и Результат в виде пингвина на загрузке 

![пингвин при загрузке][img7]


