confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:latest
confluent-hub install --no-prompt confluentinc/kafka-connect-hdfs:5.5.1

mkdir /root/connector 
mkdir /usr/share/java/kafka-connect-mqtt

wget https://github.com/lensesio/stream-reactor/releases/download/2.0.0/kafka-connect-mqtt-2.0.0-2.4.0-all.tar.gz -O /root/connector.tar.gz \
	&& tar -xzf /root/connector.tar.gz -C /root/connector \
	&& rm -rf /root/connectot.tar.gz

mv /root/connector/* /usr/share/java/kafka-connect-mqtt/