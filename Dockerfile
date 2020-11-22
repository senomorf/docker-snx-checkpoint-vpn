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
        # libstdc++6:i386 \ # not actually needed
        libstdc++5:i386 \
        # libnss3-tools \ # not actually needed
        # jre dependency
        # default-jre-headless \ # not actually needed
        # snx client requires tun kernel module
        kmod \
        # snx installer requirements
        bzip2 \
        curl \
        # snx.sh script requirements
        expect \
        iptables \
        iproute2 \
        gawk \
        # tunnel debug utilities
        # net-tools \
        # netcat \
        # tcpdump \
        # dnsutils \
        # nano \
        # iputils-ping \
    && DEBIAN_FRONTEND=noninteractive \
        apt clean \
    && DEBIAN_FRONTEND=noninteractive \
        apt autoremove

RUN curl $( \
        curl -s "https://supportcenter.checkpoint.com/supportcenter/portal/user/anon/page/default.psml/media-type/html?action=portlets.DCFileAction&eventSubmit_doGetdcdetails=&fileid=22824" \
        | grep -Pzo -m 1 "<a onclick=.{10,60}?href=\"\K.*?(?=\">\s*<button.{0,20}?>Download<\/button>)") \
    -o snx_install.sh

RUN bash -x snx_install.sh

RUN rm -rf snx_install.sh

ENV SNX_SERVER 127.0.0.1
ENV SNX_USER user
ENV SNX_PASSWORD changeme
ENV SNX_ARGS ""

ADD scripts/snx.sh .

RUN chmod +x snx.sh

CMD ["/root/snx.sh"]
