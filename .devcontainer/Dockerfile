FROM mcr.microsoft.com/devcontainers/ruby:dev-4.0-bookworm
RUN apt-get update && apt-get install -y vim curl gpg postgresql postgresql-contrib tzdata imagemagick

# The dev-4.0 tag tracks the latest Ruby 4.0.x patch, which may not match the
# exact version pinned in .ruby-version. If it doesn't, install the pinned
# version via rvm so Bundler is happy. When patch versions align, this is a
# no-op and the build stays fast.
USER vscode
COPY --chown=vscode:vscode .ruby-version /tmp/.ruby-version
RUN /bin/bash -lc '\
    pinned="$(cat /tmp/.ruby-version)"; \
    if ! ruby -v | grep -q "ruby $pinned"; then \
      rvm install "$pinned" && rvm --default use "$pinned"; \
    fi' \
    && rm /tmp/.ruby-version
USER root
