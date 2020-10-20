# Лабораторная работа №12.  PAM
[img1]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab12/img/scr1.PNG "" 
[img2]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab12/img/scr2.PNG "" 
[img3]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab12/img/scr3.PNG "" 


## Задачи

- Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников


## Решение 

* Разворачиваем Вагрантом 2 хоста чтобы подключаться по ssh с одного на другой 
	также в провижне установлены заранее сгенерённые ssh ключи - для организации доступа пользователя **vagrant**  [ссылка на Vagrant файл](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab12/Vagrantfile). 
	Также провижном на одном из хостов создаётся группа **admin** в которую добавляется пользователь **vagrant**
	
* для решения задачи используется модуль **pam_exec**, для чего в файл ```/etc/pam.d/sshd``` провижном добавляется строка
```
account    required     pam_exec.so stdout /usr/local/bin/test_login.sh
``` 

* Cкрипт ```/usr/local/bin/test_login.sh``` также создаётся при провижне и его содержание приведено ниже

```
#!/bin/bash                                                                                        
echo -e "\nhello, "$PAM_USER"\nYour group list is\n"$(id -Gn $PAM_USER)                            
if [ $(date +%u) -ge 5 ]; then                                                                     
        echo "today is weekend"                                                                    
        if [ $(id -Gn $PAM_USER | grep "admin" | wc -l) -gt 0 ]; then                              
                echo "...and you can work!"                                                        
                exit 0                                                                             
        else                                                                                       
                echo "...and you need some rest. Bye!"                                             
        exit 1                                                                                     
        fi                                                                                         
else                                                                                               
        echo "today is weekday and you must work!"                                                 
        exit 0                                                                                     
fi                                                                                                 
```

## Проверка работы.

* Входим на хост в будний день 
![будний день][img1]
	
* Меняем на целевом хосте дату на выходной ```date +%Y%m%d -s "20201017"``` и повторяем попытку пока пользователь состоит в группе **admin** 
![выходной день][img2]

* Удаляем пользователя **vagrant** из группы  **admin** ```gpasswd -d vagrant admin```  и повторяем попытку входа, которая заканчивается неудачей
![выходной день для не admin][img3]

