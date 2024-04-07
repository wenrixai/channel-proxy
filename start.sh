#!/bin/bash

set -e

DEBUG=${WP_SERVER_DEBUG:-false}

# Replace environment variables in the nginx configuration, and start nginx
# Setup default values for environment variables
export WP_SERVER_PORT=${WP_SERVER_PORT:-8080}
export WP_SERVER_RESOLVER=${WP_SERVER_RESOLVER:-'8.8.8.8'}

# Create htpasswd file
export WP_SERVER_HTTP_USER=${WP_SERVER_HTTP_USER:-}
export WP_SERVER_HTTP_PASS=${WP_SERVER_HTTP_PASS:-}

if [ -n "$WP_SERVER_HTTP_USER" ] && [ -n "$WP_SERVER_HTTP_PASS" ]; then
    htpasswd -c -b /etc/nginx/.htpasswd "${WP_SERVER_HTTP_USER}" "${WP_SERVER_HTTP_PASS}"
    chmod 644 /etc/nginx/.htpasswd

    export WP_SERVER_BASIC_AUTH="Restricted"
else
    export WP_SERVER_BASIC_AUTH="off"
fi

# TravelFusion
export WP_CHANNELS_TRAVELFUSION_LOGIN_ID=${WP_CHANNELS_TRAVELFUSION_LOGIN_ID:-}
export WP_CHANNELS_TRAVELFUSION_HOST=${WP_CHANNELS_TRAVELFUSION_HOST:-api.travelfusion.com}

# British Airways NDC
export WP_CHANNELS_BA_API_KEY=${WP_CHANNELS_BA_API_KEY:-}
export WP_CHANNELS_BA_MERCHANT_ID=${WP_CHANNELS_BA_MERCHANT_ID:-}
export WP_CHANNELS_BA_HOST=${WP_CHANNELS_BA_HOST:-api.ba.com}

# Replace environment variables in the nginx configuration
export DOLLAR='$' # Escape $ for envsubst
envsubst < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

printf "Starting nginx"

if [ "${DEBUG}" = true ]; then
    printf " in debug mode\n"
    cat /etc/nginx/nginx.conf
fi

# Start nginx
exec nginx -c /etc/nginx/nginx.conf
