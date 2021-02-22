FROM golang:1.16-buster AS build
WORKDIR /stolon
COPY . /stolon
RUN make

FROM postgres:10.16
RUN apt-get update && \
  apt install -y cron python3-pip lzop pv daemontools git make unzip gcc libssl-dev zlib1g-dev postgresql-server-dev-$PG_MAJOR wget openssh-server && \
  pip3 install azure==2.0.0 git+https://github.com/nkiraly/wal-e.git@update-azure-storage-api && \
  wget -q -O pg_repack.zip "https://api.pgxn.org/dist/pg_repack/1.4.6/pg_repack-1.4.6.zip" && \
  unzip pg_repack.zip && \
  cd pg_repack-* && \
  make && \
  make install && \
  cd .. && \
  apt-get remove --auto-remove -y make unzip gcc libssl-dev zlib1g-dev && \
  rm -rf /var/lib/apt/lists/* pg_repack*
RUN useradd -ms /bin/bash stolon
COPY --from=build /stolon/bin/ /usr/local/bin/
