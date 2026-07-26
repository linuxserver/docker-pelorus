FROM ghcr.io/linuxserver/baseimage-selkies:arch

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PELORUS_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE="Pelorus" \
    PIXELFLUX_WAYLAND=true \
    PIXELFLUX_CU=5000 \
    NO_GAMEPAD=true \
    ROOT_PATH=/pelorus

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/pelorus-logo.png && \
  echo "**** install packages ****" && \
  pacman -Sy --noconfirm --needed \
    chromium \
    discover \
    dolphin \
    drawing \
    gimp \
    git \
    gobject-introspection \
    inkscape \
    kate \
    kdenlive \
    konsole \
    kwin-x11 \
    libreoffice \
    plasma-desktop \
    plasma-x11-session \
    python-gobject \
    rust && \
  cargo install \
    wl-clipboard-rs-tools && \
  echo "**** replace wl-clipboard with rust ****" && \
  mv \
    /config/.cargo/bin/wl-* \
    /usr/bin/ && \
  echo "**** install pelorus ****" && \
  mkdir -p /tmp/pelorus && \
  if [ -z ${PELORUS_RELEASE+x} ]; then \
    PELORUS_RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/pelorus/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/pelorus.tar.gz -L \
    "https://github.com/linuxserver/pelorus/archive/${PELORUS_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/pelorus.tar.gz -C \
    /tmp/pelorus/ --strip-components=1 && \
  pip install /tmp/pelorus && \
  echo "**** application tweaks ****" && \
  mv \
    /usr/bin/chromium \
    /usr/bin/chromium-real && \
  setcap -r \
    /usr/sbin/kwin_wayland && \
  echo "**** cleanup ****" && \
  rm -rf \
    /config/.cache \
    /config/.cargo \
    /tmp/* \
    /var/cache/pacman/pkg/* \
    /var/lib/pacman/sync/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
