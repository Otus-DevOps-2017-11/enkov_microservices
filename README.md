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

### Homework 16

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

### Homework 17

Изучение сетей и docker-compose

При запуске```docker run --network host -d nginx``` будет запущен одни контейнер,
т.к. используется host сеть и порт 80 может занять только одно приложение

----

Повторите запуски контейнеров с использованием драйверов
none и host и посмотрите, как меняется список namespace-ов

Если запускать контейнер с драйвером none, то создается новый namespace,
а если запускать с драйвером host то namespace не создается

----

Создаем 2 сети. Запускаем контейнеры и добавляем их с сеть.

```bash
docker network create back_net --subnet=10.0.2.0/24
docker network create front_net --subnet=10.0.1.0/24

docker run -d --network=front_net -p 9292:9292 --name ui  aardvarkx1/ui:1.0
docker run -d --network=back_net --name comment  aardvarkx1/comment:1.0
docker run -d --network=back_net --name post  aardvarkx1/post:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest

docker network connect front_net post
docker network connect front_net comment
```

----

Имя проекта в docker-compose можно задать с помощью флага ```-p``` или установив переменную окружения ```COMPOSE_PROJECT_NAME```

### Homework 19

Создаем директории для gitlab.

```bash
mkdir -p /home/user/test/gitlab/config /home/user/test/gitlab/data /home/user/test/gitlab/logs
```

Запускаем gitlab

```bash
docker-compose up -d
```

Запускаем gitlab-runner

```bash
docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```

Регистрируем gitlab-runner

```bash
docker exec -it gitlab-runner gitlab-runner register
```

Клонируем тестовое приложение

```bash
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
git add reddit/
git commit -m 'Add reddit app'
git push gitlab docker-6
```

Задания со звезвочкой

Автоматизаци развертывания

Можно сделать playbook для ansible для автоматического развертывания gitlab-runner

Можно использовать [runners autoscale configuration](https://docs.gitlab.com/runner/configuration/autoscale.html)

Интеграция со slack была настроена по [мануалу](https://gitlab.com/help/user/project/integrations/slack.md)
