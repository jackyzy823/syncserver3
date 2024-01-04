#!/bin/sh

cd $(dirname $0)
case "$1" in
    server)
        export SYNCSERVER_SQLURI="${SYNCSERVER_SQLURI:-sqlite://}"
        exec gunicorn \
            --bind ${HOST-0.0.0.0}:${PORT-5000} \
            --forwarded-allow-ips="${SYNCSERVER_FORWARDED_ALLOW_IPS:-127.0.0.1,172.17.0.1}" \
            syncserver.wsgi_app
        ;;

    *)
        echo "Unknown CMD, $1"
        exit 1
        ;;
esac
