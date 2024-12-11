#!/bin/bash

set -e

WP_SERVER_DEBUG=${WP_SERVER_DEBUG:-false}

if [ "${WP_SERVER_DEBUG}" = true ]; then
    set -x
fi

# Replace environment variables in the nginx configuration, and start nginx
# Setup default values for environment variables
export WP_SERVER_PORT=${WP_SERVER_PORT:-8080}
export WP_SERVER_RESOLVER=${WP_SERVER_RESOLVER:-'8.8.8.8'}

# File includes, generate `include` directives for nginx configuration for every file in WP_SERVER_PATH_INCLUDES
# The variables are comma-separated, so we need to split them into a string "include file1; include file2; ..."
WP_SERVER_PATH_INCLUDES=${WP_SERVER_PATH_INCLUDES:-}
if [ -n "$WP_SERVER_PATH_INCLUDES" ]; then
    include_directives=""
    for include_file in $(echo "$WP_SERVER_PATH_INCLUDES" | tr "," "\n"); do
        include_directives="${include_directives}include ${include_file}; "
    done

    export WP_SERVER_FILE_INCLUDES="${include_directives}"
fi

export WP_SERVER_PROXY_PASS=${WP_SERVER_PROXY_PASS:-}

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

    base64 -d <<< "$CERTIFICATE_CONTENT" > /etc/nginx/cert.crt
    dos2unix /etc/nginx/cert.crt
    echo "Wrote certificate to /etc/nginx/cert.crt"
fi

CERTIFICATE_KEY_CONTENT=${WP_SERVER_TLS_CERTIFICATE_KEY:-}
if [ -n "$CERTIFICATE_KEY_CONTENT" ]; then
    if [ "${WP_SERVER_TLS_ENABLED}" = false ]; then
        echo "TLS certificate key provided but TLS is not enabled. Please set WP_SERVER_TLS_ENABLED=true to enable TLS."
        exit 1
    fi

    base64 -d <<< "$CERTIFICATE_KEY_CONTENT" > /etc/nginx/cert.key
    dos2unix /etc/nginx/cert.key
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

# ---------

# TravelFusion
export WP_CHANNELS_TRAVELFUSION_LOGIN_ID=${WP_CHANNELS_TRAVELFUSION_LOGIN_ID:-}
export WP_CHANNELS_TRAVELFUSION_HOST=${WP_CHANNELS_TRAVELFUSION_HOST:-api.travelfusion.com}
export WP_CHANNELS_TRAVELFUSION_PROXY_PASS=${WP_CHANNELS_TRAVELFUSION_PROXY_PASS:-${WP_SERVER_PROXY_PASS:-"https://${WP_CHANNELS_TRAVELFUSION_HOST}"}}

# British Airways NDC
export WP_CHANNELS_BA_API_KEY=${WP_CHANNELS_BA_API_KEY:-}
export WP_CHANNELS_BA_MERCHANT_ID=${WP_CHANNELS_BA_MERCHANT_ID:-}
export WP_CHANNELS_BA_HOST=${WP_CHANNELS_BA_HOST:-api.ba.com}
export WP_CHANNELS_BA_PROXY_PASS=${WP_CHANNELS_BA_PROXY_PASS:-${WP_SERVER_PROXY_PASS:-"https://${WP_CHANNELS_BA_HOST}"}}

# Farelogix AA
export WP_CHANNELS_FARELOGIX_AA_HOST=${WP_CHANNELS_FARELOGIX_AA_HOST:-aa.farelogix.com}
export WP_CHANNELS_FARELOGIX_AA_PROXY_PASS=${WP_CHANNELS_FARELOGIX_AA_PROXY_PASS:-${WP_SERVER_PROXY_PASS:-"https://${WP_CHANNELS_FARELOGIX_AA_HOST}"}}
export WP_CHANNELS_FARELOGIX_AA_API_KEY=${WP_CHANNELS_FARELOGIX_AA_API_KEY:-}
export WP_CHANNELS_FARELOGIX_AA_AGENT=${WP_CHANNELS_FARELOGIX_AA_AGENT:-}
export WP_CHANNELS_FARELOGIX_AA_USERNAME=${WP_CHANNELS_FARELOGIX_AA_USERNAME:-}
export WP_CHANNELS_FARELOGIX_AA_PASSWORD=${WP_CHANNELS_FARELOGIX_AA_PASSWORD:-}
export WP_CHANNELS_FARELOGIX_AA_AGENT_USER=${WP_CHANNELS_FARELOGIX_AA_AGENT_USER:-}
export WP_CHANNELS_FARELOGIX_AA_AGENT_PASSWORD=${WP_CHANNELS_FARELOGIX_AA_AGENT_PASSWORD:-}

# Farelogix LH
export WP_CHANNELS_FARELOGIX_LH_HOST=${WP_CHANNELS_FARELOGIX_LH_HOST:-lhg.farelogix.com}
export WP_CHANNELS_FARELOGIX_LH_PROXY_PASS=${WP_CHANNELS_FARELOGIX_LH_PROXY_PASS:-${WP_SERVER_PROXY_PASS:-"https://${WP_CHANNELS_FARELOGIX_LH_HOST}"}}
export WP_CHANNELS_FARELOGIX_LH_API_KEY=${WP_CHANNELS_FARELOGIX_LH_API_KEY:-}
export WP_CHANNELS_FARELOGIX_LH_AGENT=${WP_CHANNELS_FARELOGIX_LH_AGENT:-}
export WP_CHANNELS_FARELOGIX_LH_USERNAME=${WP_CHANNELS_FARELOGIX_LH_USERNAME:-}
export WP_CHANNELS_FARELOGIX_LH_PASSWORD=${WP_CHANNELS_FARELOGIX_LH_PASSWORD:-}
export WP_CHANNELS_FARELOGIX_LH_AGENT_USER=${WP_CHANNELS_FARELOGIX_LH_AGENT_USER:-}
export WP_CHANNELS_FARELOGIX_LH_AGENT_PASSWORD=${WP_CHANNELS_FARELOGIX_LH_AGENT_PASSWORD:-}

# Farelogix UA
export WP_CHANNELS_FARELOGIX_UA_HOST=${WP_CHANNELS_FARELOGIX_UA_HOST:-ua.farelogix.com}
export WP_CHANNELS_FARELOGIX_UA_PROXY_PASS=${WP_CHANNELS_FARELOGIX_UA_PROXY_PASS:-${WP_SERVER_PROXY_PASS:-"https://${WP_CHANNELS_FARELOGIX_UA_HOST}"}}
export WP_CHANNELS_FARELOGIX_UA_API_KEY=${WP_CHANNELS_FARELOGIX_UA_API_KEY:-}
export WP_CHANNELS_FARELOGIX_UA_AGENT=${WP_CHANNELS_FARELOGIX_UA_AGENT:-}
export WP_CHANNELS_FARELOGIX_UA_USERNAME=${WP_CHANNELS_FARELOGIX_UA_USERNAME:-}
export WP_CHANNELS_FARELOGIX_UA_PASSWORD=${WP_CHANNELS_FARELOGIX_UA_PASSWORD:-}
export WP_CHANNELS_FARELOGIX_UA_AGENT_USER=${WP_CHANNELS_FARELOGIX_UA_AGENT_USER:-}
export WP_CHANNELS_FARELOGIX_UA_AGENT_PASSWORD=${WP_CHANNELS_FARELOGIX_UA_AGENT_PASSWORD:-}

# ---------

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