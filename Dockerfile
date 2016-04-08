FROM debian:stretch
ENV DEBIAN_FRONTEND noninteractive

## set timezone
RUN ln -s -f /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && dpkg-reconfigure tzdata

## add packages
RUN echo 'apt-get update -qq && apt-get install -yq $@ && apt-get clean && rm -rf /var/lib/apt/lists/*' > /usr/local/bin/apt.sh \
    && chmod +x /usr/local/bin/apt.sh
RUN apt.sh \
      fizsh \
      fonts-takao \
      ibus-anthy \
      locales \
      lxde-core \
      lxterminal \
      ssh \
      sudo \
      tightvncserver \
      vim \
      wget \
      xrdp
## ja_JP.UTF-8
RUN sed -i -e 's/# ja_JP.UTF-8/ja_JP.UTF-8/' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG="ja_JP.UTF-8" \
    && LANG=C xdg-user-dirs-update --force

## ibus
ENV LANG "ja_JP.UTF-8"
ENV XMODIFIERS "'@im=ibus'"
ENV GTK_IM_MODULE "ibus"
ENV QT_IM_MODULE "ibus"

## xrdp jp106 keyboard support.
WORKDIR /etc/xrdp
# http://www.mail-archive.com/xrdp-devel@lists.sourceforge.net/msg00263/km-e0010411.ini
COPY files/km-e0010411.ini km-0411.ini
RUN ln -s km-0411.ini km-e0010411.ini \
    && ln -s km-0411.ini km-e0200411.ini \
    && ln -s km-0411.ini km-e0210411.ini \
    && sed -i -e "8i /usr/bin/ibus-daemon -d" startwm.sh \
    && sed -i -e "8i export LANG=ja_JP.UTF-8" startwm.sh \
    && sed -i -e "8i export GTK_IM_MODULE=ibus" startwm.sh \
    && sed -i -e "8i export XMODIFIERS='@im=ibus'" startwm.sh \
    && sed -i -e "8i export QT_IM_MODULE=ibus" startwm.sh

## create vagrant account.uid:gid=1000:1000
ENV USER vagrant
ENV HOME /home/${USER}
RUN export uid=1000 gid=1000 \
    && echo "${USER}:x:${uid}:${gid}:Developer,,,:${HOME}:/bin/bash" >> /etc/passwd \
    && echo "${USER}:x:${uid}:" >> /etc/group \
    && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && install -d -m 0755 -o ${uid} -g ${gid} ${HOME} \
    && echo "${USER}:${USER}" | chpasswd \
    && LANG=C xdg-user-dirs-update --force
WORKDIR ${HOME}

## vnc server settings.
RUN export uid=1000 gid=1000 \
    && install -d -m 0755 -o ${uid} -g ${gid} \
         .vnc \
         .thunderbird \
         .ssh \
         .fizsh

COPY files/vnc/xstartup .vnc/
RUN \
    echo "${USER}" | vncpasswd -f > .vnc/passwd \
    && chmod 600 .vnc/passwd

## x2goserver
# RUN apt-key adv --recv-keys --keyserver keys.gnupg.net E1F958385BFE2B6E \
#     && sed -i -e "$ a deb http://packages.x2go.org/debian stretch main" /etc/apt/sources.list \
#     && apt-get update -qq \
#     && apt-get install -y x2goserver x2goserver-xsession

VOLUME ${HOME}
EXPOSE 3389
CMD /etc/init.d/xrdp start; tail -f /dev/null
