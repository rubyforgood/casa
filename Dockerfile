FROM ruby:3.1.3-alpine AS builder

LABEL maintainer="jeanine@littleforestconsulting.com"

RUN apk update && apk upgrade && apk add --update --no-cache \
  build-base \
  curl-dev \
  nodejs \
  postgresql-dev \
  tzdata \
  vim \
  yarn && rm -rf /var/cache/apk/*

ARG RAILS_ROOT=/usr/src/app/
WORKDIR $RAILS_ROOT

COPY package*.json yarn.lock $RAILS_ROOT
RUN yarn install --check-files

COPY Gemfile* $RAILS_ROOT
RUN bundle install

COPY . .
RUN yarn build && yarn build:css

### BUILD STEP DONE ###

FROM ruby:3.1.3-alpine

ARG RAILS_ROOT=/usr/src/app/

RUN apk update && apk upgrade && apk add --update --no-cache \
  bash \
  imagemagick \
  nodejs \
  postgresql-client \
  tzdata \
  vim \
  yarn && rm -rf /var/cache/apk/*

WORKDIR $RAILS_ROOT

COPY --from=builder $RAILS_ROOT $RAILS_ROOT
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["bin/rails", "s", "-b", "0.0.0.0"]
