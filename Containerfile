FROM registry.access.redhat.com/ubi8/ubi:latest

RUN dnf install -y openssl openssl-libs openssl-pkcs11 openssl-devel openssh-clients java-1.8.0-openjdk bash nano wget curl git python3 python3-pip python3-pip-wheel augeas-libs

RUN python3 -m pip install --upgrade certbot

USER 1001

ENTRYPOINT /bin/bash
