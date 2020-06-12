#!/bin/sh
set -e

if [ "$1" = "generate" ] ; then
        # can be run inside a container or from a host
        openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -extensions v3_ca -keyout squid-ca-key.pem -out squid-ca-cert.pem
        openssl x509 -in squid-ca-cert.pem -outform DER -out squid-ca-cert.der
        openssl dhparam -outform PEM -out dhparam.pem 2048
        cat squid-ca-cert.pem squid-ca-key.pem > squid-ca-cert-key.pem
        chmod 0600 squid-ca-key.pem squid-ca-cert.pem squid-ca-cert-key.pem dhparam.pem

elif [ "$1" = "install" ] ; then
        # to be run inside the container, and on the client machine.

        # the following is only tested on Alpine. Other distributions/OSes will need their
        # own steps to install the CA certificate into the certificate chain.

        mkdir -p /etc/squid/certs
        mv squid-ca-cert-key.pem /etc/squid/certs/
        mkdir -p /usr/local/share/ca-certificates
        cp /etc/squid/certs/squid-ca-cert.pem /usr/local/share/ca-certificates/squid-ca-cert.crt
        update-ca-certificates

        # The following only needs to be run in the container
        if [ ! -d /var/lib/ssl_db -a -x /usr/lib/squid/security_file_certgen ] ; then
            /usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 4MB
        fi
else
    echo "Usage: $0 generate|install"
    exit 1
fi
