FROM ubuntu:bionic

ARG DEBIAN_FRONTEND=noninteractive

# Update the base system
COPY ./badproxy /etc/apt/apt.conf.d/99fixbadproxy
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y --no-install-recommends --no-install-suggests \
      apt-utils \
      git \
      wget

# Clean up
RUN apt-get -y autoremove && \
    apt-get clean &
    rm -rf /var/lib/apt/lists/*

CMD ["bash"]

