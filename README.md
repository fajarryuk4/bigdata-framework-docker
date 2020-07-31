# bigdata-framework-docker

## Do before run docker-compose

### Netflometer / CICFlowmeter
[CICFlowmeter source](https://github.com/ahlashkari/CICFlowMeter) (build as docker image)
How To Use:
1. Change configuration env file in netflometer folder
    a. MQTT_TOPIC= <your CICFlowmeter topic>
    b. MQTT_HOST= <your pc IP (not localhost)> if you not change MQTT network_mode on docker-compose
    c. MQTT_PORT= <MQTT port (default 1883)> if you change port on docker-compose
    d. NETINT= <your interface that want to listen>

### [Snort](https://www.snort.org/)
[Snort source image](https://github.com/mata-elang-pens/SnorqttAlpine-Sensor)
[Snort documentation](https://www.snort.org/documents)
How To Use:
1. Change configuration env file in snort folder
    a. PROTECTED_SUBNET= <subnet that you want to protect>
    b. EXTERNAL_SUBNET= <your external subnet (default any)>
    c. ALERT_MQTT_TOPIC= <your Snort topic>
    d. ALERT_MQTT_SERVER= <your pc IP (not localhost)> if you not change MQTT network_mode on docker-compose
    e. ALERT_MQTT_PORT= <MQTT port (default 1883)> if you change port on docker-compose
    f. DEVICE_ID= <your device id (ex: sensor-2)>
    g. NETINT= <your interface that want to listen>
    h. COMPANY= <your company>

## Do after run docker-compose

### [Confluent-Kafka](https://www.confluent.io/)
[Confluent-Kafka](https://docs.confluent.io/)
How To Use (For This Big data):
1. Change file in "connector-config" folder
    a. Change "netflowmeter" with <your CICFlowmeter topic> in nfm-connector.json in line `connect.mqtt.kcql`
    b. Change "snorqtt" with <your Snort topic> in snort-connector.json in line `connect.mqtt.kcql`
    c. Change mqtt-host-ip with <your pc IP (not localhost)> (if you not change MQTT network_mode on docker-compose) <MQTT port (default 1883)> (if you change port on docker-compose) in both script json in line `connect.mqtt.hosts`
2. Open browser and open `http://0.0.0.0:9021/`
3. Upload both file in folder "connector-config" ([How to upload config confluent](https://www.confluent.io/product/confluent-platform/gui-driven-management-and-monitoring/?utm_medium=sem&utm_source=google&utm_campaign=ch.sem_br.brand_tp.prs_tgt.confluent-brand_mt.xct_rgn.apac_lng.eng_dv.all&utm_term=control%20center%20confluent&creative=&device=c&placement=&gclid=Cj0KCQjwgo_5BRDuARIsADDEntT6rp8yE5U0UPe2fy3jPhx2THTUcaOSpHIIOMmDnVS6BMCbhqaQyAAaAmfYEALw_wcB))

### [Jupyter-Spark](https://github.com/jupyter/docker-stacks/tree/master/all-spark-notebook)
[Jupyter-Spark documentation](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/specifics.html)
How To Use (For This Big data):
1. on terminal run `docker logs spark-base` (if you not change spark-base container name)
2. copy link on terminal (ex:  `http://localhost:8888/?token=112bb073331f1460b73768c76dffb2f87ac1d4ca7870d46a` )
3. open link in browser
4. upload your processing code (python, scala, r) and run as jupyter notebook

### [Mongo](https://www.mongodb.com/)
[Mongo documentation](https://docs.mongodb.com/)
How To Use (For This Big data):
1. on terminal run `docker exec -it mongodb bash` (if you not change mongodb container name)
2. run `mongod` to open mongodb shell (Or you can install mongodb compass and connect to `localhost:27017` if you not change mongodb port on docker compose)

## Docker-Compose
[Docker](https://www.docker.com/)
[Docker documentation](https://docs.docker.com/)
[Docker Compose documentation](https://docs.docker.com/compose/compose-file/)
How To Use (For This Big data):
1. run `docker-compose up -d` 
