#!/bin/bash
echo "***********************************************************************"
echo "***********Provision script on "$(hostname)
echo "***********************************************************************"
yum install epel-release -y && yum install -y nginx rsyslog policycoreutils-python
#echo "edit 1"
sed -i 's#error_log /var/log/nginx/error.log;#error_log /var/log/nginx/error.log warn;\nerror_log syslog:server=192.168.50.10;#; s#access_log  /var/log/nginx/access.log  main;#access_log  syslog:server=192.168.50.10 combined;#' /etc/nginx/nginx.conf
systemctl start nginx && systemctl enable nginx 
#echo "edit 2"
echo "-w /etc/nginx/ -p wa -k NGNX_conf" > /etc/audit/rules.d/ngnx.rules && service auditd restart
#echo "edit 3"
echo -e "*.crit @@192.168.50.10:514\n*.err @@192.168.50.10:514\n" > /etc/rsyslog.d/crit.conf 
#echo "edit 4"
echo -e "\$ModLoad imfile\n\$InputFileName /var/log/audit/audit.log\n\$InputFileTag tag_audit_log:\n\$InputFileStateFile audit_log\n\$InputFileSeverity info\n\$InputFileFacility local6\n\$InputRunFileMonitor\n\n*.*   @@192.168.50.10:514\n" > /etc/rsyslog.d/audit.conf 
systemctl enable rsyslog && systemctl start rsyslog	