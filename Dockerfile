# Copyright 2024 dah4k
# SPDX-License-Identifier: EPL-2.0

# Ubuntu 24.04.1 LTS (Noble Numbat)
# Reference: https://www.evilsocket.net/2024/09/26/Attacking-UNIX-systems-via-CUPS-Part-I/
# > - CVE-2024-47176 | cups-browsed <= 2.0.1
# > - CVE-2024-47076 | libcupsfilters <= 2.1b1
# > - CVE-2024-47175 | libppd <= 2.1b1
# > - CVE-2024-47177 | cups-filters <= 2.0.1
FROM ubuntu@sha256:dfc10878be8d8fc9c61cbff33166cb1d1fe44391539243703c72766894fa834a

ARG TZ=Etc/UTC
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install --assume-yes --no-upgrade --no-install-recommends \
        cups-browsed \
        libcupsfilters2 \
        libppd2 \
        cups-filters \
        supervisor \
        ## DEBUG Tools \
        curl \
        fd-find \
        file \
        plocate \
        ripgrep \
        vim \
        w3m \
        iproute2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -m 660 -p /var/cache/cups && chown root:lp /var/cache/cups/

RUN mkdir -m 755 -p /var/cache/cups-browsed && chown cups-browsed:lpadmin /var/cache/cups-browsed

## Make sure default (Bonjour and legacy CUPS broadcast) protocols are enabled
## See Also cups-browsed.conf(5)
RUN sed -i 's/^BrowseRemoteProtocols.*/BrowseRemoteProtocols dnssd cups/' /etc/cups/cups-browsed.conf

COPY config/supervisord.conf /etc/supervisord.conf

EXPOSE 631

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

