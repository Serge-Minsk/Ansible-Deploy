#!/bin/bash


yum update -y
yum groupinstall -y 'Development Tools'
yum install -y epel-release-6-8
yum install -y git

#JAVA
cd /opt
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.rpm"

yum localinstall -y jdk-7u79-linux-x64.rpm

alternatives --install /usr/bin/java java /usr/java/jdk1.7.0_79/bin/java 1
alternatives --install /usr/bin/javac javac /usr/java/jdk1.7.0_79/bin/javac 1

#NGINX repository section begins
cat << 'NGINXREPO' >> /etc/yum.repos.d/NGINX.repo
[NGINX]
name=NGINX repo
baseurl=http://NGINX.org/packages/centos/6/$basearch/
gpgcheck=0
enabled=1
NGINXREPO
#NGINX repository section ends


#NGINX
yum install -y nginx

cat << 'NGINX' > /etc/nginx/conf.d/virtual.conf
server {
    listen	8080;
    server_name localhost;

    location /jenkins {
	proxy_set_header	Host $host:$server_port;
	proxy_set_header	X-Real-Ip $remote_addr;
	proxy_set_header	X-Forwarded-For $proxy_add_x_forwarded_for;
	proxy_set_header        X-Forwarded-Proto $scheme;
	
	# Fix the "It appears that your reverse proxy set up is broken" error.
	proxy_pass	http://127.0.0.1:8081;
	proxy_read_timeout  90;
	
	proxy_redirect		http://127.0.0.1:8081 http://localhost:8080;
    }


    location /mnt-lab {
	proxy_set_header	Host $host;
	proxy_set_header	X-Real-Ip $remote_addr;
	proxy_set_header	X-Forwarded-For $proxy_add_x_forwarded_for;
	
	proxy_pass	http://127.0.0.1:9090;
	proxy_read_timeout  90;
	
	proxy_redirect		default;
    }
}
NGINX

chkconfig nginx on
chown nginx:nginx /etc/nginx/conf.d/virtual.conf


#TOMCAT
useradd tomcat
echo tomcat | passwd tomcat --stdin

wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-7/v7.0.68/bin/apache-tomcat-7.0.68.tar.gz
tar -xzf apache-tomcat-7.0.68.tar.gz
chown -R tomcat:tomcat /opt/apache-tomcat-7.0.68/

cat << 'TOMCAT' >> /etc/init.d/tomcat
#!/bin/sh
# chkconfig: 345 99 10
# description: apache tomcat auto start-stop script.
. /etc/init.d/functions
RETVAL=0
start()
{
  echo -n "Starting tomcat"
  su - tomcat -c "sh /opt/apache-tomcat-7.0.68/bin/startup.sh" > /dev/null
  success
  echo
}
stop()
{
  echo -n "Stopping tomcat"
  su - tomcat -c "sh /opt/apache-tomcat-7.0.68/bin/shutdown.sh" > /dev/null
  success
  echo
}
status()
{
  echo "tomcat is running"
}
case "$1" in
start)
        start
        ;;
stop)
        stop
        ;;
status)
        status
        ;;
restart)
        stop
        start
        ;;
*)
        echo $"Usage: $0 {start|stop|status|restart}"
        exit 1
esac
TOMCAT

chmod 755 /etc/init.d/tomcat
chkconfig tomcat on
sed -i 's/port="8080"/port="9090"/' /opt/apache-tomcat-7.0.68/conf/server.xml
chown -R tomcat:tomcat /opt/apache-tomcat-7.0.68

#JENKINS

wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum install -y jenkins
sed -i 's/JENKINS_PORT="8080"/JENKINS_PORT="8081"/' /etc/sysconfig/jenkins
sed -i 's/JENKINS_ARGS=""/JENKINS_ARGS="--prefix=\/jenkins --httpListenAddress=127.0.0.1"/' /etc/sysconfig/jenkins
sed -i 's/JENKINS_AJP_PORT="8009"/JENKINS_AJP_PORT="8010"/' /etc/sysconfig/jenkins
rm -rf /var/lib/jenkins/plugins
rm -rf /var/lib/jenkins/jobs
cp -R /vagrant/jenkins /var/lib/
chown -R jenkins:jenkins /var/lib/jenkins


#MAVEN
wget http://ftp.byfly.by/pub/apache.org/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar xvf apache-maven-3.3.9-bin.tar.gz


#USERS RIGHTS
cat << 'TOMCAT-USER' >> /etc/sudoers.d/tomcat
tomcat	ALL=(ALL)	NOPASSWD: ALL
TOMCAT-USER
cat << 'JENKINS-USER' >> /etc/sudoers.d/jenkins
Defaults:jenkins	!requiretty
jenkins	ALL=(ALL)	NOPASSWD: ALL
JENKINS-USER

#STARTING SERVICES
service jenkins start
service tomcat start
service nginx start
