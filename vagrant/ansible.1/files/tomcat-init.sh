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
