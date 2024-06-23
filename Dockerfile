FROM openresty/openresty:1.25.3.1-4-focal

RUN apt-get update && apt-get install -y \
    apache2-utils \
    && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/nginx.conf.template

WORKDIR /
COPY start.sh /

STOPSIGNAL SIGTERM

CMD ["sh", "/start.sh"]
