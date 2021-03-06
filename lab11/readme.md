# Лабораторная работа №11.  Первые шаги с Ansible
[img1]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab11/img/scr1.PNG "" 
[img2]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab11/img/scr2.PNG "" 
[img3]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab11/img/scr3.PNG "" 
[img4]: https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab11/img/scr4.PNG "" 

## Полезные ссылки 

[Molecule — тестируем роли Ansible](https://habr.com/ru/post/437216/)
[Динамическое инвентори в Ansible – Nikolay Antsiferov – Medium](https://medium.com/@Nklya/%D0%B4%D0%B8%D0%BD%D0%B0%D0%BC%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%BE%D0%B5-%D0%B8%D0%BD%D0%B2%D0%B5%D0%BD%D1%82%D0%BE%D1%80%D0%B8-%D0%B2-ansible-9ee880d540d6)

## Задачи

- необходимо использовать модуль yum/apt
- конфигурационные файлы должны быть взяты из шаблона jinja2 с перемененными
- после установки nginx должен быть в режиме enabled в systemd
- должен быть использован notify для старта nginx после установки
- сайт должен слушать на нестандартном порту - 8080, для этого использовать переменные в Ansible


## Решение 

* Я в своей работе использую PC с Windows, поэтому пришлось описывать в вагранте 2 хоста: для Ansible (**Control Machine**) и Nginx (**Managed Node**), 
	а также в провижне установить заранее сгенерённые ssh ключи - для организации доступа пользователя **vagrant**  [ссылка на Vagrant файл](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab11/Vagrantfile). 
	Также провижном устанавливается **Ansible**
* Создан [inventory](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab11/ansible/inventories/staging/hosts) и [ansible.cfg](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab11/ansible.cfg) Вополнена проверка доступности управлямого хоста и запуженны на нём однострочные команды
 
![Доступность и однострочники][img1]
![Установка epel-release на управлямый хост][img2]

* Создан [playbook](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab11/epel.yml) установки пакета epel-release. Запущен до и после его удаления на управляемом хосте

![Установка epel-release на управлямый хост посредством playbook][img3]

* Создан [playbook установки nginx](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab11/nginx.yml) с использование [шаблона](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab11/ansible/templates/nginx.conf.j2). Запущен на управляемом хосте. Получаем **html** вывод при обращении к порту **8080** хоста с развёрнутым **nginx** 

![Установка nginx и проверка работы][img4]
 


