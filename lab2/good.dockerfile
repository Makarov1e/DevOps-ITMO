FROM ubuntu:20.04

RUN apt-get update && apt-get install -y python3 python3-pip \
    && pip3 install flask \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY . /app
WORKDIR /app

CMD ["python3", "app.py"]
