SHELL := /bin/bash

default: test

install:
	bundle install

test:
	rake spec

lint:
	bundle exec standardrb --fix

run:
	bundle exec rails server
