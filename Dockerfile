FROM ubuntu:latest

USER root

WORKDIR /root

RUN dpkg --add-architecture i386 \
    && DEBIAN_FRONTEND=noninteractive \
        apt update \
    && DEBIAN_FRONTEND=noninteractive \
        apt upgrade -y \
    && DEBIAN_FRONTEND=noninteractive \
        apt install -y \
        # official dependencies:
        libpam0g:i386 \
        libx11-6:i386 \
        libstdc++6:i386 \
        libstdc++5:i386 \
        libnss3-tools \
        # jre dependency - but its not needed really
        default-jre-headless \
        # requirements?
        bzip2 \
        kmod \
        # snx.sh script requirements
        expect \
        iptables \
        iproute2 \
        # tunnel debug utilities - remove when finished
        net-tools \
        netcat \
        tcpdump \
        dnsutils \
        iputils-ping \
        nano \
        curl \
    && DEBIAN_FRONTEND=noninteractive \
        apt clean \
    && DEBIAN_FRONTEND=noninteractive \
        apt autoremove

ARG DOWNLOAD_URL="https://supportcenter.checkpoint.com/supportcenter/portal/user/anon/page/default.psml/media-type/html?action=portlets.DCFileAction&eventSubmit_doGetdcdetails=&fileid=22824"

RUN curl $( \
        curl -s $DOWNLOAD_URL \
        | grep -Pzo -m 1 "<a onclick=.{10,60}?href=\"\K.*?(?=\">\s*<button.{0,20}?>Download<\/button>)") \
    -o snx_install_linux30.sh

RUN bash -x snx_install_linux30.sh

ENV SNX_SERVER 127.0.0.1
ENV SNX_USER user
ENV SNX_PASSWORD changeme
ENV SNX_ARGS ""

ADD scripts/snx.sh .

RUN chmod +x snx.sh

CMD ["/root/snx.sh"]
