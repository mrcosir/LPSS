#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear;
cd /root
rm -f /root/VPSMPY.sh
echo -e "\033[33m=========================================================================\033[0m"
echo -e "\033[36m                 VPN and pam_mysql Automatic installation\033[0m"
echo ""
echo -e "\033[32m                      版本：http转接 -- 远程数据库版本\033[0m"
echo ""
echo -e "\033[32m                                                            by 落魄书生\033[0m"
echo -e "\033[35m    请按回车继续开始安装\033[0m"
echo -e "\033[33m==========================================================================\033[0m"
echo "$CopyrightLogo";
read
cd /
echo 
echo "设置远程数据库信息"
echo 
echo -n "  输入数据库地址："
read dz
if [ -z $dz ]
	then
	echo -n "    输入数据库地址："
	read dz
	if [ -z $dz]
		then
			echo  "  地址设定失败"
			dz=127.0.0.1;
	fi
fi 
echo -n "  输入数据库端口："
read dk
if [ -z $dk ]
	then
	echo -n "    输入数据库端口："
	read dk
	if [ -z $dk]
		then
			echo  "  端口设定失败"
			dk=3306;
	fi
fi
echo -n "  输入数据库管理员："
read us
if [ -z $us ]
	then
	echo -n "    输入数据库管理员："
	read us
	if [ -z $us]
		then
			echo  "  管理员设定失败"
			us=root;
	fi
fi
echo -n "  输入数据库密码："
read ps
if [ -z $ps ]
	then
	echo -n "    输入数据库密码："
	read ps
	if [ -z $ps]
		then
			echo  "  密码设定失败"
			ps=root;
	fi
fi
echo -n "  是否需要重建数据库（y/n）："
read cj
if [ -z $cj ]
	then
	echo -n "  是否需要重建数据库（y/n）："
	read cj
	if [ -z $cj]
		then
			echo  " 设定失败,默认不重建"
			cj=n;
	fi
fi

echo "安装openvpn"
rpm -ivh ttps://github.com/mu228/LPSS/raw/master/epel-release-6-8.noarch.rpm
echo "升级"
yum -y update
yum -y install vixie-cron  
yum -y install crontabs  
echo "防火墙" 
iptables -F
service iptables save
service iptables restart 
setenforce 0
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -A INPUT -p TCP --dport 443 -j ACCEPT
iptables -A INPUT -p TCP --dport 80 -j ACCEPT
iptables -A INPUT -p TCP --dport 8080 -j ACCEPT 
iptables -A INPUT -p TCP --dport 22 -j ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
service iptables save
service iptables restart
setenforce 0

yum install -y wget squid openssl openssl-devel lzo lzo-devel pam pam-devel automake pkgconfig 
yum install -y openvpn 
cd /etc/openvpn/
wget https://github.com/mu228/LPSS/raw/master/EasyRSA-2.2.2.tar.gz
wget https://github.com/mu228/LPSS/raw/master/MP/server.conf
wget https://github.com/mu228/LPSS/raw/master/openvpn-auth-pam.so
wget https://github.com/mu228/LPSS/raw/master/yc/connect.sh
wget https://github.com/mu228/LPSS/raw/master/yc/disconnect.sh
wget https://github.com/mu228/LPSS/raw/master/yc/test.sh

tar -zxvf EasyRSA-2.2.2.tar.gz

sed -i 's/127.0.0.1/'$dz'/' /etc/openvpn/connect.sh
sed -i 's/3306/'$dk'/' /etc/openvpn/connect.sh
sed -i 's/127.0.0.1/'$dz'/' /etc/openvpn/disconnect.sh
sed -i 's/3306/'$dk'/' /etc/openvpn/disconnect.sh
sed -i 's/127.0.0.1/'$dz'/' /etc/openvpn/test.sh
sed -i 's/3306/'$dk'/' /etc/openvpn/test.sh

gzexe connect.sh
gzexe disconnect.sh
gzexe test.sh

chmod +x /etc/openvpn/connect.sh
chmod +x /etc/openvpn/disconnect.sh
chmod +x /etc/openvpn/test.sh

