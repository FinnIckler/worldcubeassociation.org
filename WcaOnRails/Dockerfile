# base (contains everything for a dev setup)
FROM ruby:3.2.1 as base
EXPOSE 3000

ENV DEBIAN_FRONTEND noninteractive
ENV REPO_ROOT /app
WORKDIR $REPO_ROOT

RUN apt-get update && apt-get install -y curl gnupg

# Add PPA needed to install nodejs.
# From: https://github.com/nodesource/distributions
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -

# Add PPA needed to install yarn.
# From: https://yarnpkg.com/en/docs/install#debian-stable
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y \
  git \
  yarn \
  build-essential \
  nodejs \
  mariadb-client \
  libssl-dev \
  libghc-zlib-dev \
  libyaml-dev \
  imagemagick \
  poppler-utils \
  fonts-thai-tlwg \
  tzdata

RUN gem update --system && gem install bundler


# live server (staging or prod)
FROM base AS live

# Cronjobs
COPY ./init/cronjobs.sh /init/cronjobs.sh
RUN chmod +x /init/cronjobs.sh
RUN /init/cronjobs.sh

# Email daemon
RUN apt-get install -y exim4-daemon-light
ENV FQDN *.worldcubeassociation.org
COPY ./init/email.sh /init/email.sh
RUN chmod +x /init/email.sh
RUN /init/email.sh

# Regulations compiler
RUN apt-get install -y python3-pip fonts-unfonts-core fonts-wqy-microhei \
    fonts-ipafont lmodern libxrender1 wget xz-utils

RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz -O wkhtml.tar.xz && \
    tar -xf wkhtml.tar.xz --strip-components=1 -C /usr/local && \
    rm wkhtml.tar.xz

RUN pip3 install wrc

# jobs

RUN ./bin/delayed_job start

# staging
FROM live as staging

# mailcatcher
RUN gem install mailcatcher
RUN mailcatcher --no-quit --http-ip=0.0.0.0

# prod (currently empty, but adds prod as a target in docker-compose)
FROM live as prod
