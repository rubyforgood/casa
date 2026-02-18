ARG ROOT=/usr/src/app/

# available alpine packages: https://pkgs.alpinelinux.org/packages

FROM node:24-alpine AS node-source

FROM ruby:3.3.10-alpine AS build
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

FROM ruby:3.3.10-alpine
  ARG ROOT
  WORKDIR $ROOT

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
  COPY --from=node-source /usr/local/bin/node /usr/local/bin/node
  COPY --from=node-source /usr/local/lib/node_modules /usr/local/lib/node_modules
  RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm
  RUN npm ci

  COPY --from=build /usr/local/bundle/ /usr/local/bundle/

  EXPOSE 3000

  ENTRYPOINT ["./docker-entrypoint.sh"]
  CMD ["bin/rails", "s", "-b", "0.0.0.0"]
