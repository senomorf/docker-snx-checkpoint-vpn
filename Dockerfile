FROM ubuntu:latest

USER root

WORKDIR /root

RUN dpkg --add-architecture i386 \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        bzip2 \
        kmod \
        libstdc++5:i386 \
        libpam0g:i386 \
        libx11-6:i386 \
        expect \
        iptables \
        net-tools \
        iputils-ping \
        iproute2 \
        nano \
        curl \
    && apt-get clean \
    && apt-get autoremove

RUN curl $(curl -s "https://supportcenter.checkpoint.com/supportcenter/portal/user/anon/page/default.psml/media-type/html?action=portlets.DCFileAction&eventSubmit_doGetdcdetails=&fileid=22824" | grep -Pzo -m 1 "<a onclick=.{10,60}?href=\"\K.*?(?=\">\s*<button.{0,20}?>Download<\/button>)") -o snx_install_linux30.sh

RUN bash -x snx_install_linux30.sh

ADD scripts/snx.sh .

RUN chmod +x snx.sh

CMD ["/root/snx.sh"]
