# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:dev

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"
ARG DEBIAN_FRONTEND="noninteractive"

# title
ENV TITLE="Pelorus" \
    PIXELFLUX_WAYLAND=true \
    SELKIES_DESKTOP=true \
    PELORUS=true \
    CUSTOM_PORT=8082 \
    CUSTOM_HTTPS_PORT=0 \
    SELKIES_ADDR=127.0.0.1

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/pelorus-logo.png && \
  echo "**** setup chrome repo ****" && \
  curl -fsSL \
    https://dl.google.com/linux/linux_signing_key.pub \
    | gpg --dearmor | tee /usr/share/keyrings/google-chrome.gpg >/dev/null && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> \
    /etc/apt/sources.list.d/google-chrome.list && \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    7zip \
    breeze-gtk-theme \
    file-roller \
    gnome-calculator \
    gnome-console \
    gnome-text-editor \
    google-chrome-stable \
    loupe \
    nginx \
    papers \
    resources \
    unrar \
    xdg-user-dirs && \
  echo "**** desktop tweaks ****" && \
  mkdir -p \
    /etc/xdg/selkies-desktop && \
  echo 'wallpaper=/usr/share/wallpapers/Next' > \
    /etc/xdg/selkies-desktop/config && \
  sed -i \
    's#^Exec=/usr/bin/google-chrome-stable#Exec=/usr/local/bin/wrapped-chrome#g' \
    /usr/share/applications/google-chrome.desktop && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001
VOLUME /config
