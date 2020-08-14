# Лабораторная работа №2.  Дисковая подсистема 
 
## Ход выполнения и возникшие проблемы

* Команда из методички, зануляющая суперблоки  `mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}` завершается с ошибкой. Как выяснилось - это нормальное поведение системы если рэйд собирается впервые и **mdadm** про него ничего не знает.
* В команде из методички по созданию рэйда `mdadm --create --verbose /dev/md0 -l 6 -n 5/dev/sd{b,c,d,e,f}` допущена синтаксическая ошибка - пропущен пробел. После итоговая команда приведена к следующему виду: `mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f}`


## Результат работы

* В репозиторий GitHUB добавлен bash скрипт ([mkRaid.sh](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab2/mkRaid.sh)) создания рэйда, конф для автосборки рейда при загрузке ([mdadm.conf](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab2/mdmadm.conf)) и изменённый [Vagrant файл](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab2/Vagrant),  который собирает рэйд массив 5 при первом запуске.

 


