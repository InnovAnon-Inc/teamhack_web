FROM voidlinux/voidlinux-musl:latest as build

RUN echo repository=https://repo-fastly.voidlinux.org/current/musl/nonfree > /etc/xbps.d/10-repository-nonfree.conf
RUN xbps-install -Sy                 \
    xbps
RUN xbps-install -Syu
RUN xbps-install -Sy                 \
    gcc                              \
    git                              \
    make

RUN git clone   \
    --depth=1   \
    --recursive \
    git://git.suckless.org/quark
WORKDIR quark
RUN make
RUN make install

FROM scratch

COPY --from=build /lib/ld-musl-x86_64.so.1 /lib/
COPY --from=build /usr/bin/quark           /usr/bin/

WORKDIR  /var/teamhack
VOLUME ["/var/teamhack/certs"]
VOLUME ["/var/teamhack/crl"]

  #"-h", $QUARK_HOST, \
ENTRYPOINT [         \
  "/usr/bin/env",    \
  "quark",           \
  "-l"               \
]

EXPOSE 80/tcp

