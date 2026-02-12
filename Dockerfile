ARG ROOT=/usr/src/app/

FROM ruby:3.3.8-alpine AS builder

ARG ROOT
WORKDIR $ROOT

RUN apk update && apk upgrade && apk add --update --no-cache \
  build-base \
  curl-dev \
  libffi-dev \
  yaml-dev \
  linux-headers \
  postgresql-dev \
  tzdata


COPY Gemfile* $ROOT
RUN bundle install

FROM ruby:3.3.8-alpine

ARG ROOT
WORKDIR $ROOT

RUN apk add  --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/ nodejs=24.13.0-r2 npm

# available: https://pkgs.alpinelinux.org/packages
RUN apk update && apk upgrade && apk add --update --no-cache \
  bash \
  build-base \
  curl \
  imagemagick \
  postgresql-client \
  tzdata \
  vim \
  && rm -rf /var/cache/apk/*

COPY . .
RUN npm install --global npm@latest
RUN npm install
RUN npm run build && npm run build:css

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["bin/rails", "s", "-b", "0.0.0.0"]
