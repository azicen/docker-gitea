FROM --platform=$BUILDPLATFORM library/debian:12-slim AS download

ARG TARGETOS
ARG TARGETARCH
ARG GITEA_VERSION

ADD https://dl.gitea.com/gitea/$GITEA_VERSION/gitea-$GITEA_VERSION-$TARGETOS-$TARGETARCH gitea
ADD https://dl.gitea.com/gitea/$GITEA_VERSION/gitea-$GITEA_VERSION-$TARGETOS-$TARGETARCH.sha256 gitea.sha256
ADD https://dl.gitea.com/gitea/$GITEA_VERSION/gitea-src-$GITEA_VERSION.tar.gz gitea-src.tar.gz

RUN tar -zxf gitea-src.tar.gz && \
    mv gitea-src-$GITEA_VERSION gitea-src

RUN echo "$(cat gitea.sha256 | cut -d ' ' -f 1)  gitea" | sha256sum -c || (echo "SHA256 校验失败, 停止构建." && false)

# ---

FROM --platform=$BUILDPLATFORM library/golang:1.23 AS build-tool

ARG TARGETOS
ARG TARGETARCH

COPY --from=download gitea-src /gitea-src

# Begin env-to-ini build
RUN cd /gitea-src && \
	GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o ./environment-to-ini contrib/environment-to-ini/environment-to-ini.go

# ---

FROM ghcr.io/linuxserver/baseimage-debian:bookworm AS release

# dockerignore: Sensitive data is not used here
ENV APP_NAME="Gitea on debian" \
    RUN_MODE=prod \
    DOMAIN=localhost \
    SSH_DOMAIN=localhost \
    SSH_PORT=2222 \
    SSH_LISTEN_PORT= \
    DISABLE_SSH=false \
    HTTP_PORT=3000 \
    ROOT_URL="" \
    LFS_START_SERVER=false \
    DB_TYPE=sqlite3 \
    DB_HOST=localhost:3306 \
    DB_NAME=gitea \
    DB_USER=root \
    DB_PASSWD="" \
    INSTALL_LOCK=false \
    SECRET_KEY="" \
    DISABLE_REGISTRATION=false \
    REQUIRE_SIGNIN_VIEW=false \
    HOME=/config \
    WORK_PATH=/config \
    CONF_FILE=/config/conf/app.ini

ENV PYTHONUNBUFFERED=1 PIP_BREAK_SYSTEM_PACKAGES=1
RUN apt update && apt install -y --no-install-recommends \
        ca-certificates \
        iproute2 \
        iputils-ping \
        pandoc \
        git \
        git-lfs \
        python3 \
        python3-pip && \
    pip install \
        jupyter \
        nbconvert && \
    apt autoremove -y && \
    apt autoclean -y && \
    apt clean

COPY --from=download gitea /usr/bin/gitea
COPY --from=build-tool /gitea-src/environment-to-ini /usr/bin/environment-to-ini

COPY ./root /

RUN chmod 755 -R \
    /usr/bin/gitea \
    /usr/bin/environment-to-ini \
    /etc/cont-init.d/* \
    /etc/services.d/*

VOLUME /config/conf /config/custom /config/data /config/tmp

EXPOSE 2222 3000
