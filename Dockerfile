ARG TAG=latest
FROM debian:$TAG as base

ARG  DEBIAN_FRONTEND=noninteractive
ARG  DEBCONF_NONINTERACTIVE_SEEN=true

ARG  TZ=Etc/UTC
ENV  TZ $TZ
ARG  LANG=C.UTF-8
ENV  LANG $LANG
ARG  LC_ALL=C.UTF-8
ENV  LC_ALL $LC_ALL

ARG EXT=tgz

# TODO encrypted program
#      use build arg to decrypt
#      use prog to authenticate with lmaddox
#      download encryption key for real program

#COPY       ./stage-0.$EXT       /tmp/
COPY       ./stage-0/           /tmp/stage-0
RUN ( cd                        /tmp/stage-0      \
 &&   tar pcf - .                                ) \
  | tar pxf - -C /                                 \
 && rm -rf                      /tmp/stage-0      \
 && chmod -v 1777               /tmp              \
 && apt update                                    \
 && [ -x          /tmp/dpkg.list ]                \
 && apt install $(/tmp/dpkg.list)                 \
 && rm    -v      /tmp/dpkg.list                  \
 && apt-key add < /tmp/key.asc                    \
 && rm    -v      /tmp/key.asc                    \
 && exec true || exec false

#COPY          ./stage-1.$EXT    /tmp/
COPY          ./stage-1/        /tmp/stage-1
RUN ( cd                        /tmp/stage-1      \
 &&   tar pcf - .                                ) \
  | tar pxf - -C /                                 \
 && rm -rf                      /tmp/stage-1      \
 && chmod -v 1777               /tmp              \
 && apt update                                    \
 && [ -x          /tmp/dpkg.list ]                \
 && apt install $(/tmp/dpkg.list)                 \
 && rm    -v      /tmp/dpkg.list                  \
 && exec true || exec false

# TODO maybe encrypt support bin
#COPY          ./stage-2.$EXT    /tmp/
COPY          ./stage-2         /tmp/stage-2
RUN ( cd                        /tmp/stage-2      \
 &&   tar pcf - .                                ) \
  | tar pxf - -C /                                 \
 && rm -rf                      /tmp/stage-2      \
 && chmod -v 1777               /tmp              \
 && sed -i 's@^ORPort@#&@'      /etc/tor/torrc    \
 && echo 'SOCKSPolicy accept 127.0.0.1' >> /etc/tor/torrc \
 && echo 'SOCKSPolicy reject *'         >> /etc/tor/torrc \
 && tor --verify-config                           \
 && exec true || exec false
# TODO
# && sysctl -p

# start bg services
SHELL ["/bin/bash", "-l", "-c"]

RUN sleep 91                                       \
 && apt update                                     \
 && [ -x          /tmp/dpkg.list ]                 \
 && apt install $(/tmp/dpkg.list)                  \
 && rm -v         /tmp/dpkg.list                   \
 && update-alternatives --force --install          \
      $(command -v gzip   || echo /usr/bin/gzip)   \
      gzip   $(command -v pigz)   200              \
 && update-alternatives --force --install          \
      $(command -v gunzip || echo /usr/bin/gunzip) \
      gunzip $(command -v unpigz) 200              \
 && update-alternatives --force --install          \
      $(command -v bzip2  || echo /usr/bin/bzip2)  \
      bzip2  $(command -v pbzip2) 200              \
 && update-alternatives --force --install          \
      $(command -v xz     || echo /usr/bin/xz)     \
      xz     $(command -v pixz)   200              \
 && apt full-upgrade                               \
 && clean.sh                                       \
 && exec true || exec false

# TODO take this out until shc -S is an option
FROM base as support
ARG EXT=tgz
#COPY          ./stage-3.$EXT    /tmp/
COPY          ./stage-3         /tmp/stage-3
RUN ( cd                        /tmp/stage-3       \
 &&   tar pcf - .                                 ) \
  | tar pxf - -C /                                  \
 && rm -rf                      /tmp/stage-3       \
 && chmod -v 1777               /tmp               \
 && apt update                                     \
 && [ -x            /tmp/dpkg.list ]               \
 && apt install   $(/tmp/dpkg.list)                \
 && cd /usr/local/bin                              \
 && shc -rUf     support-wrapper                   \
 && rm    -v     support-wrapper.x.c            \
 && chmod -v 0555 support-wrapper.x                \
 && apt-mark auto $(/tmp/dpkg.list)                \
 && rm -v           /tmp/dpkg.list                 \
 && clean.sh                                       \
 && exec true || exec false
 #&& rm    -v     support-wrapper{,.x.c}            \

FROM base as base-1
# TODO
#COPY --from=support /usr/local/bin/support-wrapper.x \
#                    /usr/local/bin/support-wrapper
COPY --from=support /usr/local/bin/support-wrapper \
                    /usr/local/bin/support-wrapper
#SHELL ["/bin/bash", "-c"]

FROM base-1 as lfs-bare
ARG EXT=tgz
ARG LFS=/mnt/lfs
ARG TEST=
SHELL ["/bin/bash", "-l", "-c"]
#COPY          ./stage-4.$EXT    /tmp/
COPY          ./stage-4         /tmp/stage-4
RUN ( cd                        /tmp/stage-4       \
 &&   tar pcf - .                                 ) \
  | tar pxf - -C /                                  \
 && rm -rf                      /tmp/stage-4       \
 && chmod -v 1777               /tmp                \
 && apt update                                      \
 && [ -x           /tmp/dpkg.list ]                 \
 && apt install  $(/tmp/dpkg.list)                  \
 && rm    -v       /tmp/dpkg.list                  \
 && clean.sh                                       \
 && mkdir -vp         $LFS/sources                  \
 && chmod -v a+wt     $LFS/sources                  \
 && groupadd lfs                                    \
 && useradd -s /bin/bash -g lfs -G debian-tor -m -k /dev/null lfs \
 && chown -v  lfs:lfs $LFS/sources                  \
 && chown -vR lfs:lfs /home/lfs                     \
 && exec true || exec false
 #&& chown  -R lfs:lfs /var/lib/tor

#FROM lfs-bare as test
#USER lfs
#RUN sleep 31 \
# && tsocks wget -O- https://3g2upl4pq6kufc4m.onion
#
#FROM lfs-bare as final

#FROM lfs-bare as squash-tmp
#USER root
#RUN  squash.sh
#FROM scratch as squash
#ADD --from=squash-tmp /tmp/final.tar /

#FROM scratch as squash
#COPY --from=lfs-bare / /
#
#FROM squash as test
#USER lfs
#RUN tor --verify-config
#USER root
#RUN apt update
#RUN apt full-upgrade
#
#FROM squash as final

FROM lfs-bare as final
