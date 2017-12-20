#!/bin/bash
#
# Init script
#
###########################################################
# Thanks to http://stackoverflow.com/a/10467453
function sedeasy {
  sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

if [ -z "$API_KEY" ]; then
  # Generate a random API Key everytime so only this Docker knowns it, not everybody
  API_KEY=`dbus-uuidgen`
fi

# Update PowerDNS Server config file
sedeasy "api-key=API_KEY" "api-key=$API_KEY" /etc/pdns/pdns.conf
sedeasy "gmysql-host=MYSQL_HOST" "gmysql-host=$MYSQL_HOST" /etc/pdns/pdns.conf
sedeasy "gmysql-port=MYSQL_PORT" "gmysql-port=$MYSQL_PORT" /etc/pdns/pdns.conf
sedeasy "gmysql-dbname=MYSQL_DB" "gmysql-dbname=$MYSQL_DB" /etc/pdns/pdns.conf
sedeasy "gmysql-user=MYSQL_USER" "gmysql-user=$MYSQL_USER" /etc/pdns/pdns.conf
sedeasy "gmysql-password=MYSQL_PWD" "gmysql-password=$MYSQL_PWD" /etc/pdns/pdns.conf

# Add custom DNS entries
sedeasy "forward-zones-recurse=.=CUSTOM_DNS" "forward-zones-recurse=.=$CUSTOM_DNS" /etc/pdns/recursor.conf

# Update PowerDNS Admin GUI configuration file
sedeasy "PDNS_API_KEY = 'PDNS_API_KEY'" "PDNS_API_KEY = '$API_KEY'" /usr/share/webapps/powerdns-admin/config.py
sedeasy "SQLA_DB_USER = 'MYSQL_USER'" "SQLA_DB_USER = '$MYSQL_USER'" /usr/share/webapps/powerdns-admin/config.py
sedeasy "SQLA_DB_PASSWORD = 'MYSQL_PWD'" "SQLA_DB_PASSWORD = '$MYSQL_PWD'" /usr/share/webapps/powerdns-admin/config.py
sedeasy "SQLA_DB_HOST = 'MYSQL_HOST'" "SQLA_DB_HOST = '$MYSQL_HOST'" /usr/share/webapps/powerdns-admin/config.py
sedeasy "SQLA_DB_NAME = 'MYSQL_ADMIN_DB'" "SQLA_DB_NAME = '$MYSQL_ADMIN_DB'" /usr/share/webapps/powerdns-admin/config.py

if $MYSQL_AUTOCONF ; then
  MYSQLCMD="mysql --host=$MYSQL_HOST --user=$MYSQL_USER --password=${MYSQL_PWD} -r -N"
  # wait for Database come ready
  isDBup () {
    echo "SHOW STATUS" | $MYSQLCMD 1>/dev/null
    echo $?
  }

  RETRY=10
  until [ `isDBup` -eq 0 ] || [ $RETRY -le 0 ] ; do
    echo "Waiting for database to come up"
    sleep 5
    RETRY=$(expr $RETRY - 1)
  done
  if [ $RETRY -le 0 ]; then
    >&2 echo Error: Could not connect to Database on $MYSQL_HOST:$MYSQL_PORT
    exit 1
  fi

  # init database if necessary
  echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DB;" | $MYSQLCMD
  MYSQLCMD="$MYSQLCMD $MYSQL_DB"

  if [ "$(echo "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = \"$MYSQL_DB\";" | $MYSQLCMD)" -le 1 ]; then
    echo Initializing PowerDNS Database
    cat /usr/share/doc/pdns/schema.mysql.sql | $MYSQLCMD
  fi

fi

if $MYSQL_AUTOCONF ; then
  echo Initializing PowerDNS Admin Database
  python /usr/share/webapps/powerdns-admin/create_db.py

  unset -v MYSQL_PASS
fi

# Fix permissions
find $DATA_DIR -type d -exec chmod 775 {} \;
find $DATA_DIR -type f -exec chmod 664 {} \;
chown -R nobody:nobody $DATA_DIR

if [ $ENABLE_ADBLOCK = true ]; then
  echo Initializing ADBLOCK
  # Run at least the first time
  /root/updateHosts.sh

  # Initialize the cronjob to update hosts, if feature is enabled
  cronFile=/tmp/buildcron
  printf "SHELL=/bin/bash" > $cronFile
  printf "\n$CRONTAB_TIME /usr/bin/flock -n /tmp/lock.hosts /root/updateHosts.sh\n" >> $cronFile
  crontab $cronFile
  rm $cronFile
fi

# Start supervisor
/usr/bin/supervisord -c /etc/supervisord.conf
