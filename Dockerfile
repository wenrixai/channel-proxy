FROM openresty/openresty:1.25.3.1-4-focal

RUN apt-get update && apt-get install -y \
    apache2-utils \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/nginx.conf.template

WORKDIR /
COPY start.sh /
COPY travelfusion.lua /

STOPSIGNAL SIGTERM

CMD ["bash", "-x", "/start.sh"]
