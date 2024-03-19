FROM docker.elastic.co/logstash/logstash:7.10.0
# Customize your Logstash setup here. For example, add your Logstash configuration files.
COPY logstash.conf /usr/share/logstash/pipeline/logstash.conf
