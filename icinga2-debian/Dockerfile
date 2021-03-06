
FROM bitnami/minideb:latest

ENV \
  TERM=xterm \
  DEBIAN_FRONTEND=noninteractive

ARG BUILD_DATE
ARG BUILD_VERSION
ARG ICINGA2_VERSION

RUN \
  echo "export BUILD_DATE=${BUILD_DATE}"            > /etc/profile.d/icinga2.sh && \
  echo "export BUILD_VERSION=${BUILD_VERSION}"     >> /etc/profile.d/icinga2.sh && \
  echo "export ICINGA2_VERSION=${ICINGA2_VERSION}" >> /etc/profile.d/icinga2.sh && \
  DIST=$(awk -F"[)(]+" '/VERSION=/ {print $2}' /etc/os-release) && \
  chsh -s /bin/bash && \
  ln -sf /bin/bash /bin/sh && \
  ln -s  /sbin/killall5 /sbin/killall && \
  apt-get update  --quiet --quiet > /dev/null && \
  apt-get dist-upgrade --quiet --quiet > /dev/null && \
  groupadd -g 1000 icinga && \
  useradd -u 1000 -g icinga -G icinga -d /etc/icinga2 -s /bin/bash icinga && \
  apt-get install --quiet --quiet --assume-yes --no-install-recommends \
    bash \
    bzip2 \
    curl \
    ca-certificates \
    dnsutils \
    expect \
    file \
    gnupg2 \
    inotify-tools \
    jq \
    netcat-openbsd \
    pwgen \
    python3.5-minimal \
    xz-utils \
    > /dev/null && \
  curl \
    --silent \
    --location \
    --retry 3 \
    --output /usr/bin/vercomp \
  https://gist.githubusercontent.com/bodsch/065b16ea3c3deb83af7f41990d2d273c/raw/6ba6d7b43de7cff78b7eaf3959f4546642b76750/vercomp && \
  chmod +x /usr/bin/vercomp && \
  curl \
    --silent \
    https://packages.icinga.com/icinga.key | apt-key add - && \
  echo "deb http://packages.icinga.com/debian icinga-${DIST} main" > \
    /etc/apt/sources.list.d/${DIST}-icinga.list && \
  apt-get update --quiet --quiet > /dev/null && \
  ln -s /etc/default /etc/sysconfig && \
  apt-get --quiet --quiet --assume-yes --no-install-recommends install \
    icinga2-bin \
    icinga2-ido-mysql \
    monitoring-plugins \
    > /dev/null && \
  export MONITORING_PLUGIN_DIR="/usr/share/monitoring-plugins" && \
  curl \
    --silent \
    --location \
    --retry 3 \
    --output ${MONITORING_PLUGIN_DIR}/check_linux_memory \
  https://raw.githubusercontent.com/hugme/Nag_checks/master/check_linux_memory && \
  chmod +x ${MONITORING_PLUGIN_DIR}/check_linux_memory && \
  /usr/sbin/icinga2 feature disable command checker mainlog notification && \
  mkdir -p /etc/icinga2/objects.d && \
  mkdir -p /run/icinga2/cmd && \
  mkdir -p /etc/icinga2/zones.d/global-templates && \
  mkdir -p /etc/icinga2/zones.d/director-global && \
  cp /etc/icinga2/zones.conf /etc/icinga2/zones.conf-distributed && \
  rm -f /etc/apt/sources.list.d/* && \
  apt-get clean --quiet --quiet > /dev/null && \
  echo "" && \
  which icinga2 && \
  icinga2 --version && \
  icinga2 daemon --validate && \
  icinga2 feature list && \
  echo ""

COPY rootfs/ /

WORKDIR /etc/icinga2

VOLUME [ "/etc/icinga2", "/var/lib/icinga2" ]

HEALTHCHECK \
  --interval=5s \
  --timeout=2s \
  --retries=12 \
  --start-period=10s \
  CMD ps ax | grep -v grep | grep -c $(cat /run/icinga2/icinga2.pid) || exit 1

CMD ["/bin/bash"]