rm -f connect.sh~
rm -f disconnect.sh~
rm -f test.sh~

chkconfig crond on
/sbin/service crond restart
cd /etc
sleep 1
echo "40 3 * * * root  /etc/openvpn/test.sh"  >> crontab
/sbin/service crond restart
rm -f sysctl.conf
wget https://github.com/mu228/LPSS/raw/master/sysctl.conf
chmod 0755 /etc/sysctl.conf
sysctl -p

echo  "配置Squid"
cd /etc/squid
rm -f ./squid.conf
wget https://github.com/mu228/LPSS/raw/master/squid.conf
wget https://github.com/mu228/LPSS/raw/master/squid_passwd
chmod 0755 /etc/squid/squid.conf
squid –z
squid -s 

chkconfig squid on 
chkconfig openvpn on  
chkconfig squid on  

sleep 1
echo "pam_mysql安装开始"
yum install -y mysql-devel pam-devel gcc gcc-c++ openssl
sleep 1
echo "pam_mysql下载解压"
wget https://github.com/mu228/LPSS/raw/master/pam_mysql-0.7RC1.tar.gz
tar zxvf pam_mysql-0.7RC1.tar.gz
echo   
sleep 1
cd pam_mysql-0.7RC1
echo "文件校验"
sleep 1
./configure –with-openssl
echo
sleep 2
./configure
echo  
sleep 1
echo  "安装中"
make
make install
ln /lib/security/pam_mysql.* /lib64/security/

cd /etc/pam.d
wget https://github.com/mu228/LPSS/raw/master/yc/openvpn
sed -i 's/127.0.0.1/'$dz'/' /etc/pam.d/openvpn
sed -i 's/3306/'$dk'/' /etc/pam.d/openvpn
cd /etc
wget https://github.com/mu228/LPSS/raw/master/MP/mproxy
chmod 0755 mproxy
cd /home
wget  https://github.com/mu228/LPSS/raw/master/vpn.sql
echo "安装 完毕"

echo  "重启服务"
/etc/init.d/saslauthd start
service squid start

mysql -h$dz -P$dk -u$us -p$ps -e "

USE openvpn;

GRANT ALL ON openvpn.* TO 'lpss'@'%' IDENTIFIED BY 'lpss';

"

if [ $cj = 'y' ];then
echo  "不重建"
 mysql -h$dz -P$dk -u$us -p$ps -e "

CREATE DATABASE openvpn;

USE openvpn;

GRANT ALL ON openvpn.* TO 'lpss'@'%' IDENTIFIED BY 'lpss';

source /home/vpn.sql

INSERT INTO test(username,password,name,note,mo,quota,now,zq,zxzt,start,active,updata,downdata) VALUES('test', ENCRYPT('123456'),'test','12321',1,10240000,0,30,0,0,1,0,0);

"
fi

rm -f /home/vpn.sql

cd /etc/openvpn/easy-rsa/
source vars
./clean-all
echo 
echo "正在生成CA证书文件..."
echo 
sleep 1
echo -e "nnnnnnnn" | ./build-ca
echo -e "nnnnnnnnnn" | ./build-key-server server && echo -e "nnnnnnnnnn" | ./build-key user01
./build-ca
echo "正在生成服务端证书，请根据提示输入 y 进行确认，按回车继续"
read
./build-key-server centos
echo 
echo "正在生成SSL加密证书，这是一个漫长的过程..."
sleep 4
./build-dh
echo
echo "正在生成TLS密钥..."
sleep 2
openvpn --genkey --secret ta.key
cp /etc/openvpn/easy-rsa/keys/ca.crt /home/

/etc/init.d/saslauthd restart
/etc/init.d/openvpn restart	
service squid start
cd /etc
./mproxy -l 8080 -d

echo '=========================================================================='
echo                            远程数据库版安装完毕
echo 
echo              数据库地址：$dz  数据库端口：$dk
Client='                      

            常规模板地址：https://github.com/mu228/LPSS/raw/master/openvpn-http.ovpn

	                             注：证书在home目录 
				
==========================================================================';
echo "$Client";


