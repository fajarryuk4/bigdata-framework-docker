confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:latest
confluent-hub install --no-prompt confluentinc/kafka-connect-hdfs:5.5.2

mkdir ~/connector 
mkdir /usr/share/java/kafka-connect-mqtt

wget https://github.com/lensesio/stream-reactor/releases/download/2.0.0/kafka-connect-mqtt-2.0.0-2.4.0-all.tar.gz -O ~/connector.tar.gz \
	&& tar -xzf ~/connector.tar.gz -C ~/connector \
	&& rm -rf ~/connectot.tar.gz

mv ~/connector/* /usr/share/java/kafka-connect-mqtt/