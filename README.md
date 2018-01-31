### Homework 14

Был установлен docker, настроена возможность docker без sudo.

Изучены основные команды для работы с docker.


### Homework 15

Установка и использование docker-machine

С помощью docker-machine была создана ВМ с докер в GCP

```bash
docker-machine create --driver google \
 --google-project docker-193413 \
 --google-zone europe-west1-b \
 --google-machine-type g1-small \
 --google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
 docker-host
```

Был создан докер образ с приложением

```bash
docker build -t reddit:latest .
```


Запущено приложение

```bash
docker run --name reddit -d --network=host reddit:latest
```

Открыт файрвол для приложения

```bash
docker run --name reddit -d --network=host reddit:latest
```

Образ протегирован и залит в докер хаб

```bash
docker tag reddit:latest aardvarkx1/otus-reddit:1.0
docker push aardvarkx1/otus-reddit:1.0
```
