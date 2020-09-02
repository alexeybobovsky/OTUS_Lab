sudo su && cd /root
#sudo su -l
yum install  redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc -y
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz
yum-builddep rpmbuild/SPECS/nginx.spec -y
mv /root/rpmbuild/SPECS/nginx.spec /root/rpmbuild/SPECS/nginx.spec."$(date +%d-%m-%Y.%H.%M)" && cp /home/vagrant/nginx.spec /root/rpmbuild/SPECS/nginx.spec
rpmbuild -bb rpmbuild/SPECS/nginx.spec
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
#systemctl start nginx
#systemctl status nginx
mkdir /usr/share/nginx/html/repo
cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
createrepo /usr/share/nginx/html/repo/
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf."$(date +%d-%m-%Y.%H.%M)" && cp /home/vagrant/default.conf /etc/nginx/conf.d/default.conf
#nginx -t
#nginx -s reload
systemctl start nginx
#curl -a http://localhost/repo/
if [ -f /etc/yum.repos.d/otus.repo ]; then echo "file exist"; else echo -e "[otus]\nname=otus-linux\nbaseurl=http://localhost/repo\ngpgcheck=0\nenabled=1\n" >  /etc/yum.repos.d/otus.repo; fi
#yum repolist enabled | grep otus
yum install percona-release -y