FROM registry.access.redhat.com/ubi8/ubi:latest

RUN dnf install -y openssl openssl-libs openssl-pkcs11 openssl-devel openssh-clients java-1.8.0-openjdk bash nano wget curl

USER 1001

ENTRYPOINT /bin/bash
