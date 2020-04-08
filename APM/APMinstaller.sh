#!/bin/bash
 
#####################################################################################
#                                                                                   #
# * APMinstaller Beta v.0.3 with CentOS8                                            #
# * CentOS-8-x86_64-1911                                                            #
# * Apache 2.4.X , MariaDB 10.4.X, PHP 7.2.X setup shell script                     #
# * Created Date    : 2020/04/07                                                    #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################

##########################################
#                                        #
#           repositories install         #
#                                        #
########################################## 

yum -y install wget openssh-clients bind-utils git nc vim-enhanced man ntsysv \
iotop sysstat strace lsof mc lrzsz zip unzip bzip2 glibc* net-tools bind gcc dnf \
libxml2-devel libXpm-devel gmp-devel libicu-devel openssl-devel gettext-devel \
bzip2-devel libcurl-devel libjpeg-devel libpng-devel freetype-devel readline-devel \
libxslt-devel pcre-devel curl-devel ncurses-devel autoconf automake zlib-devel libuuid-devel \
net-snmp-devel libevent-devel libtool-ltdl-devel postgresql-devel bison make pkgconfig firewalld yum-utils

dnf config-manager --set-enabled PowerTools
dnf config-manager --set-enabled remi

cd /etc/yum.repos.d && wget https://repo.codeit.guru/codeit.el`rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release)`.repo

dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm

yum install -y epel-release yum-utils

echo "[mariadb]" > /etc/yum.repos.d/mariadb.repo
echo "name = MariaDB" >> /etc/yum.repos.d/mariadb.repo
echo "baseurl = http://yum.mariadb.org/10.4/centos8-amd64" >> /etc/yum.repos.d/mariadb.repo
echo "module_hotfixes=1" >> /etc/yum.repos.d/mariadb.repo
echo "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/mariadb.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/mariadb.repo 

yum -y update

cd /root/AAI/APM

##########################################
#                                        #
#           SELINUX disabled             #
#                                        #
##########################################

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
/usr/sbin/setenforce 0

##########################################
#                                        #
#           아파치 및 HTTP2 설치            #
#                                        #
########################################## 

# Nghttp2 설치
yum --enablerepo=epel -y install libnghttp2

# /etc/mime.types 설치 
yum -y install mailcap

# httpd 설치
yum -y install c-ares

yum -y install httpd mod_ssl

yum -y install openldap-devel expat-devel

yum -y install libdb-devel perl

yum -y install httpd-devel

systemctl start httpd
systemctl enable httpd

cd /root/AAI
wget https://dl.eff.org/certbot-auto
mv certbot-auto /usr/local/bin/certbot-auto
chown root /usr/local/bin/certbot-auto
chmod 0755 /usr/local/bin/certbot-auto

##########################################
#                                        #
#               firewalld                #
#                                        #
##########################################  

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-port=3306/tcp
firewall-cmd --permanent --zone=public --add-port=9090/tcp
firewall-cmd --reload

##########################################
#                                        #
#           httpd.conf   Setup           #
#                                        #
##########################################  

sed -i '/nameserver/i\nameserver 127.0.0.1' /etc/resolv.conf
cp -av /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.original
sed -i 's/DirectoryIndex index.html/ DirectoryIndex index.html index.htm index.php index.php3 index.cgi index.jsp/' /etc/httpd/conf/httpd.conf
sed -i 's/Options Indexes FollowSymLinks/Options FollowSymLinks/' /etc/httpd/conf/httpd.conf
sed -i 's/#ServerName www.example.com:80/ServerName localhost:80/' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride none/AllowOverride All/' /etc/httpd/conf/httpd.conf
sed -i 's/#AddHandler cgi-script .cgi/AddHandler cgi-script .cgi/' /etc/httpd/conf/httpd.conf
#sed -i '/AddType application\/x-gzip .gz .tgz/a\    AddType application\/x-httpd-php .html .htm .php .ph php3 .php4 .phtml .inc' /etc/httpd/conf/httpd.conf
#sed -i '/AddType application\/x-httpd-php .htm .html .php .ph php3 .php4 .phtml .inc/a\    AddType application\/x-httpd-php-source .phps' /etc/httpd/conf/httpd.conf
sed -i 's/UserDir disabled/#UserDir disabled/' /etc/httpd/conf.d/userdir.conf
sed -i 's/#UserDir public_html/UserDir public_html/' /etc/httpd/conf.d/userdir.conf
sed -i 's/Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec/Options MultiViews SymLinksIfOwnerMatch IncludesNoExec/' /etc/httpd/conf.d/userdir.conf
#sed -i 's/LoadModule mpm_prefork_module/#LoadModule mpm_prefork_modul/' /etc/httpd/conf.modules.d/00-mpm.conf
#sed -i 's/#LoadModule mpm_event_module/LoadModule mpm_event_module/' /etc/httpd/conf.modules.d/00-mpm.conf

cp /root/AAI/APM/index.html /var/www/html/
#cp -f /root/AAI/APM/index.html /usr/share/httpd/noindex/

echo "<VirtualHost *:80>
  DocumentRoot /var/www/html
</VirtualHost> " >> /etc/httpd/conf.d/default.conf

systemctl restart httpd
systemctl restart named.service

##########################################
#                                        #
#         PHP7.2 및 라이브러리 install      #
#                                        #
########################################## 

dnf module reset php
dnf module enable php:remi-7.2 -y

