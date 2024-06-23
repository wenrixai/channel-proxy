#!/bin/bash

set -e

WP_SERVER_DEBUG=${WP_SERVER_DEBUG:-false}

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

# TLS
CERTIFICATE_CONTENT=${WP_SERVER_TLS_CERTIFICATE:-}
if [ -n "$CERTIFICATE_CONTENT" ]; then
    if [ "${WP_SERVER_TLS_ENABLED}" = false ]; then
        echo "TLS certificate provided but TLS is not enabled. Please set WP_SERVER_TLS_ENABLED=true to enable TLS."
        exit 1
    fi

    echo "$CERTIFICATE_CONTENT" > /etc/nginx/cert.crt
    echo "Wrote certificate to /etc/nginx/cert.crt"
fi

CERTIFICATE_KEY_CONTENT=${WP_SERVER_TLS_CERTIFICATE_KEY:-}
if [ -n "$CERTIFICATE_KEY_CONTENT" ]; then
    if [ "${WP_SERVER_TLS_ENABLED}" = false ]; then
        echo "TLS certificate key provided but TLS is not enabled. Please set WP_SERVER_TLS_ENABLED=true to enable TLS."
        exit 1
    fi

    echo "$CERTIFICATE_KEY_CONTENT" > /etc/nginx/cert.key
    echo "Wrote certificate key to /etc/nginx/cert.key"
fi

WP_SERVER_TLS_ENABLED=${WP_SERVER_TLS_ENABLED:-false}


# TLS certificates, write them to files if provided. If TLS is enabled, the certificates are required and must be provided (exit if not)
if [ "${WP_SERVER_TLS_ENABLED}" = true ]; then
    if [ -z "$WP_SERVER_TLS_CERTIFICATE" ]; then
        echo "TLS enabled but no certificate provided. Please set WP_SERVER_TLS_CERTIFICATE to the content of the certificate file."
        exit 1
    fi

    if [ -z "$WP_SERVER_TLS_CERTIFICATE_KEY" ]; then
        echo "TLS enabled but no certificate key provided. Please set WP_SERVER_TLS_CERTIFICATE_KEY to the content of the certificate key file."
        exit 1
    fi

    WP_SERVER_TLS_PORT=${WP_SERVER_TLS_PORT:-18443}
    WP_SERVER_TLS_SERVER_NAME=${WP_SERVER_TLS_SERVER_NAME:-}

    ssl_directives="listen ${WP_SERVER_TLS_PORT} ssl;"
    ssl_directives="${ssl_directives}  server_name ${WP_SERVER_TLS_SERVER_NAME};"
    ssl_directives="${ssl_directives}  ssl_certificate /etc/nginx/cert.crt;"
    ssl_directives="${ssl_directives}  ssl_certificate_key /etc/nginx/cert.key;"
    ssl_directives="${ssl_directives}  ssl_protocols TLSv1.2 TLSv1.3;"

    export WP_SERVER_TLS_DIRECTIVES="${ssl_directives}"
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

if [ "${WP_SERVER_DEBUG}" = true ]; then
    printf " in debug mode\n"
    cat /etc/nginx/nginx.conf
fi

# Start nginx
exec nginx -c /etc/nginx/nginx.conf
