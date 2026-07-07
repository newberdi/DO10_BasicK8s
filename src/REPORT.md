## Basic Kubernetes

<details>
  <summary>Архитектура Kubernetes</summary>

Любой Kubernetes-кластер состоит из двух больших частей.

```
Kubernetes Cluster
├── Control Plane
└── Worker Node
```

### Control Plane

Это "мозг" Kubernetes. Он принимает команды пользователя.

Например, команда `kubectl apply -f booking-deployment.yaml` **не запускает контейнер напрямую** — она отправляется в Control Plane.

Внутри Control Plane находятся несколько компонентов.

#### API Server

Это главный компонент Kubernetes. Практически всё взаимодействие происходит через него.

Когда мы вводим команду, происходит следующее:

```
kubectl -> API Server -> обработка запроса
```

#### etcd

После получения манифеста API Server сохраняет его в базе данных Kubernetes — **etcd**.

В ней хранится абсолютно всё:
- Pod
- Secret
- ConfigMap
- Service
- Deployment
- Namespace

#### Scheduler

Scheduler решает, **на каком узле запускать Pod**. Если нод несколько, то он решает, какой выбрать.
Он анализирует:
- свободную память;
- загрузку CPU;
- ограничения (`nodeSelector`);
- `taints`;
- `affinity`.

#### Controller Manager

После выбора узла начинается контроль состояния.

Например:
```
Deployment

replicas: 1
```

Controller постоянно проверяет:
```
Есть ли Pod?
  Да.
  ↓
  Работаем дальше.
```

Если Pod исчезнет:
```
Deployment
↓
Controller
↓
Создать новый Pod
```

Т.е. Kubernetes автоматически восстанавливает приложение.

### Worker Node

После этого начинается работа непосредственно на машине, где запускаются контейнеры (у нас Minikube).

```
Worker Node
├── kubelet
├── Container Runtime
└── Pods
```

#### kubelet

Каждый Worker имеет собственный kubelet.
Он получает задачу:
```
Нужно запустить booking-service.
```

Далее kubelet:
1. скачивает образ;
2. создаёт Pod;
3. следит за его состоянием;
4. сообщает API Server результат.

#### Container Runtime

Сам kubelet контейнеры не запускает. Он обращается к Container Runtime.

Чаще всего это:
- containerd;
- Docker (через CRI, в старых конфигурациях);
- CRI-O.

Runtime выполняет:
```
docker pull
↓
создать контейнер
↓
запустить контейнер
```

#### Pod

Контейнеры Kubernetes **не запускает напрямую**. Он запускает **Pod**.

```
Pod                                              Pod
└── booking-service container                   ├── nginx
                   или                          └── sidecar
```

Pod — минимальная единица запуска.

Весь этап запуска выглядит примерно так:

```bash
kubectl apply -f booking-deployment.yaml
```

#### Шаг 1
`kubectl` читает YAML.
↓

#### Шаг 2
Отправляет его в API Server.
↓

#### Шаг 3
API Server проверяет корректность.
↓

#### Шаг 4
Сохраняет объект в etcd.
↓

#### Шаг 5
Deployment Controller замечает:
> "Нужно создать Pod."
> kubelet -> CRI (Container Runtime Interface) -> CNI (Container Network Interface) назначает уникальный IP
↓

#### Шаг 6
Scheduler выбирает Worker Node.
↓

#### Шаг 7
kubelet получает задачу.
↓

#### Шаг 8
Container Runtime скачивает образ:
```text
newberdi/do9:booking-service
```
↓

#### Шаг 9
Создается Pod.
↓

#### Шаг 10
Контейнер получает переменные окружения из `ConfigMap` и `Secret`.
↓

#### Шаг 11
Spring Boot запускается.
↓

#### Шаг 12
Pod получает статус:
```
Running
```

Дальше идут:
#### Шаг 13
CNI-плагин (Calico/Flannel/Weave) выделяет Pod'у IP из внутренней подсети кластера
↓

#### Шаг 14
Создается виртуальный сетевой интерфейс (veth pair) в пространстве имен Pod'а и на хосте
↓

#### Шаг 15
Настраиваются iptables/ipvs правила для маршрутизации
↓

***
kubectl apply -f booking-service.yaml
↓

#### Шаг 16
API Server создает Service-объект в etcd
↓

#### Шаг 17
Endpoint Controller отслеживает Pod'ы с меткой app=booking
↓

