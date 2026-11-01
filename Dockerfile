FROM mcr.microsoft.com/playwright/python:v1.47.0-jammy

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/*

# В репозитории лежит один zip с проектом — распаковываем его при сборке
COPY *.zip /tmp/bundle.zip
RUN mkdir -p /tmp/src && unzip -q /tmp/bundle.zip -d /tmp/src \
    && if [ -f /tmp/src/app.py ]; then SRC=/tmp/src; else SRC="$(dirname "$(find /tmp/src -maxdepth 3 -name app.py | head -n 1)")"; fi \
    && cp -a "$SRC"/. /app/ \
    && rm -rf /tmp/src /tmp/bundle.zip

RUN pip install --no-cache-dir -r requirements.txt

ENV PORT=8080
EXPOSE 8080

CMD gunicorn -w 1 -k gthread --threads 4 --timeout 600 -b 0.0.0.0:${PORT} app:app
