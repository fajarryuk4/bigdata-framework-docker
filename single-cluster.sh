#!bin/bash

#run as root checker
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#Requirement checker
command -v docker >/dev/null 2>&1 || { echo >&2 "This service requires Docker, but your computer doesn't have it. Install Docker then try again. Aborting."; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo >&2 "This service requires Docker-Compose, but your computer doesn't have it. Install Docker-Compose then try again. Aborting."; exit 1;}
command -v ifconfig >/dev/null 2>&1 || { echo >&2 "This service requires Net-Tools, but your computer doesn't have it. Install Net-Tools then try again. Aborting."; exit 1; }
command -v mosquitto >/dev/null 2>&1 || { echo >&2 "This service requires Mosquitto Broker, but your computer doesn't have it. Install Mosquitto Broker then try again. Aborting."; exit 1; }

#Opening
printf '
 __  __    _  _____  _       _____ _        _    _   _  ____    _        _    ____
|  \/  |  / \|_   _|/ \     | ____| |      / \  | \ | |/ ___|  | |      / \  | __ )
| |\/| | / _ \ | | / _ \    |  _| | |     / _ \ |  \| | |  _   | |     / _ \ |  _ \
| |  | |/ ___ \| |/ ___ \   | |___| |___ / ___ \| |\  | |_| |  | |___ / ___ \| |_) |
|_|  |_/_/   \_|_/_/   \_\  |_____|_____/_/   \_|_| \_|\____|  |_____/_/   \_|____/'

echo -e "\n"
echo ----------------------------------------------------------
echo -e "\t\tStandalone BigData Framework"
echo ----------------------------------------------------------
echo -e "\n"

YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#Note
echo -----------
printf "${YELLOW}Warning: ${NC}If Using Virtual Machine, Please use NAT Mode\n"
echo -e "-----------\n"

#Get NIC input
echo "Available Network Interface : `ls -C /sys/class/net`"
echo "Network Interface Card for Tapping (ex: eth0)"
read -p "Your Choice: " NETINT

echo -e "\nInput Mongo Chart UserAdmin Account"
read -p "Username: " USERNAME
read -s -p "Password: " PASSWORD

#Get NIC IP then override env file
ip4=$(ifconfig $NETINT | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'  | cut -d' ' -f2)
##Netflowmeter
sed -i 's/^NETINT=.*/NETINT='$NETINT'/' envfile/netflowmeter.env
sed -i 's/^MQTT_HOST=.*/MQTT_HOST='$ip4'/' envfile/netflowmeter.env
##Snort
sed -i 's/^PROTECTED_SUBNET=.*/PROTECTED_SUBNET='$ip4'\/24/' envfile/snort.env 
sed -i 's/^ALERT_MQTT_SERVER=.*/ALERT_MQTT_SERVER='$ip4'/' envfile/snort.env
sed -i 's/^NETINT=.*/NETINT='$NETINT'/' envfile/snort.env

#Running MQTT
systemctl start mosquitto

#Allow mqqt in firewall
echo -e "\n\nAdding rule for MQTT transfer file"
ufw allow 1883 

#Remove Exist Volume
rm -rf ./volume/mongochart

#Starting Big Data
echo -e "\nStarting Compose BigData..."
echo "-----------------------------------\ "
docker-compose up -d

echo -----------------------------------/
chars="/-\|"
container_name="connect"

#Set MQTT IP in confluent-config file for connection between Kafka-MQTT
sed -i 's|tcp://.*|tcp://'$ip4':1883",|' connector-config/nfm-connector.json
sed -i 's|tcp://.*|tcp://'$ip4':1883",|' connector-config/snort-connector.json

while [ "$( docker container inspect -f '{{.State.Running}}' $container_name )" == "true" ];
do
  for (( i=0; i<${#chars}; i++ )); do
    sleep 0.1
    echo -en "Configuring Kafka Connector...[${chars:$i:1}]" "\r"
  done

  if [ "$( docker container inspect -f '{{.State.Health.Status}}' $container_name )" == "healthy" ]
  then
    curl -s -X POST -H 'Content-Type: application/json' --data @connector-config/nfm-connector.json http://localhost:8083/connectors
    curl -s -X POST -H 'Content-Type: application/json' --data @connector-config/snort-connector.json http://localhost:8083/connectors
    break;
  fi
done

#Create Charts users
if [ "$( docker container inspect -f '{{.State.Running}}' mongo-charts )" == "true" ];
then
  echo -en "\nAdd MongoDB Chart UserAdmin... \n"
  sleep 10
  docker exec -it mongo-charts bash -c \
  "charts-cli add-user \
  --first-name "$USERNAME" \
  --last-name \"lab\" \
  --email \"$USERNAME@mail.com\" \
  --password "$PASSWORD" \
  --role \"UserAdmin\""
fi

#Display Available Link
echo -e "\n\n-----------------------------------"
echo -e "${YELLOW}Available WebApp${NC}"
echo -e "(For easier Please Bookmark or Copy link)"
echo -e "-----------------------------------"
echo -e "Kafka Control Center\t http://0.0.0.0:9021/"
echo -e "Mongo Chart Panel\t http://0.0.0.0:9080/"
echo -e "Jupyter"
docker exec -it spark-base bash -c 'jupyter notebook list'
echo -e "\nSave The Jupyter Token"
echo -e "If you forgot the token, you can access token by running command\n\tdocker exec -it spark-base bash -c 'jupyter notebook list'"

echo -e "\n\n-----------------------------------"
echo -e "${YELLOW}Setup completed.${NC}"
echo -e "-----------------------------------"

echo -e "You can start/stop/restart the bigdata-framework now by the heading to folder project and using command : 
\tdocker-compose start
\tdocker-compose kill
\tdocker-compose restart "

echo -e "For Uninstall run command:\n\tdocker-compose down -v\n"
echo -e "For Re-Install or Re-build run\n\tdocker-compose up --build"