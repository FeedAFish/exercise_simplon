FROM python:3.13.3-slim

RUN apt-get update && apt-get install -y postgresql-client

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir -r requirements.txt