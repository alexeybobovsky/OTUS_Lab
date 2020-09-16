# Лабораторная работа №8. Практические навыки работы с ZFS
 


## Порядок работы

* В репозиторий **GitHUB** добавлен [Vagrant файл](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab8/Vagrantfile),  который в провиженинге добавляет в гостевую систему 2 файла для 2 и 3 этапапа.
* Протокол работы отражён в  [файле typescript.txt](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab8/typescript.txt) 



### 1. Определить алгоритм с наилучшим сжатием. 

* создать 4 файловых системы на каждой применить свой алгоритм сжатия.
```
[root@ZFS vagrant]# zfs create poolmirror/dir1                                                         
[root@ZFS vagrant]# zfs create poolmirror/dir2                                                         
[root@ZFS vagrant]# zfs create poolmirror/dir3                                                         
[root@ZFS vagrant]# zfs create poolmirror/dir4                                                         
[root@ZFS vagrant]# zfs set compression=gzip poolmirror/dir1                                                                                                                         
[root@ZFS vagrant]# zfs set compression=zle poolmirror/dir2                                                                                                                                                    
[root@ZFS vagrant]# zfs set compression=lzjb poolmirror/dir3                                                                                                              
[root@ZFS vagrant]# zfs set compression=lz4 poolmirror/dir4                                                                                                               
```

* скачать файл “Война и мир” и расположить на файловой системе
```
[root@ZFS dir1]# wget -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8                                                                                       
--2020-09-14 15:58:02--  http://www.gutenberg.org/ebooks/2600.txt.utf-8                                                                                                         
Resolving www.gutenberg.org (www.gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47                                                                               
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:80... connected.                                                                                             
HTTP request sent, awaiting response... 302 Found                                                                                                                               
Location: http://www.gutenberg.org/cache/epub/2600/pg2600.txt [following]                                                                                                       
--2020-09-14 15:58:04--  http://www.gutenberg.org/cache/epub/2600/pg2600.txt                                                                                                    
Reusing existing connection to www.gutenberg.org:80.                                                                                                                            
HTTP request sent, awaiting response... 200 OK                                                                                                                                  
Length: 1209374 (1.2M) [text/plain]                                                                                                                                             
Saving to: ‘War_and_Peace.txt’                                                                                                                                                  
                                                                                                                                                                                
14% [=================>                                                                                                        ] 118,116      113KB/s                           
43% [=============================================>                                                                            ] 459,732      189KB/s                           
72% [=======================================================================================>                                  ] 878,004      234KB/s  eta 3s                   
100%[=========================================================================================================================>] 1,209,374    313KB/s   in 4.4s                 
                                                                                                                                                                                
2020-09-14 15:58:09 (266 KB/s) - ‘War_and_Peace.txt’ saved [1209374/1209374]                                                                                                    
                                                                                                                                                                                
[root@ZFS dir1]# ls -la                                                                                                                                                         
total 1185                                                                                                                                                                      
drwxr-xr-x. 2 root root       3 Sep 14 15:58 .                                                                                                                                  
drwxr-xr-x. 6 root root       6 Sep 14 15:46 ..                                                                                                                                 
-rw-r--r--. 1 root root 1209374 May  6  2016 War_and_Peace.txt                                                                                                                  
[root@ZFS dir1]# cp War_and_Peace.txt /poolmirror/dir2/War_and_Peace.txt                                                                                                        
[root@ZFS dir1]# cp War_and_Peace.txt /poolmirror/dir3/War_and_Peace.txt                                                                                                        
[root@ZFS dir1]# cp War_and_Peace.txt /poolmirror/dir4/War_and_Peace.txt                                                                                                        
```

* Результат - вывод команды из которой видно какой из алгоритмов лучше

```
[root@ZFS dir1]# zfs list                                                                                                                                                       
NAME              USED  AVAIL     REFER  MOUNTPOINT                                                                                                                             
poolmirror       4.86M   827M       28K  /poolmirror                                                                                                                            
poolmirror/dir1  1.18M   827M     1.18M  /poolmirror/dir1                                                                                                                       
poolmirror/dir2  1.18M   827M     1.18M  /poolmirror/dir2                                                                                                                       
poolmirror/dir3  1.19M   827M     1.19M  /poolmirror/dir3                                                                                                                       
poolmirror/dir4  1.18M   827M     1.18M  /poolmirror/dir4                                                                                                                       
[root@ZFS dir1]# zfs get compression,compressratio                                                                                                                              
NAME             PROPERTY       VALUE     SOURCE                                                                                                                                
poolmirror       compression    off       default                                                                                                                               
poolmirror       compressratio  1.08x     -                                                                                                                                     
poolmirror/dir1  compression    gzip      local                                                                                                                                 
poolmirror/dir1  compressratio  1.08x     -                                                                                                                                     
poolmirror/dir2  compression    zle       local                                                                                                                                 
poolmirror/dir2  compressratio  1.08x     -                                                                                                                                     
poolmirror/dir3  compression    lzjb      local                                                                                                                                 
poolmirror/dir3  compressratio  1.07x     -                                                                                                                                     
poolmirror/dir4  compression    lz4       local                                                                                                                                 
poolmirror/dir4  compressratio  1.08x     -                                                                                                                                     
```

