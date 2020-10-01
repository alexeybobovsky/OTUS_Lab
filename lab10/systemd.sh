#!/bin/bash
echo "Provision script"
yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
#TASK 1 files
echo -e "WORD=\"ALERT\"\nLOG=\"/var/log/watchlog.log\"" > /etc/sysconfig/watchlog
printf '%s\n' '#!/bin/bash' 'WORD=$1' 'LOG=$2' 'DATE=`date`' 'if grep $WORD $LOG &> /dev/null' 'then' 'logger "$DATE: I found word, Master!"' 'else' 'exit 0' 'fi' > /opt/watchlog.sh  && chmod +x /opt/watchlog.sh
echo -e "[Unit]\nDescription=My watchlog service\n[Service]\nType=oneshot\nEnvironmentFile=/etc/sysconfig/watchlog\nExecStart=/opt/watchlog.sh \$WORD \$LOG\n" > /etc/systemd/system/watchlog.service
echo -e "[Unit]\nDescription=Run watchlog script every 30 second\n[Timer]\nOnBootSec=1m\nOnUnitActiveSec=30\nUnit=watchlog.service\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/watchlog.timer 
echo -e "[$(date +%d-%m-%Y%t%H:%M:%S)]: [INFO] New session created\n[$(date +%d-%m-%Y%t%H:%M:%S)]: [ALERT] It's looks like a intruder's attack.\n[$(date +%d-%m-%Y%t%H:%M:%S)]: [INFO] I'll kill this session now.\n[$(date +%d-%m-%Y%t%H:%M:%S)]: [ERROR] Sorry, I can't  kill this session." > /var/log/watchlog.log 
#TASK 2 files
echo -e "[Unit]\nDescription=Spawn-fcgi startup service by Otus\nAfter=network.target\n[Service]\nType=simple\nPIDFile=/var/run/spawn-fcgi.pid\nEnvironmentFile=/etc/sysconfig/spawn-fcgi\nExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS\nKillMode=process\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/spawn-fcgi.service
sed -i 's/#SOCKET/SOCKET/; s/#OPTIONS/OPTIONS/' /etc/sysconfig/spawn-fcgi
#TASK 3 files
cp /usr/lib/systemd/system/httpd.service /usr/lib/systemd/system/httpd@.service
sed -i 's/sysconfig\/httpd/sysconfig\/httpd-%I/' /usr/lib/systemd/system/httpd@.service
cp  /etc/sysconfig/httpd /etc/sysconfig/httpd-first && cp  /etc/sysconfig/httpd /etc/sysconfig/httpd-second
sed -i 's/#OPTIONS=/OPTIONS=-f conf\/first.conf/' /etc/sysconfig/httpd-first
sed -i 's/#OPTIONS=/OPTIONS=-f conf\/second.conf/' /etc/sysconfig/httpd-second
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf &&  cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
sed -i 's/Listen 80/Listen 80\nPidFile \/var\/run\/httpd-first.pid/' /etc/httpd/conf/first.conf
sed -i 's/Listen 80/Listen 8080\nPidFile \/var\/run\/httpd-second.pid/' /etc/httpd/conf/second.conf

systemctl daemon-reload  
#TASK 1 service
systemctl enable watchlog.service 
systemctl enable watchlog.timer
systemctl start watchlog.timer
#TASK 2 service
systemctl enable spawn-fcgi
systemctl start spawn-fcgi
#TASK 3 service
systemctl start httpd@first
systemctl start httpd@second

