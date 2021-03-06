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

### Homework 21

Создаем правила файрвола

```bash
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
```

Запускаем виртуальную машину с docker c помощью docker-machine

```bash
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    vm1
```

Настраиваем переменные окружения для работы с докером на удаленном хосте

```bash
eval $(docker-machine env vm1)
```

Запускаем контейнер с prometheus

```bash
docker run --rm -p 9090:9090 -d --name prometheus  prom/prometheus
```

Собираем все образа приложения

```bash
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
```

Запускаем приложение и мониторинг

```bash
docker-compose up -d
```

Проверяем что все работает.

Останавливаем контейнер post для проверки что мониторинг работает правильно

```bash
docker-compose stop post
```

Запускаем контейнер обратно

```bash
docker-compose start post
```

Задание со звездочкой 1

Мониторинг mongodb

Для мониторинга mongodb был выбран экспортер от percona. Подготовлен докер файл для сборки контейнера.
Параметры для подключения к базе задаются через переменную окружения, указанную в docker-compose

```bash
environment:
  MONGODB_URL: 'mongodb://post_db:27017'
```

Задание со звездочкой 2

Мониторинг приложения с помощьб blackbox-exporter

Подготовлен докер файл для сборки контейнера.

Для того чтобы экспортер работал правильно необходимо правильно его настроить в prometheus.yml

```bash
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - http://comment:9292/healthcheck
        - http://post:5000/healthcheck
        - http://ui:9292/healthcheck
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox-exporter:9115
```

где в ```replacement: blackbox-exporter:9115``` нужно указать адрес экспортера, а в ```targets``` url, которые нужно мониторить

Задание со звездочкой 3

Был написал Makefile, который может собрать все контейнеры для мониторинга, а так же залить из в докер хаб.

Если в консоли набрать ```make```, то будет выведена справка с возможными аргументами для make.

### Homework 23

