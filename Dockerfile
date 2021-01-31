FROM docker:18.06.3-ce

ENV JAVA_VERSION="11.0.9_p11-r1"
ENV NODE_VERSION="10.19.0-r0"
# Note: Latest version of kubectl may be found at:
# https://github.com/kubernetes/kubernetes/releases
ENV KUBECTL_VERSION="v1.18.10"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v3.4.0"

# Update packages
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/main' > /etc/apk/repositories \
    && echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/community' >> /etc/apk/repositories \
    && apk upgrade -U -a

RUN { \
        echo '#!/bin/sh'; \
        echo 'set -e'; \
        echo; \
        echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
    } > /usr/local/bin/docker-java-home \
    && chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-11-openjdk/jre/bin:/usr/lib/jvm/java-11-openjdk/bin
RUN set -x \
    && apk update \
    && apk add --no-cache \
        openjdk11="${JAVA_VERSION}" \
        maven \
        curl \
        nodejs="${NODE_VERSION}" \
        npm \
        yarn \
        git \
        python3 \
        --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
    && pip3 install --no-cache-dir --upgrade pip \
    && [ "${JAVA_HOME}" = "$(docker-java-home)" ] \
    && rm -rf /var/cache/* \
    && rm -rf /root/.cache/* \
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    && wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

ENTRYPOINT ["/bin/sh"]
