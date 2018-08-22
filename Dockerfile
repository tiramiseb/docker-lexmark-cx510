FROM ubuntu:xenial

RUN apt-get update && apt-get -y upgrade && apt-get -y install sane sane-utils dbus avahi-utils cups && rm -rf /var/lib/apt/lists/*
ADD http://downloads.lexmark.com/downloads/drivers/lexmark_network-scan-linux-glibc2_06082017_x86_64.deb /tmp
ADD http://www.downloaddelivery.com/downloads/drivers/Lexmark-AD5-PPD-Files-1.0-03072017.amd64.deb /tmp
RUN dpkg -i /tmp/lexmark_network-scan-linux-glibc2_06082017_x86_64.deb /tmp/Lexmark-AD5-PPD-Files-1.0-03072017.amd64.deb && rm -f /tmp/lexmark_network-scan-linux-glibc2_06082017_x86_64.deb /tmp/Lexmark-AD5-PPD-Files-1.0-03072017.amd64.deb


# CUPS must be started to change its config
RUN /etc/init.d/cups start && /etc/init.d/cups-browsed start && cupsctl --remote-admin --remote-any --share-printers --user-cancel-any

# Even with this stuff, scanimage -L doesn't see the scanner :'(
RUN echo 0.0.0.0/0 > /etc/sane.d/saned.conf
RUN ln -s /usr/local/lexmark/unix_scan_drivers/lib/sane/libsane-lexmark_nscan.so.1.0.16 /usr/lib/x86_64-linux-gnu/sane/libsane-lexmark_nscan.so
RUN ln -s /usr/local/lexmark/unix_scan_drivers/lib/sane/libsane-lexmark_nscan.so.1.0.16 /usr/lib/x86_64-linux-gnu/sane/libsane-lexmark_nscan.so.1
RUN ln -s /usr/local/lexmark/unix_scan_drivers/lib/sane/libsane-lexmark_nscan.so.1.0.16 /usr/lib/x86_64-linux-gnu/sane/libsane-lexmark_nscan.so.1.0.16
RUN echo lexmark_nscan > /etc/sane.d/dll.conf
RUN sed -i 's/^DISCOVER_NET_FLAG=.*/DISCOVER_NET_FLAG=0/;s/^SHOW_PSEUDO_NETWORK_FLAG=.*/SHOW_PSEUDO_NETWORK_FLAG=0/' /etc/sane.d/lexmark_nscan.conf

COPY cups_sane.sh /usr/local/bin/cups_sane.sh
ENTRYPOINT ["cups_sane.sh"]
CMD []