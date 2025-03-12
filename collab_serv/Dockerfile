FROM debian:bookworm

RUN apt update && apt install -y \
    tzdata \
    curl \
    tar \
    gzip \
    gawk \
    procps \
    sysvinit-utils \
    systemd \
    libasound2 \
    libfreetype6 \
    libfontconfig1 \
    libx11-6 \
    libxdmcp6 \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libxau6 \
    libxcb1 && \
    update-alternatives --set awk /usr/bin/gawk && \
    rm -rf /var/lib/apt/lists/*

ENV TZ=Europe/Moscow

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /app

COPY axiomjdk-jre-pro11.0.25+11-linux-amd64.deb /app/

RUN apt-get install -y /app/axiomjdk-jre-pro11.0.25+11-linux-amd64.deb && \
    rm /app/axiomjdk-jre-pro11.0.25+11-linux-amd64.deb

COPY 1c_cs_26.0.53_linux_x86_64.tar.gz /app/

RUN tar -xzf 1c_cs_26.0.53_linux_x86_64.tar.gz && rm 1c_cs_26.0.53_linux_x86_64.tar.gz
RUN chmod +x /app/1ce-installer-cli
RUN /app/1ce-installer-cli install --ignore-signature-warnings

# Подумать как вытащить пути через $(find /opt -type d -name "1c-enterprise-ring-*") 
#                                    $(find /usr -type d -name "axiomjdk-java11-*")
ENV JAVA_HOME=/usr/lib/jvm/axiomjdk-java11-runtime-pro-amd64
ENV RING_PATH=/opt/1C/1CE/components/1c-enterprise-ring-0.19.5+12-x86_64
ENV MC_PATH=/app/minio-binaries

ENV PATH=$PATH:$JAVA_HOME/bin:$RING_PATH:$MC_PATH

RUN useradd -m csuser

RUN mv /bin/pidof /bin/_pidof && cp /bin/echo /bin/pidof 

RUN mkdir -p /var/cs/hcdev && chown csuser:csuser /var/cs/hcdev && \
    mkdir -p /var/cs/esdev && chown csuser:csuser /var/cs/esdev && \
	mkdir -p /var/cs/csdev && chown csuser:csuser /var/cs/csdev

RUN ring hazelcast instance create --dir /var/cs/hcdev --owner csuser && \
    ring elasticsearch instance create --dir /var/cs/esdev --owner csuser && \
    ring cs instance create --dir /var/cs/csdev --owner csuser

RUN ring hazelcast --instance hcdev service create --username csuser --stopped && \
    ring elasticsearch --instance esdev service create --username csuser --stopped && \
    ring cs --instance csdev service create --username csuser --stopped

RUN ring hazelcast --instance hcdev service java-home set $JAVA_HOME && \
    ring elasticsearch --instance esdev service java-home set $JAVA_HOME && \
    ring cs --instance csdev service java-home set $JAVA_HOME

COPY ./run.sh /app/
COPY ./init.sh /app/
COPY ./restart.sh /app/
COPY ./status.sh /app/
RUN chmod +x /app/run.sh /app/init.sh /app/restart.sh /app/status.sh

EXPOSE 9090

CMD ["/app/run.sh"]
