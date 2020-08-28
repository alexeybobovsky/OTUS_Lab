sudo yum install nfs-utils nfs-utils-lib -y
sudo systemctl start firewalld && sudo systemctl enable firewalld
sudo firewall-cmd --permanent --zone=public --add-service=nfs && sudo firewall-cmd --permanent --zone=public --add-service=mountd &&  sudo firewall-cmd --permanent --zone=public --add-service=rpc-bind  && sudo firewall-cmd --permanent --add-port=2049/udp --zone=public && sudo firewall-cmd --reload 
sudo mkdir /shared  && sudo mkdir /shared/upload
sudo chown -R nfsnobody:nfsnobody /shared && sudo chmod -R 777 /shared
echo -e "/shared 192.168.50.11(rw,sync,no_root_squash)" | sudo tee --append /etc/exports
sudo systemctl enable rpcbind nfs-server
sudo systemctl start rpcbind nfs-server