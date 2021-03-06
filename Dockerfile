FROM frolvlad/alpine-glibc:alpine-3.4

MAINTAINER Dan Boykis <danboykis@gmail.com>
RUN apk update && apk add git vim tree
RUN apk upgrade libssl1.0 --update-cache
RUN apk add wget ca-certificates
RUN apk add tar
RUN apk add curl
RUN apk add bash

# Java Version
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 111
ENV JAVA_VERSION_BUILD 14
ENV JAVA_PACKAGE       jdk

# Download and unarchive Java
RUN mkdir -p /opt && curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" \
  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
    | tar -xzf - -C /opt &&\
    ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk &&\
    rm -rf /opt/jdk/*src.zip \
           /opt/jdk/lib/missioncontrol \
           /opt/jdk/lib/visualvm \
           /opt/jdk/lib/*javafx* \
           /opt/jdk/jre/lib/plugin.jar \
           /opt/jdk/jre/lib/ext/jfxrt.jar \
           /opt/jdk/jre/bin/javaws \
           /opt/jdk/jre/lib/javaws.jar \
           /opt/jdk/jre/lib/desktop \
           /opt/jdk/jre/plugin \
           /opt/jdk/jre/lib/deploy* \
           /opt/jdk/jre/lib/*javafx* \
           /opt/jdk/jre/lib/*jfx* \
           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
           /opt/jdk/jre/lib/amd64/libprism_*.so \
           /opt/jdk/jre/lib/amd64/libfxplugins.so \
           /opt/jdk/jre/lib/amd64/libglass.so \
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jdk/jre/lib/amd64/libjavafx*.so \
           /opt/jdk/jre/lib/amd64/libjfx*.so

# Set environment
ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin

WORKDIR /root

RUN mkdir -p /root/bin && wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && \
	chmod +x lein && \
	mv lein bin
RUN git clone https://github.com/luminus-framework/guestbook.git

EXPOSE 3000
EXPOSE 7000
WORKDIR /root/guestbook
ENV LEIN_ROOT "yes"
RUN ~/bin/lein deps
RUN ~/bin/lein run migrate
CMD ~/bin/lein run
