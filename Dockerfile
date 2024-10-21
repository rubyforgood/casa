FROM ruby:3.2.4-alpine AS builder

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

FROM ruby:3.2.4-alpine

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

COPY . .
RUN yarn install
RUN yarn build && yarn build:css

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

EXPOSE 3000

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["bin/rails", "s", "-b", "0.0.0.0"]