* Согласно выводам, лучший результат сразу у трёх алгоритмов (**1.08x**), а худший с коэффициентом сжатия **1.07x** у **lzjb**

### 2. Определить настройки pool’a 

* С помощью команды zfs import собрать pool ZFS.

```
[root@ZFS vagrant]# zpool import -d ${PWD}/import/zpoolexport/ otus                                        

```

* Командами zfs определить настройки, размер хранилища, тип pool, значение recordsize, какое сжатие используется,какая контрольная сумма используется 

```
[root@ZFS vagrant]# zpool list                                                            
NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus         480M  2.21M   478M        -         -     0%     0%  1.00x    ONLINE  -      
poolmirror   960M  9.58M   950M        -         -     0%     0%  1.00x    ONLINE  -      
[root@ZFS vagrant]# zpool status  otus                                                                                               
  pool: otus                                                                           
 state: ONLINE                                                                         
  scan: none requested                                                                 
config:                                                                                
                                                                                       
        NAME                                        STATE     READ WRITE CKSUM         
        otus                                        ONLINE       0     0     0         
          mirror-0                                  ONLINE       0     0     0         
            /home/vagrant/import/zpoolexport/filea  ONLINE       0     0     0         
            /home/vagrant/import/zpoolexport/fileb  ONLINE       0     0     0         
                                                                                       
errors: No known data errors                                                           
  
[root@ZFS vagrant]$ zfs get compression,compressratio  otus
NAME  PROPERTY       VALUE     SOURCE
otus  compression    zle       local
otus  compressratio  1.23x     -

                                                       
[root@ZFS vagrant]# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local


[vagrant@ZFS ~]$ zfs get checksum otus
NAME                  PROPERTY  VALUE      SOURCE
otus                  checksum  sha256     local
```

* Таким образом:

1. 	размер хранилища = 480M
2. 	тип pool = mirror-0
3. 	recordsize = 128K
4. 	сжатие = zle
5. 	контрольная сумма = sha256



### 3. Найти сообщение от преподавателей 

* Скопировать файл из удаленной директории.    Файл был получен командой `zfs send otus/storage@task2 > otus_task2.file` Восстановить его локально. `zfs receive`

```
[root@ZFS vagrant]# zfs receive otus/storage/task2 < otus_task2.file                
cannot open 'otus/storage': dataset does not exist                                  
cannot receive new filesystem stream: unable to restore to destination              
[root@ZFS vagrant]# zfs list                                                        
NAME              USED  AVAIL     REFER  MOUNTPOINT                                 
otus             2.05M   350M       24K  /otus                                      
otus/hometask2   1.88M   350M     1.88M  /otus/hometask2                            
poolmirror       9.51M   822M       28K  /poolmirror                                
poolmirror/dir1  2.34M   822M     2.34M  /poolmirror/dir1                           
poolmirror/dir2  2.34M   822M     2.34M  /poolmirror/dir2                           
poolmirror/dir3  2.35M   822M     2.35M  /poolmirror/dir3                           
poolmirror/dir4  2.34M   822M     2.34M  /poolmirror/dir4                           
[root@ZFS vagrant]# mkdir /otus/hometask3                                           
[root@ZFS vagrant]# zfs receive otus/hometask3 < otus_task2.file                    
[root@ZFS vagrant]# ls -la /otus/hometask3                                          
total 2592                                                                          
drwxr-xr-x. 3 root    root         11 May 15 07:08 .                                
drwxr-xr-x. 4 root    root          4 Sep 15 13:17 ..                               
-rw-r--r--. 1 root    root          0 May 15 06:46 10M.file                         
-rw-r--r--. 1 root    root     727040 May 15 07:08 cinderella.tar                   
-rw-r--r--. 1 root    root         65 May 15 06:39 for_examaple.txt                 
-rw-r--r--. 1 root    root          0 May 15 06:39 homework4.txt                    
-rw-r--r--. 1 root    root     309987 May 15 06:39 Limbo.txt                        
-rw-r--r--. 1 root    root     509836 May 15 06:39 Moby_Dick.txt                    
drwxr-xr-x. 3 vagrant vagrant       4 Dec 18  2017 task1                            
-rw-r--r--. 1 root    root    1209374 May  6  2016 War_and_Peace.txt                
-rw-r--r--. 1 root    root     398635 May 15 06:45 world.sql                        
```

* *Найти зашифрованное сообщение в файле `secret_message`*
```
[root@ZFS vagrant]# find  /otus/hometask3 -type f -name "secret_message"            
/otus/hometask3/task1/file_mess/secret_message                                      
[root@ZFS vagrant]# cat /otus/hometask3/task1/file_mess/secret_message              
**https://github.com/sindresorhus/awesome**
```
