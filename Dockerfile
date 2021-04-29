FROM debian:buster-slim

LABEL maintainer="SoftInstigate <info@softinstigate.com>"

ARG JAVA_VERSION="21.1.0.r16-grl"
ARG MAVEN_VERSION="3.6.3"

ENV SDKMAN_DIR=/root/.sdkman


RUN apt-get update \
    && apt-get install -y --no-install-recommends tzdata curl zip unzip build-essential libz-dev zlib1g-dev ca-certificates fontconfig locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

RUN curl 'https://get.sdkman.io' | bash \
    && echo "sdkman_auto_answer=true" > $SDKMAN_DIR/etc/config \
    && echo "sdkman_auto_selfupdate=false" >> $SDKMAN_DIR/etc/config \
    && echo "sdkman_insecure_ssl=true" >> $SDKMAN_DIR/etc/config \
    && chmod +x $SDKMAN_DIR/bin/sdkman-init.sh

RUN bash -c "source $SDKMAN_DIR/bin/sdkman-init.sh \
        && sdk version \
        && sdk install java $JAVA_VERSION \
        && gu install native-image \
        && sdk install maven $MAVEN_VERSION \
        && rm -rf $SDKMAN_DIR/archives/* \
        && rm -rf $SDKMAN_DIR/tmp/*"

RUN mkdir -p /usr/share/maven /usr/share/maven/ref


ARG USER_HOME_DIR="/root"
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"



COPY bin/mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY bin/entrypoint.sh /usr/local/bin/entrypoint.sh


WORKDIR /opt/app
SHELL ["/bin/bash", "-i", "-c"]
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD ["mvn"]