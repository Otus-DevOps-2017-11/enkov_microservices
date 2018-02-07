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

### Homework 15

Создание докер образов.

Собираем образы

```bash
docker build -t aardvarkx1/post:1.0 ./post-py
docker build -t aardvarkx1/comment:1.0 ./comment
docker build --no-cache -t aardvarkx1/ui:1.0 ./ui
```

Создаем сеть

```bash
docker network create reddit
```

Запускаем контейнеры

```bash
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post aardvarkx1/post:1.0
docker run -d --network=reddit --network-alias=comment aardvarkx1/comment:1.0
docker run -d --network=reddit -p 9292:9292 aardvarkx1/ui:1.0
```

Задание со звездочкой 1

Использование переменных окружения
Для того чтобы передать в контейнер переменную окружения можно воспользоваться опцией ```-e```

```bash
docker run -d --network=reddit --network-alias=posta_db --network-alias=commenta_db mongo:latest
docker run -d -e POST_DATABASE_HOST=posta_db --network=reddit --network-alias=posta aardvarkx1/post:1.0
docker run -d -e COMMENT_DATABASE_HOST=commenta_db --network=reddit --network-alias=commenta aardvarkx1/comment:1.0
docker run -d -e POST_SERVICE_HOST=posta -e COMMENT_SERVICE_HOST=commenta --network=reddit -p 9292:9292 aardvarkx1/ui:1.0
```

Использование docker volume для сохранения данные при уничтожении контейнеров

```bash
docker volume create reddit_db

docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post aardvarkx1/post:1.0
docker run -d --network=reddit --network-alias=comment aardvarkx1/comment:1.0
docker run -d --network=reddit -p 9292:9292 aardvarkx1/ui:2.0
```
