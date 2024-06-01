- READ THE FOLLOWING INSTRUCTION BEFORE PROCEEDING

-  go to EFS > Access point > select tooling >  View details > Attach 
- copy efs mount helper without last efs part and paste it
- before  :/ /var/www/" on line 13
- use the same mount point you used for "wordpress"
- acs-database.cxgqmm0me4bb.us-east-1.rds.amazonaws.com
- paste it between "mysqli_connect(' ....... ', 'ACSadmin', 'admin12345', 'toolingdb');/g" functions.php" on line 30
- we are going to create the toolingdb later


#!/bin/bash
mkdir /var/www/
sudo mount -t efs -o tls,accesspoint=fsap-0e9251530ad655e9d fs-07d12dccdc93fa0bd:/ /var/www/
yum install -y httpd 
systemctl start httpd
systemctl enable httpd
yum module reset php -y
yum module enable php:remi-7.4 -y
yum install -y php php-common php-mbstring php-opcache php-intl php-xml php-gd php-curl php-mysqlnd php-fpm php-json
systemctl start php-fpm
systemctl enable php-fpm
git clone https://github.com/Olaminiyi/tooling.git
mkdir /var/www/html
cp -R /tooling/html/*  /var/www/html/
cd /tooling
mysql -h acs-database.cdqpbjkethv0.us-east-1.rds.amazonaws.com -u ACSadmin -p toolingdb < tooling-db.sql
cd /var/www/html/
touch healthstatus
sed -i "s/$db = mysqli_connect('mysql.tooling.svc.cluster.local', 'admin', 'admin', 'tooling');/$db = mysqli_connect('acs-database.cxgqmm0me4bb.us-east-1.rds.amazonaws.com', 'ACSadmin', 'admin12345', 'toolingdb');/g" functions.php
chcon -t httpd_sys_rw_content_t /var/www/html/ -R
systemctl restart httpd