FROM hexpm/elixir:1.17.3-erlang-27.1.2-debian-buster-20240612-slim AS elixir-build

RUN apt-get update && \
  apt-get install -y git && \
  apt-get install -y postgresql-client && \
  apt-get install -y inotify-tools && \
  apt-get install -y curl && \
  apt-get install -y wget && \
  apt-get install -y gnupg2 && \
  apt-get install -y dirmngr && \
  apt-get install -y gpg && \
  apt-get install -y gawk
