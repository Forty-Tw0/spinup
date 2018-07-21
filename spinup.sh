yum install -y epel-release nano git

echo "[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.2/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1" > /etc/yum.repos.d/MariaDB.repo

yum install -y mariadb-server
echo "[mysqld]
bind-address=127.0.0.1" > /etc/my.cnf.d/server.cnf
chkconfig mysql on
service mysql start

curl -sL https://rpm.nodesource.com/setup_10.x | sudo -E bash -
yum install -y nodejs
npm install -g npm @angular/cli

yum install -y nginx
chkconfig httpd off
chkconfig nginx on
#https://stackoverflow.com/questions/5009324/node-js-nginx-what-now/5015178#5015178
yes | cp stuff/nginx.conf /etc/nginx/nginx.conf
service httpd stop
service nginx restart

yum install -y python2-certbot-nginx
certbot --nginx certonly -d consultlieske.com -d www.consultlieske.com
certbot --nginx certonly -d devwei.com -d www.devwei.com -d mx.devwei.com
ln -s /etc/letsencrypt/live/devwei.com /etc/letsencrypt/live/mx.devwei.com
certbot --nginx certonly -d project-lilium.org -d www.project-lilium.org -d mx.project-lilium.org
ln -s /etc/letsencrypt/live/project-lilium.org /etc/letsencrypt/live/mx.project-lilium.org
chmod 755 /etc/letsencrypt/archive
chmod 755 /etc/letsencrypt/live
(crontab -l ; echo "0 0,12 * * * python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew") | crontab
sed -i 's/#ssl_certificate \/etc\/letsencrypt/ssl_certificate \/etc\/letsencrypt/g' /etc/nginx/nginx.conf
sed -i 's/#ssl_certificate_key \/etc\/letsencrypt/ssl_certificate_key \/etc\/letsencrypt/g' /etc/nginx/nginx.conf
sed -i 's/#include \/etc\/letsencrypt/include \/etc\/letsencrypt/g' /etc/nginx/nginx.conf
sed -i 's/#ssl_dhparam \/etc\/letsencrypt/ssl_dhparam \/etc\/letsencrypt/g' /etc/nginx/nginx.conf
service nginx restart

#email
yum install -y exim dovecot dovecot-core dovecot-mysql
chkconfig sendmail off
chkconfig postfix off
chkconfig exim on
chkconfig dovecot on
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 4242 -nodes -out /etc/dovecot/dovecot.crt -keyout /etc/dovecot/dovecot.key
yes | cp stuff/exim.conf /etc/exim/exim.conf
yes | cp stuff/dovecot/conf.d/10-auth.conf /etc/dovecot/conf.d/10-auth.conf
yes | cp stuff/dovecot/conf.d/10-mail.conf /etc/dovecot/conf.d/10-mail.conf
yes | cp stuff/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf
yes | cp stuff/dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf
yes | cp stuff/dovecot/conf.d/auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext
yes | cp stuff/dovecot/dovecot.conf /etc/dovecot/dovecot.conf
yes | cp stuff/dovecot/dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext
mysql -e "CREATE DATABASE dovecot; CREATE TABLE dovecot.users (user varchar(255) NOT NULL PRIMARY KEY, password varchar(255) NOT NULL)"
mysql -e "INSERT INTO dovecot.users SET user='postmaster@devwei.com',password=ENCRYPT('')"
mysql -e "INSERT INTO dovecot.users SET user='postmaster@project-lilium.org',password=ENCRYPT('')"
mkdir /var/mail/vhosts/
#groupadd -g 5000 vmail
#useradd -g vmail -u 5000 vmail -d /var/mail/vhosts
chown -R vmail:vmail /var/mail/vhosts
service sendmail stop
service stop postfix
service exim restart
service dovecot restart
