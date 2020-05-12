FROM docker:18.06.3-ce

ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.name="jenkins-slave-base" \
      org.label-schema.url="https://hub.docker.com/r/sergiomartins8/jenkins-slave-base/" \
      org.label-schema.vcs-url="https://github.com/sergiomartins8/jenkins-slave-base" \
      org.label-schema.build-date=$BUILD_DATE

ENV JAVA_VERSION="8.242.08-r0"
ENV NODE_VERSION="10.14.2-r0"
# Note: Latest version of kubectl may be found at:
# https://github.com/kubernetes/kubernetes/releases
ENV KUBECTL_VERSION="v1.18.2"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v3.2.1"

# Update packages
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/main' > /etc/apk/repositories \
    && echo 'http://dl-cdn.alpinelinux.org/alpine/v3.9/community' >> /etc/apk/repositories \
    && apk upgrade -U -a

# Install Java, Maven, Node, Curl, Git, Python
RUN { \
        echo '#!/bin/sh'; \
        echo 'set -e'; \
        echo; \
        echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
    } > /usr/local/bin/docker-java-home \
    && chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin
RUN set -x \
    && apk update \
    && apk add --no-cache \
        openjdk8="${JAVA_VERSION}" \
        maven \
        curl \
        nodejs="${NODE_VERSION}" \
        yarn \
        git \
        python \
        py-pip \
    && [ "${JAVA_HOME}" = "$(docker-java-home)" ]

# Install Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# Install helm
RUN wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

ENTRYPOINT ["/bin/sh"]