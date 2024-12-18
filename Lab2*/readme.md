# Отчёт по лабораторной работе  2*

## Команда "Буцефалы"


### Плохой docker-compose-bad.yml

```
services:
  app:
    image: myapp:latest
    environment:
      - SECRET_KEY=mysecretkey
    ports:
      - "8080:80"
  db:
    image: postgres:latest
    environment:
      - POSTGRES_PASSWORD=supersecret
    volumes:
      - ./some_nonexistent_dir:/var/lib/postgresql/data
```

### Хороший docker-compose-good.yml

```
version: "3.9"
services:
  app:
    image: myapp:1.2.3
    env_file:
      - .env
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: '256M'
    network_mode: none

  db:
    image: postgres:14.5
    env_file:
      - .env
    volumes:
      - db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $POSTGRES_USER"]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 10s
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: '512M'
    network_mode: none

volumes:
  db_data:

```

# Проблемы

1. Отсутствует версия docker-compose файла.
2. Использование latest тегов для образов.
3. Хранение чувствительных данных (пароли, секреты) прямо в docker-compose.
4. Нет ограничений по ресурсам.



# Объяснение и решение проблем

1. Использование `latest` версии может привести к неожиданному поведению контейнера и непредвиденным конфликтам, так как в последних версиях могут создаваться конфликты на фоне неподдерживаемых файлов. Решением стало использование конкретной версии.

2. Не указан драйвер сети. В `docker-compose-good` мы его добавили, и это позволяет нам оптимизировать производительность и безопасность сети в зависимости от наших требований.

3. Хранение чувствительных данных прямо в docker-compose.
Пароли, ключи в docker-compose могут попасть в репозиторий и быть украдены, поэтому мы добавили env_file: .env, вынесли секретную инфу в отдельный файл.

4. Добавление `container-name` упрощает управление контейнерами, так как обращаться к ним по понятным именам легче, чем по автоматически созданным docker.


### Изоляция контейнеров 

После исправления плохих практик в “хорошем” docker-compose.yml было настроено, чтобы контейнеры поднимались вместе, но не видели друг друга по сети. Это сделано с помощью указания `network_mode: none` для каждого сервиса. Таким образом, каждый контейнер запускается без сетевого интерфейса внутри общей сети проекта и не может обращаться к соседям.

# Вывод

Поработали с docker-compose, на самом деле bad practiсes довольно не мало и можно поискать и добавить еще что-то, но так как тз этого не требует, то решили ограничиться 3-4. Лабораторная понравилась <3