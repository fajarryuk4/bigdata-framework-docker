FROM mataelang/snorqttalpine-sensor:latest

ARG OINKCODE
COPY conf/pulledpork-registered.conf /etc/snort/pulledpork.conf

# Setting up rules
RUN sed -i 's@.oinkcode.@'"${OINKCODE}"'@' /etc/snort/pulledpork.conf && \
  /usr/local/bin/pulledpork.pl -c /etc/snort/pulledpork.conf -l && \
  rm -rf /tmp/snort/* && \
  sed -i 's@^\(\/usr\/local\/bin\/pulledpork\.pl .*\)@# \1@' /root/startup.sh && \
  sed -i 's@^\(rm \-rf .*\)@# \1@' /root/startup.sh