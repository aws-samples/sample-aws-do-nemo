ARG BASE_IMAGE_PATH="ubuntu:22.04"

FROM $BASE_IMAGE_PATH

ARG BUILD="20250625"
ARG MAINTAINER="Alex Iankoulski <iankouls@amazon.com>"
ARG DESCRIPTION="AWS do NEMO Depend on Docker Image"
ARG http_proxy
ARG https_proxy
ARG no_proxy

LABEL MAINTAINER="$MAINTAINER"

LABEL DESCRIPTION="$DESCRIPTION"

LABEL BUILD="$BUILD"

ADD Container-Root /

RUN export http_proxy=$http_proxy; export https_proxy=$https_proxy; export no_proxy=$no_proxy; /setup.sh; rm -f /setup.sh

CMD /startup.sh

WORKDIR /aws-do-nemo

