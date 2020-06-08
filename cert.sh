#!/bin/sh
set -e

case "$1" in
    generate)
        openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -extensions v3_ca -keyout squid-ca-key.pem -out squid-ca-cert.pem ;
        cat squid-ca-cert.pem squid-ca-key.pem > squid-ca-cert-key.pem ;
        chmod 0600 squid-ca-cert-key.pem ;
        ;;
    install)
        mkdir /etc/squid/certs ;
        mv squid-ca-cert-key.pem /etc/squid/certs/ ;
        id squid && chown squid:squid -R /etc/squid/certs ;
        /usr/lib64/squid/ssl_crtd -c -s /var/lib/ssl_db ;
        id squid && chown squid:squid -R /var/lib/ssl_db ;
        # install squid-ca-cert.pem into the OS cert chain
        ;;
esac

