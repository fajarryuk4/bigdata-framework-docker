#!bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

command -v docker >/dev/null 2>&1 || { echo >&2 "This service requires Docker, but your computer doesn't have it. Install Docker then try again. Aborting."; exit 1; }
command -v ifconfig >/dev/null 2>&1 || { echo >&2 "This service requires net-tools, but your computer doesn't have it. Install net-tools then try again. Aborting."; exit 1; }

echo -e "\n"
echo ----------------------------------------------------------
echo -e "\t\tStandalone BigData Framework"
echo ----------------------------------------------------------
echo -e "\n"

echo -e "\tNote :\nIf Using Virtual Machine, Please disable windows Firewall\nOr\nYou can allow MQTT-port (1883) in windows\n"

echo "Available Network Interface : `ls -C /sys/class/net`"
echo "Network Interface Card for Tapping (ex: eth0)"
read -p "Your Choice: " NETINT

# ip4=$( /sbin/ip -o -4 addr list $NETINT | awk '{print $4}' | cut -d/ -f1 )
ip4=$(ifconfig $NETINT | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'  | cut -d' ' -f2)

sed -i 's/^NETINT=.*/NETINT='$NETINT'/' envfile/netflowmeter.env
sed -i 's/^MQTT_HOST=.*/MQTT_HOST='$ip4'/' envfile/netflowmeter.env

echo "-----------------------------------\ "
echo "Starting Compose BigData..."
/usr/bin/docker-compose up -d

echo -----------------------------------/
chars="/-\|"
container_name="connect"

#Set MQTT IP in confluent-config file for connection between Kafka-MQTT
container_network_name="$( docker inspect -f '{{ .HostConfig.NetworkMode}}' $container_name )"
stack_gateway="$( docker network inspect -f '{{(index .IPAM.Config 0).Gateway}}' $container_network_name )"
sed -i 's|tcp://.*|tcp://'$stack_gateway':1883",|' connector-config/nfm-connector.json

while [ "$( docker container inspect -f '{{.State.Running}}' $container_name )" == "true" ];
do
  for (( i=0; i<${#chars}; i++ )); do
    sleep 0.1
    echo -en "Configuring Kafka Connector...[${chars:$i:1}]" "\r"
  done

  if [ "$( docker container inspect -f '{{.State.Health.Status}}' $container_name )" == "healthy" ]
  then
    curl -s -X POST -H 'Content-Type: application/json' --data @connector-config/nfm-connector.json http://localhost:8083/connectors
    break;
  fi
done

echo -e "\n\n-----------------------------------"
echo -e "\tJupyter Notebook Token"
docker exec -it spark-base bash -c 'jupyter notebook list'
echo "Save The Token"
echo "If you forgot the token, you can access token by running command\n\tdocker exec -it spark-base bash -c 'jupyter notebook list'"

echo -e "\n\n-----------------------------------"
echo -e "Setup completed.\nYou can start/stop/restart the bigdata-framework now by the heading to folder project and using command : 
\tdocker-compose start
\tdocker-compose kill
\tdocker-compose restart "

echo -e "For Uninstall run command:\n\tdocker-compose down\nFor install or Re-Install run\n\tsudo bash single-cluster.sh"