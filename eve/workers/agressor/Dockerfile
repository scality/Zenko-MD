FROM node:6-slim
MAINTAINER Giorgio Regni <gr@scality.com>

ENV TERM xterm
WORKDIR /usr/src/app

ADD https://bootstrap.pypa.io/get-pip.py get-pip.py
# get-pip.py 24-Apr-2018 13:15
RUN echo '35ac67d8b15c308b22e3234c8a6f44a652f2d869 get-pip.py' | sha1sum -c
RUN apt-get update \
    && apt-get install -y jq python python-dev git build-essential \
               --no-install-recommends \
    && python get-pip.py \
    && pip install buildbot-worker

