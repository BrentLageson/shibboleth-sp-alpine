#########################################

#########################################
FROM alpine:latest

ENV LANG="C.UTF-8" \
    TZ="Europe/Paris" \
    LD_LIBRARY_PATH="/etc/shibboleth/lib" \
    OPENSSL_INCLUDE_DIR="/usr/include/openssl" \
    OPENSSL_SSL_LIBRARY="/usr/lib/libssl.so" \
    OPENSSL_CRYPTO_LIBRARY="/usr/lib/libcrypto.so" \
    LDFLAGS="-L/etc/shibboleth/lib" \
    LOG4SHIB="1.0.9" \
    XERCES_BASE="3" \
    XERCES="3.2.1" \
    XMLSECURITY="1.7.3" \
    SHIBB_SP="2.6.1" \
    OPENSAML="2.6.1" \
    XMLTOOL="1.6.4"



COPY xml-security-c/*.patch /tmp/
COPY httpd-shibd-foreground /tmp/
COPY shibboleth/* /tmp/
COPY /httpd/* /tmp/

RUN set -ex && \
    apk add --update --no-cache bash apache2 apache2-ssl libstdc++ curl su-exec && \
    mkdir -p /etc/shibboleth/metadata /etc/shibboleth/etc/shibboleth/ /etc/apache2/conf.d /run/apache2  /etc/shibboleth/lib /var/www/html /tmp/log4shib /tmp/xerces /tmp/xml-security-c  /tmp/xmltooling /tmp/opensaml && \
    mv /tmp/httpd-shibd-foreground /usr/local/bin && \
    mv /tmp/*.logger /etc/shibboleth/etc/shibboleth && \
    mv /tmp/httpd.conf /etc/apache2 && \
    mv /tmp/ssl.conf /etc/apache2/conf.d && \
    mv /tmp/shibd.sh /etc/shibboleth && \
    mv /tmp/functions /etc/init.d && \
    chmod +x /usr/local/bin/httpd-shibd-foreground /etc/init.d/* && \
    apk add --no-cache --virtual .native-build-deps \
             unzip file \
             apr-dev \
             apr-util-dev \
             alpine-sdk \
             autoconf \
             m4 \
             perl \
             zlib-dev \
             automake \
             apache2-dev \
             coreutils \
             dpkg-dev dpkg \
             g++ \
             gcc \
             curl \
             curl-dev \
             libc-dev \
             make \
             boost-dev && \
    curl -sSL --fail https://shibboleth.net/downloads/log4shib/${LOG4SHIB}/log4shib-${LOG4SHIB}.tar.gz -o /tmp/log4shib.tar.gz && \
    curl -sSL --fail http://apache.rediris.es//xerces/c/${XERCES_BASE}/sources/xerces-c-${XERCES}.tar.gz -o /tmp/xerces.tar.gz && \
    curl -sSL --fail http://apache.rediris.es/santuario/c-library/xml-security-c-${XMLSECURITY}.tar.gz -o /tmp/xml-security-c.tar.gz && \
    curl -sSL --fail http://shibboleth.net/downloads/service-provider/${SHIBB_SP}/shibboleth-sp-${SHIBB_SP}.zip -o /tmp/shibsp.zip && \
    curl -sSL --fail http://shibboleth.net/downloads/c++-opensaml/${OPENSAML}/opensaml-${OPENSAML}.tar.gz -o /tmp/opensaml.tar.gz && \
    curl -sSL --fail http://shibboleth.net/downloads/c++-opensaml/${OPENSAML}/xmltooling-${XMLTOOL}.tar.gz -o /tmp/xmltooling.tar.gz && \
    tar -xf /tmp/log4shib*.tar.gz --strip-components=1 -C /tmp/log4shib && \
    tar -xf /tmp/xerces*.tar.gz --strip-components=1 -C /tmp/xerces && \
    tar -xf /tmp/xml-security-c*.tar.gz --strip-components=1 -C /tmp/xml-security-c && \
    tar -xf /tmp/xmltooling*.tar.gz --strip-components=1 -C /tmp/xmltooling && \
    tar -xf /tmp/opensaml*.tar.gz --strip-components=1 -C /tmp/opensaml && \
    unzip /tmp/shib*.zip -d /tmp && \
    echo "building log4shib..." && \
    cd /tmp/log4shib  && \
    ./configure -q \
        --disable-static \
        --disable-doxygen \
        --prefix=/etc/shibboleth \
        CXXFLAGS="-std=c++11" && \
    make -s && make install -s && \
    echo "building xerces ..." && \
    cd /tmp/xerces && \
    ./configure \
        -q \
        --prefix=/etc/shibboleth && \
    make -s && make install -s && \
    cd /tmp/xml-security-c && \
    echo "patching xsecurity known bugs..." && \
    patch -p1 < /tmp/xml-security-c-cxx11.patch && \
    echo "building xsecurity ..." && \
    ./configure \
        -q \
        --without-xalan \
        --disable-static \
        --prefix=/etc/shibboleth \
        --with-xerces=/etc/shibboleth \
        --with-openssl=/usr/include/openssl  && \
    make -s && make install -s  && \
    echo "building xmltooling..." && \
    cd /tmp/xmltooling && \
    ./configure  -q \
        --with-log4shib=/etc/shibboleth \
        --with-xerces=/etc/shibboleth \
        --with-openssl=/usr/include/openssl \
        --prefix=/etc/shibboleth && \
    make -s && make install -s && \
    echo "building opensaml..." && \
    cd /tmp/opensaml && \
    ./configure \
        -q \
        --with-log4shib=/etc/shibboleth \
        --with-apxs=/usr/bin/apxs \
        --prefix=/etc/shibboleth -C   && \
    make  -s && make install -s && \
    cd /tmp/shibboleth-sp-${SHIBB_SP} && \
         ./configure \
                -q \
                --with-log4shib=/etc/shibboleth \
                --prefix=/etc/shibboleth \
                --exec-prefix=/etc/shibboleth \
                -C && \
    make -s &&  make install -s && \
    echo "cleanup..." && \
    rm -fR /tmp/* /var/cache/apk/* && \
    apk del .native-build-deps


EXPOSE 80 443

CMD ["httpd-shibd-foreground"]

