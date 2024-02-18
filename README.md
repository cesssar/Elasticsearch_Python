# Monitorando logs de app Python com Elasticsearch e Kibana

> Utiliza Docker para executar servidor Elasticsearch e Kibana a fim de monitorar logs de aplicação Python através do Filebeat

<img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" /> <img src="https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white" /> <img src="https://img.shields.io/badge/-ElasticSearch-005571?style=for-the-badge&logo=elasticsearch" />

<img src="https://github.com/cesssar/Elasticsearch_Python/blob/main/Screenshot.png" />

### Estrutura

- Contâiner app Python: salva logs em arquivo JSON
- Contâiner Filebeat: copia os logs e salva no Elasticsearch
- Contâiner Elasticsearch: servidor que processa, armazena e disponibiliza dados em JSON
- Contâiner Kibana: provẽ a interface web com visualizações dos dados salvos no Elasticsearch


### Pré-requisitos

- Docker 


### Elasticsearch

Executar os comandos abaixo para criar o servidor Elasticsearch

```
docker network create elastic
docker pull docker.elastic.co/elasticsearch/elasticsearch:8.12.1
docker run -d --name es01 --net elastic -p 9200:9200 -v ./esdata:/usr/share/elasticsearch/data -v ./eslog:/usr/share/elasticsearch/logs -it -m 2GB docker.elastic.co/elasticsearch/elasticsearch:8.12.1
```

Se houver falha ao carregar, alterar tamanho máximo de VM (comando para Linux)

```
sudo sysctl -w vm.max_map_count=262144
```


### Gerar senha e token

Gerar senha para usuário elastic

```
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
```

Gerar token Kibana

```
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```


### Configurar arquivo filebeat.yml

Editar o arquivo filebeat.yml com o IP da máquina que está executando os containers Docker. Linhas abaixo em destaque onde deve-se trocar o IP.

...
host: "10.0.0.113:5601"
...
output.elasticsearch:
  hosts: ["10.0.0.113:9200"]

Na linha password alterar para a senha gerada na etapa "Gerar senha e token"

...
password: "6sLjmJle2ISmPhAdw8qZ"


### Kibana

Executar os seguintes comandos para executar o Kibana no Docker

```
docker pull docker.elastic.co/kibana/kibana:8.12.1
docker run -d --name kib01 --net elastic -v ./kibana_data:/usr/share/kibana/data -p 5601:5601 docker.elastic.co/kibana/kibana:8.12.1
```

Ao executar será gerado um link para acessar a configuração do Kibana. Acessar o link, a tela irá pedir o token de acesso gerado na etapa anterior.


### Executar o aplicativo Python

Executar o comando abaixo para construir a imagem com o aplicativo:

```
docker-compose build 
```

O comando abaixo irá subir um container a partir da imagem gerada acima para o aplicativo Python e um container para o Filebeat

```
docker-compose up -d
```


### Configurar um dashboard com visualização dos logs 

Acessar o site http://0.0.0.0:5601 com login elastic e a senha gerada na etapa "Gerando senha e token".

Passos:

- menu Analytics -> Dashboard
- clicar no botão "Create dashboard"
- clicar no botão "Create visualization"
- no lado direito selecionar filebeat-*
- no lado esquerdo pesquisar por @timestamp e arrastar este item para o centro da tela
- ainda no lado esquerdo pesquisar por log.level e arrastar para o centro da tela
- no lado direito configurar o Breakdown para 4 no campo Number of values
- no lado direiteo superior (ao lado ícone calendário) selecionar um intervalo de tempo para visualização (como por exemplo últimos 15 minutos)
- clicar no botão Save and return
- clicar no botão Save e definiar um nome para o dashboard

A visualização criada exibirá um gráfico de barras com quantidade de logs por nível (informativo, aviso, erro e crítico).





### Referências

[https://www.elastic.co/guide/en/cloud-enterprise/current/ece-getting-started-search-use-cases-python-logs.html]
[https://www.elastic.co/guide/en/beats/filebeat/8.12/setup-repositories.html#_apt]
