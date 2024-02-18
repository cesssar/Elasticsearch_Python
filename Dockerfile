FROM python

WORKDIR /app

COPY robo.py /app/

COPY requirements.txt /app/

RUN pip install -r requirements.txt

# INSTALA CERTIFICADO DO ELASTICSEARCH
# COPY http_ca.crt /usr/local/share/ca-certificates
# RUN update-ca-certificates

# INSTALA FILEBEAT PARA ENVIAR LOGS DO ROBÔ PARA O ELASTICSEARCH
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - 
RUN apt-get install apt-transport-https
RUN echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-8.x.list
RUN apt-get update
RUN apt-get install filebeat
COPY filebeat.yml /etc/filebeat/filebeat.yml
RUN chmod go-w /etc/filebeat/filebeat.yml
RUN update-rc.d filebeat defaults 95 10
RUN filebeat setup -e

# INICIA SERVIÇO FILEBEAT
RUN apt install systemctl
RUN systemctl enable filebeat

CMD ["python", "robo.py"]