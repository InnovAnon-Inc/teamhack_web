FROM voidlinux/voidlinux-musl:latest as build

RUN echo repository=https://repo-fastly.voidlinux.org/current/musl/nonfree > /etc/xbps.d/10-repository-nonfree.conf
RUN xbps-install -Sy                 \
    xbps                             \
&&  xbps-install -Syu                \
&&  xbps-install -Sy                 \
    gcc                              \
    git                              \
    make                             \
&&  git clone                        \
    --depth=1                        \
    --recursive                      \
    git://git.suckless.org/quark     \
&&  cd quark                         \
&&  make                             \
&&  make install                     \
&&        command -v quark           \
&&  ldd $(command -v quark)
#WORKDIR quark

FROM scratch

COPY --from=build /lib/ld-musl-x86_64.so.1 /lib/
COPY --from=build /usr/local/bin/quark     /usr/bin/

WORKDIR  /var/teamhack
VOLUME ["/var/teamhack/certs"]
VOLUME ["/var/teamhack/crl"]

  #"-h", $QUARK_HOST, \
ENTRYPOINT [         \
  "/usr/bin/quark",  \
  "-l"               \
]

EXPOSE 80/tcp

