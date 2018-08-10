#!/bin/sh
set -e

AUTODISCOVERY_RULES=${AUTODISCOVERY_RULES:-yes}

if [ $AUTODISCOVERY_RULES == "yes" ]
then

  if [ -f /etc/modsecurity/main.conf ]
  then
    echo "WARNING: ..."
    echo "WARNING: ..."
    echo "WARNING: /etc/modsecurity/main.conf file already exist. Bypassing discovery of rules."
    echo "WARNING: ..."
    echo "WARNING: ..."
  else
    if [ -d /etc/modsecurity/rules ]
    then
      # echo "include /etc/modsecurity/crs-setup.conf" > $DIR/conf.d/modsecurity-main.conf
      for file in $( ls /etc/modsecurity/rules/*conf ) 
      do
        echo "include $file" >> /etc/modsecurity/main.conf
      done
    fi
  fi
fi

exec "$@"