#### Шаг 18
Создается Endpoints (список IP:портов активных Pod'ов)
↓

#### Шаг 19
kube-proxy (на каждом Worker Node) получает изменения
↓

#### Шаг 20
kube-proxy обновляет iptables/ipvs правила:
        - Создает ClusterIP (виртуальный IP)
        - Настраивает балансировку на Pod'ы

Как работает сеть:

```
  [External Traffic]
         ↓
   [Ingress/LoadBalancer]  ← внешний доступ (опционально)
         ↓
   [Service: ClusterIP]    ← 10.96.0.1:8080 (стабильный адрес)
         ↓
   kube-proxy (iptables)   ← балансировка
         ↓         ↓         ↓
    [Pod A]    [Pod B]    [Pod C]
    10.244.1.5  10.244.2.3  10.244.1.8
         ↓         ↓         ↓
   [CNI: veth pairs + маршрутизация]
```

### Важные моменты

1. **Deployment** управляет **Pod'ами** (их количеством, обновлениями)
2. **Service** управляет **доступом** к Pod'ам (стабильный IP, балансировка)
3. **Сеть Pod'ов** создается CNI-плагином при запуске каждого Pod'а
4. **Сеть Service'ов** создается kube-proxy при создании Service
5. **Внутренняя сеть** (CNI) существует всегда, но динамически выделяет IP для новых Pod'ов
6. **ClusterIP Service** не запускается как процесс — это просто правила в iptables/ipvs

### Последовательность запуска для полного приложения

```bash
# Сначала ConfigMap и Secret (если есть)
kubectl apply -f booking-configmap.yaml
kubectl apply -f booking-secret.yaml

# Запускаем Deployment (создаются Pod'ы + сеть)
kubectl apply -f booking-deployment.yaml

# Создаем Service (настраивается доступ к Pod'ам)
kubectl apply -f booking-service.yaml

# Проверяем
kubectl get pods,svc,ep
```

</details>

### Part 1. Использование готового манифеста

1. Запустить окружение Kubernetes с памятью 4 GB.

Устанавливаем нужные инструменты
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check   # проверяем
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client     # проверяем
```

Запускаем миникуб

`minikube start --memory=4096`

![check](images/image_01.png)

2. Применяем манифест из директории `/src/example` к созданному окружению Kubernetes.

![start](images/image_02.png)

3. Запускаем стандартную панель управления Kubernetes с помощью команды `minikube dashboard`.

![example](images/image_03.png)

в браузере отображается
![minikube dashboard](images/image_04.png)

4. Прокидываем туннели для доступа к развернутым сервисам с помощью команды `minikube service`.

![minikube service](images/image_05.png)

Согласно [документации](https://minikube.sigs.k8s.io/docs/handbook/accessing/), minikube service возвращает URL и открывает сервис типа NodePort или LoadBalancer в браузере по умолчанию.

5. Проверяем работоспособность развернутого приложения, открыв в браузере страницу приложения (сервис apache).

![service apache](images/image_06.png)

![apache catalog](images/image_07.png)

### Part 2. Написание собственного манифеста

1. Написать собственные yml-файлы манифестов для приложения из первого проекта (`/src/services`), реализующие следующее:
    - карту конфигурации со значениями хостов БД и сервисов,

Согласно документации [Kubernetes](https://kubernetes.io/docs/concepts/configuration/configmap/), ConfigMap используется для хранения неконфиденциальных данных в парах ключ-значение.
Создадим ConfigMap для хранения хостов БД и сервисов на основе application.properties файлов

![ConfigMap](images/image_08.png)

    - секреты с паролем и логином к БД и ключами межсервисной авторизации (их можно найти в файлах `application.properties`),

![secrets](images/image_09.png)

    - поды и сервисы для всех модулей приложения: postgres, rabbitmq и 7 сервисов приложения. Для всех сервисов нужно использовать единственную реплику.

postgres, rabbitmq
![postgres rabbitmq](images/image_10.png)

7 сервисов приложения

![7 services](images/image_11.png)

2. Запустим приложение путем последовательного применения манифестов командой `kubectl apply -f <манифест>.yaml`.
```bash
kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/secrets.yml
kubectl apply -f k8s/rabbitmq/rabbitmq-deployment.yml
bash k8s/postgres/generate-init.sh # генерируем postgres-init-configmap.yml
kubectl apply -f k8s/postgres/postgres-init-configmap.yml
kubectl apply -f k8s/postgres/postgres-deployment.yml
kubectl apply -f k8s/services/services-deployment.yml
kubectl apply -f k8s/services/services-network.yml
kubectl apply -f k8s/services/gateway-session-service.yml

# вспомогательные
kubectl get pods -n devops-app
kubectl wait --for=condition=ready pod -l app=postgres -n devops-app --timeout=120s
```
![apply manifests](images/image_12.png)

3. Проверим статус созданных объектов (секреты, конфигурационная карта, поды и сервисы) в кластере с помощью команд `kubectl get <тип_объекта> <имя_объекта>` и `kubectl describe <тип_объекта> <имя_объекта>`. Результат отобразить в отчете.

```bash
kubectl get pod session-service-567c4b645c-dj6lz -n devops-app # прямое указание пода
kubectl get pod -l app=session-service -n devops-app # через фильтр по меткам (label selector)
```

секреты
![get describe secrets](images/image_13.png)

configmap
![get describe configmap](images/image_14.png)

сервис
![describe session-service](images/image_15.png)

под
![kubectl get pod](images/image_16.png)

4. Проверяем наличие правильных значений секретов, применив команду `kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 --decode` для декодирования секрета.

![kubectl get secret](images/image_17.png)

5. Проверяем логи приложения, запущенного в кластере, командой `kubectl logs <имя_контейнера>`.

![kubectl logs](images/image_18.png)

6. Прокидываем туннели для доступа к gateway service и session service.

можно через:
```bash
minikube service gateway-service-external -n devops-app &
minikube service session-service-external -n devops-app &
```

- Дает доступ через NodePort (например, localhost:30817)  
- Требует сервис типа NodePort или LoadBalancer  
- Открывает браузер автоматически  
- придется менять путь для Postman тестов  

или
```bash
kubectl port-forward service/gateway-service -n devops-app 8087:8087 &
kubectl port-forward service/session-service -n devops-app 8081:8081 &
```

- Дает доступ через напрямую указанный порт (localhost:8087)  
- Работает с любым типом сервиса (ClusterIP, NodePort, LoadBalancer)  
- Не открывает браузер  

![port localhost](images/image_19.png)

7. Запускаем функциональные тесты Postman и удостовериться в работоспособности приложения.

![Postman tests](images/image_20.png)

8. Запустили стандартную панель управления Kubernetes с помощью команды `minikube dashboard`.

Смотрим текущее состояние узлов кластера, загрузку ЦП и память
![nodes dashboard](images/image_21.png)

список запущенных Pod
![pod dashboard](images/image_22.png)

логи Pod
![logs dashboard](images/image_23.png)

конфигурации
![configmap dashboard](images/image_24.png)

секреты
![secrets dashboard](images/image_25.png)

9. Обновляем приложение, изменив образ из registry на вариант из do7 (без метрик micrometer), и пересобираем его со следующими стратегиями развертывания (+ замеряем время переразвертывания приложения для каждого случая):

    - пересоздание (recreate),
    - последовательное обновление (rolling).

![strategy manifests](images/image_26.png)

recreate
![recreate](images/image_27.png)

Для чистоты эксперимента сначала удаляем выбранный сервис, очищаем minikube от остатков и запускаем

![delete](images/image_28.png)

rolling
![rolling](images/image_29.png)

#### Recreate:
1. Останавливает старый под (SIGTERM)
2. Ждет его полной остановки (terminationGracePeriodSeconds — 30 сек по умолчанию)
3. Удаляет старый под
4. Создает новый под
5. Запускает новый под
6. Ждет readiness пробы

#### Rolling Update:
1. Сразу создает новый под (параллельно с работой старого)
2. Как только новый готов — удаляет старый
3. Не ждет полной остановки старого перед созданием нового


### Part 3. Настройка Jenkins pipeline (для себя)

Пишем манифест для Jenkins. Из важного - установка git и kubectl
![jenkins manifest](images/image_30.png)

Пишем Jenkinsfile c правильными путями
![Jenkinsfile](images/image_31.png)

Запускаем манифест
```bash
kubectl apply -f jenkins-deployment.yml  
kubectl wait --for=condition=ready pod -l app=jenkins -n jenkins --timeout=120s  
kubectl exec -it deployment/jenkins -n jenkins -- bash -c "
        mkdir -p /var/jenkins_home/init.groovy.d
        cat > /var/jenkins_home/init.groovy.d/admin.groovy << 'EOF'
        import jenkins.model.*
        import hudson.security.*
        
        def instance = Jenkins.getInstance()
        def hudsonRealm = new HudsonPrivateSecurityRealm(false)
        hudsonRealm.createAccount('admin', 'zadolbal')
        instance.setSecurityRealm(hudsonRealm)
        def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
        instance.setAuthorizationStrategy(strategy)
        instance.save()
        EOF
        "
kubectl rollout restart deployment/jenkins -n jenkins  
minikube service jenkins -n jenkins --url
```
![apply jenkins](images/image_32.png)

Пересоздаем логин/пароль (потому что PVC с неудачных попыток сохранился и лень было заново настраивать пайплайны и настройки)
![admin new](images/image_33.png)

Дальше последовательность действий такая:
1. вводим пароль (если норм запустили, а если пересоздавали, то обычная авторизация с логин/пароль)
2. устанавливаем нужные плагины: git, Pipeline, Kubernetes CLI
3. создаем новый пайплайн: New Item -> вводим название -> Выбираем тип (Pipeline) -> OK
4. настраиваем для Github: Pipeline Definition -> Pipeline script from SCM
                                                  SCM -> Git
                                                  Repository URL: путь к репозиторию
                                                  Branch: */develop
                                                  Script Path: Jenkinsfile -> OK

5. запускаем через Build now

видим пайплайн
![main page](images/image_34.png)

меню пайплайна
![pipeline menu](images/image_35.png)

добавились тесты
![postman](images/image_36.png)

вывод консоли
![pipeline menu](images/image_37.png)
