# syntax=docker/dockerfile:experimental

FROM alpine:3.10.3

LABEL maintainer="mahnke@sub.uni-goettingen.de"

ARG YAZ_VERSION=5.27.2
ARG PAZPAR2_VERSION=1.14.0

ENV BUILD_DIR=/tmp/build \
    REQ_BUILD="wget alpine-sdk bison libxslt-dev gnutls-dev icu-dev libgcrypt-dev libgpg-error-dev" \
    REQ_RUN="busybox libxslt gnutls icu libgcrypt libgpg-error" \
    USER=pazpar2 \
    YAZ_DOWNLOAD_URL=http://ftp.indexdata.dk/pub/yaz/yaz-5.27.2.tar.gz \
    PAZPAR2_DOWNLOAD_URL=http://ftp.indexdata.dk/pub/pazpar2/pazpar2-1.14.0.tar.gz \
    CONF_DIR=/etc/pazpar2 \
    CONF_FILE=/etc/pazpar2/pazpar2.cfg
 
# Update and install dependencies    
RUN apk --update upgrade && \
    apk add --no-cache $REQ_RUN $REQ_BUILD && \
# Create $USER
    addgroup -Sg 1000 $USER && \
    adduser -SG $USER -u 1000 -h /src $USER && \
# Create directories
    mkdir -p $BUILD_DIR $CONF_DIR && \
# Get and extract YAZ
    cd $BUILD_DIR && \
    if test -n "$YAZ_VERSION" ; then \
    	YAZ_DL=$(echo $YAZ_DOWNLOAD_URL |sed "s/\(.*\)-\(.*\).tar.gz/\1-$YAZ_VERSION.tar.gz/g");  \
    else \
    	YAZ_DL="$YAZ_DOWNLOAD_URL"; \
    fi && \
    echo "Downloading '$YAZ_DL'" && \
    wget $YAZ_DL && \
    tar xzf $(basename $YAZ_DL) && \
# Get and extract Pazpar2
    cd $BUILD_DIR && \
    if test -n "$PAZPAR2_VERSION" ; then \
    	PAZPAR2_DL=$(echo $PAZPAR2_DOWNLOAD_URL |sed "s/\(.*\)-\(.*\).tar.gz/\1-$PAZPAR2_VERSION.tar.gz/g"); \
    else \
    	PAZPAR2_DL="$PAZPAR2_DOWNLOAD_URL"; \
    fi && \
    echo "Downloading '$PAZPAR2_DL'" && \
    wget $PAZPAR2_DL && \
    tar xzf $(basename $PAZPAR2_DL) && \
# Configure and build YAZ
    cd /tmp/build/$(basename $YAZ_DL .tar.gz) && \
    ./configure --with-iconv --with-xslt --with-xml2 --with-icu --with-gnutls --prefix=/usr/local && \
    make install && \
# Configure and build Pazpar2
    cd /tmp/build/$(basename $PAZPAR2_DL .tar.gz) && \
    ./configure && \
    make install && \
# Copy default config
    cp -r ./etc/* $CONF_DIR && \
    mv $CONF_DIR/pazpar2.cfg.dist $CONF_DIR/pazpar2.cfg && \
# Cleanup
    rm -rf $BUILD_DIR && \
    apk del $REQ_BUILD 
    
USER $USER

EXPOSE 9004

ENTRYPOINT /usr/local/sbin/pazpar2 -f $CONF_FILE