dnf install -y GeoIP GeoIP-data GeoIP-devel
dnf install -y php php-cli php-fpm \
php-common php-devel php-gd php-json php-ldap \
php-mbstring php-mysqlnd php-opcache php-soap php-xml \
php-iconv php-xmlrpc php-pdo php-pecl-apcu php-pecl-zip \
php-pgsql php-process php-snmp php-soap

echo "#geoip setup
<IfModule mod_geoip.c>
 GeoIPEnable On
 GeoIPDBFile /usr/share/GeoIP/GeoIP.dat MemoryCache
</IfModule>" > /etc/httpd/conf.d/geoip.conf

cp -av /etc/php.ini /etc/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/php.ini 

echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /etc/php.ini


mkdir /etc/skel/public_html

chmod 707 /etc/skel/public_html

chmod 700 /root/AAI/adduser.sh

chmod 700 /root/AAI/deluser.sh

chmod 700 /root/AAI/restart.sh

cp /root/AAI/APM/skel/index.html /etc/skel/public_html/

systemctl restart httpd


curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php.ini

systemctl restart httpd

echo '<?php
phpinfo();
?>' >> /var/www/html/phpinfo.php

##########################################
#                                        #
#          MARIADB 10.4.X install        #
#                                        #
########################################## 

# MariaDB 10.4.x 설치
dnf install -y boost-program-options
dnf install -y MariaDB-server

systemctl enable --now mariadb

systemctl start mariadb

# S.M.A.R.T. 디스크 모니터링을 설치
yum -y install smartmontools

systemctl enable smartd

systemctl start smartd

##########################################
#                                        #
#            mysql root 설정              #
#                                        #
##########################################

/usr/bin/mysql_secure_installation

##########################################
#                                        #
#        운영 및 보안 관련 추가 설정           #
#                                        #
##########################################

cd /root/AAI/

#chkrootkit 설치
wget ftp://ftp.pangeia.com.br/pub/seg/pac/chkrootkit.tar.gz 

tar xvfz chkrootkit.tar.gz

mv chkrootkit-* chkrootkit

cd chkrootkit

make sense

rm -rf /root/AAI/chkrootkit.tar.gz

#mod_evasive mod_security fail2ban.noarch arpwatch 설치
yum -y install  mod_security mod_security_crs fail2ban 

sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' /etc/httpd/conf.d/mod_security.conf

#fail2ban 설치
service fail2ban start
chkconfig --level 2345 fail2ban on

sed -i 's,\(#filter = sshd-aggressive\),\1\nenabled = true,g;' /etc/fail2ban/jail.conf 


mkdir /backup


echo "#mod_expires configuration" > /tmp/httpd.conf_tempfile
echo "<IfModule mod_expires.c>"   >> /tmp/httpd.conf_tempfile
echo "    ExpiresActive On"    >> /tmp/httpd.conf_tempfile
echo "    ExpiresDefault \"access plus 1 days\""    >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType text/css \"access plus 1 days\""       >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType text/javascript \"access plus 1 days\""      >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType text/x-javascript \"access plus 1 days\""        >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType application/x-javascript \"access plus 1 days\"" >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType application/javascript \"access plus 1 days\""    >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/jpeg \"access plus 1 days\""    >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/gif \"access plus 1 days\""       >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/png \"access plus 1 days\""      >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/bmp \"access plus 1 days\""        >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/cgm \"access plus 1 days\"" >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/tiff \"access plus 1 days\""       >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/basic \"access plus 1 days\""      >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/midi \"access plus 1 days\""        >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/mpeg \"access plus 1 days\""        >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/x-aiff \"access plus 1 days\""  >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/x-mpegurl \"access plus 1 days\"" >> /tmp/httpd.conf_tempfile
echo "	  ExpiresByType audio/x-pn-realaudio \"access plus 1 days\""   >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/x-wav \"access plus 1 days\""   >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType application/x-shockwave-flash \"access plus 1 days\""   >> /tmp/httpd.conf_tempfile
echo "</IfModule>"   >> /tmp/httpd.conf_tempfile
cat /tmp/httpd.conf_tempfile >> /etc/httpd/conf.d/mod_expires.conf
rm -f /tmp/httpd.conf_tempfile

##########################################
#                                        #
#            Local SSL 설정              #
#                                        #
##########################################

mv /root/AAI/APM/etc/cron.daily/backup /etc/cron.daily/
mv /root/AAI/APM/etc/cron.daily/check_chkrootkit /etc/cron.daily/

chmod 700 /etc/cron.daily/backup
chmod 700 /etc/cron.daily/check_chkrootkit

echo "00 20 * * * /root/check_chkrootkit" >> /etc/crontab
echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/local/bin/certbot-auto renew" | sudo tee -a /etc/crontab > /dev/null


#openssl 로 디피-헬만 파라미터(dhparam) 키 만들기 둘중 하나 선택
#openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

#중요 폴더 및 파일 링크
ln -s /etc/httpd/conf.d /root/AAI/conf.d
ln -s /etc/my.cnf /root/AAI/my.cnf
ln -s /etc/php.ini /root/AAI/php.ini

service httpd restart

##########################################
#                                        #
#             Cockpit install            #
#                                        #
########################################## 

dnf install -y cockpit

systemctl enable --now cockpit.socket


echo ""
echo ""
echo "축하 드립니다. APMinstaller 모든 작업이 끝났습니다."

exit 0