Ссылка на [докер хаб](https://hub.docker.com/u/aardvarkx1/)

Создадим правила файрвола

```bash
gcloud compute firewall-rules create cadvisor-default --allow tcp:8080
gcloud compute firewall-rules create grafana-default --allow tcp:3000
gcloud compute firewall-rules create alertmanager-default --allow tcp:9093
```

Разделим docker-compose файл на 2. Один для приложения второй для мониторинга.

В мониторинг добавим alertmanager, grafana, cadvisor.

Задние со звездочной 1

В Makefile были добавлены новые сервисы

Задние со звездочной 2

Для того чтобы собирать метрики с докера нужно включить экспорт метрик в докер демоне

```bash
{
  "metrics-addr" : "0.0.0.0:9323",
  "experimental" : true
}
```
И добавить в конфиг prometheus сбор метрик с докера

```bash
- job_name: 'docker'
  static_configs:
    - targets:
      - '10.128.0.2:9323'
```

Адрес для сбора метрик - приватный ip виртуальной машины, т.к. prometheus запущен в контейнере.

Задние со звездочной 3

В конфиг алертинга для prometheus были добалены алерты:

- Алерт на 95 перцинтиль времени ответа UI
- Алерт на сободное место на диске
- Алерт на свободную ОЗУ

Задние со звездочной 4

Для настройки одновременной отправки алертов в слак и на почту нужно сделать объединенный receiver

```bash
receivers:
- name: 'slack_email'
  slack_configs:
  - channel: '#petr-enkov'
  email_configs:
  - to: 'someone@example.com'

```

Задание с двумя звездочками 1

Для того чтобы grafana брала конфигураци из фалов нужно в docker-compose примонтировать эти файлы:

```bash
volumes:
  - /tmp/prometheus.yaml:/etc/grafana/provisioning/datasources/prometheus.yaml
  - /tmp/dashboards.yaml:/etc/grafana/provisioning/dashboards/dashboards.yaml
  - /tmp/dashboards/:/tmp/dashboards/
```

В файлах дашбордов нужно поменять источник на тот, который указан в создании источника

```bash
"datasource": "Prometheus_t"
```

Задание с двумя звездочками 2

Для сбора метрик со Stackdriver был использован stackdriver_exporter.
Для того чтобы stackdriver_exporter мог собирать метрики нужно создать IAM роль для чтения метрик и предать файл в контейнр

```bash
stackdriver_exporter:
  image: frodenas/stackdriver-exporter
  volumes:
    - /tmp/docker-30b712ea8f7d.json:/tmp/docker-30b712ea8f7d.json
  command:
    - '--google.project-id=docker-193413'
    - '--monitoring.metrics-type-prefixes=compute.googleapis.com/instance/cpu,compute.googleapis.com/instance/disk'
  environment:
    - GOOGLE_APPLICATION_CREDENTIALS=/tmp/docker-30b712ea8f7d.json
  ports:
    - 9255:9255
```

Удалось собрать метрики по загрузке диска, процессора.


### Homework 25

Развертывание логирования для приложения

### Homework 26

Создаем машины

```bash
docker-machine create --driver google \
   --google-project docker-193413  \
   --google-zone europe-west1-b \
   --google-machine-type g1-small \
   --google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
   master-1

docker-machine create --driver google \
   --google-project docker-193413  \
   --google-zone europe-west1-b \
   --google-machine-type g1-small \
   --google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
   node-1

docker-machine create --driver google \
   --google-project docker-193413  \
   --google-zone europe-west1-b \
   --google-machine-type g1-small \
   --google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
   node-2
```

Инициализируем кластер

```bash
docker-machine ssh master-1
docker swarm init
```

Добавляем ноды в кластер

```bash
docker swarm join --token SWMTKN-1-447nkoml9kyd89l5bbqbsbjoi5z8cd20ot3gwucr9racdwo6ep-51op5m9143u1wbfj64eryswz9 10.132.0.2:2377
```

Смотрим что все ноды добавлены

```bash
docker node ls
```

Деплоим приложение

```bash
docker stack deploy --compose-file=<(docker-compose -f docker-compose.yml config 2>/dev/null) DEV
```

Для управления количеством реплик в ручную используем команду

```bash
docker service update --replicas 3 DEV_ui
```

Задание со *

При добавлении новой ноды сервисы начинают стартовать на ней т.к. она меньше всех загружена

Задание со ***

Для выбора необходимого файла с переменными окружения нужно добавить в докер композ

```bash
    env_file:
      - .env
```
и создать файлы переменных

- env_DEV
- env_STAGING
- env_PROD

### Homework 28

Изучение основ kubernetes.

Был развернут kubernetes кластер по мануалу kubernetes The Hard way

### Homework 29

Развертывание и спользование kubernetes с помощью minikube и GCP.

```bash
minikube start
```

```bash
kubectl get nodes
```

```bash
kubectl config current-context
```

```bash
kubectl config get-contexts
```

```bash
kubectl apply -f ui-deployment.yml
```

```bash
kubectl get deployment
```

```bash
kubectl get pods --selector component=ui
```

```bash
kubectl port-forward ui-766b67bd46-lv2kg 8181:9292
```

```bash
kubectl port-forward post-57968fff8d-2lsjs 8181:5000
```

```bash
kubectl port-forward comment-688db68cbd-t2hz4 8181:9292
```

```bash
kubectl describe service post | grep Endpoints
```

```bash
kubectl exec -ti comment-688db68cbd-t2hz4 ping -c 1 post
```

```bash
kubectl port-forward ui-766b67bd46-lv2kg 9292:9292
```

```bash
kubectl logs comment-65c46f9cd-ts7js
```

```bash
kubectl delete -f mongodb-service.yml
```

```bash
minikube service ui
```

```bash
minikube service list
```

```bash
minikube addons list
```

```bash
minikube addons enable dashboard
```

```bash
kubectl get all  -n kube-system --selector app=kubernetes-dashboard
```

```bash
minikube service kubernetes-dashboard -n kube-system
```

Задание со звездочкой

Развертываение kubernetes с помощью терраформ

Все конфиг файлы для терраформ лежат в папке kubernetes/terraform

YAML-манифесты для dashboard:

- dashboard_clusterrolebinding.yml
- dashboard_deployment.yml


### Homework 30

Изучение сетей и хранилищ в kubernetes

Создание ingress

```bash
kubectl apply -f ui-ingress.yml -n dev
```

Получаем список доступных ingress

```bash
kubectl get ingress -n dev
```

Создаем ssl сертификаты и загружаем их в kubernetes

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=35.186.236.198"

kubectl create secret tls ui-ingress --key tls.key --cert tls.crt -n dev

kubectl describe secret ui-ingress -n dev
```

Так же загрузить секреты можно с помощью созданного манифеста

```bash
kubectl apply -f ui-secret.yml -n dev
```

После применения правила, которое разрешает использовать https, http остался рабочим.
Пришлось пересоздать ingress.

```bash
kubectl delete ingress ui -n dev

kubectl apply -f ui-ingress.yml -n dev
```

Включаем поддержку network policy

```bash
gcloud beta container clusters list
gcloud beta container clusters update test-cluster1 --zone=europe-west1-b --update-addons=NetworkPolicy=ENABLED
gcloud beta container clusters update test-cluster1 --zone=europe-west1-b  --enable-network-policy
```

Создаем диск

```bash
gcloud compute disks create --size=25GB --zone=europe-west1-b reddit-mongo-disk
```

Создаем persisten volume

```bash
kubectl apply -f mongo-volume.yml -n dev
```

Создаем PersistentVolumeClaim

```bash
kubectl apply -f mongo-claim.yml -n dev
```

Создаем StorageClass и dynamic claim

```bash
kubectl apply -f mongo-deployment.yml -n dev

kubectl apply -f storage-fast.yml -n dev

kubectl apply -f mongo-claim-dynamic.yml -n dev
```

Пересоздаем деплоймент mongo

```bash
kubectl delete deploy mongo -n dev

kubectl apply -f mongo-deployment.yml -n dev
```

Смотрим какие persistentvolume есть

```bash
kubectl get persistentvolume -n dev
```

### Homework 31

CI/CD в Kubernetes

Установка helm

```bash
kubectl apply -f tiller.yml
helm init --service-account tiller
```

Запуск приложения через helm

```bash
helm install --name test-ui-1 ui/
```

Поиск готовых пакетом для helm

```bash
helm search mongo
```

Установка gitlab

```bash
helm repo add gitlab https://charts.gitlab.io
helm fetch gitlab/gitlab-omnibus --version 0.1.36 --untar
helm install --name gitlab . -f values.yaml
```

### Homework 32

Мониторинг и логирование в kubernetes

Установка nginx-ingress

```bash
helm install stable/nginx-ingress --name nginx
```

Развертывание мониторинга

```bash
helm upgrade prom . -f custom_values.yml --install
```

Проверка что метрики экспортируются

```bash
gcloud compute --project "docker-193413" ssh --zone "europe-west2-b" "gke-cluster-1-default-pool-93864766-fqd4"
curl http://localhost:4194/metrics
```

Установка grafana

```bash
helm upgrade --install grafana stable/grafana --set "server.adminPassword=admin" \
--set "server.service.type=NodePort" \
--set "server.ingress.enabled=true" \
--set "server.ingress.hosts={reddit-grafana}"
```

Установка efk

```bash
kubectl label node  gke-cluster-1-default-pool-93864766-fqd4 elastichost=true

kubectl apply -f ./efk

helm upgrade --install kibana stable/kibana \
--set "ingress.enabled=true" \
--set "ingress.hosts={reddit-kibana}" \
--set "env.ELASTICSEARCH_URL=http://elasticsearch-logging:9200" \
--version 0.1.1
```
