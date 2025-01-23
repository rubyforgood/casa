FROM ruby:3.3.6-alpine AS builder

RUN apk update && apk upgrade && apk add --update --no-cache \
  build-base \
  curl-dev \
  postgresql-dev \
  tzdata

ARG RAILS_ROOT=/usr/src/app/
WORKDIR $RAILS_ROOT

COPY Gemfile* $RAILS_ROOT
RUN bundle install

### BUILD STEP DONE ###

FROM ruby:3.3.6-alpine

ARG RAILS_ROOT=/usr/src/app/

RUN apk update && apk upgrade && apk add --update --no-cache \
  bash \
  curl \
  imagemagick \
  postgresql-client \
  tzdata \
  vim && rm -rf /var/cache/apk/*
# The ruby alpine image's apk doesn't have the current version of node
RUN apk add  --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/ nodejs npm

WORKDIR $RAILS_ROOT

COPY . .
RUN npm install --global npm
RUN npm install
RUN npm run build && npm run build:css

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["bin/rails", "s", "-b", "0.0.0.0"]
