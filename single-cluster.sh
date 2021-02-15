#!bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

command -v docker >/dev/null 2>&1 || { echo >&2 "This service requires Docker, but your computer doesn't have it. Install Docker then try again. Aborting."; exit 1; }


echo -e "\n"
echo ----------------------------------------------------------
echo -e "\t\tStandalone BigData Framework"
echo ----------------------------------------------------------
echo -e "\n"

echo "Available Network Interface : `ls -C /sys/class/net`"
read -p "Network Interface for Tapping: " NETINT

ip4=$(/sbin/ip -o -4 addr list $NETINT | awk '{print $4}' | cut -d/ -f1)

sed -i 's/^NETINT=.*/NETINT='$NETINT'/' envfile/netflowmeter.env
sed -i 's/^MQTT_HOST=.*/MQTT_HOST='$ip4'/' envfile/netflowmeter.env

echo -----------------------------------\
echo "Starting Compose BigData..."
/usr/bin/docker-compose up -d

echo -----------------------------------/
chars="/-\|"
container_name="connect"

sed -i 's|tcp://.*|tcp://'$ip4':1883",|' connector-config/nfm-connector.json

while [ "$( docker container inspect -f '{{.State.Running}}' $container_name )" == "true" ];
do
  for (( i=0; i<${#chars}; i++ )); do
    sleep 0.01
    echo -en "Configuring Kafka Connector...[${chars:$i:1}]" "\r"
  done

  if [ "$( docker container inspect -f '{{.State.Health.Status}}' $container_name )" == "healthy" ]
  then
    curl -s -X POST -H 'Content-Type: application/json' --data @connector-config/nfm-connector.json http://localhost:8083/connectors
    break;
  fi
done
echo -e "\n\n-----------------------------------"
echo -e "Setup completed.\nYou can start/stop/restart the bigdata-framework now by the heading to folder project and using command : 
\tdocker-compose start
\tdocker-compose kill
\tdocker-compose restart "
