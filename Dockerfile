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
        # libstdc++6:i386 \ # not actually required
        libstdc++5:i386 \
        # libnss3-tools \ # not actually required
        # default-jre-headless \ # jre dependency - not actually required

        # snx client also requires tun kernel module and will probe for it
        kmod \

        # snx installer requirements
        bzip2 \

        # snx.sh launcher script requirements
        expect \
        iptables \
        iproute2 \
        gawk \

        # Dockerfile requirements
        curl \

        # optionals for tunnel debug
        # net-tools \
        iputils-ping \
        netcat \
        # tcpdump \
        dnsutils \
        # nano \

    && DEBIAN_FRONTEND=noninteractive \
        apt clean \
    && DEBIAN_FRONTEND=noninteractive \
        apt autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN curl $( \
        curl -s "https://supportcenter.checkpoint.com/supportcenter/portal/user/anon/page/default.psml/media-type/html?action=portlets.DCFileAction&eventSubmit_doGetdcdetails=&fileid=22824" \
        | grep -Pzo -m 1 "<a onclick=.{10,60}?href=\"\K.*?(?=\">\s*<button.{0,20}?>Download<\/button>)") \
    -o snx_install.sh \
    && bash -x snx_install.sh \
    && rm -rf snx_install.sh

ENV SNX_SERVER 127.0.0.1
ENV SNX_USER user
ENV SNX_PASSWORD changeme
ENV SNX_ARGS ""
ENV SNX_MANUAL_ROUTES ""

ADD scripts/snx.sh .

RUN chmod +x snx.sh

CMD ["/root/snx.sh"]

HEALTHCHECK --interval=5s --timeout=2s --start-period=5s --retries=1 \
    CMD ps aux | grep '[s]nx ' || exit 1