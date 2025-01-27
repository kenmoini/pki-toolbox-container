FROM registry.access.redhat.com/ubi8/ubi:latest

RUN dnf update -y \
 && dnf install -y openssl openssl-libs openssl-pkcs11 openssl-devel openssh-clients java-1.8.0-openjdk bash nano wget curl git python3 python3-pip python3-pip-wheel augeas-libs iputils bind-utils jq iproute \
 && dnf clean all \
 && rm -rf /var/cache/yum

RUN python3 -m pip install --upgrade pip && python3 -m pip install --upgrade certbot

RUN mkdir -p /opt/pki-toolbox && chown 1001:1001 /opt/pki-toolbox

USER 1001

WORKDIR /opt/pki-toolbox

ENTRYPOINT /bin/bash
