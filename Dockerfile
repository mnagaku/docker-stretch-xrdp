FROM debian:stretch
ENV DEBIAN_FRONTEND noninteractive

# timezone
RUN ln -s -f /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && dpkg-reconfigure tzdata \
    && apt-get update -qq

# add packages
RUN apt-get install -y \
      lxde-core xrdp locales mozc-server wget vim-gtk fonts-takao \
    && apt-get clean
# ja_JP.UTF-8
RUN sed -i -e 's/# ja_JP.UTF-8/ja_JP.UTF-8/' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG="ja_JP.UTF-8" \
    && LANG=C xdg-user-dirs-update --force

RUN apt-get install -y --install-recommends \
      fcitx-mozc

# fcitx
ENV LANG "ja_JP.UTF-8"
ENV XMODIFIERS "'@im=fcitx'"
ENV GTK_IM_MODULE "fcitx"
ENV QT_IM_MODULE "fcitx"

## xrdp jp106 keyboard support.
# WORKDIR /etc/xrdp
# http://www.mail-archive.com/xrdp-devel@lists.sourceforge.net/msg00263/km-e0010411.ini
# COPY files/km-e0010411.ini km-0411.ini
# RUN ln -s km-0411.ini km-e0010411.ini \
#     && ln -s km-0411.ini km-e0200411.ini \
#     && ln -s km-0411.ini km-e0210411.ini \
#     && sed -i -e "8i /usr/bin/fcitx-daemon -d" startwm.sh
RUN echo "root:root" | chpasswd

WORKDIR /root
RUN touch lxde.sh \
    && sed -i -e "$ a export LANG=ja_JP.UTF-8" lxde.sh \
    && sed -i -e "$ a export GTK_IM_MODULE=fcitx" lxde.sh \
    && sed -i -e "$ a export XMODIFIERS='@im=fcitx'" lxde.sh \
    && sed -i -e "$ a export QT_IM_MODULE=fcitx" lxde.sh \
    && chmod +x lxde.sh

RUN apt-key adv --recv-keys --keyserver keys.gnupg.net E1F958385BFE2B6E \
    && sed -i -e "$ a deb http://packages.x2go.org/debian stretch main" /etc/apt/sources.list \
    && apt-get update -qq \
    && apt-get install -y x2goserver x2goserver-xsession

RUN apt-get install -y ssh \
    && mkdir /root/.ssh \
    && sed -i -e "s/^PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
#COPY files/authorized_keys /root/.ssh/authorized_keys
