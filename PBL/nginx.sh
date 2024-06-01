# READ AND FOLLOW THE INSTRUCTION BELOW
# since you've forked the Olaminiyi's repo in to your own repo at the begining of this project
# change line 9 to your own repo directory i.e git clone https://github.com/yourName/ACS-project-config.git

#!/bin/bash
yum install -y nginx
systemctl start nginx
systemctl enable nginx
git clone https://github.com/Olaminiyi/ACS-project-config.git
mv /ACS-project-config/reverse.conf /etc/nginx/
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf-distro
cd /etc/nginx/
touch nginx.conf
sed -n 'w nginx.conf' reverse.conf
systemctl restart nginx
rm -rf reverse.conf
rm -rf /ACS-project-config