# Лабораторная работа №9. Управление процессами
 


## Задание: написать свою реализацию `ps ax` используя анализ `/proc`

* В репозиторий **GitHUB** добавлен [bash файл](https://github.com/alexeybobovsky/OTUS_Lab/blob/master/lab9/psax.sh),  который выводит требуемые данные, за исключением параметра **TIME**, так как не нашел точного описания как он вычисляется.



### Краткое описание работы скрипта. 

* Шебанг и указатель на интерпритатор. В переменную добавим каталог 
```
#!/bin/bash
srcDir="/proc/"
```

* Вывод заголовочных полей таблицы процессов. Инициализация цикла обхода каталога `proc` с выбором только цифровых, `натурально` отсортированных папок. Переменной `terminal` задаём дефолтное значение.
```
#echo -e "PID\tTTY\tSTAT\tTIME\tCOMMAND"
echo -e "PID\tTTY\tSTAT\tCOMMAND"
for var in $(ls $srcDir | sort -V | awk '/[[:digit:]]/{print $0}')
do
terminal=" ? "
```

* Проверка на существование файла с наименование процесса: если нет - пропускаем каталог. Проверяем доступен ли первый файловый дескриптор и если да, то отображаем ссылку в качестве консоли с которой стартован процесс.
```
    if [ -f $srcDir$var/comm ]
    then
        if [ -r $srcDir$var/fd/0 ]
        then
            terminal=$(ls -la $srcDir$var/fd | grep dev | head -n 1 |  sed  's/\/dev\//\ /' | awk '{print $11}')
        fi
```

* Из файла `stst` вытаскиваем букву текущего состояния процесса. Также  позиции 14 и 15 означают кол-во времени затраченное на обработку процесса в User и Kernel режимах, соответственно и скорее всего параметр **TIME** является суммой этих двух столбцов, дополнительно обработанной для приведения к виду `hh:mm`
```
        prrocState=$(cat $srcDir$var/stat | awk '{print $3}')
#        utime=$(cat $srcDir$var/stat | awk '{print $14}')
#        stime=$(cat $srcDir$var/stat | awk '{print $15}')
```

* Проверяем содержимое файла `cmdline` и если оно нулевое, то в качестве параметра **COMMAND** показываем содержимое файла `comm` в квадратных скобках. Иначе меняем в  строке из файла `cmdline` спецсимволы - разделители на традиционные пробелы, чтобы не получить на выходе слитную строку, и полученную строку присваиваем параметру **COMMAND**
```
        if [ "$(cat $srcDir$var/cmdline | wc -c)" -eq 0 ]
        then
            comm="["$(cat $srcDir$var/comm)"]"
        else
            comm=$(cat $srcDir$var/cmdline | tr '\000' ' ')
        fi
```

* Вывод итоговой строки о процессе
```
        echo -e $var"\t"$terminal"\t"$prrocState"\t"$utime:$stime"\t"$comm"\t"
    fi
done
```

* На выводе получаем немного упрощённый вариант работы комманды `ps ax`
```
PID     TTY     STAT    COMMAND
1        ?      S       /usr/lib/systemd/systemd --switched-root --system --deserialize 21
2        ?      S       [kthreadd]
4        ?      S       [kworker/0:0H]
5        ?      S       [kworker/u2:0]
6        ?      S       [ksoftirqd/0]
7        ?      S       [migration/0]
8        ?      S       [rcu_bh]
9        ?      R       [rcu_sched]
10       ?      S       [lru-add-drain]
11       ?      S       [watchdog/0]
13       ?      S       [kdevtmpfs]
14       ?      S       [netns]
15       ?      S       [khungtaskd]
16       ?      S       [writeback]
17       ?      S       [kintegrityd]
18       ?      S       [bioset]
19       ?      S       [bioset]
20       ?      S       [bioset]
21       ?      S       [kblockd]
22       ?      S       [md]
23       ?      S       [edac-poller]
24       ?      S       [watchdogd]
26       ?      S       [kworker/u2:1]
33       ?      S       [kswapd0]
34       ?      S       [ksmd]
35       ?      S       [crypto]
43       ?      S       [kthrotld]
44       ?      S       [kmpath_rdacd]
45       ?      S       [kaluad]
46       ?      S       [kpsmoused]
47       ?      S       [ipv6_addrconf]
61       ?      S       [deferwq]
95       ?      S       [kauditd]
123      ?      S       [ata_sff]
128      ?      S       [scsi_eh_0]
129      ?      S       [scsi_tmf_0]
131      ?      S       [scsi_eh_1]
132      ?      S       [scsi_tmf_1]
155      ?      S       [bioset]
156      ?      S       [xfsalloc]
157      ?      S       [xfs_mru_cache]
158      ?      S       [xfs-buf/sda1]
159      ?      S       [xfs-data/sda1]
160      ?      S       [xfs-conv/sda1]
161      ?      S       [xfs-cil/sda1]
162      ?      S       [xfs-reclaim/sda]
163      ?      S       [xfs-log/sda1]
164      ?      S       [xfs-eofblocks/s]
165      ?      S       [xfsaild/sda1]
166      ?      S       [kworker/0:1H]
228      ?      S       /usr/lib/systemd/systemd-journald
264      ?      S       /usr/lib/systemd/systemd-udevd
292      ?      S       /sbin/auditd
315      ?      S       [rpciod]
317      ?      S       [xprtiod]
366      ?      S       /usr/lib/systemd/systemd-logind
367      ?      S       /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation
368      ?      S       /sbin/rpcbind -w
47       ?      S       [ipv6_addrconf]
61       ?      S       [deferwq]
95       ?      S       [kauditd]
123      ?      S       [ata_sff]
128      ?      S       [scsi_eh_0]
129      ?      S       [scsi_tmf_0]
131      ?      S       [scsi_eh_1]
132      ?      S       [scsi_tmf_1]
155      ?      S       [bioset]
156      ?      S       [xfsalloc]
157      ?      S       [xfs_mru_cache]
158      ?      S       [xfs-buf/sda1]
159      ?      S       [xfs-data/sda1]
160      ?      S       [xfs-conv/sda1]
161      ?      S       [xfs-cil/sda1]
162      ?      S       [xfs-reclaim/sda]
163      ?      S       [xfs-log/sda1]
164      ?      S       [xfs-eofblocks/s]
165      ?      S       [xfsaild/sda1]
166      ?      S       [kworker/0:1H]
228      ?      S       /usr/lib/systemd/systemd-journald
264      ?      S       /usr/lib/systemd/systemd-udevd
292      ?      S       /sbin/auditd
315      ?      S       [rpciod]
317      ?      S       [xprtiod]
366      ?      S       /usr/lib/systemd/systemd-logind
367      ?      S       /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation
368      ?      S       /sbin/rpcbind -w
375      ?      S       /usr/lib/polkit-1/polkitd --no-debug
378      ?      S       /usr/sbin/chronyd
380      ?      S       /usr/sbin/gssproxy -D
394      ?      S       /sbin/agetty --noclear tty1 linux
395      ?      S       /usr/sbin/crond -n
672      ?      S       /usr/sbin/sshd -D -u0
673      ?      S       /usr/bin/python2 -Es /usr/sbin/tuned -l -P
675      ?      S       /usr/sbin/rsyslogd -n
903      ?      S       /usr/libexec/postfix/master -w
908      ?      S       qmgr -l -t unix -u
1637     ?      S       /usr/sbin/NetworkManager --no-daemon
1652     ?      S       /sbin/dhclient -d -q -sf /usr/libexec/nm-dhcp-helper -pf /var/run/dhclient-eth0.pid -lf /var/lib/NetworkManager/dhclient-5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03-eth0.lease -cf /var/lib/NetworkManager/dhclient-
2258     ?      S       sshd: vagrant [priv]
2261     ?      S       sshd: vagrant@pts/0
2262    pts/0   S       -bash
2289     ?      S       sshd: vagrant [priv]
2292     ?      S       sshd: vagrant@pts/1
2293    pts/1   S       -bash
2466    pts/2   S       less sys.out
2669     ?      S       [kworker/0:2]
2673     ?      S       [kworker/0:1]
2674     ?      S       pickup -l -t unix -u
3936     ?      S       [kworker/0:0]
5217    pts/1   S       /bin/bash ./psax.sh
20023   pts/0   S       mcedit psax.sh
21938    ?      S       sshd: vagrant [priv]
21941    ?      S       sshd: vagrant@pts/2
21942   pts/2   S       -bash
21992    ?      S       sshd: vagrant [priv]
21995    ?      S       sshd: vagrant@pts/3
21996   pts/3   S       -bash
```

